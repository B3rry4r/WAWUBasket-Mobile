import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../auth/application/role_controller.dart';
import '../../data/profile_api.dart';

/// Empathetic delete-account flow, pre-leave checklist, reason chips,
/// destructive confirm. UI-only: confirming signs the user out.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String _reason = '';
  bool _deleting = false;

  List<String> _checklist(BuildContext context) => [
    context.l10n.deleteAccountCheck1,
    context.l10n.deleteAccountCheck2,
    context.l10n.deleteAccountCheck3,
  ];

  List<String> _reasons(BuildContext context) => [
    context.l10n.deleteAccountReasonExpensive,
    context.l10n.deleteAccountReasonSlow,
    context.l10n.deleteAccountReasonOptions,
    context.l10n.deleteAccountReasonTech,
    context.l10n.deleteAccountReasonOther,
  ];

  void _confirm() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Padding(
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
                loading: _deleting,
                onPressed: _deleting
                    ? null
                    : () async {
                        setSheet(() => _deleting = true);
                        try {
                          await ProfileApi.instance.deleteAccount(
                            reason: _reason.isEmpty ? null : _reason,
                          );
                        } on ApiException catch (e) {
                          if (sheetCtx.mounted) {
                            wbShowSnack(sheetCtx, e.message);
                          }
                          setSheet(() => _deleting = false);
                          return;
                        }
                        RoleController.instance.signOut();
                        if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                        if (mounted) context.go(AppRoutes.welcome);
                      },
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              WBButton(
                label: 'No, I want to stay',
                size: WBButtonSize.lg,
                fullWidth: true,
                variant: WBButtonVariant.secondary,
                onPressed: _deleting ? null : () => Navigator.of(sheetCtx).pop(),
              ),
            ],
          ),
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
                      for (var i = 0; i < _checklist(context).length; i++) ...[
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
                                _checklist(context)[i],
                                style: WBTypography.body.copyWith(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (i != _checklist(context).length - 1)
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
                    for (final r in _reasons(context))
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
