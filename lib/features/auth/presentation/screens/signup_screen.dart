import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
              const WBInput(
                label: 'Full name',
                initialValue: 'Brooks Adesanya',
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              WBInput(
                label: 'WhatsApp number',
                initialValue: '803 421 1820',
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
              const WBInput(
                label: 'Email',
                initialValue: 'brooks@wawu.africa',
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              const WBInput(
                label: 'Password',
                placeholder: 'At least 8 characters',
                leadingIcon: WBIconName.card,
                obscureText: true,
              ),
              const SizedBox(height: WBSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: WBColors.surfaceDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const WBIcon(
                      WBIconName.check,
                      size: 12,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
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
              const SizedBox(height: WBSpacing.lg),
              WBButton(
                label: 'Send code',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () => context.push(AppRoutes.otp),
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
