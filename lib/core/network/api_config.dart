/// Resolves the WAWUBasket API base URL.
///
/// Resolution order:
///   1. `--dart-define=API_BASE_URL=https://...` (CI / release builds).
///   2. The local fallback below — the Railway staging URL, or
///      `http://10.0.2.2:3000` for an Android emulator hitting a local
///      API (`10.0.2.2` is the host loopback from inside the emulator).
///
/// All endpoints are versioned under `/v1`; [apiBaseUrl] already includes
/// it so callers pass bare paths like `/auth/login`.
library;

const String _envBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: '');

/// Local fallback — replace with the Railway URL once it is live.
const String _localFallback = 'http://10.0.2.2:3000';

/// The effective API origin, no trailing slash, no `/v1`.
String get apiOrigin =>
    (_envBaseUrl.isNotEmpty ? _envBaseUrl : _localFallback)
        .replaceAll(RegExp(r'/+$'), '');

/// The versioned base URL every request is built against.
String get apiBaseUrl => '$apiOrigin/v1';

/// Per-request timeout.
const Duration apiTimeout = Duration(seconds: 20);
