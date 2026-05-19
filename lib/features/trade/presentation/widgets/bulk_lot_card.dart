import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/bulk_lot.dart';

/// Compact bulk-lot card used in both the home Trade carousel and the
/// TradeScreen grid. Tap anywhere to push the lot detail; the small
/// `Request quote` button is just a more deliberate hit-target for the
/// same destination.
class BulkLotCard extends StatelessWidget {
  const BulkLotCard({
    super.key,
    required this.lot,
    this.onTap,
    this.onRequestQuote,
  });

  final BulkLot lot;
  final VoidCallback? onTap;
  final VoidCallback? onRequestQuote;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: WBShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1.5:1 image. Slightly wider keeps the produce visible while
            // leaving more room for content below.
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: WBNetworkImage(url: lot.imageUrl),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: WBColors.surfaceDark,
                      borderRadius: BorderRadius.circular(WBRadius.pill),
                    ),
                    child: Text(
                      'BULK',
                      style: WBTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.66,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lot.produce,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lot.lotSize,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lot.unitPriceLabel,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    lot.minOrderLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onRequestQuote ?? onTap,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: WBColors.bgSoft,
                        borderRadius: BorderRadius.circular(WBRadius.pill),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Request quote',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
