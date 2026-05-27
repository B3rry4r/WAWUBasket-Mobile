import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/vendor_orders_controller.dart';
import '../widgets/vendor_status_pill.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  static const _filters = [
    ('Pending', [OrderStage.pending]),
    ('Preparing', [OrderStage.preparing]),
    ('Ready', [OrderStage.ready, OrderStage.handover]),
    ('Done', [OrderStage.done, OrderStage.declined]),
  ];
  int _tab = 0;

  void _open(VendorOrder o) =>
      context.push('${AppRoutes.vendorOrderDetail}/${o.id}');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: VendorOrdersController.instance.orders,
        builder: (_, orders, _) {
          final stages = _filters[_tab].$2;
          final filtered = [
            for (final o in orders)
              if (stages.contains(o.stage)) o,
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              12,
              WBSpacing.screenPadding,
              140,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live orders', style: WBTypography.page),
                        Text(
                          'The ones waiting for your magic.',
                          style: WBTypography.body.copyWith(
                            color: WBColors.fgSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  WBButton(
                    label: context.l10n.vendorAlertsTitle,
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    trailingIcon: WBIconName.bell,
                    onPressed: () => context.push(AppRoutes.vendorAlerts),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => WBTag(
                    label: '${_filters[i].$1} · ${_countFor(orders, _filters[i].$2)}',
                    active: i == _tab,
                    onTap: () => setState(() => _tab = i),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              if (filtered.isEmpty)
                _EmptyState(label: 'No orders right now. Time to take a breath.')
              else
                for (final o in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: o, onOpen: () => _open(o)),
                  ),
            ],
          );
        },
      ),
    );
  }

  int _countFor(List<VendorOrder> orders, List<OrderStage> stages) {
    var n = 0;
    for (final o in orders) {
      if (stages.contains(o.stage)) n++;
    }
    return n;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
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
        style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order, required this.onOpen});
  final VendorOrder order;
  final VoidCallback onOpen;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _accepting = false;
  bool _declining = false;
  bool _advancing = false;

  String get _itemSummary {
    final parts = [
      for (final i in widget.order.items) '${i.name} × ${i.qty}'
    ];
    return parts.join(' · ');
  }

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await VendorOrdersController.instance.advance(widget.order.id);
      if (mounted) wbShowSnack(context, 'Order accepted');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _declining = true);
    try {
      await VendorOrdersController.instance.decline(widget.order.id);
      if (mounted) wbShowSnack(context, 'Order declined');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _declining = false);
    }
  }

  Future<void> _advance() async {
    setState(() => _advancing = true);
    try {
      await VendorOrdersController.instance.advance(widget.order.id);
      final next = widget.order.stage.advance;
      if (mounted && next != null) {
        wbShowSnack(context, '${widget.order.id} · ${next.next.label}');
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final next = order.stage.advance;
    final busy = _accepting || _declining || _advancing;

    return GestureDetector(
      onTap: widget.onOpen,
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
              order.customerName,
              style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              _itemSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  wbNaira(order.total),
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (order.stage == OrderStage.pending) ...[
                  WBButton(
                    label: context.l10n.vendorHomeDecline,
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    loading: _declining,
                    onPressed: busy ? null : _decline,
                  ),
                  const SizedBox(width: 8),
                  WBButton(
                    label: context.l10n.vendorHomeAccept,
                    size: WBButtonSize.sm,
                    loading: _accepting,
                    onPressed: busy ? null : _accept,
                  ),
                ] else if (next != null)
                  WBButton(
                    label: next.label,
                    size: WBButtonSize.sm,
                    loading: _advancing,
                    onPressed: busy ? null : _advance,
                  )
                else
                  WBButton(
                    label: 'Receipt',
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    onPressed: widget.onOpen,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
