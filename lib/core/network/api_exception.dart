import 'package:dio/dio.dart';

/// A normalised API failure the UI can show without knowing about Dio.
///
/// Every [ApiClient] call throws this on failure, so screens can simply
/// `catch (ApiException e)` and surface `e.message`.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isNetwork = false});

  final String message;
  final int? statusCode;

  /// True when the request never reached the server (offline, timeout,
  /// DNS) — the UI can offer a "retry" instead of a hard error.
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Builds an [ApiException] from a Dio failure, pulling the API's
  /// `{ message }` body when present.
  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('The request timed out. Try again.',
            isNetwork: true);
      case DioExceptionType.connectionError:
        return ApiException("Can't reach WAWUBasket. Check your connection.",
            isNetwork: true);
      default:
        final status = e.response?.statusCode;
        return ApiException(
          _extractMessage(e.response?.data) ?? _fallbackForStatus(status),
          statusCode: status,
        );
    }
  }

  static String _fallbackForStatus(int? status) => switch (status) {
        401 => 'Incorrect code or password. Please try again.',
        403 => "You don't have permission to do that.",
        404 => 'Not found.',
        409 => 'This already exists.',
        422 => 'Invalid input. Please check your details.',
        500 || 502 || 503 => 'Server error. Please try again later.',
        _ => 'Something went wrong. Please try again.',
      };

  /// The API's error body is `{ statusCode, message, ... }`, where
  /// `message` is a string or (from class-validator) a list of strings.
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final m = data['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
