import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key, this.standalone = false});

  /// When reached as a pushed route (e.g. the Home "Reorder" quick
  /// action) we render a back chip. As a bottom-nav tab it stays
  /// chrome-free since the nav bar is the way back.
  final bool standalone;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

enum _OrderStatus { active, done, cancelled }

class _Order {
  const _Order({
    required this.id,
    required this.vendor,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
  });
  final String id;
  final String vendor;
  final String items;
  final String total;
  final String date;
  final _OrderStatus status;
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const _tabs = ['All', 'Active', 'Past'];
  static const _orders = [
    _Order(
      id: 'ORD-8821',
      vendor: 'Mama Cass Kitchen',
      items: 'Jollof rice, Suya platter',
      total: '₦14,600',
      date: 'Today, 12:31',
      status: _OrderStatus.active,
    ),
    _Order(
      id: 'ORD-8804',
      vendor: 'The Daily Grain',
      items: 'Garden bowl × 2',
      total: '₦7,400',
      date: 'Yesterday, 18:02',
      status: _OrderStatus.done,
    ),
    _Order(
      id: 'ORD-8790',
      vendor: 'Suya & Smoke',
      items: 'Suya platter, Drinks',
      total: '₦6,200',
      date: 'Mon 12 May',
      status: _OrderStatus.done,
    ),
    _Order(
      id: 'ORD-8771',
      vendor: 'Hako Sushi',
      items: 'Salmon nigiri set',
      total: '₦9,800',
      date: 'Sat 10 May',
      status: _OrderStatus.cancelled,
    ),
  ];

  String _activeTab = 'All';

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          120,
        ),
        children: [
          if (widget.standalone)
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(
                  child: Text('Your past baskets', style: WBTypography.page),
                ),
              ],
            )
          else
            Text('Your past baskets', style: WBTypography.page),
          const SizedBox(height: WBSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => WBTag(
                label: _tabs[i],
                active: _tabs[i] == _activeTab,
                onTap: () => setState(() => _activeTab = _tabs[i]),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          for (final order in _orders) ...[
            _OrderCard(order: order),
            const SizedBox(height: WBSpacing.md),
          ],
        ],
      ),
    );
    if (widget.standalone) {
      return Scaffold(backgroundColor: WBColors.bgPrimary, body: body);
    }
    return body;
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _Order order;

  WBStatusKind get _statusKind {
    switch (order.status) {
      case _OrderStatus.active:
        return WBStatusKind.info;
      case _OrderStatus.done:
        return WBStatusKind.success;
      case _OrderStatus.cancelled:
        return WBStatusKind.error;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case _OrderStatus.active:
        return 'On the way';
      case _OrderStatus.done:
        return 'Delivered';
      case _OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WBCard(
      padding: const EdgeInsets.all(WBSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.vendor,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.items,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              WBStatusPill(label: _statusLabel, kind: _statusKind),
            ],
          ),
          const SizedBox(height: 14),
          const WBDivider(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.total,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.date,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.status == _OrderStatus.active)
                WBButton(
                  label: 'Track order',
                  size: WBButtonSize.sm,
                  onPressed: () => context.push(AppRoutes.tracking),
                )
              else ...[
                if (order.status == _OrderStatus.done) ...[
                  WBButton(
                    label: 'Receipt',
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    onPressed: () => context.push(AppRoutes.receipt),
                  ),
                  const SizedBox(width: 8),
                ],
                WBButton(
                  label: order.status == _OrderStatus.done ? 'Reorder' : 'View',
                  size: WBButtonSize.sm,
                  variant: order.status == _OrderStatus.done
                      ? WBButtonVariant.primary
                      : WBButtonVariant.secondary,
                  onPressed: () {
                    if (order.status == _OrderStatus.done) {
                      wbShowSnack(context, 'Items added to your basket');
                      context.push(AppRoutes.cart);
                    } else {
                      context.push(AppRoutes.receipt);
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
