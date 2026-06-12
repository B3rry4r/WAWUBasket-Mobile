import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/country_api.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/utils/wb_validators.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../../data/auth_api.dart';

/// Desktop-web layout for [SignupScreen]. Behaviour is mirrored exactly from
/// the mobile screen; only the layout is re-arranged into a split brand/form
/// panel. This file is shown ONLY at desktop width and is isolated from the
/// mobile build.
class SignupDesktopScreen extends StatefulWidget {
  const SignupDesktopScreen({super.key});

  @override
  State<SignupDesktopScreen> createState() => _SignupDesktopScreenState();
}

class _SignupDesktopScreenState extends State<SignupDesktopScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  Country? _country;
  bool _agreed = true;
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Normalises the local number into E.164 using the picked country's
  /// dial code (`803 421 1820` + NG → `+2348034211820`).
  String get _e164Phone {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    return '${_country?.dialCode ?? '+234'}$local';
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _email.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.signupErrorName);
      return;
    }
    if (!WbValidators.isValidEmail(_email.text)) {
      wbShowSnack(context, 'Please enter a valid email address.');
      return;
    }
    if (_password.text.length < 8) {
      wbShowSnack(context, context.l10n.signupErrorPassword);
      return;
    }
    if (!_agreed) {
      wbShowSnack(context, context.l10n.signupErrorTerms);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.signup(
        fullName: _name.text.trim(),
        phone: _e164Phone,
        email: _email.text.trim(),
        password: _password.text,
        country: _country?.name ?? 'Nigeria',
      );
      // WAWU ID returns a live session from /auth/register, so the account is
      // ready. Mirror the login/OTP post-auth sequence before routing.
      await RoleController.instance.syncFromApi();
      GuestModeController.instance.exit();
      NotificationService.instance.registerToken();
      if (!mounted) return;
      context.go(AppRoutes.roleSelect);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (e) {
      // Non-API failure — show the cause instead of failing silently.
      if (mounted) wbShowSnack(context, "Couldn't create account: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A tappable, underlined legal link inside the agreement clause. Tapping it
  /// opens the in-app document and does not toggle the agreement checkbox.
  InlineSpan _legalLink(BuildContext context, String label, String url) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: () => wbLaunchWebUrl(context, url),
        child: Text(
          label,
          style: WBTypography.caption.copyWith(
            color: WBColors.fgHeader,
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showBrand = constraints.maxWidth >= 1100;
            return Row(
              children: [
                if (showBrand) const Expanded(child: _BrandPanel()),
                SizedBox(
                  width: 520,
                  child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: WBSpacing.xl,
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
            );
          },
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
        const SizedBox(height: WBSpacing.lg),
        Text(context.l10n.signupTitle, style: WBTypography.hero),
        const SizedBox(height: WBSpacing.sm),
        Text(
          context.l10n.signupSubtitle,
          style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
        ),
        const SizedBox(height: WBSpacing.lg),
        WBInput(
          label: context.l10n.signupNameLabel,
          controller: _name,
          leadingIcon: WBIconName.user,
        ),
        const SizedBox(height: WBSpacing.sm + 6),
        WBPhoneField(
          label: context.l10n.signupPhoneLabel,
          controller: _phone,
          onCountryChanged: (c) => _country = c,
        ),
        const SizedBox(height: WBSpacing.sm + 6),
        WBInput(
          label: context.l10n.signupEmailLabel,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          leadingIcon: WBIconName.user,
        ),
        const SizedBox(height: WBSpacing.sm + 6),
        WBInput(
          label: context.l10n.signupPasswordLabel,
          controller: _password,
          placeholder: context.l10n.signupPasswordPlaceholder,
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
        const SizedBox(height: WBSpacing.lg),
        GestureDetector(
          onTap: () => setState(() => _agreed = !_agreed),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _agreed ? WBColors.surfaceDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreed ? WBColors.surfaceDark : WBColors.bgDivider,
                    width: 1.5,
                  ),
                ),
                child: _agreed
                    ? const WBIcon(
                        WBIconName.check,
                        size: 12,
                        color: Colors.white,
                        strokeWidth: 2.5,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      _legalLink(context, 'Terms', wbTermsUrl),
                      const TextSpan(text: ' and '),
                      _legalLink(context, 'Privacy Policy', wbPrivacyUrl),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        WBButton(
          label: context.l10n.signupSendCode,
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          loading: _busy,
          onPressed: _submit,
        ),
        const SizedBox(height: WBSpacing.sm + 4),
        Center(
          child: Text(
            context.l10n.signupDisclaimer,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgPlaceholder,
            ),
          ),
        ),
        const SizedBox(height: WBSpacing.md),
        Center(
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.login),
            child: RichText(
              text: TextSpan(
                style: WBTypography.secondary,
                children: [
                  TextSpan(text: '${context.l10n.signupHaveAccount} '),
                  TextSpan(
                    text: context.l10n.signIn,
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
    );
  }
}

/// Left-hand brand panel shown only at desktop width. Calm, minimal lock-up
/// over the dark surface — premium marketplace tone.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: WBColors.surfaceDark),
      child: Padding(
        padding: const EdgeInsets.all(WBSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WBWMark(size: 40, color: Colors.white),
            const SizedBox(height: WBSpacing.lg),
            Text(
              context.l10n.signupSubtitle,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
