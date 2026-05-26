import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/biometric_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_store.dart';
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
  String _bioLabel = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadBioLabel();
  }

  Future<void> _loadBioLabel() async {
    final label = await BiometricService.instance.label();
    if (!mounted) return;
    setState(() => _bioLabel = label);
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifier.text.trim().isEmpty || _password.text.isEmpty) {
      wbShowSnack(context, context.l10n.loginErrorEmpty);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.login(_identifier.text.trim(), _password.text);
      // Sync role / KYC status from the backend so returning users see their
      // actual approved/pending roles on the role-select screen.
      await RoleController.instance.syncFromApi();
      RoleController.instance.setRole(AppRole.customer);
      GuestModeController.instance.exit();
      // Register FCM token — fire-and-forget, non-critical.
      NotificationService.instance.registerToken();
      if (!mounted) return;
      await _offerBiometric();
      if (!mounted) return;
      context.go(AppRoutes.roleSelect);
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// After a password sign-in, offers to turn on biometric unlock so the
  /// next launch can skip the password.
  Future<void> _offerBiometric() async {
    final bio = BiometricService.instance;
    if (!await bio.isAvailable() || await bio.isEnabled()) return;
    if (!mounted) return;
    final enable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.loginBiometricOfferTitle),
        content: Text(context.l10n.loginBiometricOfferBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.loginBiometricNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.loginBiometricEnable),
          ),
        ],
      ),
    );
    if (enable == true) await bio.setEnabled(true);
  }

  /// Unlocks an existing session with Face ID / fingerprint. Needs a prior
  /// password sign-in (the refresh token is what gets unlocked).
  Future<void> _biometricSignIn() async {
    final bio = BiometricService.instance;
    if (!await bio.isAvailable()) {
      if (mounted) {
        wbShowSnack(context, context.l10n.loginBiometricNotAvailable);
      }
      return;
    }
    final refresh = TokenStore.instance.refreshToken;
    if (refresh == null || refresh.isEmpty || !await bio.isEnabled()) {
      if (mounted) {
        // TODO(i18n): key=loginBiometricFirstSignInHint
        wbShowSnack(
          context,
          'Sign in with your password once to turn on $_bioLabel.',
        );
      }
      return;
    }
    final ok = await bio.authenticate(reason: 'Sign in to WAWUBasket');
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      // TODO(i18n): key=loginBiometricFailed
      wbShowSnack(context, "Couldn't verify it's you — try your password.");
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
              const WBBackChip(),
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
              Row(
                children: [
                  const Expanded(child: WBDivider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: WBDivider()),
                ],
              ),
              const SizedBox(height: WBSpacing.md),
              _OutlineCta(
                // TODO(i18n): key=loginBiometricDynamic — the localised
                // string still hard-codes "Face ID"; surface the device
                // label until the next i18n pass.
                label: 'Use $_bioLabel',
                icon: _bioLabel == 'Fingerprint'
                    ? WBIconName.user
                    : WBIconName.user,
                onPressed: _biometricSignIn,
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

class _OutlineCta extends StatelessWidget {
  const _OutlineCta({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final WBIconName icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WBColors.bgPrimary,
          borderRadius: BorderRadius.circular(WBRadius.pill),
          border: Border.all(color: WBColors.bgDivider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WBIcon(icon, size: 18, color: WBColors.fgHeader),
            const SizedBox(width: 10),
            Text(
              label,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w500,
                color: WBColors.fgHeader,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
