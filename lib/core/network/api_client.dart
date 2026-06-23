import 'dart:async';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// The single HTTP gateway to the WAWUBasket API.
///
/// Wraps Dio with:
///  - the API base URL + timeouts,
///  - an interceptor that attaches the Bearer access token,
///  - transparent 401 handling — one refresh-and-retry, and if the
///    refresh itself fails, [onSessionExpired] fires so the app can
///    bounce the user to sign-in.
///
/// Every method returns decoded JSON and throws [ApiException] on failure.
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: apiTimeout,
      receiveTimeout: apiTimeout,
      sendTimeout: apiTimeout,
      contentType: 'application/json',
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  final _tokens = TokenStore.instance;

  /// Fired when the refresh token is rejected — the app wires this to a
  /// navigation back to the welcome/login screen.
  void Function()? onSessionExpired;

  /// Guards against a stampede of concurrent refreshes.
  Future<bool>? _refreshing;

  /// How long after a session is (re)minted we treat a 401 as transient rather
  /// than a real expiry. Right after sign-in, several authed calls fire almost
  /// at once (role sync, push-token registration, the first home fetch). If any
  /// races the freshly minted token and 401s, bouncing the user to /login would
  /// undo the login they just completed. Within this window we refresh-and-retry
  /// as usual but never trigger [onSessionExpired].
  static const Duration _freshSessionGrace = Duration(seconds: 8);

  /// Auth endpoints that must never trigger a refresh-and-retry: the
  /// unauthenticated surfaces (login/signup/OTP/password-reset — a 401 is a
  /// real credential error), the refresh endpoint itself (retrying recurses),
  /// and exchange (a one-shot during login carrying the WAWU ID token, not the
  /// Basket session). Every OTHER authenticated /auth/* call refreshes normally.
  static bool _isNoRefreshPath(String path) {
    const noRefresh = <String>[
      '/auth/login',
      '/auth/signup',
      '/auth/refresh',
      '/auth/exchange',
      '/auth/phone/start',
      '/auth/phone/verify',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];
    return noRefresh.any(path.contains);
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only the UNAUTHENTICATED auth surfaces are exempt from refresh-and-retry:
    // a 401 there is a real credential error (or, for /auth/refresh, would
    // recurse). Authenticated /auth/* endpoints — role switch, roles, logout,
    // password — MUST refresh-and-retry like any other call. Treating every
    // path containing "/auth/" as exempt was the bug behind "switch roles →
    // unauthorized": once the 15-minute access token lapsed, /auth/role/switch
    // 401'd and was never refreshed.
    final noRefresh = _isNoRefreshPath(err.requestOptions.path);
    if (err.response?.statusCode != 401 ||
        noRefresh ||
        _tokens.refreshToken == null) {
      return handler.next(err);
    }

    // Capture session freshness BEFORE attempting the refresh: a failed
    // refresh clears the token (and its timestamp), so this must be read first.
    // A 401 in the post-login window is a race against the just-minted token,
    // not a genuine expiry — without this guard a best-effort post-login call
    // (e.g. push-token registration) could yank the user straight back to
    // /login, which is the "logged in, then bounced to login" bug.
    final savedAt = _tokens.savedAt;
    final isFreshSession = savedAt != null &&
        DateTime.now().difference(savedAt) < _freshSessionGrace;

    // Refresh once (shared across concurrent 401s), then replay the request.
    final ok = await (_refreshing ??= _refresh());
    _refreshing = null;
    if (!ok) {
      // Only bounce to login when the session was genuinely invalidated — i.e.
      // _refresh cleared the tokens after a definitive rejection (401/403). A
      // transient network/timeout/5xx during refresh leaves the tokens intact;
      // we surface the original error but keep the user signed in, so a blip
      // doesn't log them out and drop them to guest on the next launch.
      final sessionLost = !_tokens.hasSession;
      if (sessionLost && !isFreshSession) {
        onSessionExpired?.call();
      }
      return handler.next(err);
    }
    try {
      final retried = await _dio.fetch<dynamic>(
        err.requestOptions
          ..headers['Authorization'] = 'Bearer ${_tokens.accessToken}',
      );
      return handler.resolve(retried);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Exchanges the refresh token for a fresh pair. Uses a bare Dio so it
  /// never recurses through this interceptor.
  Future<bool> _refresh() async {
    try {
      final bare = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final res = await bare.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': _tokens.refreshToken},
      );
      // Accept both the top-level shape and a { data: {...} } envelope so a
      // future response-shape change can't silently fail to parse and wipe the
      // session.
      final body = res.data!;
      final payload = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      final access = payload['accessToken'];
      final refresh = payload['refreshToken'];
      if (access is! String || access.isEmpty || refresh is! String || refresh.isEmpty) {
        // Malformed success response — don't tear down a possibly-valid session.
        return false;
      }
      await _tokens.save(accessToken: access, refreshToken: refresh);
      return true;
    } on DioException catch (e) {
      // ONLY a definitive rejection (the server says the refresh token itself
      // is invalid) should clear the session. A network error, timeout, or 5xx
      // is transient — keep the tokens so the next request or app launch can
      // recover instead of logging the user out and dropping them to guest.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokens.clear();
      }
      return false;
    } catch (_) {
      // Unexpected (non-HTTP) error — keep the session; treat as transient.
      return false;
    }
  }

  // ─── Verbs ─────────────────────────────────────────────────────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post<dynamic>(path, data: body));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  Future<dynamic> delete(String path, {Object? body}) =>
      _send(() => _dio.delete<dynamic>(path, data: body));

  Future<dynamic> _send(Future<Response<dynamic>> Function() run) async {
    try {
      final res = await run();
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
