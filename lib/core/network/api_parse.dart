/// Crash-safe parsing of dynamic API payloads.
///
/// The API client returns decoded JSON as `dynamic`. Casting it directly
/// (`res as Map<String, dynamic>`, `list.first`, `x as String`) throws at
/// runtime the moment the server returns null, a different type, an error
/// body, or an empty list — turning a recoverable API hiccup into a crash.
///
/// These helpers degrade safely instead: they coerce when they reasonably
/// can, log a diagnostic when the shape is unexpected, and return a benign
/// fallback. Money is the deliberate exception — see [safeMoney].
library;

import 'package:flutter/foundation.dart';

import 'api_exception.dart';

void _warn(String message) {
  // debugPrint is a no-op in release builds, so this is safe to leave in.
  if (kDebugMode) debugPrint('[api_parse] $message');
}

/// Coerces a value to `Map<String, dynamic>`. Returns an empty map (with a
/// log) when the value isn't a map, so callers can keep reading keys via the
/// safe accessors below without a null/type crash.
Map<String, dynamic> safeMap(dynamic v, {String context = 'object'}) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.cast<String, dynamic>();
  if (v != null) _warn('Expected a JSON object for "$context", got ${v.runtimeType}');
  return <String, dynamic>{};
}

/// Coerces a value to `List<dynamic>`. Returns an empty list (with a log) for
/// anything that isn't a list.
List<dynamic> safeList(dynamic v, {String context = 'list'}) {
  if (v is List) return v;
  if (v != null) _warn('Expected a JSON array for "$context", got ${v.runtimeType}');
  return const [];
}

/// Coerces a value to a list of string-keyed maps, dropping any non-map
/// entries. Ideal for `(json['items'] as List).map((e) => Model.fromJson(e))`.
List<Map<String, dynamic>> safeMapList(dynamic v, {String context = 'list'}) =>
    safeList(v, context: context)
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);

/// First element of a list, or null when empty/not-a-list — never throws.
T? safeFirst<T>(dynamic v) {
  final list = v is List ? v : const [];
  return list.isEmpty ? null : list.first as T?;
}

String safeString(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

/// Nullable string: returns null for null/empty rather than a placeholder.
String? safeStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v is String ? v : v.toString();
  return s.isEmpty ? null : s;
}

int safeInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? fallback;
  return fallback;
}

double safeDouble(dynamic v, {double fallback = 0}) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim()) ?? fallback;
  return fallback;
}

bool safeBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return fallback;
}

DateTime? safeDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

/// Strict money parser. Money arrives from the API as an integer minor-unit
/// value, usually a BigInt serialised to a string (see API `main.ts`).
///
/// Financial correctness beats hiding errors: a malformed value must NOT
/// silently become 0 and show a wrong total. By default this throws an
/// [ApiException] (which screens already catch and surface) and logs the
/// anomaly. Pass [orZero] only where a missing value legitimately means 0
/// (e.g. an optional, not-yet-applied fee).
int safeMoney(dynamic v, {String field = 'amount', bool orZero = false}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final parsed = int.tryParse(v.trim());
    if (parsed != null) return parsed;
  }
  if (v == null && orZero) return 0;
  _warn('Malformed money for "$field": ${v.runtimeType} ($v)');
  if (orZero) return 0;
  throw ApiException('The server returned an invalid "$field" value.');
}
