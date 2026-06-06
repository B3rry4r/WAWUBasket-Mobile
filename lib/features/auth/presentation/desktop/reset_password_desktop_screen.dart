import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../../data/auth_api.dart';

/// Desktop-web layout for the final password-recovery step. Mirrors
/// [ResetPasswordScreen] exactly — same [identifier] + [code] inputs, same
/// API call, validation, error handling and navigation — re-laid-out as a
/// split brand/form panel for wide windows. Isolated from the mobile build.
class ResetPasswordDesktopScreen extends StatefulWidget {
  const ResetPasswordDesktopScreen({
    super.key,
    required this.identifier,
    required this.code,
  });

  final String identifier;
  final String code;

  @override
  State<ResetPasswordDesktopScreen> createState() =>
      _ResetPasswordDesktopScreenState();
}

class _ResetPasswordDesktopScreenState
    extends State<ResetPasswordDesktopScreen> {
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
      if (mounted) wbShowSnack(context, e.message);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LEFT — brand panel. Collapses below ~1100px so the form stays
            // comfortable in narrower desktop windows.
            LayoutBuilder(
              builder: (context, _) {
                final showBrand = MediaQuery.sizeOf(context).width >= 1100;
                if (!showBrand) return const SizedBox.shrink();
                return const Expanded(child: _BrandPanel());
              },
            ),
            // RIGHT — fixed-width form column, vertically centered.
            SizedBox(
              width: 520,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WBSpacing.screenPadding,
                    vertical: WBSpacing.xl,
                  ),
                  child: WBMaxWidth(
                    maxWidth: WBBreakpoints.maxReading,
                    alignment: Alignment.center,
                    child: _buildForm(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                        color: ok ? WBColors.surfaceDark : WBColors.bgDivider,
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
                        fontWeight: ok ? FontWeight.w500 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (label != _rules.last.$2) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: context.l10n.resetButton,
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          loading: _busy,
          onPressed: _save,
        ),
      ],
    );
  }
}

/// Calm, minimal brand panel shown on the left of the desktop split layout.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WBColors.surfaceDark,
      padding: const EdgeInsets.all(WBSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WBWordmark(height: 40, color: Colors.white),
          const SizedBox(height: WBSpacing.lg),
          Text(
            context.l10n.splashTagline,
            style: WBTypography.section.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
