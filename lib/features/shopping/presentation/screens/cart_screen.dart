import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/cart_controller.dart';
import '../widgets/sticky_action_bar.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    if (cart.loading) {
      return _scaffold(
        context,
        const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
      );
    }
    if (cart.error != null) {
      return _scaffold(
        context,
        _CenterHint(
          text: cart.error!,
          actionLabel: 'Try again',
          onAction: controller.load,
        ),
      );
    }
    if (cart.items.isEmpty) {
      return _scaffold(
        context,
        const _CenterHint(text: 'Your basket is empty.'),
      );
    }

    final lines = cart.items;
    final subtotal = controller.subtotal;
    const delivery = 600;
    const serviceFee = 200;
    final total = subtotal + delivery + serviceFee;
    final vendorName = lines.first.product.vendorName.isEmpty
        ? 'Your vendor'
        : lines.first.product.vendorName;

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                140,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Your basket', style: WBTypography.page),
                    ),
                    Text(
                      '${controller.itemCount} items',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                WBCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(WBSpacing.md - 2),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: WBColors.bgSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                vendorName,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const WBDivider(),
                      for (var i = 0; i < lines.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.all(WBSpacing.md - 2),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: WBNetworkImage(
                                    url: lines[i].product.imageUrl,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lines[i].product.name,
                                      style: WBTypography.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (lines[i].note != null &&
                                        lines[i].note!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        lines[i].note!,
                                        style: WBTypography.caption.copyWith(
                                          color: WBColors.fgSecondary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      lines[i].totalLabel,
                                      style: WBTypography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WBQtyStepper(
                                value: lines[i].quantity,
                                onChanged: (q) => controller.setQuantity(
                                  lines[i].product.id,
                                  q,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i != lines.length - 1) const WBDivider(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                WBCard(
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: 'Subtotal', value: '₦${_n(subtotal)}'),
                      const SizedBox(height: 12),
                      const _SummaryRow(
                          label: 'Delivery fee', value: '₦600'),
                      const SizedBox(height: 12),
                      const _SummaryRow(
                          label: 'Service fee', value: '₦200'),
                      const SizedBox(height: 14),
                      const WBDivider(),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        label: 'Total',
                        value: '₦${_n(total)}',
                        emphasised: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionBar(
              child: WBButton(
                label: 'Proceed to checkout',
                fullWidth: true,
                size: WBButtonSize.lg,
                trailing: Text(
                  '₦${_n(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => context.push(AppRoutes.checkout),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scaffold(BuildContext context, Widget body) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                0,
              ),
              child: Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Text('Your basket', style: WBTypography.page),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
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

class _CenterHint extends StatelessWidget {
  const _CenterHint({required this.text, this.actionLabel, this.onAction});
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WBSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              WBButton(
                label: actionLabel!,
                size: WBButtonSize.sm,
                variant: WBButtonVariant.secondary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });
  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final style = emphasised
        ? WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          )
        : WBTypography.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: WBColors.fgHeader)),
      ],
    );
  }
}
