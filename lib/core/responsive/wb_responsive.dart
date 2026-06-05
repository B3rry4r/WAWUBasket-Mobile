import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import 'wb_breakpoints.dart';

/// Form-factor helpers used across the desktop-responsive layer.
///
/// The golden rule that keeps the desktop work *isolated from the mobile
/// build*: [formFactor] short-circuits to [WBFormFactor.mobile] whenever the
/// app is not running on Flutter web. So a `context.isDesktop` check compiles
/// into the iOS/Android binaries as a constant `false`, the desktop branch is
/// never taken there, and the native app behaves exactly as it does today.
extension WBResponsive on BuildContext {
  /// Logical width of the current media. Uses [MediaQuery.sizeOf] so widgets
  /// rebuild when the browser window is resized across a breakpoint.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  WBFormFactor get formFactor {
    // Desktop layouts only exist on the web build. Native devices — phones,
    // tablets, foldables — always get the mobile layout.
    if (!kIsWeb) return WBFormFactor.mobile;
    final w = screenWidth;
    if (w >= WBBreakpoints.desktop) return WBFormFactor.desktop;
    if (w >= WBBreakpoints.tablet) return WBFormFactor.tablet;
    return WBFormFactor.mobile;
  }

  /// True only on a wide-enough browser. The single switch every desktop
  /// layout and route wrapper keys off of.
  bool get isDesktop => formFactor == WBFormFactor.desktop;

  bool get isTablet => formFactor == WBFormFactor.tablet;

  /// True whenever we should render the mobile layout — i.e. anything that is
  /// not desktop. Product decision: tablet-width browsers keep the mobile
  /// layout until 1024px.
  bool get isMobileLayout => formFactor != WBFormFactor.desktop;

  /// True on very large monitors (≥1440). Layouts use this to widen gutters
  /// while keeping the content column capped.
  bool get isWide => kIsWeb && screenWidth >= WBBreakpoints.wide;

  /// Pick a value per form factor. `tablet` falls back to `mobile` when
  /// omitted (matching the "tablet renders mobile" decision).
  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    switch (formFactor) {
      case WBFormFactor.desktop:
        return desktop;
      case WBFormFactor.tablet:
        return tablet ?? mobile;
      case WBFormFactor.mobile:
        return mobile;
    }
  }
}
