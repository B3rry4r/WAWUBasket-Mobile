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

  /// Registers the user and triggers an OTP to their phone. The account is
  /// only created once [verifySignup] succeeds.
  Future<void> signup({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _idPost('/auth/register', body: {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
    });
  }

  /// Confirms the sign-up OTP, creating the account and starting a session.
  Future<void> verifySignup(String phone, String code) async {
    final res = await _idPost('/auth/otp/verify',
        body: {'phone': phone, 'code': code});
    await _persist(res);
  }

  // ─── Login ───────────────────────────────────────────────────────────────

  /// Password sign-in with a phone number or email.
  Future<void> login(String identifier, String password) async {
    final res = await _idPost('/auth/login',
        body: {'identifier': identifier, 'password': password});
    await _persist(res);
  }

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
