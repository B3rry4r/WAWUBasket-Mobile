import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_store.dart';

/// Thin typed wrapper over the WAWUBasket `/v1/auth/*` endpoints.
///
/// Every call that returns a JWT pair persists it to [TokenStore] before
/// returning, so callers just `await` and then route on success.
class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  final _api = ApiClient.instance;
  final _tokens = TokenStore.instance;

  /// Dedicated client for the WAWU ID identity service. Auth (login, OTP,
  /// sign-up, password recovery) lives there now; role/session endpoints
  /// stay on the Basket API via [_api].
  final Dio _wawuId = Dio(BaseOptions(
    baseUrl: wawuIdBaseUrl,
    connectTimeout: apiTimeout,
    receiveTimeout: apiTimeout,
    sendTimeout: apiTimeout,
    contentType: 'application/json',
  ));

  Future<dynamic> _idPost(String path, {Object? body}) async {
    try {
      final res = await _wawuId.post<dynamic>(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Records the user's consent to the current privacy-policy version on WAWU ID
  /// (the consent ledger shared across the whole ecosystem). The WAWU ID access
  /// token is read straight from the register response so this works even when
  /// the persisted session token is later exchanged for a Basket token.
  /// Best-effort: a consent-logging failure must never break sign-up.
  Future<void> _recordPrivacyConsent(dynamic res) async {
    try {
      final data = res is Map ? res['data'] : null;
      final token = (data is Map ? data['accessToken'] : null) as String?;
      if (token == null || token.isEmpty) return;
      await _wawuId.post<dynamic>(
        '/policies/privacy/accept',
        data: {'source': 'wawubasket'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {
      // Non-fatal — the app can re-capture consent later via /policies/.../status.
    }
  }

  // ─── Sign-up (name + phone + email + password, verified by OTP) ─────────

  /// Registers the user on WAWU ID and starts their session.
  ///
  /// WAWU ID's `/auth/register` requires `country` and a `password` (min 8),
  /// creates the account, and returns a token pair immediately — there is no
  /// separate phone-OTP step for password sign-up, so we persist the tokens
  /// here and the caller can route straight into the app.
  Future<void> signup({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String country,
  }) async {
    final res = await _idPost('/auth/register', body: {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'country': country,
    });
    await _persistWawuThenExchange(res);
    // The sign-up screen gates on accepting the terms, so log that consent
    // against the new WAWU ID account for the ecosystem-wide ledger.
    await _recordPrivacyConsent(res);
  }

  /// Confirms a phone OTP, creating the account and starting a session.
  /// Retained for the optional phone-verification flow.
  Future<void> verifySignup(String phone, String code) async {
    final res = await _idPost('/auth/otp/verify',
        body: {'phone': phone, 'code': code});
    await _persistWawuThenExchange(res);
  }

  // ─── Login (with organic WAWU ID migration) ──────────────────────────────

  /// Password sign-in with a phone number or email.
  ///
  /// Accounts created before the WAWU ID cutover only exist on the legacy
  /// Basket backend. We migrate them transparently on their first sign-in:
  ///
  ///   1. Try WAWU ID first. If it knows the user, we're done.
  ///   2. If — and ONLY if — WAWU ID reports the user doesn't exist there yet
  ///      (404 / `USER_NOT_IN_WAWUID`), verify the credentials against the old
  ///      Basket `/auth/login`. Any *other* WAWU ID error (wrong password,
  ///      locked account, network/server) is a real failure and is surfaced.
  ///   3. Once Basket confirms the password, best-effort mirror the account
  ///      into WAWU ID using the user's real profile, so the next login goes
  ///      through the identity service. If that mirror can't complete, the
  ///      user still gets in on the Basket session and migration retries later.
  Future<void> login(String identifier, String password) async {
    try {
      final res = await _idPost('/auth/login',
          body: {'identifier': identifier, 'password': password});
      await _persistWawuThenExchange(res);
      return;
    } on ApiException catch (e) {
      final notMigrated =
          e.statusCode == 404 || e.message.contains('USER_NOT_IN_WAWUID');
      // Real error (incorrect password, etc.) — surface it untouched.
      if (!notMigrated) rethrow;
    }

    // ── Organic migration: this user predates WAWU ID. ─────────────────────
    // Verify on the legacy Basket backend. A failure here (e.g. wrong
    // password) throws an ApiException that bubbles up to the UI unchanged.
    final basketRes = await _api.post('/auth/login',
        body: {'identifier': identifier, 'password': password});
    // Persist the Basket tokens immediately so the session is live regardless
    // of whether the WAWU ID mirror below succeeds.
    await _persist(basketRes);

    // Best-effort mirror into WAWU ID. The Basket login response carries only
    // tokens, so fetch the real profile (now that we hold a session) to
    // register with good data rather than guesses.
    try {
      final profile = await _fetchProfile();
      final fullName = _nonEmpty(profile?['fullName'] as String?) ?? 'WAWUBasket User';
      final phone = _nonEmpty(profile?['phone'] as String?) ??
          (_looksLikePhone(identifier) ? identifier : '');
      final email = _nonEmpty(profile?['email'] as String?) ??
          (identifier.contains('@') ? identifier : '');

      await _idPost('/auth/register', body: {
        'identifier': identifier,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'password': password,
        'country': 'Nigeria',
      });
      // The account is now mirrored into WAWU ID for next time. Keep the Basket
      // session we already hold — do NOT switch to the WAWU ID tokens (the
      // Basket API can't authenticate them). Next login takes the primary path.
    } catch (_) {
      // Mirror failed or needs OTP verification — the working Basket session
      // stays; migration retries on the next login.
    }
  }

  /// Fetches the signed-in user's `/profile` record, or null on any failure.
  /// Used by the migration path to register WAWU ID with real profile data.
  Future<Map<String, dynamic>?> _fetchProfile() async {
    try {
      final res = await _api.get('/profile');
      return res is Map<String, dynamic> ? res : null;
    } catch (_) {
      return null;
    }
  }

  /// Mirrors the Basket backend's phone-vs-email heuristic.
  bool _looksLikePhone(String identifier) =>
      identifier.startsWith('+') ||
      (identifier.isNotEmpty && RegExp(r'^\d').hasMatch(identifier));

  String? _nonEmpty(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

  // ─── OTP-only sign-in (no password) ──────────────────────────────────────

  Future<void> startOtp(String phone) =>
      _idPost('/auth/otp/start', body: {'phone': phone});

  Future<void> verifyOtp(String phone, String code) async {
    final res = await _idPost('/auth/otp/verify',
        body: {'phone': phone, 'code': code});
    await _persistWawuThenExchange(res);
  }

  // ─── Password recovery ──────────────────────────────────────────────────

  Future<void> forgotPassword(String identifier, {String method = 'sms'}) =>
      _idPost('/auth/forgot-password',
          body: {'identifier': identifier, 'method': method});

  Future<void> resetPassword(
      String identifier, String code, String newPassword) async {
    final res = await _idPost('/auth/reset-password', body: {
      'identifier': identifier,
      'code': code,
      'newPassword': newPassword,
    });
    await _persistWawuThenExchange(res);
  }

  Future<void> changePassword(
          String currentPassword, String newPassword) =>
      _api.post('/auth/password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  // ─── Roles + session ────────────────────────────────────────────────────

  /// All roles the user holds, with each role's KYC status.
  Future<List<dynamic>> getRoles() async {
    final res = await _api.get('/auth/roles');
    return (res as List<dynamic>?) ?? const [];
  }

  /// Switches the active role for the session — returns a fresh token pair
  /// carrying the new `activeRole` claim.
  Future<void> switchRole(String role) async {
    final res = await _api.post('/auth/role/switch', body: {'role': role});
    await _persist(res);
  }

  /// Server-side sign-out, then drop the local session.
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Even if the network call fails, clear the device session below.
    }
    await _tokens.clear();
  }

  Future<void> _persist(dynamic res) async {
    // WAWU ID wraps the session as { data: { accessToken, refreshToken, ... } },
    // while the legacy Basket API returns the tokens at the top level. Accept
    // either shape rather than blindly casting (a missing key would otherwise
    // throw an opaque CastError that surfaces as "Something went wrong").
    final body = res is Map<String, dynamic> ? res : const <String, dynamic>{};
    final payload = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
    final access = payload['accessToken'];
    final refresh = payload['refreshToken'];
    if (access is! String || access.isEmpty || refresh is! String || refresh.isEmpty) {
      throw ApiException(
        'Signed in, but no session was returned. Please try again.',
      );
    }
    await _tokens.save(accessToken: access, refreshToken: refresh);
  }

  /// Persist a WAWU ID session, then immediately exchange it for a Basket
  /// session. WAWU ID tokens authenticate the identity, but the Basket API's
  /// protected routes (and token refresh) need a Basket token carrying the
  /// local user id + active role — so this is the session we actually run on.
  Future<void> _persistWawuThenExchange(dynamic res) async {
    await _persist(res); // WAWU ID tokens (used only for the exchange call)
    await _exchangeForBasketSession();
  }

  /// POST /v1/auth/exchange with the just-persisted WAWU ID bearer token; the
  /// Basket API resolves/links the local account and returns a Basket token
  /// pair, which replaces the WAWU ID tokens as the live session.
  Future<void> _exchangeForBasketSession() async {
    final res = await _api.post('/auth/exchange');
    await _persist(res);
  }
}
