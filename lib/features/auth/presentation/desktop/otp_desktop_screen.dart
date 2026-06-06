import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../../data/auth_api.dart';

/// Desktop-web re-layout of [OtpScreen]. Same phone-OTP verification logic —
/// reached after sign-up (`flow=signup`), the password-less OTP sign-in
/// (`flow=login`) or password recovery (`flow=reset`); [phone] is the number
/// the code was sent to. Only the arrangement differs: a brand-left split
/// panel with the form in a fixed right column. The mobile build is untouched.
class OtpDesktopScreen extends StatefulWidget {
  const OtpDesktopScreen({super.key, required this.phone, this.flow = 'signup'});

  final String phone;
  final String flow;

  @override
  State<OtpDesktopScreen> createState() => _OtpDesktopScreenState();
}

class _OtpDesktopScreenState extends State<OtpDesktopScreen>
    with SingleTickerProviderStateMixin {
  final _code = TextEditingController();
  final _focus = FocusNode();
  late final _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  Timer? _ticker;
  int _secondsLeft = 42;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _caret.dispose();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _ticker?.cancel();
    setState(() => _secondsLeft = 42);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _masked {
    final p = widget.phone;
    if (p.length < 7) return p;
    return '${p.substring(0, p.length - 4)}•••${p.substring(p.length - 1)}';
  }

  Future<void> _verify() async {
    if (_code.text.length != 6 || _busy) return;
    setState(() => _busy = true);
    try {
      if (widget.flow == 'reset') {
        // Carry the code forward — the reset screen sets the password.
        if (!mounted) return;
        context.push(
          '${AppRoutes.resetPassword}?identifier=${Uri.encodeComponent(widget.phone)}'
          '&code=${_code.text}',
        );
      } else if (widget.flow == 'login') {
        await AuthApi.instance.verifyOtp(widget.phone, _code.text);
        // Sync role / KYC status from the backend before showing roleSelect.
        await RoleController.instance.syncFromApi();
        GuestModeController.instance.exit();
        // Register FCM token — fire-and-forget, non-critical.
        NotificationService.instance.registerToken();
        if (!mounted) return;
        context.go(AppRoutes.roleSelect);
      } else {
        await AuthApi.instance.verifySignup(widget.phone, _code.text);
        // Sync role / KYC status from the backend before showing roleSelect.
        await RoleController.instance.syncFromApi();
        GuestModeController.instance.exit();
        // Register FCM token — fire-and-forget, non-critical.
        NotificationService.instance.registerToken();
        if (!mounted) return;
        context.go(AppRoutes.roleSelect);
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } catch (e) {
      // Non-API failure — show the cause instead of failing silently.
      if (mounted) wbShowSnack(context, "Couldn't verify code: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    try {
      await AuthApi.instance.startOtp(widget.phone);
      if (mounted) {
        _startCountdown();
        wbShowSnack(context, context.l10n.otpNewCode);
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Hide the brand panel when the window gets cramped.
          final showBrand = constraints.maxWidth >= 1100;
          return Row(
            children: [
              if (showBrand) const Expanded(child: _BrandPanel()),
              SizedBox(
                width: 520,
                child: _FormColumn(
                  masked: _masked,
                  flow: widget.flow,
                  code: _code,
                  focus: _focus,
                  caret: _caret,
                  busy: _busy,
                  secondsLeft: _secondsLeft,
                  onChanged: (v) {
                    setState(() {});
                    if (v.length == 6) _verify();
                  },
                  onVerify: _verify,
                  onResend: _resend,
                  onFocusBoxes: () => _focus.requestFocus(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The left brand panel — calm, minimal, premium-marketplace tone.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WBColors.surfaceDark,
      padding: const EdgeInsets.all(WBSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const WBWordmark(height: 40, color: WBColors.bgPrimary),
          const SizedBox(height: WBSpacing.lg),
          SizedBox(
            width: 360,
            child: Text(
              context.l10n.loginSubtitle,
              style: WBTypography.body.copyWith(
                color: WBColors.bgPrimary.withValues(alpha: 0.72),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The right-hand form column. Holds the real screen content, capped to a
/// readable width and vertically centered.
class _FormColumn extends StatelessWidget {
  const _FormColumn({
    required this.masked,
    required this.flow,
    required this.code,
    required this.focus,
    required this.caret,
    required this.busy,
    required this.secondsLeft,
    required this.onChanged,
    required this.onVerify,
    required this.onResend,
    required this.onFocusBoxes,
  });

  final String masked;
  final String flow;
  final TextEditingController code;
  final FocusNode focus;
  final Animation<double> caret;
  final bool busy;
  final int secondsLeft;
  final ValueChanged<String> onChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onFocusBoxes;

  @override
  Widget build(BuildContext context) {
    final entered = code.text;
    final filled = entered.length == 6;
    String two(int n) => n.toString().padLeft(2, '0');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.xl,
          vertical: WBSpacing.xxl,
        ),
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxReading,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const WBBackChip(),
              const SizedBox(height: WBSpacing.xl),
              Text(context.l10n.otpTitle, style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              RichText(
                text: TextSpan(
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(text: '${context.l10n.otpSubtitle} '),
                    TextSpan(
                      text: masked,
                      style: const TextStyle(
                        color: WBColors.fgHeader,
                        fontWeight: FontWeight.w500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.sm),
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WBIcon(
                      WBIconName.phone,
                      size: 13,
                      color: WBColors.fgHeader,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.otpEditNumber,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgHeader,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              GestureDetector(
                onTap: onFocusBoxes,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 6; i++)
                      _OtpBox(
                        digit: i < entered.length ? entered[i] : '',
                        active: i == entered.length,
                        caret: caret,
                      ),
                  ],
                ),
              ),
              // Off-screen field that captures the keystrokes.
              SizedBox(
                height: 0,
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: code,
                    focusNode: focus,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: onChanged,
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              Center(
                child: GestureDetector(
                  onTap: onResend,
                  child: secondsLeft > 0
                      ? RichText(
                          text: TextSpan(
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgPlaceholder,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(text: '${context.l10n.otpResend} in '),
                              TextSpan(
                                text:
                                    '${secondsLeft ~/ 60}:${two(secondsLeft % 60)}',
                                style: const TextStyle(
                                  color: WBColors.fgHeader,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          context.l10n.otpResend,
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: WBSpacing.xxl),
              WBButton(
                label: context.l10n.otpVerifyButton,
                size: WBButtonSize.lg,
                fullWidth: true,
                loading: busy,
                onPressed: filled ? onVerify : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.active,
    required this.caret,
  });

  final String digit;
  final bool active;
  final Animation<double> caret;

  @override
  Widget build(BuildContext context) {
    final filled = digit.isNotEmpty;
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: filled ? WBColors.bgPrimary : WBColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? WBColors.fgHeader
              : (filled ? WBColors.bgDivider : Colors.transparent),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              digit,
              style: WBTypography.hero.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            )
          : (active
              ? AnimatedBuilder(
                  animation: caret,
                  builder: (_, _) => Opacity(
                    opacity: caret.value,
                    child: Container(
                      width: 2,
                      height: 24,
                      color: WBColors.fgHeader,
                    ),
                  ),
                )
              : null),
    );
  }
}
