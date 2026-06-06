import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../data/profile_api.dart';

/// Desktop-web layout for the empathetic delete-account flow. Isolated from the
/// mobile build: re-lays the same checklist, reason chips and destructive
/// confirm into a centered settings column, reusing the identical controllers,
/// providers and l10n keys.
class DeleteAccountDesktopScreen extends StatefulWidget {
  const DeleteAccountDesktopScreen({super.key});

  @override
  State<DeleteAccountDesktopScreen> createState() =>
      _DeleteAccountDesktopScreenState();
}

class _DeleteAccountDesktopScreenState
    extends State<DeleteAccountDesktopScreen> {
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
                sheetCtx.l10n.deleteAccountConfirmPermanent,
                style: WBTypography.page,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WBSpacing.sm),
              Text(
                sheetCtx.l10n.deleteAccountCannotUndo,
                textAlign: TextAlign.center,
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: sheetCtx.l10n.deleteAccountYes,
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
                            wbShowError(sheetCtx, e.message);
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
                label: sheetCtx.l10n.deleteAccountNo,
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
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.screenPadding,
          vertical: WBSpacing.xl,
        ),
        child: WBMaxWidth(
          maxWidth: 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: WBBackChip(onPressed: () => context.pop()),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.deleteAccountLeavingTitle,
                style: WBTypography.page,
              ),
              const SizedBox(height: WBSpacing.xs),
              Text(
                context.l10n.deleteAccountLeavingBody,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                ),
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
                context.l10n.deleteAccountWhyLeaving,
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
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: context.l10n.deleteAccountYes,
                fullWidth: true,
                size: WBButtonSize.lg,
                variant: WBButtonVariant.danger,
                onPressed: _confirm,
              ),
              const SizedBox(height: 10),
              WBButton(
                label: context.l10n.deleteAccountNo,
                fullWidth: true,
                size: WBButtonSize.lg,
                variant: WBButtonVariant.secondary,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
