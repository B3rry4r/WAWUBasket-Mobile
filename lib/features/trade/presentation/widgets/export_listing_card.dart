import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/corridor.dart';
import '../../domain/models/export_listing.dart';

/// One trader-posted export listing rendered as a card. Used in the
/// customer-side `/trade` browse, on the trader dashboard, and inside
/// supplier-detail listings. `showStatus` toggles the Active / Sold pill
/// (trader-facing), buyer-facing surfaces just show the enquiry count.
class ExportListingCard extends StatelessWidget {
  const ExportListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showStatus = false,
    this.trailing,
  });

  final ExportListing listing;
  final VoidCallback onTap;
  final bool showStatus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: WBNetworkImage(url: listing.imageUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.produce,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (showStatus)
                        WBStatusPill(
                          label: listing.status.label,
                          kind: switch (listing.status) {
                            ExportListingStatus.active => WBStatusKind.success,
                            ExportListingStatus.draft => WBStatusKind.warning,
                            ExportListingStatus.sold => WBStatusKind.info,
                            ExportListingStatus.expired => WBStatusKind.error,
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${listing.farmName} · ${listing.farmRegion}',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Pill(
                        text: '${_compactQty(listing.quantityKg)} kg',
                        emphasised: true,
                      ),
                      const SizedBox(width: 6),
                      _Pill(text: '${wbNaira(listing.pricePerKgNaira)}/kg'),
                      const SizedBox(width: 6),
                      _CorridorPair(
                        from: listing.originCorridor,
                        to: listing.destinationCorridor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          showStatus
                              ? '${listing.enquiries} enquiry${listing.enquiries == 1 ? '' : 'ies'} · ${_age(listing.harvestDate)}'
                              : 'Lot value ${wbNaira(listing.lotValueNaira)}',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactQty(int kg) {
    if (kg >= 1000) {
      final t = kg / 1000;
      return t == t.roundToDouble()
          ? '${t.toInt()}k'
          : '${t.toStringAsFixed(1)}k';
    }
    return '$kg';
  }

  String _age(DateTime d) {
    final days = DateTime.now().difference(d).inDays;
    if (days <= 0) return 'fresh today';
    if (days == 1) return '1 day ago';
    return '$days days ago';
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.emphasised = false});
  final String text;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: emphasised ? WBColors.surfaceDark : WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Text(
        text,
        style: WBTypography.caption.copyWith(
          color: emphasised ? Colors.white : WBColors.fgHeader,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CorridorPair extends StatelessWidget {
  const _CorridorPair({required this.from, required this.to});
  final Corridor from;
  final Corridor to;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            from.short,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgHeader,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          const WBIcon(
            WBIconName.arrowRight,
            size: 10,
            color: WBColors.fgPlaceholder,
          ),
          const SizedBox(width: 4),
          Text(
            to.short,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgHeader,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
