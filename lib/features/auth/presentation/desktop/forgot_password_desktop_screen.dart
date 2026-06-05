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
/// of its behaviour: same controller, same SMS/email method toggle, same
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
  String _method = 'sms';
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
      await AuthApi.instance.forgotPassword(id, method: _method);
      if (!mounted) return;
      context.push('${AppRoutes.otp}?phone=${Uri.encodeComponent(id)}&flow=reset');
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
                label: context.l10n.forgotSmsLabel,
                sub: context.l10n.forgotSmsSub,
                active: _method == 'sms',
                onTap: () => setState(() => _method = 'sms'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MethodCard(
                label: context.l10n.forgotEmailLabel,
                sub: context.l10n.forgotEmailSub,
                active: _method == 'email',
                onTap: () => setState(() => _method = 'email'),
              ),
            ),
          ],
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
          const WBWordmark(height: 40, color: WBColors.bgPrimary),
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
