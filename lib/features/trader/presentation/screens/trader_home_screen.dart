import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_home_app_bar.dart';
import '../../../../core/widgets/wb_random_tagline.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../../escrow/application/escrow_controller.dart';
import '../../../escrow/domain/models/bulk_order.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/presentation/widgets/export_listing_card.dart';

class TraderHomeScreen extends StatefulWidget {
  const TraderHomeScreen({super.key});

  @override
  State<TraderHomeScreen> createState() => _TraderHomeScreenState();
}

class _TraderHomeScreenState extends State<TraderHomeScreen> {
  @override
  void initState() {
    super.initState();
    TradeController.instance.loadMyListings();
    ProfileController.instance.load();
    EscrowController.instance.load();
  }

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
              ValueListenableBuilder(
                valueListenable: ProfileController.instance.profile,
                builder: (_, profile, _) => WBHomeAppBar(
                  title: profile?.traderBusinessName?.isNotEmpty == true
                      ? profile!.traderBusinessName!
                      : profile?.fullName.isNotEmpty == true
                          ? profile!.fullName
                          : 'My Business',
                  subtitle: context.l10n.traderDashboardSubtitle,
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              const WBRandomTagline(
                pairs: WBTaglines.trader,
                fontSize: 26,
              ),
              const SizedBox(height: WBSpacing.lg),
              ValueListenableBuilder(
                valueListenable: ProfileController.instance.profile,
                builder: (_, profile, _) => _Hero(
                  listings: active.length,
                  enquiries: totalEnquiries,
                  lotValue: totalLotValue,
                  businessName: profile?.traderBusinessName?.isNotEmpty == true
                      ? profile!.traderBusinessName!
                      : profile?.fullName.isNotEmpty == true
                          ? profile!.fullName
                          : 'My Business',
                ),
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
                      context.l10n.actionSeeAll,
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
                const WBEmptyState(
                  illustration: WBEmptyIllustration.noActiveListing,
                  label: 'No listings up yet.',
                  sub: 'Post one to start receiving enquiries.',
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
              const SizedBox(height: WBSpacing.lg),
              _LiveEscrowSection(),
            ],
          );
        },
      ),
    );
  }
}

class _LiveEscrowSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: EscrowController.instance.orders,
      builder: (_, orders, _) {
        final live = orders
            .where((o) =>
                o.status == EscrowStatus.held ||
                o.status == EscrowStatus.disputed)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live escrow',
                        style: WBTypography.cardTitle.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        live.isEmpty
                            ? 'No funded orders right now.'
                            : '${live.length} order${live.length == 1 ? '' : 's'} awaiting fulfilment.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (live.isEmpty)
              const WBEmptyState(
                illustration: WBEmptyIllustration.noOrders,
                label: 'No funded orders right now.',
                sub: 'Funds sit here when a buyer pays, released on delivery.',
              )
            else
              for (final o in live)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EscrowOrderRow(order: o),
                ),
          ],
        );
      },
    );
  }
}

class _EscrowOrderRow extends StatelessWidget {
  const _EscrowOrderRow({required this.order});
  final BulkOrder order;

  @override
  Widget build(BuildContext context) {
    final disputed = order.status == EscrowStatus.disputed;
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.escrowStatus}/${order.id}'),
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: WBNetworkImage(url: order.imageUrl),
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
                          '${order.produce} · ${order.quantityKg} kg',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      WBStatusPill(
                        label: order.status.label,
                        kind: disputed
                            ? WBStatusKind.warning
                            : WBStatusKind.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.buyerName} · ${wbNaira(order.totalNaira)} held',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const WBIcon(
              WBIconName.chevronRight,
              size: 16,
              color: WBColors.fgPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.listings,
    required this.enquiries,
    required this.lotValue,
    required this.businessName,
  });
  final int listings;
  final int enquiries;
  final int lotValue;
  final String businessName;

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
            businessName,
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
