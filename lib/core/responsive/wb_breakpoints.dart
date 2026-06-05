/// Responsive breakpoints for the WAWUBasket **web** build.
///
/// Desktop layouts are a web-only concern — the native iOS/Android build
/// always renders the mobile layout (see [WBResponsive.formFactor]). These
/// thresholds therefore only ever fire inside a browser.
///
///   • mobile   < 768   → the existing mobile screens, untouched
///   • tablet   768–1023 → still the mobile layout (product decision), just wider
///   • desktop  ≥ 1024  → the isolated `desktop/` layouts kick in
///   • wide     ≥ 1440  → desktop layout with extra gutter; content stays capped
abstract final class WBBreakpoints {
  /// Below this the layout is unambiguously a phone.
  static const double tablet = 768;

  /// At/above this the desktop layouts take over.
  static const double desktop = 1024;

  /// At/above this we're on a large monitor — content stays capped at
  /// [maxContent] and the extra width becomes gutter.
  static const double wide = 1440;

  /// Max width a centered desktop content column is allowed to grow to.
  /// Keeps line-lengths readable and the layout from sprawling on 4K panels.
  static const double maxContent = 1200;

  /// Narrower cap for single-column reading surfaces (auth forms, legal copy,
  /// receipts) shown centered on a desktop backdrop.
  static const double maxReading = 480;

  /// Fixed width of the operator dashboard side-nav rail.
  static const double sideNavWidth = 248;
}

/// The three layout regimes the app renders in. Note that on native mobile
/// the form factor is *always* [mobile] regardless of physical screen size —
/// desktop chrome (side-nav, hover affordances, mouse-drag scroll) is only
/// ever appropriate in a browser.
enum WBFormFactor { mobile, tablet, desktop }
