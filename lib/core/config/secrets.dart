/// Mapbox access token resolution.
///
/// Resolution order:
///   1. `--dart-define=MAPBOX_TOKEN=pk...` (used by CI — value comes from
///      the `MAPBOX_TOKEN` GitHub Actions secret).
///   2. The local fallback constant below.
///
/// The committed copy of this file keeps the fallback EMPTY so a token
/// never lands in git history (GitHub push-protection blocks it anyway).
/// For local development, paste your public token into [_localFallback]
/// — the file is marked `skip-worktree` so that local edit is never
/// staged or committed. To re-enable tracking:
///   git update-index --no-skip-worktree lib/core/config/secrets.dart
library;

const String _envToken =
    String.fromEnvironment('MAPBOX_TOKEN', defaultValue: '');

/// Local-only fallback. Keep this EMPTY in any commit.
const String _localFallback = '';

/// The effective public token — env-define wins, local fallback second.
const String kMapboxPublicToken =
    _envToken.isNotEmpty ? _envToken : _localFallback;

/// True when a usable token is configured. Screens use this to decide
/// whether to render the Mapbox widget or the placeholder.
bool get kMapboxConfigured =>
    kMapboxPublicToken.isNotEmpty && kMapboxPublicToken.startsWith('pk.');
