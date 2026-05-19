import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/vendor.dart';

/// The "DS" vendor card — pixel match for `preview/components-card.html`
/// and the verified Home (HomeV4).
///
/// Anatomy:
/// - 300px wide white card with 28px outer radius and 12px inner padding.
/// - Inset photo at 18px radius (height 132).
/// - Frosted glass brand pill (top-left of the photo).
/// - White heart chip (top-right of the photo).
/// - 56px black ETA medallion straddling the photo / info seam.
/// - Info block: name, cuisine, rating + reviews + fee.
/// - Hairline footer with tag pills + "View menu →".
class DSVendorCard extends StatelessWidget {
  const DSVendorCard({super.key, required this.vendor, this.onTap});

  final Vendor vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WBColors.bgPrimary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 6),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Inset photo
              SizedBox(
                height: 132,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: WBNetworkImage(url: vendor.imageUrl),
                ),
              ),
              // Frosted brand pill
              Positioned(
                top: 14,
                left: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.fromLTRB(6, 0, 10, 0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(WBRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vendor.shortName,
                            style: WBTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Heart chip
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const WBIcon(
                    WBIconName.heart,
                    size: 16,
                    strokeWidth: 1.6,
                  ),
                ),
              ),
              // ETA medallion — straddles photo/info seam
              Positioned(
                right: 12,
                bottom: -28,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: WBColors.bgPrimary, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2E000000),
                        offset: Offset(0, 8),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vendor.etaShort,
                        style: WBTypography.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          letterSpacing: -0.34,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'MIN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.54,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28), // room for medallion overflow
          // Info block
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: WBTypography.cardTitle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.085,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vendor.cuisine,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const WBIcon(WBIconName.star, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      vendor.rating.toString(),
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgHeader,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${vendor.reviews})',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC7C7C7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${vendor.feeLabel} delivery',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEFEFEF))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in vendor.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(WBRadius.pill),
                          ),
                          child: Text(
                            t,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View menu',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgHeader,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const WBIcon(
                      WBIconName.arrowRight,
                      size: 14,
                      strokeWidth: 1.6,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return onTap == null
        ? card
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: card,
          );
  }
}
