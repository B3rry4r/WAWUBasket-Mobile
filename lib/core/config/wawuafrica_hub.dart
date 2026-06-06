/// Base URL of the WAWUAfrica hub web platform.
///
/// Configurable via dart-define `WAWUAFRICA_HUB_URL`. Used to deep-link from
/// the home services strip into the hub's service pages (EasyBuy, Insurance,
/// Pension, etc.).
///
/// The production fallback is used whenever the dart-define is absent OR
/// resolves to an empty string (e.g. web CI passes
/// `--dart-define=WAWUAFRICA_HUB_URL=` when the secret is unset, which makes
/// `String.fromEnvironment` return "" and bypass `defaultValue`). Resolving at
/// runtime guarantees a usable URL on web too.
const String _wawuAfricaHubUrlEnv =
    String.fromEnvironment('WAWUAFRICA_HUB_URL', defaultValue: '');
const String _wawuAfricaHubUrlFallback =
    'https://wawuafrica-new-production.up.railway.app';

String get wawuAfricaHubUrl => _wawuAfricaHubUrlEnv.isNotEmpty
    ? _wawuAfricaHubUrlEnv
    : _wawuAfricaHubUrlFallback;
