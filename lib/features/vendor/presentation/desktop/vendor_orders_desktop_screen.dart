import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/vendor_orders_controller.dart';
import '../widgets/vendor_status_pill.dart';

/// Desktop-web layout for the vendor live-orders board.
///
/// TAB screen: renders as body content only inside the operator desktop
/// scaffold (the role shell supplies the persistent sidebar), so there is no
/// scaffold/top bar here.
///
/// Reuses [VendorOrdersController] (the same singleton + [orders] notifier the
/// mobile screen listens to), [VendorOrder]/[OrderStage], [VendorOrderStatusPill]
/// and the identical stage filters, counts, money formatting, accept/decline/
/// advance actions and navigation. This is a re-lay-out only: the vertical
/// mobile list becomes a header + summary tiles + a comfortable multi-column
/// grid of the same order cards.
class VendorOrdersDesktopScreen extends StatefulWidget {
  const VendorOrdersDesktopScreen({super.key});

  @override
  State<VendorOrdersDesktopScreen> createState() =>
      _VendorOrdersDesktopScreenState();
}

class _VendorOrdersDesktopScreenState extends State<VendorOrdersDesktopScreen> {
  static const _filters = [
    ('Pending', [OrderStage.pending]),
    ('Preparing', [OrderStage.preparing]),
    ('Ready', [OrderStage.ready, OrderStage.handover]),
    ('Done', [OrderStage.done, OrderStage.declined]),
  ];
  int _tab = 0;

  void _open(VendorOrder o) =>
      context.push('${AppRoutes.vendorOrderDetail}/${o.id}');

  int _countFor(List<VendorOrder> orders, List<OrderStage> stages) {
    var n = 0;
    for (final o in orders) {
      if (stages.contains(o.stage)) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(mobile: 1, tablet: 2, desktop: 2);
    return ValueListenableBuilder(
      valueListenable: VendorOrdersController.instance.orders,
      builder: (_, orders, _) {
        final stages = _filters[_tab].$2;
        final filtered = [
          for (final o in orders)
            if (stages.contains(o.stage)) o,
        ];
        return WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.xl,
            WBSpacing.xl,
            WBSpacing.xl,
            WBSpacing.xxl,
          ),
          child: ListView(
            children: [
              // Page header: title + subtitle on the left, alerts action right.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.vendorLiveOrdersTitle,
                          style: WBTypography.page,
                        ),
                        const SizedBox(height: 4),
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
                  const SizedBox(width: WBSpacing.lg),
                  WBButton(
                    label: context.l10n.vendorAlertsTitle,
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    trailingIcon: WBIconName.bell,
                    onPressed: () => context.push(AppRoutes.vendorAlerts),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.xl),
              // Summary tiles double as the stage filters.
              Row(
                children: [
                  for (var i = 0; i < _filters.length; i++) ...[
                    if (i != 0) const SizedBox(width: WBSpacing.md),
                    Expanded(
                      child: _SummaryTile(
                        label: _filters[i].$1,
                        count: _countFor(orders, _filters[i].$2),
                        active: i == _tab,
                        onTap: () => setState(() => _tab = i),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: WBSpacing.xl),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: WBEmptyState(
                    illustration: WBEmptyIllustration.noNewOrder,
                    label: 'No orders right now.',
                    sub: 'Time to take a breath.',
                  ),
                )
              else
                _OrderGrid(
                  orders: filtered,
                  columns: columns,
                  onOpen: _open,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A stat tile in the summary row that also acts as the stage filter chip.
class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        padding: const EdgeInsets.all(WBSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: WBTypography.hero.copyWith(
                fontSize: 26,
                color: active ? WBColors.fgHeader : WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: WBTypography.caption.copyWith(
                color: active ? WBColors.fgHeader : WBColors.fgSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lays the order cards into a responsive multi-column grid that keeps each
/// card at its natural height (no fixed aspect ratio clipping).
class _OrderGrid extends StatelessWidget {
  const _OrderGrid({
    required this.orders,
    required this.columns,
    required this.onOpen,
  });

  final List<VendorOrder> orders;
  final int columns;
  final void Function(VendorOrder) onOpen;

  @override
  Widget build(BuildContext context) {
    const gap = WBSpacing.md;
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = gap * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalGap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final o in orders)
              SizedBox(
                width: cardWidth,
                child: _OrderCard(order: o, onOpen: () => onOpen(o)),
              ),
          ],
        );
      },
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
      for (final i in widget.order.items) '${i.name} × ${i.qty}',
    ];
    return parts.join(' · ');
  }

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await VendorOrdersController.instance.advance(widget.order.id);
      if (mounted) wbShowSnack(context, context.l10n.vendorOrderAccepted);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _declining = true);
    try {
      await VendorOrdersController.instance.decline(widget.order.id);
      if (mounted) wbShowSnack(context, context.l10n.vendorOrderDeclined);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
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
      if (mounted) wbShowError(context, e.message);
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
                VendorOrderStatusPill(stage: order.stage),
                const Spacer(),
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
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
