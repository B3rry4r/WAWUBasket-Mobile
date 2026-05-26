import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage for the JWT access + refresh tokens.
///
/// The access token is short-lived (15 min) and attached to every request;
/// the refresh token (30 days) is exchanged for a new pair when the access
/// token expires. Both are held in the platform keystore/keychain, never
/// in plain SharedPreferences.
class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  static const _kAccess = 'wb.token.access';
  static const _kRefresh = 'wb.token.refresh';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// In-memory cache so the interceptor doesn't hit the keystore on every
  /// request. Populated by [load] at boot and kept in sync on [save].
  String? _access;
  String? _refresh;

  /// Reactive view of [accessToken]. Auxiliary services (WebSocket,
  /// background sync) listen here to wire themselves up on login and tear
  /// down on logout without touching the auth screens.
  final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  bool get hasSession => _access != null && _access!.isNotEmpty;

  /// Reads persisted tokens into memory. Call once on app boot.
  Future<void> load() async {
    _access = await _storage.read(key: _kAccess);
    _refresh = await _storage.read(key: _kRefresh);
    tokenNotifier.value = _access;
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
    tokenNotifier.value = accessToken;
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    tokenNotifier.value = null;
  }
}
