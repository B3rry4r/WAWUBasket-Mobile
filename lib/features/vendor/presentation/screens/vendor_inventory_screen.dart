import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorInventoryScreen extends StatelessWidget {
  const VendorInventoryScreen({super.key});

  static const _items = [
    (name: 'Long grain rice', stock: '48 kg', threshold: '10 kg', status: 'Healthy', kind: WBStatusKind.success),
    (name: 'Tomatoes (basket)', stock: '6', threshold: '8', status: 'Low', kind: WBStatusKind.warning),
    (name: 'Goat meat', stock: '0 kg', threshold: '5 kg', status: 'Out', kind: WBStatusKind.error),
    (name: 'Suya pepper', stock: '12 packs', threshold: '5 packs', status: 'Healthy', kind: WBStatusKind.success),
    (name: 'Plantain (bunch)', stock: '4', threshold: '6', status: 'Low', kind: WBStatusKind.warning),
  ];

  @override
  Widget build(BuildContext context) {
    final lowOrOut = [
      for (final i in _items)
        if (i.kind != WBStatusKind.success) i,
    ];
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
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
                      Text("What's in stock?", style: WBTypography.page),
                      Text(
                        'Keep your shelves honest.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            if (lowOrOut.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WBColors.surfaceDark,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const WBIcon(
                        WBIconName.bell,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${lowOrOut.length} items need restocking',
                        style: WBTypography.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.md),
            ],
            for (final i in _items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WBCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i.name,
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'In stock: ${i.stock} · low at ${i.threshold}',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      WBStatusPill(label: i.status, kind: i.kind),
                      const SizedBox(width: 8),
                      WBButton(
                        label: 'Update',
                        size: WBButtonSize.sm,
                        variant: WBButtonVariant.secondary,
                        onPressed: () =>
                            wbShowSnack(context, '${i.name} updated'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
