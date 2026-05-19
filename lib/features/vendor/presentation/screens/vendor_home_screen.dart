import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          // Hero
          Container(
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
                            'Good morning,',
                            style: WBTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mama Cass Kitchen',
                            style: WBTypography.hero.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _open = !_open),
                      child: AnimatedContainer(
                        duration: WBMotion.base,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _open
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(WBRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _open
                                    ? const Color(0xFF10B981)
                                    : Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _open ? 'Open' : 'Closed',
                              style: WBTypography.caption.copyWith(
                                color: _open
                                    ? WBColors.fgHeader
                                    : Colors.white,
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
                  children: const [
                    _StatTile(label: 'Orders', value: '14'),
                    SizedBox(width: 10),
                    _StatTile(label: 'Earned', value: '₦68k'),
                    SizedBox(width: 10),
                    _StatTile(label: 'Rating', value: '★ 4.8'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          _SectionLabel(label: 'Quick actions'),
          const SizedBox(height: 10),
          Row(
            children: [
              _Action(
                icon: WBIconName.plus,
                label: 'Add item',
                onTap: () => context.push(AppRoutes.vendorMenuEdit),
              ),
              const SizedBox(width: 10),
              _Action(
                icon: WBIconName.more,
                label: 'Analytics',
                onTap: () => context.push(AppRoutes.vendorAnalytics),
              ),
              const SizedBox(width: 10),
              _Action(
                icon: WBIconName.card,
                label: 'Payout',
                onTap: () => context.push(AppRoutes.vendorPayouts),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          _SectionLabel(label: 'Fresh orders'),
          const SizedBox(height: 4),
          Text(
            'The ones waiting for your magic.',
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: 12),
          _PendingOrder(
            id: 'WAWU-8821',
            customer: 'Adunni · 4 min ago',
            items: 'Jollof × 2, Suya × 1',
            onAccept: () => wbShowSnack(context, 'Order accepted'),
            onDecline: () => wbShowSnack(context, 'Order declined'),
          ),
          const SizedBox(height: 12),
          _PendingOrder(
            id: 'WAWU-8822',
            customer: 'Tobi · 7 min ago',
            items: 'Egusi & pounded yam',
            onAccept: () => wbShowSnack(context, 'Order accepted'),
            onDecline: () => wbShowSnack(context, 'Order declined'),
          ),
          const SizedBox(height: WBSpacing.lg),
          _SectionLabel(label: 'More'),
          const SizedBox(height: 10),
          _MoreRow(
            icon: WBIconName.basket,
            label: 'Inventory',
            sub: 'Stock levels & batches',
            onTap: () => context.push(AppRoutes.vendorInventory),
          ),
          _MoreRow(
            icon: WBIconName.star,
            label: 'Reviews',
            sub: 'What customers say',
            onTap: () => context.push(AppRoutes.vendorReviews),
          ),
          _MoreRow(
            icon: WBIconName.more,
            label: 'Store settings',
            sub: 'Hours, prep time, holiday mode',
            onTap: () => context.push(AppRoutes.vendorSettings),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
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
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
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

class _PendingOrder extends StatelessWidget {
  const _PendingOrder({
    required this.id,
    required this.customer,
    required this.items,
    required this.onAccept,
    required this.onDecline,
  });
  final String id;
  final String customer;
  final String items;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$id',
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              const WBStatusPill(label: 'Pending', kind: WBStatusKind.warning),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            customer,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            items,
            style: WBTypography.body.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: WBButton(
                  label: 'Decline',
                  size: WBButtonSize.sm,
                  variant: WBButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WBButton(
                  label: 'Accept',
                  size: WBButtonSize.sm,
                  fullWidth: true,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
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
