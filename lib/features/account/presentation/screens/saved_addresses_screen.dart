import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  static const _addresses = [
    (
      label: 'Home',
      line: '12 Adeola Odeku St, Victoria Island',
      note: 'Apt 4B · Use the gate on Akin Adesola',
      isDefault: true,
    ),
    (
      label: 'Office',
      line: '8 Karimu Kotun St, Victoria Island',
      note: 'Reception desk, ask for Brooks',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
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
                Text('Saved addresses', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Add address',
              icon: WBIconName.plus,
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () => context.push(AppRoutes.addAddress),
            ),
            const SizedBox(height: WBSpacing.lg),
            for (final a in _addresses) ...[
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
                          child: const WBIcon(WBIconName.pin, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            a.label,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (a.isDefault)
                          const WBStatusPill(
                            label: 'Default',
                            kind: WBStatusKind.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      a.line,
                      style: WBTypography.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.note,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        WBButton(
                          label: 'Edit',
                          size: WBButtonSize.sm,
                          variant: WBButtonVariant.secondary,
                          onPressed: () => context.push(AppRoutes.addAddress),
                        ),
                        const SizedBox(width: 8),
                        if (!a.isDefault)
                          WBButton(
                            label: 'Make default',
                            size: WBButtonSize.sm,
                            variant: WBButtonVariant.ghost,
                            onPressed: () => wbShowSnack(
                              context,
                              '${a.label} set as default',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
