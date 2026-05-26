import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_home_app_bar.dart';
import '../../../../core/widgets/wb_random_tagline.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../application/vendor_orders_controller.dart';
import '../../data/vendor_api.dart';
import '../widgets/vendor_status_pill.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  bool _open = true;

  @override
  void initState() {
    super.initState();
    ProfileController.instance.load();
    VendorOrdersController.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: VendorOrdersController.instance.orders,
        builder: (_, orders, _) {
          final pending = [
            for (final o in orders)
              if (o.stage == OrderStage.pending) o,
          ];
          final inProgress = [
            for (final o in orders)
              if (o.stage == OrderStage.preparing ||
                  o.stage == OrderStage.ready ||
                  o.stage == OrderStage.handover)
                o,
          ];
          final todayRevenue =
              orders.fold<int>(0, (s, o) => s + o.total);

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
                  title: profile?.vendorBusinessName?.isNotEmpty == true
                      ? profile!.vendorBusinessName!
                      : profile?.fullName.isNotEmpty == true
                          ? profile!.fullName
                          : 'My Store',
                  subtitle: 'Vendor dashboard',
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              const WBRandomTagline(
                pairs: WBTaglines.vendor,
                fontSize: 26,
              ),
              const SizedBox(height: WBSpacing.lg),
              ValueListenableBuilder(
                valueListenable: ProfileController.instance.profile,
                builder: (_, profile, _) => _Hero(
                  open: _open,
                  onToggle: () {
                    final newVal = !_open;
                    setState(() => _open = newVal);
                    VendorApi.instance
                        .updateSettings({'isOpen': newVal}).catchError((_) {
                      if (mounted) setState(() => _open = !newVal);
                    });
                  },
                  ordersToday: orders.length,
                  revenue: todayRevenue,
                  businessName: profile?.vendorBusinessName?.isNotEmpty == true
                      ? profile!.vendorBusinessName!
                      : profile?.fullName.isNotEmpty == true
                          ? profile!.fullName
                          : 'My Store',
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              _SectionLabel(context.l10n.vendorHomeQuickActions),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Action(
                    icon: WBIconName.plus,
                    label: context.l10n.vendorHomeAddItem,
                    onTap: () => context.push(AppRoutes.vendorMenuEdit),
                  ),
                  const SizedBox(width: 10),
                  _Action(
                    icon: WBIconName.more,
                    label: context.l10n.vendorHomeAnalytics,
                    onTap: () => context.push(AppRoutes.vendorAnalytics),
                  ),
                  const SizedBox(width: 10),
                  _Action(
                    icon: WBIconName.card,
                    label: context.l10n.vendorHomePayouts,
                    onTap: () => context.push(AppRoutes.vendorPayouts),
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
                        _SectionLabel(context.l10n.vendorHomeFreshOrders),
                        const SizedBox(height: 4),
                        Text(
                          pending.isEmpty
                              ? 'No orders right now. Time to take a breath.'
                              : '${pending.length} waiting for your magic.',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.vendorOrders),
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
              if (pending.isEmpty)
                _EmptyTile(label: context.l10n.vendorHomeNoOrders)
              else
                for (final o in pending.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PendingCard(order: o),
                  ),

              if (inProgress.isNotEmpty) ...[
                const SizedBox(height: WBSpacing.md),
                _SectionLabel(context.l10n.vendorHomeInKitchen),
                const SizedBox(height: 10),
                for (final o in inProgress.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _InProgressCard(order: o),
                  ),
              ],

              const SizedBox(height: WBSpacing.lg),
              _SectionLabel(context.l10n.vendorHomeMore),
              const SizedBox(height: 10),
              _MoreRow(
                icon: WBIconName.basket,
                label: context.l10n.vendorHomeInventory,
                sub: context.l10n.vendorHomeInventorySub,
                onTap: () => context.push(AppRoutes.vendorInventory),
              ),
              _MoreRow(
                icon: WBIconName.star,
                label: context.l10n.vendorHomeReviews,
                sub: context.l10n.vendorHomeReviewsSub,
                onTap: () => context.push(AppRoutes.vendorReviews),
              ),
              _MoreRow(
                icon: WBIconName.bell,
                label: context.l10n.vendorHomeAlerts,
                sub: context.l10n.vendorHomeAlertsSub,
                onTap: () => context.push(AppRoutes.vendorAlerts),
              ),
              _MoreRow(
                icon: WBIconName.more,
                label: context.l10n.vendorHomeSettings,
                sub: context.l10n.vendorHomeSettingsSub,
                onTap: () => context.push(AppRoutes.vendorSettings),
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
    required this.open,
    required this.onToggle,
    required this.ordersToday,
    required this.revenue,
    required this.businessName,
  });
  final bool open;
  final VoidCallback onToggle;
  final int ordersToday;
  final int revenue;
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.vendorHomeGoodMorning,
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
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: WBMotion.base,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        open ? Colors.white : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: open
                              ? const Color(0xFF10B981)
                              : Colors.white.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        open ? context.l10n.vendorHomeOpen : context.l10n.vendorHomeClosed,
                        style: WBTypography.caption.copyWith(
                          color: open ? WBColors.fgHeader : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              _DarkStat(label: context.l10n.vendorAnalyticsOrders, value: '$ordersToday'),
              const SizedBox(width: 10),
              _DarkStat(label: 'Earned', value: wbNaira(revenue)),
              const SizedBox(width: 10),
              _DarkStat(label: context.l10n.vendorAnalyticsRating, value: '★ 4.8'),
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

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.vendorOrderDetail}/${order.id}'),
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${order.id}',
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                VendorOrderStatusPill(stage: order.stage),
                const Spacer(),
                Text(
                  '${order.placedMinsAgo} min',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.customerName} · ${order.items.length} item${order.items.length == 1 ? '' : 's'}',
              style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              [for (final i in order.items) i.name].join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: WBButton(
                    label: context.l10n.vendorHomeDecline,
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () {
                      VendorOrdersController.instance.decline(order.id);
                      wbShowSnack(context, '${order.id} declined');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WBButton(
                    label: context.l10n.vendorHomeAccept,
                    size: WBButtonSize.sm,
                    fullWidth: true,
                    onPressed: () {
                      VendorOrdersController.instance.advance(order.id);
                      wbShowSnack(context, '${order.id} accepted');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  const _InProgressCard({required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    final next = order.stage.advance;
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.vendorOrderDetail}/${order.id}'),
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WBColors.bgSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const WBIcon(WBIconName.basket, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '#${order.id}',
                              overflow: TextOverflow.ellipsis,
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          VendorOrderStatusPill(stage: order.stage),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.customerName} · ${wbNaira(order.total)}',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (next != null) ...[
              const SizedBox(height: 12),
              WBButton(
                label: next.label,
                size: WBButtonSize.sm,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () {
                  VendorOrdersController.instance.advance(order.id);
                  wbShowSnack(context, '${order.id} · ${next.next.label}');
                },
              ),
            ],
          ],
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

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
