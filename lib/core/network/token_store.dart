import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage for the JWT access + refresh tokens.
///
/// On web, flutter_secure_storage can throw platform-channel errors (the
/// underlying JS interop uses constructs that fail with primitives as Expando
/// keys). To keep auth working on web, storage operations are always wrapped
/// in try/catch: the in-memory tokens are updated regardless, and any
/// persistence failure is logged but does NOT propagate to callers.
class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  static const _kAccess = 'wb.token.access';
  static const _kRefresh = 'wb.token.refresh';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _access;
  String? _refresh;

  /// Reactive view of [accessToken]. Auxiliary services (WebSocket,
  /// background sync) listen here to wire themselves up on login and tear
  /// down on logout without touching the auth screens.
  final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  bool get hasSession => _access != null && _access!.isNotEmpty;

  /// When the live session token was last (re)written. Used by [ApiClient] to
  /// suppress a spurious "session expired" bounce in the brief window right
  /// after sign-in, when the post-login burst of authed calls (role sync, push
  /// token registration, the first home fetch) races the freshly minted token.
  /// A transient 401 in that window must NOT tear down a session the user just
  /// established — that is the "logged in, then bounced back to login" bug.
  DateTime? _savedAt;
  DateTime? get savedAt => _savedAt;

  Future<void> load() async {
    try {
      _access = await _storage.read(key: _kAccess);
      _refresh = await _storage.read(key: _kRefresh);
    } catch (e) {
      debugPrint('[TokenStore] load failed (web degraded to in-memory): $e');
    }
    tokenNotifier.value = _access;
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Update in-memory first — navigation must not be blocked by storage.
    _access = accessToken;
    _refresh = refreshToken;
    _savedAt = DateTime.now();
    tokenNotifier.value = accessToken;
    try {
      await _storage.write(key: _kAccess, value: accessToken);
      await _storage.write(key: _kRefresh, value: refreshToken);
    } catch (e) {
      debugPrint('[TokenStore] save failed (tokens kept in-memory only): $e');
    }
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _savedAt = null;
    tokenNotifier.value = null;
    try {
      await _storage.delete(key: _kAccess);
      await _storage.delete(key: _kRefresh);
    } catch (e) {
      debugPrint('[TokenStore] clear failed: $e');
    }
  }
}
