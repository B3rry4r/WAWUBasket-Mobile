import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/trade_controller.dart';
import '../../domain/models/corridor.dart';
import '../../domain/models/export_listing.dart';

/// Buyer-facing detail for one export listing. The Enquire CTA records
/// an enquiry against the listing (which the trader sees on their
/// dashboard) and shows a snackbar, the actual escrow checkout lands
/// in batch D.
class ExportListingDetailScreen extends StatelessWidget {
  const ExportListingDetailScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: ValueListenableBuilder(
        valueListenable: TradeController.instance.listings,
        builder: (_, _, _) {
          final l = TradeController.instance.byId(listingId);
          if (l == null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(WBSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(height: WBSpacing.xl),
                    Text(context.l10n.exportListingNotFound, style: WBTypography.page),
                    const SizedBox(height: WBSpacing.sm),
                    Text(
                      'It may have sold or been pulled by the trader.',
                      style: WBTypography.body.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return _Body(listing: l);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.listing});
  final ExportListing listing;

  void _enquire(BuildContext context) {
    TradeController.instance.recordEnquiry(listing.id);
    wbShowSnack(context, context.l10n.exportEnquirySent);
  }

  void _buyNow(BuildContext context) {
    context.push('${AppRoutes.escrowCheckout}/${listing.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: WBNetworkImage(url: listing.imageUrl),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: WBSpacing.screenPadding,
                  child: WBBackChip(onPressed: () => context.pop()),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                WBSpacing.lg,
                WBSpacing.screenPadding,
                160,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.produce,
                    style: WBTypography.hero.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.farmName} · ${listing.farmRegion}',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  _StatsCard(listing: listing),
                  const SizedBox(height: WBSpacing.lg),
                  Text(
                    'About this lot',
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  WBCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: WBIconName.basket,
                          label: context.l10n.exportQtyAvailable,
                          value: '${wbThousands(listing.quantityKg)} kg',
                        ),
                        const SizedBox(height: 12),
                        const WBDivider(),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: WBIconName.card,
                          label: context.l10n.exportPricePerKg,
                          value: wbNaira(listing.pricePerKgNaira),
                        ),
                        const SizedBox(height: 12),
                        const WBDivider(),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: WBIconName.clock,
                          label: context.l10n.exportHarvestDate,
                          value: _formatDate(listing.harvestDate),
                        ),
                        const SizedBox(height: 12),
                        const WBDivider(),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: WBIconName.pin,
                          label: context.l10n.exportCorridor,
                          value:
                              '${listing.originCorridor.label} → ${listing.destinationCorridor.label}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x1410B981),
                      borderRadius: BorderRadius.circular(WBRadius.card),
                      border: Border.all(color: const Color(0x3310B981)),
                    ),
                    child: Row(
                      children: [
                        const WBIcon(WBIconName.check, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Payments held in escrow until you confirm delivery.',
                            style: WBTypography.body.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                18,
              ),
              decoration: BoxDecoration(
                color: WBColors.bgPrimary,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: WBButton(
                      label: context.l10n.exportEnquire,
                      size: WBButtonSize.lg,
                      variant: WBButtonVariant.secondary,
                      onPressed: () => _enquire(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: WBButton(
                      label: 'Buy ${wbNaira(listing.lotValueNaira)}',
                      size: WBButtonSize.lg,
                      trailingIcon: WBIconName.arrowRight,
                      onPressed: () => _buyNow(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.listing});
  final ExportListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.lg),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LOT VALUE',
            style: WBTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            wbNaira(listing.lotValueNaira),
            style: WBTypography.hero.copyWith(
              color: Colors.white,
              fontSize: 32,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${listing.quantityKg} kg · ${wbNaira(listing.pricePerKgNaira)}/kg',
            style: WBTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final WBIconName icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: WBIcon(icon, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
