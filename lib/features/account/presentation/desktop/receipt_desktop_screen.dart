import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../../shopping/data/orders_api.dart';
import '../../../shopping/domain/models/order.dart';

/// Desktop-web layout for the order receipt. Isolated from the mobile build:
/// re-lays the same data and logic into a centered, print-friendly document
/// column inside [CustomerWebScaffold]. Mirrors `ReceiptScreen` exactly for
/// data loading, state, error handling, money formatting, and navigation.
class ReceiptDesktopScreen extends StatefulWidget {
  const ReceiptDesktopScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<ReceiptDesktopScreen> createState() => _ReceiptDesktopScreenState();
}

class _ReceiptDesktopScreenState extends State<ReceiptDesktopScreen> {
  OrderModel? _order;
  String? _error;
  bool _reordering = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      setState(() => _error = context.l10n.receiptNotFound);
      return;
    }
    try {
      final res = await OrdersApi.instance.orderDetail(id);
      if (!mounted) return;
      setState(() => _order = OrderModel.fromJson(res));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _reorder() async {
    final order = _order;
    if (order == null) return;
    setState(() => _reordering = true);
    try {
      await OrdersApi.instance.reorder(order.id);
      if (!mounted) return;
      wbShowSnack(context, context.l10n.orderHistoryReordered);
      context.go(AppRoutes.cart);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _reordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
        child: Center(
          child: WBMaxWidth(
            maxWidth: 720,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.screenPadding,
              ),
              child: _error != null
                  ? _errorState(_error!)
                  : _order == null
                      ? _loadingState()
                      : _body(_order!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(height: 120),
        const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorState(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(height: 96),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: WBTypography.body
                    .copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: 14),
              WBButton(
                label: context.l10n.actionRetry,
                size: WBButtonSize.sm,
                variant: WBButtonVariant.secondary,
                onPressed: _load,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(height: WBSpacing.md),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.receiptTitle, style: WBTypography.page),
                  Text(
                    'Order ${order.shortId}',
                    style: WBTypography.caption
                        .copyWith(color: WBColors.fgSecondary),
                  ),
                ],
              ),
            ),
            WBStatusPill(
              label: order.statusLabel,
              kind: order.isCancelled
                  ? WBStatusKind.error
                  : order.isDelivered
                      ? WBStatusKind.success
                      : WBStatusKind.info,
            ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        Container(
          padding: const EdgeInsets.all(WBSpacing.md + 2),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: WBShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in order.items) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${it.title}  × ${it.quantity}',
                        style: WBTypography.body.copyWith(fontSize: 14),
                      ),
                    ),
                    Text(
                      '₦${_n(it.lineTotal)}',
                      style: WBTypography.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              const WBDivider(),
              const SizedBox(height: 14),
              _Line(
                label: context.l10n.receiptSubtotal,
                value: '₦${_n(order.subtotal)}',
              ),
              const SizedBox(height: 8),
              _Line(
                label: context.l10n.receiptDelivery,
                value: '₦${_n(order.deliveryFee)}',
              ),
              const SizedBox(height: 8),
              _Line(
                label: context.l10n.receiptServiceFee,
                value: '₦${_n(order.serviceFee)}',
              ),
              const SizedBox(height: 14),
              const WBDivider(),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.receiptTotalPaid,
                    style: WBTypography.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₦${_n(order.total)}',
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        WBButton(
          label: context.l10n.receiptReorder,
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          loading: _reordering,
          onPressed: _reorder,
        ),
        const SizedBox(height: 10),
        WBButton(
          label: context.l10n.receiptReportIssue,
          size: WBButtonSize.lg,
          fullWidth: true,
          variant: WBButtonVariant.secondary,
          onPressed: () => context.push(AppRoutes.support),
        ),
      ],
    );
  }
}

String _n(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WBTypography.secondary),
        Text(
          value,
          style: WBTypography.secondary.copyWith(
            color: WBColors.fgHeader,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
