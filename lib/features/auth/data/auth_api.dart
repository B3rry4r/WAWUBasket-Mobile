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
    await _persist(res);
  }

  /// Confirms a phone OTP, creating the account and starting a session.
  /// Retained for the optional phone-verification flow.
  Future<void> verifySignup(String phone, String code) async {
    final res = await _idPost('/auth/otp/verify',
        body: {'phone': phone, 'code': code});
    await _persist(res);
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
      await _persist(res);
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

      final registerRes = await _idPost('/auth/register', body: {
        'identifier': identifier,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'password': password,
        'country': 'Nigeria',
      });
      // If WAWU ID returns a token pair (pre-verified migration), switch the
      // session to it. If it instead kicks off an OTP and returns no tokens,
      // [_persist] throws and the catch below keeps the working Basket session.
      await _persist(registerRes);
    } catch (_) {
      // Mirror failed or needs OTP verification — keep the legacy Basket
      // session. The user is signed in; migration retries on the next login.
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
    await _persist(res);
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
    await _persist(res);
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
    final map = res as Map<String, dynamic>;
    await _tokens.save(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
    );
  }
}
