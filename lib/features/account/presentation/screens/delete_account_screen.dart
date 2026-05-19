import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

/// Empathetic delete-account flow, pre-leave checklist, reason chips,
/// destructive confirm. UI-only: confirming signs the user out.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String _reason = '';

  static const _checklist = [
    'Use your wallet balance, it will be lost',
    'Complete any active orders',
    "Download your receipts, you won't access them after",
  ];
  static const _reasons = [
    'Too expensive',
    'Delivery too slow',
    'Not enough options',
    'Technical issues',
    'Other',
  ];

  void _confirm() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: WBSpacing.screenPadding,
          right: WBSpacing.screenPadding,
          top: WBSpacing.lg,
          bottom: MediaQuery.of(sheetCtx).padding.bottom + WBSpacing.xl,
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
              'Delete your account permanently?',
              style: WBTypography.page,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              'This cannot be undone.',
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: 'Yes, delete my account',
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.danger,
              onPressed: () {
                RoleController.instance.signOut();
                Navigator.of(sheetCtx).pop();
                context.go(AppRoutes.welcome);
              },
            ),
            const SizedBox(height: WBSpacing.sm + 4),
            WBButton(
              label: 'No, I want to stay',
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leaving us?', style: WBTypography.page),
                          Text(
                            "We're sad to see you go. Before you leave:",
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
                WBCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < _checklist.length; i++) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: WBIcon(WBIconName.bell, size: 14),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _checklist[i],
                                style: WBTypography.body.copyWith(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (i != _checklist.length - 1)
                          const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'Why are you leaving? (optional)',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in _reasons)
                      WBTag(
                        label: r,
                        active: _reason == r,
                        onTap: () => setState(() => _reason = r),
                      ),
                  ],
                ),
              ],
            ),
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
                    20,
                  ),
                  child: Column(
                    children: [
                      WBButton(
                        label: 'Yes, delete my account',
                        fullWidth: true,
                        size: WBButtonSize.lg,
                        variant: WBButtonVariant.danger,
                        onPressed: _confirm,
                      ),
                      const SizedBox(height: 10),
                      WBButton(
                        label: 'No, I want to stay',
                        fullWidth: true,
                        size: WBButtonSize.lg,
                        variant: WBButtonVariant.secondary,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
