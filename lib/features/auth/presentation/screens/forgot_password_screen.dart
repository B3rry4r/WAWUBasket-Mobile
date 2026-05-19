import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _method = 'sms';

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
              Text('Reset password', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              Text(
                "Tell us where to send a verification code and we'll help you back in.",
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: WBSpacing.lg + 4),
              const WBInput(
                label: 'Phone or email',
                initialValue: 'brooks@wawu.africa',
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.lg + 4),
              Text(
                'SEND CODE VIA',
                style: WBTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WBColors.fgPlaceholder,
                  letterSpacing: 0.66,
                ),
              ),
              const SizedBox(height: WBSpacing.sm + 2),
              Row(
                children: [
                  Expanded(
                    child: _MethodCard(
                      label: 'SMS',
                      sub: '+234 803 ••• 1820',
                      active: _method == 'sms',
                      onTap: () => setState(() => _method = 'sms'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MethodCard(
                      label: 'Email',
                      sub: 'brooks@…africa',
                      active: _method == 'email',
                      onTap: () => setState(() => _method = 'email'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              WBButton(
                label: 'Send code',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () => context.push(AppRoutes.resetPassword),
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontSize: 13,
                    ),
                    children: const [
                      TextSpan(text: "Didn't get a code last time? "),
                      TextSpan(
                        text: 'Contact support',
                        style: TextStyle(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.label,
    required this.sub,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? WBColors.bgPrimary : WBColors.bgSecondary,
          borderRadius: BorderRadius.circular(WBRadius.card),
          border: Border.all(
            color: active ? WBColors.fgHeader : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: WBTypography.secondary.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
