import 'package:flutter/widgets.dart';

import 'wb_responsive.dart';

/// Picks between a mobile and a desktop subtree at build time, rebuilding
/// automatically when the browser crosses the desktop breakpoint (it depends
/// on [MediaQuery] via [WBResponsive]).
///
/// Use the lazy [WBAdaptive] builder form inside a screen when only part of a
/// layout differs. Use [WBAdaptiveScreen] at the route level to swap an entire
/// mobile screen for its isolated desktop counterpart — that way the mobile
/// screen file never imports the desktop one and vice-versa.
class WBAdaptive extends StatelessWidget {
  const WBAdaptive({super.key, required this.mobile, required this.desktop});

  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) =>
      context.isDesktop ? desktop(context) : mobile(context);
}

/// Route-level mobile↔desktop selector. Both subtrees are passed pre-built
/// because GoRoute builders construct them eagerly; only the selected one is
/// ever inserted into the tree, and the unselected `const` widget is free.
///
/// Canonical usage in `app_router.dart`:
/// ```dart
/// builder: (_, _) => const WBAdaptiveScreen(
///   mobile: HomeScreen(),
///   desktop: HomeDesktopScreen(),
/// ),
/// ```
class WBAdaptiveScreen extends StatelessWidget {
  const WBAdaptiveScreen({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  final Widget mobile;
  final Widget desktop;

  @override
  Widget build(BuildContext context) => context.isDesktop ? desktop : mobile;
}
