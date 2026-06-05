import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/trade_controller.dart';
import '../../domain/models/corridor.dart';
import '../../domain/models/export_listing.dart';

/// Desktop-web layout for one export listing. Mirrors
/// [ExportListingDetailScreen]'s data loading (TradeController listings +
/// [TradeController.byId]), enquire / buy-now actions, money/qty formatting
/// and not-found handling exactly, re-laid out as a two-column detail: media
/// + key facts on the left, specs + pricing + escrow CTAs on the right.
/// Desktop-only — the mobile build never imports this file.
class ExportListingDetailDesktopScreen extends StatelessWidget {
  const ExportListingDetailDesktopScreen({super.key, required this.listingId});

  final String listingId;

  void _onBack(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(AppRoutes.trade);

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: ValueListenableBuilder(
        valueListenable: TradeController.instance.listings,
        builder: (_, _, _) {
          final l = TradeController.instance.byId(listingId);
          if (l == null) {
            return _NotFoundBody(onBack: () => _onBack(context));
          }
          return _Body(listing: l, onBack: () => _onBack(context));
        },
      ),
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return WBMaxWidth(
      maxWidth: WBBreakpoints.maxContent,
      padding: const EdgeInsets.all(WBSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: WBSpacing.lg),
          WBBackChip(onPressed: onBack),
          const SizedBox(height: WBSpacing.xl),
          Text(context.l10n.exportListingNotFound, style: WBTypography.page),
          const SizedBox(height: WBSpacing.sm),
          Text(
            'It may have sold or been pulled by the trader.',
            style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.listing, required this.onBack});
  final ExportListing listing;
  final VoidCallback onBack;

  void _enquire(BuildContext context) {
    TradeController.instance.recordEnquiry(listing.id);
    wbShowSnack(context, context.l10n.exportEnquirySent);
  }

  void _buyNow(BuildContext context) {
    context.push('${AppRoutes.escrowCheckout}/${listing.id}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.lg,
          WBSpacing.screenPadding,
          WBSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: WBBackChip(onPressed: onBack),
            ),
            const SizedBox(height: WBSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: media + headline + lot-value stats.
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(WBRadius.card),
                        child: AspectRatio(
                          aspectRatio: 16 / 11,
                          child: WBNetworkImage(url: listing.imageUrl),
                        ),
                      ),
                      const SizedBox(height: WBSpacing.lg),
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
                    ],
                  ),
                ),
                const SizedBox(width: WBSpacing.xl),
                // Right column: specs + escrow note + CTAs.
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: WBSpacing.xl),
                      Row(
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
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
