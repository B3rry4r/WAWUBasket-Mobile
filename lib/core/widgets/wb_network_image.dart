import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Network image with a calm placeholder + error fallback that respects the
/// monochrome aesthetic. Keeps the surface readable while images load instead
/// of flashing black.
class WBNetworkImage extends StatelessWidget {
  const WBNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: true,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: WBColors.bgSoft);
      },
      errorBuilder: (_, _, _) => Container(color: WBColors.bgSoft),
    );
  }
}
