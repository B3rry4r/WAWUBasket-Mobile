import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/auth_api.dart';

/// Desktop-web layout for the forgot-password screen. Re-lays-out
/// [ForgotPasswordScreen] into a split brand/form panel without changing any
/// of its behaviour: same controller, same code-only recovery, same
/// [AuthApi.forgotPassword] call, same OTP push on success.
class ForgotPasswordDesktopScreen extends StatefulWidget {
  const ForgotPasswordDesktopScreen({super.key});

  @override
  State<ForgotPasswordDesktopScreen> createState() =>
      _ForgotPasswordDesktopScreenState();
}

class _ForgotPasswordDesktopScreenState
    extends State<ForgotPasswordDesktopScreen> {
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
      // Always the code path (OTP delivered by email until WhatsApp is live).
      // Never the reset-LINK path — recovery completes on the OTP screen.
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showBrand = constraints.maxWidth >= 1100;
            return Row(
              children: [
                if (showBrand) const Expanded(child: _BrandPanel()),
                SizedBox(
                  width: 520,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: WBSpacing.xl,
                        vertical: WBSpacing.xl,
                      ),
                      child: WBMaxWidth(
                        maxWidth: WBBreakpoints.maxReading,
                        alignment: Alignment.center,
                        child: _form(context),
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

  Widget _form(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: WBSpacing.xl),
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
      ],
    );
  }
}

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
          const WBWMark(size: 40, color: WBColors.bgPrimary),
          const SizedBox(height: WBSpacing.lg),
          Text(
            context.l10n.forgotSubtitle,
            style: WBTypography.body.copyWith(
              color: WBColors.bgPrimary,
              fontSize: 18,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

