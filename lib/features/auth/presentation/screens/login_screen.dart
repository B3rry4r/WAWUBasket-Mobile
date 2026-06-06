import 'package:flutter/foundation.dart' show kIsWeb;
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
  bool _showBioButton = false;

  @override
  void initState() {
    super.initState();
    _loadBioLabel();
    _resolveBioButtonVisibility();
    _maybeAutoTriggerBiometric();
  }

  /// Show the biometric button only when: not web, device supports it, AND
  /// a refresh token is already stored (returning user — never on first sign-in).
  Future<void> _resolveBioButtonVisibility() async {
    if (kIsWeb) return;
    final hasSession = (TokenStore.instance.refreshToken ?? '').isNotEmpty;
    if (!hasSession) return;
    final available = await BiometricService.instance.isAvailable();
    if (!mounted) return;
    setState(() => _showBioButton = available);
  }

  /// On app resume, auto-prompt biometrics if the user has it enabled and a
  /// refresh token is on disk (returning signed-in user).
  Future<void> _maybeAutoTriggerBiometric() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final bio = BiometricService.instance;
    final hasRefresh = (TokenStore.instance.refreshToken ?? '').isNotEmpty;
    if (!hasRefresh) return;
    if (!await bio.isAvailable() || !await bio.isEnabled()) return;
    if (!mounted) return;
    _biometricSignIn();
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
      await _offerBiometric();
      if (!mounted) return;
      await _resolveBioButtonVisibility();
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

  /// After a password sign-in, offers to turn on biometric unlock so the
  /// next launch can skip the password. Never shown on web.
  Future<void> _offerBiometric() async {
    if (kIsWeb) return;
    final bio = BiometricService.instance;
    // Don't re-offer if already enabled OR if the user previously declined —
    // the offer-dismissed flag persists so we never nag on every sign-in.
    if (!await bio.isAvailable() ||
        await bio.isEnabled() ||
        await bio.offerDismissed()) {
      return;
    }
    if (!mounted) return;
    final enable = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WBRadius.sheet),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.lg,
          WBSpacing.screenPadding,
          WBSpacing.xl,
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
              context.l10n.loginBiometricOfferTitle,
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              context.l10n.loginBiometricOfferBody,
              style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: context.l10n.loginBiometricEnable,
              fullWidth: true,
              size: WBButtonSize.lg,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            const SizedBox(height: WBSpacing.sm),
            WBButton(
              label: context.l10n.loginBiometricNotNow,
              fullWidth: true,
              size: WBButtonSize.lg,
              variant: WBButtonVariant.ghost,
              onPressed: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );
    if (enable == true) {
      final verified = await bio.authenticate(
        reason: 'Register your biometric for WAWUBasket',
      );
      if (verified) {
        await bio.setEnabled(true);
      } else if (mounted) {
        wbShowSnack(context, "Biometric not verified — it hasn't been enabled.");
      }
    } else {
      // "Not now" — remember the choice so we stop offering on each sign-in.
      // The user can still turn it on from Account → Security.
      await bio.setOfferDismissed(true);
    }
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
      await RoleController.instance.syncFromApi();
      GuestModeController.instance.exit();
      NotificationService.instance.registerToken();
      if (!mounted) return;
      _navigateAfterAuth();
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
              if (_showBioButton) ...[
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
                  label: 'Use $_bioLabel',
                  icon: WBIconName.user,
                  onPressed: _biometricSignIn,
                ),
                const SizedBox(height: WBSpacing.md),
              ],
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
