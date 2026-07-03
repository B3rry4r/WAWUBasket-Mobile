import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/auth_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifier = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifier.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.forgotErrorEmpty);
      return;
    }
    setState(() => _busy = true);
    try {
      final id = _identifier.text.trim();
      // Always the code path: WAWU ID sends a 6-digit OTP (delivered by email
      // until WhatsApp is live). Never the reset-LINK path — the app completes
      // recovery by entering that code on the OTP screen, so a link would leave
      // the user stranded on a code field with nothing to type.
      await AuthApi.instance.forgotPassword(id, method: 'sms');
      if (!mounted) return;
      context.push('${AppRoutes.otp}?phone=${Uri.encodeComponent(id)}&flow=reset');
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
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
              Text(context.l10n.forgotTitle, style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              Text(
                context.l10n.forgotSubtitle,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: WBSpacing.lg + 4),
              WBInput(
                label: context.l10n.loginPhoneLabel,
                controller: _identifier,
                leadingIcon: WBIconName.user,
              ),
              const Spacer(),
              WBButton(
                label: context.l10n.forgotSendCode,
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.support),
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
              ),
              const SizedBox(height: WBSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
