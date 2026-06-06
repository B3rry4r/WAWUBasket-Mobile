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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      // Real API failure — show the server's reason (e.g. "Incorrect password",
      // "No account found with this email or phone number.").
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: WBSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              if (context.canPop()) const WBBackChip(),
              if (!context.canPop()) const SizedBox(height: 44),
              const SizedBox(height: WBSpacing.xl),
              Text(context.l10n.loginTitle, style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                context.l10n.loginSubtitle,
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBInput(
                label: context.l10n.loginPhoneLabel,
                controller: _identifier,
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.md),
              WBInput(
                label: context.l10n.loginPasswordLabel,
                controller: _password,
                leadingIcon: WBIconName.card,
                obscureText: _obscure,
                trailing: TextButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
              const Spacer(),
              WBButton(
                label: context.l10n.signIn,
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: WBSpacing.md),
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
              const SizedBox(height: WBSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
