import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_random_tagline.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../../escrow/application/escrow_controller.dart';
import '../../../escrow/domain/models/bulk_order.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/export_listing.dart';
import '../../../trade/presentation/widgets/export_listing_card.dart';

/// Desktop-web layout for the trader home dashboard.
///
/// TAB screen: renders BODY CONTENT ONLY — the operator shell already wraps it
/// in [OperatorDesktopScaffold] (sidebar + content pane). Reuses the exact same
/// controllers, providers, models, actions and l10n keys as the mobile
/// [TraderHomeScreen]; only the layout is re-flowed for wide screens.
class TraderHomeDesktopScreen extends StatefulWidget {
  const TraderHomeDesktopScreen({super.key});

  @override
  State<TraderHomeDesktopScreen> createState() =>
      _TraderHomeDesktopScreenState();
}

class _TraderHomeDesktopScreenState extends State<TraderHomeDesktopScreen> {
  @override
  void initState() {
    super.initState();
    TradeController.instance.loadMyListings();
    ProfileController.instance.load();
    EscrowController.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
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

        return ValueListenableBuilder(
          valueListenable: ProfileController.instance.profile,
          builder: (_, profile, _) {
            final businessName =
                profile?.traderBusinessName?.isNotEmpty == true
                    ? profile!.traderBusinessName!
                    : profile?.fullName.isNotEmpty == true
                        ? profile!.fullName
                        : 'My Business';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.xl,
                vertical: WBSpacing.xl,
              ),
              child: WBMaxWidth(
                maxWidth: WBBreakpoints.maxContent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page header: title left, quick actions right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(businessName, style: WBTypography.page),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.traderDashboardSubtitle,
                                style: WBTypography.body.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: WBSpacing.lg),
                        _DesktopActionButton(
                          icon: WBIconName.plus,
                          label: 'Post listing',
                          onTap: () => context.push(
                            '${AppRoutes.traderListings}/edit',
                          ),
                        ),
                        const SizedBox(width: 10),
                        _DesktopActionButton(
                          icon: WBIconName.bike,
                          label: 'Post load',
                          onTap: () => context.push(AppRoutes.traderTransport),
                        ),
                        const SizedBox(width: 10),
                        _DesktopActionButton(
                          icon: WBIconName.card,
                          label: 'Prices',
                          onTap: () => context.go(AppRoutes.traderPrices),
                        ),
                      ],
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    const WBRandomTagline(
                      pairs: WBTaglines.trader,
                      fontSize: 26,
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    _Hero(
                      listings: active.length,
                      enquiries: totalEnquiries,
                      lotValue: totalLotValue,
                      businessName: businessName,
                    ),
                    const SizedBox(height: WBSpacing.xl),
                    // Two-column working area: listings left, escrow right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ListingsColumn(
                            active: active,
                            totalEnquiries: totalEnquiries,
                          ),
                        ),
                        const SizedBox(width: WBSpacing.xl),
                        Expanded(
                          flex: 1,
                          child: _LiveEscrowSection(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListingsColumn extends StatelessWidget {
  const _ListingsColumn({
    required this.active,
    required this.totalEnquiries,
  });
  final List<ExportListing> active;
  final int totalEnquiries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Active listings'),
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
      ],
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
                      _SectionLabel('Live escrow'),
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
              _DarkStat(label: 'Listings', value: '$listings'),
              const SizedBox(width: 10),
              _DarkStat(label: 'Enquiries', value: '$enquiries'),
              const SizedBox(width: 10),
              _DarkStat(label: 'Lot value', value: wbNaira(lotValue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.label, required this.value});
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: WBTypography.cardTitle.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DesktopActionButton extends StatelessWidget {
  const _DesktopActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WBIcon(icon, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
