/// Local-only secrets. Excluded from version control via .gitignore so a
/// token never ends up in a commit by accident.
///
/// To enable the Mapbox-backed rider home + active-delivery mini-map:
///   1. Go to https://account.mapbox.com/access-tokens/
///   2. Copy your default *public* token (starts with `pk.`).
///   3. Paste it as the value of [kMapboxPublicToken] below.
///
/// While the token is empty the rider home renders a graceful placeholder
/// instead of the map — every other rider screen still works.
library;

const String kMapboxPublicToken = '';

/// True when a usable token is configured. Screens use this to decide
/// whether to render the Mapbox widget or the placeholder.
bool get kMapboxConfigured =>
    kMapboxPublicToken.isNotEmpty && kMapboxPublicToken.startsWith('pk.');
