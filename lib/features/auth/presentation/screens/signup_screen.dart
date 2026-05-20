import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/auth_api.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Normalises the local number into E.164 (`803 421 1820` → `+2348034211820`).
  String get _e164Phone {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    return '+234$local';
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _email.text.trim().isEmpty) {
      wbShowSnack(context, 'Fill in your name, number and email.');
      return;
    }
    if (_password.text.length < 8) {
      wbShowSnack(context, 'Password must be at least 8 characters.');
      return;
    }
    if (!_agreed) {
      wbShowSnack(context, 'Accept the Terms to continue.');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthApi.instance.signup(
        fullName: _name.text.trim(),
        phone: _e164Phone,
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      context.push('${AppRoutes.otp}?phone=$_e164Phone&flow=signup');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const WBBackChip(),
              const SizedBox(height: WBSpacing.lg),
              Text("What's your WhatsApp number?", style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                "We'll send a code to make sure it's really you.",
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.lg),
              WBInput(
                label: 'Full name',
                controller: _name,
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: 'WhatsApp number',
                controller: _phone,
                leadingIcon: WBIconName.phone,
                keyboardType: TextInputType.phone,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: WBColors.bgSoft,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+234',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const WBIcon(
                        WBIconName.chevronDown,
                        size: 12,
                        color: WBColors.fgSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: 'Password',
                controller: _password,
                placeholder: 'At least 8 characters',
                leadingIcon: WBIconName.card,
                obscureText: true,
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
                        color: _agreed
                            ? WBColors.surfaceDark
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreed
                              ? WBColors.surfaceDark
                              : WBColors.bgDivider,
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
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: WBColors.fgHeader,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: WBColors.fgHeader,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              WBButton(
                label: 'Send code',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              Center(
                child: Text(
                  'No spam. No calls. Just your basket updates.',
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
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
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
