import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/presentation/widgets/export_listing_card.dart';

class TraderHomeScreen extends StatelessWidget {
  const TraderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: TradeController.instance.listings,
        builder: (_, listings, _) {
          final active = listings
              .where((l) =>
                  l.status.toString().endsWith('active') ||
                  l.status.toString().endsWith('draft'))
              .toList();
          final totalEnquiries =
              listings.fold<int>(0, (s, l) => s + l.enquiries);
          final totalLotValue =
              listings.fold<int>(0, (s, l) => s + l.lotValueNaira);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              12,
              WBSpacing.screenPadding,
              140,
            ),
            children: [
              _Hero(
                listings: active.length,
                enquiries: totalEnquiries,
                lotValue: totalLotValue,
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                'Quick actions',
                style: WBTypography.cardTitle.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Action(
                    icon: WBIconName.plus,
                    label: 'Post listing',
                    onTap: () => context.push(
                      '${AppRoutes.traderListings}/edit',
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Action(
                    icon: WBIconName.bike,
                    label: 'Post load',
                    onTap: () => context.push(AppRoutes.traderTransport),
                  ),
                  const SizedBox(width: 10),
                  _Action(
                    icon: WBIconName.card,
                    label: 'Prices',
                    onTap: () => context.go(AppRoutes.traderPrices),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active listings',
                          style:
                              WBTypography.cardTitle.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${active.length} live · $totalEnquiries enquiry${totalEnquiries == 1 ? '' : 'ies'}',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.traderListings),
                    child: Text(
                      'See all',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (active.isEmpty)
                _EmptyTile(
                  label:
                      'No listings up yet. Post one to start receiving enquiries.',
                )
              else
                for (final l in active.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ExportListingCard(
                      listing: l,
                      showStatus: true,
                      onTap: () => context.push(
                        '${AppRoutes.traderListings}/edit?id=${l.id}',
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.listings,
    required this.enquiries,
    required this.lotValue,
  });
  final int listings;
  final int enquiries;
  final int lotValue;

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
            'Hello,',
            style: WBTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Hauwa & Sons Bulk Co.',
            style: WBTypography.hero.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Listings', value: '$listings'),
              const SizedBox(width: 10),
              _Stat(label: 'Enquiries', value: '$enquiries'),
              const SizedBox(width: 10),
              _Stat(label: 'Lot value', value: wbNaira(lotValue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: WBShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: WBIcon(icon, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  const _EmptyTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Text(
        label,
        style: WBTypography.body.copyWith(
          color: WBColors.fgSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
