import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/biometric_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/data/auth_api.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';

/// Desktop-web layout for account security: change password + biometric login
/// toggle. Re-lays the mobile [SecurityScreen] into a centered settings column
/// inside the customer web chrome. Behavior, toggles, actions, and l10n keys
/// mirror the mobile screen exactly.
class SecurityDesktopScreen extends StatefulWidget {
  const SecurityDesktopScreen({super.key});

  @override
  State<SecurityDesktopScreen> createState() => _SecurityDesktopScreenState();
}

class _SecurityDesktopScreenState extends State<SecurityDesktopScreen> {
  bool _biometric = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final enabled = await BiometricService.instance.isEnabled();
    if (!mounted) return;
    setState(() => _biometric = enabled);
  }

  Future<void> _toggleBiometric(bool value) async {
    await BiometricService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _biometric = value);
    wbShowSnack(
      context,
      value ? 'Biometric unlock enabled' : 'Biometric unlock disabled',
    );
  }

  void _changePassword() {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    var busy = false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
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
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + WBSpacing.xl,
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
              Text(context.l10n.securityChangePassword,
                  style: WBTypography.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: WBSpacing.lg),
              WBInput(label: context.l10n.securityCurrentPassword, controller: current, obscureText: true),
              const SizedBox(height: WBSpacing.md),
              WBInput(label: context.l10n.securityNewPassword, controller: next, obscureText: true),
              const SizedBox(height: WBSpacing.md),
              WBInput(label: context.l10n.securityConfirmNewPassword, controller: confirm, obscureText: true),
              const SizedBox(height: WBSpacing.lg),
              WBButton(
                label: context.l10n.securityUpdatePassword,
                fullWidth: true,
                size: WBButtonSize.lg,
                loading: busy,
                onPressed: () async {
                  if (next.text != confirm.text) {
                    wbShowSnack(sheetCtx, sheetCtx.l10n.securityPasswordMismatch);
                    return;
                  }
                  if (next.text.length < 8) {
                    wbShowSnack(sheetCtx, sheetCtx.l10n.securityPasswordShort);
                    return;
                  }
                  setSheet(() => busy = true);
                  try {
                    await AuthApi.instance.changePassword(current.text, next.text);
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                    if (mounted) wbShowSnack(context, context.l10n.securityPasswordUpdated);
                  } on ApiException catch (e) {
                    if (sheetCtx.mounted) wbShowError(sheetCtx, e.message);
                  } finally {
                    if (sheetCtx.mounted) setSheet(() => busy = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      current.dispose();
      next.dispose();
      confirm.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.screenPadding,
          vertical: WBSpacing.xl,
        ),
        children: [
          WBMaxWidth(
            maxWidth: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: WBBackChip(onPressed: () => context.pop()),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(context.l10n.securityTitle, style: WBTypography.page),
                Text(
                  context.l10n.securitySubtitle,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                GestureDetector(
                  onTap: _changePassword,
                  behavior: HitTestBehavior.opaque,
                  child: WBCard(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: WBColors.bgSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const WBIcon(WBIconName.card, size: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.securityChangePassword,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.securityChangePasswordSub,
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const WBIcon(
                          WBIconName.chevronRight,
                          size: 16,
                          color: WBColors.fgPlaceholder,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                WBCard(
                  padding: EdgeInsets.zero,
                  child: _ToggleRow(
                    label: context.l10n.securityBiometric,
                    sub: context.l10n.securityBiometricSub,
                    value: _biometric,
                    onChanged: _toggleBiometric,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: WBColors.surfaceDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
