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

/// Desktop-web layout for the login screen. Isolated from the mobile build:
/// it reuses the exact controllers, providers, API calls, error handling and
/// navigation that [LoginScreen] (mobile) uses, re-laid-out as a split brand /
/// form panel for wide windows.
class LoginDesktopScreen extends StatefulWidget {
  const LoginDesktopScreen({super.key});

  @override
  State<LoginDesktopScreen> createState() => _LoginDesktopScreenState();
}

class _LoginDesktopScreenState extends State<LoginDesktopScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Trim for the emptiness check (a spaces-only password should be rejected
    // here, not bounce off a 401), but send the password verbatim — it may
    // legitimately contain leading/trailing characters.
    if (_identifier.text.trim().isEmpty || _password.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.loginErrorEmpty);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.login(_identifier.text.trim(), _password.text);
      await RoleController.instance.syncFromApi();
      GuestModeController.instance.exit();
      NotificationService.instance.registerToken();

      if (!mounted) return;
      _navigateAfterAuth();
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (e) {
      // Unexpected (non-API) failure — surface a short cause so it isn't a
      // dead end while debugging, instead of a blanket "Something went wrong".
      if (mounted) wbShowSnack(context, "Couldn't sign in: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// After any successful auth, navigate to the user's last role home (if
  /// they're a returning user with an approved role) or to the role selector
  /// (first-time login or role no longer approved).
  void _navigateAfterAuth() {
    final ctrl = RoleController.instance;
    final lastRole = ctrl.role;
    final isReturning = ctrl.hasEverSignedIn;
    final status = ctrl.statusOf(lastRole);
    if (isReturning && status == RoleStatus.approved) {
      ctrl.setRole(lastRole);
      context.go(lastRole.homeRoute);
    } else {
      ctrl.setRole(AppRole.customer);
      context.go(AppRoutes.roleSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Hide the brand panel below ~1100px so the form never feels cramped.
          final showBrand = constraints.maxWidth >= 1100;
          return Row(
            children: [
              if (showBrand) const Expanded(child: _BrandPanel()),
              SizedBox(
                width: 520,
                child: _FormPanel(
                  identifier: _identifier,
                  password: _password,
                  obscure: _obscure,
                  busy: _busy,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onSubmit: _submit,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Left brand panel: dark surface, white wordmark, calm tagline. Desktop-only.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WBColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(WBSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WBWMark(size: 40, color: WBColors.bgPrimary),
            const SizedBox(height: WBSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                context.l10n.loginSubtitle,
                style: WBTypography.hero.copyWith(
                  color: WBColors.bgPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Right form panel: the real login content, vertically centered in a capped
/// reading column with a top-left back chip where the mobile screen had one.
class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.identifier,
    required this.password,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController identifier;
  final TextEditingController password;
  final bool obscure;
  final bool busy;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.screenPadding,
          vertical: WBSpacing.xxl,
        ),
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxReading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (context.canPop()) ...[
                const WBBackChip(),
                const SizedBox(height: WBSpacing.xl),
              ],
              Text(context.l10n.loginTitle, style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                context.l10n.loginSubtitle,
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBInput(
                label: context.l10n.loginPhoneLabel,
                controller: identifier,
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.md),
              WBInput(
                label: context.l10n.loginPasswordLabel,
                controller: password,
                leadingIcon: WBIconName.card,
                obscureText: obscure,
                trailing: TextButton(
                  onPressed: onToggleObscure,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    obscure ? 'Show' : 'Hide',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    context.l10n.loginForgotPassword,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: context.l10n.signIn,
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: busy,
                onPressed: onSubmit,
              ),
              const SizedBox(height: WBSpacing.xl),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.signup),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: [
                        TextSpan(text: '${context.l10n.loginSignupLink} '),
                        TextSpan(
                          text: context.l10n.signUp,
                          style: TextStyle(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
