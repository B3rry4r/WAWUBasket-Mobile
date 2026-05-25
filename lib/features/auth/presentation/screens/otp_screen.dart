import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../../data/auth_api.dart';

/// Phone-OTP verification. Reached after sign-up (`flow=signup`), the
/// password-less OTP sign-in (`flow=login`) or password recovery
/// (`flow=reset`); [phone] is the number the code was sent to.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, this.flow = 'signup'});

  final String phone;
  final String flow;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
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
        // Register FCM token — fire-and-forget, non-critical.
        NotificationService.instance.registerToken();
        if (!mounted) return;
        context.go(AppRoutes.roleSelect);
      } else {
        await AuthApi.instance.verifySignup(widget.phone, _code.text);
        // Sync role / KYC status from the backend before showing roleSelect.
        await RoleController.instance.syncFromApi();
        // Register FCM token — fire-and-forget, non-critical.
        NotificationService.instance.registerToken();
        if (!mounted) return;
        context.go(AppRoutes.roleSelect);
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
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
        wbShowSnack(context, 'A new code is on its way.');
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code.text;
    final filled = code.length == 6;
    String two(int n) => n.toString().padLeft(2, '0');

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
              const SizedBox(height: WBSpacing.xl),
              Text("You've got a code!", style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              RichText(
                text: TextSpan(
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 15,
                  ),
                  children: [
                    const TextSpan(
                        text: 'Check your WhatsApp. We sent a short one to '),
                    TextSpan(
                      text: _masked,
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
                      'Edit number',
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
                onTap: () => _focus.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 6; i++)
                      _OtpBox(
                        digit: i < code.length ? code[i] : '',
                        active: i == code.length,
                        caret: _caret,
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
                    controller: _code,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      setState(() {});
                      if (v.length == 6) _verify();
                    },
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              Center(
                child: GestureDetector(
                  onTap: _resend,
                  child: _secondsLeft > 0
                      ? RichText(
                          text: TextSpan(
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgPlaceholder,
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(text: 'Resend code in '),
                              TextSpan(
                                text:
                                    '${_secondsLeft ~/ 60}:${two(_secondsLeft % 60)}',
                                style: const TextStyle(
                                  color: WBColors.fgHeader,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          'Resend code',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const Spacer(),
              WBButton(
                label: 'Verify and go in',
                size: WBButtonSize.lg,
                fullWidth: true,
                loading: _busy,
                onPressed: filled ? _verify : null,
              ),
              const SizedBox(height: WBSpacing.xl),
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
