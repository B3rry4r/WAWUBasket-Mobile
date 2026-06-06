import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../../data/auth_api.dart';

/// Final step of password recovery. [identifier] + [code] arrive from the
/// OTP screen; this screen only sets the new password.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.identifier,
    required this.code,
  });

  final String identifier;
  final String code;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  List<(bool, String)> get _rules {
    final p = _password.text;
    return [
      (p.length >= 8, 'At least 8 characters'),
      (p.contains(RegExp(r'[A-Z]')), 'One uppercase letter'),
      (p.contains(RegExp(r'[0-9]')), 'One number'),
      (p.contains(RegExp(r'[^A-Za-z0-9]')), 'One symbol'),
    ];
  }

  Future<void> _save() async {
    if (_password.text.length < 8) {
      wbShowSnack(context, context.l10n.resetErrorLength);
      return;
    }
    if (_password.text != _confirm.text) {
      wbShowSnack(context, context.l10n.resetErrorMismatch);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.resetPassword(
        widget.identifier,
        widget.code,
        _password.text,
      );
      // Reset returns a live session — complete the post-auth sequence so the
      // user lands fully signed in (not still flagged as a guest).
      await RoleController.instance.syncFromApi();
      RoleController.instance.setRole(AppRole.customer);
      GuestModeController.instance.exit();
      NotificationService.instance.registerToken();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (e) {
      // Non-API failure — show the cause instead of failing silently.
      if (mounted) wbShowSnack(context, "Couldn't reset password: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const WBBackChip(),
              const SizedBox(height: WBSpacing.xl - 4),
              Text(context.l10n.resetTitle, style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              Text(
                context.l10n.resetSubtitle,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: WBSpacing.lg + 4),
              WBInput(
                label: context.l10n.resetPasswordLabel,
                controller: _password,
                obscureText: _obscure,
                trailing: TextButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    _obscure ? 'Show' : 'Hide',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: context.l10n.resetConfirmLabel,
                controller: _confirm,
                obscureText: _obscure,
              ),
              const SizedBox(height: WBSpacing.lg),
              Container(
                padding: const EdgeInsets.all(WBSpacing.md),
                decoration: BoxDecoration(
                  color: WBColors.bgSecondary,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Column(
                  children: [
                    for (final (ok, label) in _rules) ...[
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ok
                                  ? WBColors.surfaceDark
                                  : WBColors.bgDivider,
                            ),
                            alignment: Alignment.center,
                            child: ok
                                ? const WBIcon(
                                    WBIconName.check,
                                    size: 11,
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  )
                                : Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: WBColors.bgPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: WBTypography.caption.copyWith(
                              color: ok
                                  ? WBColors.fgHeader
                                  : WBColors.fgPlaceholder,
                              fontWeight:
                                  ok ? FontWeight.w500 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (label != _rules.last.$2)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              WBButton(
                label: context.l10n.resetButton,
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: _busy,
                onPressed: _save,
              ),
              const SizedBox(height: WBSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
