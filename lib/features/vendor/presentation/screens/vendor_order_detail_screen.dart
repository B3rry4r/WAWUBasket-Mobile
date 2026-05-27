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

/// Full detail for one order: items × modifiers, customer info, address,
/// special instructions, contact rider, print ticket, plus the next-stage
/// action ribbon at the bottom that walks the order through the state
/// machine in [OrderStage].
class VendorOrderDetailScreen extends StatefulWidget {
  const VendorOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<VendorOrderDetailScreen> createState() =>
      _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: ValueListenableBuilder(
        valueListenable: VendorOrdersController.instance.orders,
        builder: (_, _, _) {
          final order = VendorOrdersController.instance.byId(widget.orderId);
          if (order == null) return _NotFound(onBack: () => context.pop());
          return _Body(order: order);
        },
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(WBSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WBBackChip(onPressed: onBack),
            const SizedBox(height: WBSpacing.xl),
            Text(context.l10n.vendorOrderNotFound, style: WBTypography.page),
            const SizedBox(height: WBSpacing.sm),
            Text(
              'It may have been cancelled or archived.',
              style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.order});
  final VendorOrder order;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _advancing = false;
  bool _declining = false;

  Future<void> _advance() async {
    final order = widget.order;
    final next = order.stage.advance;
    if (next == null) return;
    if (next.next == OrderStage.handover && order.riderType == null) {
      final picked = await _showRiderTypeSheet();
      if (picked == null) return;
      order.riderType = picked;
    }
    setState(() => _advancing = true);
    try {
      await VendorOrdersController.instance.advance(order.id);
      if (mounted) wbShowSnack(context, '${order.id} · ${next.next.label}');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  Future<RiderType?> _showRiderTypeSheet() {
    final order = widget.order;
    final suggestion = _suggestRiderType(order);
    return showModalBottomSheet<RiderType>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) => _RiderTypeSheet(
        order: order,
        suggestion: suggestion,
      ),
    );
  }

  RiderType _suggestRiderType(VendorOrder o) {
    if (o.items.length >= 4 || o.subtotal >= 15000) return RiderType.car;
    if (o.items.length == 1 && o.subtotal < 3000) return RiderType.bicycle;
    return RiderType.motorbike;
  }

  Future<void> _decline() async {
    setState(() => _declining = true);
    try {
      await VendorOrdersController.instance.decline(widget.order.id);
      if (mounted) wbShowSnack(context, '${widget.order.id} declined');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _declining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final next = order.stage.advance;
    final busy = _advancing || _declining;

    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              12,
              WBSpacing.screenPadding,
              160,
            ),
            children: [
              Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${order.id}', style: WBTypography.page),
                        Text(
                          '${order.customerName} · ${order.placedMinsAgo} min ago',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  VendorOrderStatusPill(stage: order.stage),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),

              // Items
              _SectionLabel('Items'),
              const SizedBox(height: 10),
              WBCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < order.items.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: _ItemRow(item: order.items[i]),
                      ),
                      if (i != order.items.length - 1) const WBDivider(),
                    ],
                  ],
                ),
              ),

              // Special instructions
              if (order.specialInstructions.isNotEmpty) ...[
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Special instructions'),
                const SizedBox(height: 10),
                WBCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: WBIcon(WBIconName.message, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          order.specialInstructions,
                          style: WBTypography.body.copyWith(
                            fontSize: 14,
                            height: 1.45,
                            color: WBColors.fgHeader,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Customer + address
              const SizedBox(height: WBSpacing.lg),
              _SectionLabel('Customer'),
              const SizedBox(height: 10),
              WBCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: WBColors.bgSoft,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const WBIcon(WBIconName.user, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.customerPhone,
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        WBButton(
                          label: 'Call',
                          size: WBButtonSize.sm,
                          variant: WBButtonVariant.secondary,
                          trailingIcon: WBIconName.phone,
                          onPressed: () =>
                              wbShowSnack(context, context.l10n.vendorCallingCustomer),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const WBDivider(),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: WBIcon(WBIconName.pin, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order.address,
                            style: WBTypography.body.copyWith(
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rider, only once one's been assigned
              if (order.riderName != null) ...[
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Rider'),
                const SizedBox(height: 10),
                WBCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: WBColors.bgSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(WBIconName.bike, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.riderName!,
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.riderEta ?? 'Assigned',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      WBButton(
                        label: 'Message',
                        size: WBButtonSize.sm,
                        variant: WBButtonVariant.secondary,
                        onPressed: () => context.push(
                          Uri(
                            path: AppRoutes.chatRider,
                            queryParameters: {
                              'orderId': order.id,
                              'title': order.riderName!,
                            },
                          ).toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Totals
              const SizedBox(height: WBSpacing.lg),
              _SectionLabel('Totals'),
              const SizedBox(height: 10),
              WBCard(
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: wbNaira(order.subtotal)),
                    const SizedBox(height: 6),
                    _TotalRow(
                      label: 'Service fee',
                      value: wbNaira(order.serviceFee),
                    ),
                    const SizedBox(height: 6),
                    _TotalRow(
                      label: 'Delivery fee',
                      value: wbNaira(order.deliveryFee),
                    ),
                    const SizedBox(height: 10),
                    const WBDivider(),
                    const SizedBox(height: 10),
                    _TotalRow(
                      label: 'Total',
                      value: wbNaira(order.total),
                      emphasised: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: WBSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: WBButton(
                      label: 'Print ticket',
                      variant: WBButtonVariant.secondary,
                      onPressed: () =>
                          wbShowSnack(context, context.l10n.vendorTicketSent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: WBButton(
                      label: 'Report issue',
                      variant: WBButtonVariant.secondary,
                      onPressed: () =>
                          wbShowSnack(context, context.l10n.vendorIssueSent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Sticky action ribbon. Always present so the vendor sees the next
        // forward step and (while pending) the decline action.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                0,
                WBSpacing.screenPadding,
                18,
              ),
              child: next == null
                  ? WBButton(
                      label: order.stage == OrderStage.declined
                          ? 'Order declined'
                          : 'Order complete',
                      fullWidth: true,
                      size: WBButtonSize.lg,
                      disabled: true,
                      onPressed: null,
                    )
                  : Row(
                      children: [
                        if (order.stage == OrderStage.pending) ...[
                          Expanded(
                            child: WBButton(
                              label: context.l10n.vendorHomeDecline,
                              size: WBButtonSize.lg,
                              variant: WBButtonVariant.secondary,
                              loading: _declining,
                              onPressed: busy ? null : _decline,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: 2,
                          child: WBButton(
                            label: next.label,
                            fullWidth: true,
                            size: WBButtonSize.lg,
                            trailingIcon: WBIconName.arrowRight,
                            loading: _advancing,
                            onPressed: busy ? null : _advance,
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
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: WBTypography.cardTitle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '×${item.qty}',
            style: WBTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (item.mods.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.mods.join(' · '),
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '“${item.note}”',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          wbNaira(item.lineTotal),
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });
  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: WBTypography.body.copyWith(
            fontSize: emphasised ? 15 : 14,
            color: emphasised ? WBColors.fgHeader : WBColors.fgSecondary,
            fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontSize: emphasised ? 17 : 14,
            fontWeight: emphasised ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Picks a [RiderType] for an order being handed off. Pre-selects a
/// sensible default based on the basket size / value.
class _RiderTypeSheet extends StatefulWidget {
  const _RiderTypeSheet({required this.order, required this.suggestion});
  final VendorOrder order;
  final RiderType suggestion;

  @override
  State<_RiderTypeSheet> createState() => _RiderTypeSheetState();
}

class _RiderTypeSheetState extends State<_RiderTypeSheet> {
  late RiderType _picked = widget.suggestion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + WBSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          Text(
            'Pick a rider type',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on ${widget.order.items.length} item${widget.order.items.length == 1 ? '' : 's'}, we suggest ${widget.suggestion.label.toLowerCase()}.',
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.lg),
          for (final t in RiderType.values) ...[
            _RiderTypeRow(
              type: t,
              selected: _picked == t,
              suggested: widget.suggestion == t,
              onTap: () => setState(() => _picked = t),
            ),
            if (t != RiderType.values.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Request ${_picked.label.toLowerCase()} rider',
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: () => Navigator.of(context).pop(_picked),
          ),
        ],
      ),
    );
  }
}

class _RiderTypeRow extends StatelessWidget {
  const _RiderTypeRow({
    required this.type,
    required this.selected,
    required this.suggested,
    required this.onTap,
  });
  final RiderType type;
  final bool selected;
  final bool suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WBMotion.base,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? WBColors.surfaceDark : WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          border: Border.all(
            color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.12)
                    : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                WBIconName.bike,
                size: 18,
                color: selected ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        type.label,
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: selected ? Colors.white : WBColors.fgHeader,
                        ),
                      ),
                      if (suggested) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.18)
                                : WBColors.bgSoft,
                            borderRadius:
                                BorderRadius.circular(WBRadius.pill),
                          ),
                          child: Text(
                            'Suggested',
                            style: WBTypography.label.copyWith(
                              color: selected
                                  ? Colors.white
                                  : WBColors.fgSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.hint,
                    style: WBTypography.caption.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.6)
                          : WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
