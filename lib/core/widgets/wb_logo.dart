import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/wb_theme_exports.dart';

/// Renders the WAWUBasket brand mark from `assets/logos/brand-icon.svg`.
/// The painter-based fallback was a placeholder; this widget now uses the
/// real artwork the brand supplied.
class WBWMark extends StatelessWidget {
  const WBWMark({super.key, this.size = 72, this.color = WBColors.fgHeader});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/brand-icon.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(width: size, height: size),
    );
  }
}

/// Wordmark variant — the full WAWUBasket lock-up. Use when the brand needs
/// to read at a glance (welcome screen, marketing surfaces).
class WBWordmark extends StatelessWidget {
  const WBWordmark({super.key, this.height = 32, this.color = WBColors.fgHeader});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/brand-wordmark.svg',
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(height: height),
    );
  }
}
