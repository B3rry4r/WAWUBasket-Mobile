import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  static const _items = [
    (name: 'Jollof rice & grilled chicken', qty: 2, total: '₦9,000'),
    (name: 'Suya platter', qty: 1, total: '₦4,800'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
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
                      Text('Receipt', style: WBTypography.page),
                      Text(
                        'Order #WBK-8821',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const WBStatusPill(
                  label: 'Delivered',
                  kind: WBStatusKind.success,
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
                  Text(
                    'Mama Cass Kitchen',
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Delivered · Mon 18 May · 12:47 PM',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const WBDivider(),
                  const SizedBox(height: 14),
                  for (final it in _items) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${it.name}  × ${it.qty}',
                            style: WBTypography.body.copyWith(fontSize: 14),
                          ),
                        ),
                        Text(
                          it.total,
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
                  _Line(label: 'Subtotal', value: '₦13,800'),
                  const SizedBox(height: 8),
                  _Line(label: 'Delivery', value: '₦600'),
                  const SizedBox(height: 8),
                  _Line(label: 'Service fee', value: '₦200'),
                  const SizedBox(height: 14),
                  const WBDivider(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total paid',
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₦14,600',
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
            const SizedBox(height: WBSpacing.md),
            Container(
              padding: const EdgeInsets.all(WBSpacing.md + 2),
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: WBIconName.pin,
                    label: 'Delivered to',
                    value: '12 Adeola Odeku St, Victoria Island',
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: WBIconName.card,
                    label: 'Paid with',
                    value: 'Visa  •••• 4218',
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: WBIconName.bike,
                    label: 'Rider',
                    value: 'Tunde · 4.9 ★',
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Reorder',
              size: WBButtonSize.lg,
              fullWidth: true,
              trailingIcon: WBIconName.arrowRight,
              onPressed: () {
                wbShowSnack(context, 'Items added to your basket');
                context.go(AppRoutes.cart);
              },
            ),
            const SizedBox(height: 10),
            WBButton(
              label: 'Report an issue',
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () => context.push(AppRoutes.support),
            ),
          ],
        ),
      ),
    );
  }
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final WBIconName icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: WBColors.bgSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: WBIcon(icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgPlaceholder,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
