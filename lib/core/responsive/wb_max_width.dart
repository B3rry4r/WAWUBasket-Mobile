import 'package:flutter/widgets.dart';

import 'wb_breakpoints.dart';

/// Centers and caps a content column so desktop layouts don't sprawl edge to
/// edge on large monitors. A no-op constraint on mobile widths (the child is
/// already narrower than [maxWidth]), so it's safe to wrap shared widgets.
///
///   • [maxWidth] defaults to [WBBreakpoints.maxContent] (1200) for general
///     page content. Use [WBBreakpoints.maxReading] (480) for single-column
///     reading surfaces — auth forms, legal copy, receipts.
class WBMaxWidth extends StatelessWidget {
  const WBMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = WBBreakpoints.maxContent,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
