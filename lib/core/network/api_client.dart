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
    final isAuthCall = err.requestOptions.path.contains('/auth/');
    if (err.response?.statusCode != 401 ||
        isAuthCall ||
        _tokens.refreshToken == null) {
      return handler.next(err);
    }

    // Refresh once (shared across concurrent 401s), then replay the request.
    final ok = await (_refreshing ??= _refresh());
    _refreshing = null;
    if (!ok) {
      onSessionExpired?.call();
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
      final data = res.data!;
      await _tokens.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await _tokens.clear();
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
