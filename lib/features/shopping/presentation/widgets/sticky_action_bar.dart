import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';

/// Transparent footer slot that hosts the sticky CTA at the bottom of a
/// screen. Has no background fill, the dark button itself supplies all
/// the visual presence. Callers must reserve enough bottom padding on
/// their scroll content so the CTA doesn't overlap the last card.
///
/// Reserve [reserveAbove] = 110 px (56 button + 24 inner + 30 safe-area)
/// when sizing the scroll content's `paddingBottom`.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      WBSpacing.screenPadding,
      8,
      WBSpacing.screenPadding,
      28,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  /// Suggested bottom padding for scroll content above the bar.
  static const reserveAbove = 110.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(padding: padding, child: child),
    );
  }
}
