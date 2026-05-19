import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // 4-of-6 entered, matching the design. Tapping the grid fills the
  // remaining digits so the prototype is navigable end-to-end.
  final _digits = ['8', '1', '4', '2', '', ''];
  late final _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _caret.dispose();
    super.dispose();
  }

  int get _activeIndex => _digits.indexOf('');

  void _fillRemaining() {
    setState(() {
      for (var i = 0; i < _digits.length; i++) {
        if (_digits[i].isEmpty) {
          // Mock digits, completes the 6-digit code.
          _digits[i] = '${(i * 3) % 10}';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filled = _digits.every((d) => d.isNotEmpty);
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
                  children: const [
                    TextSpan(text: 'Check your WhatsApp. We sent a short one to '),
                    TextSpan(
                      text: '+234 803 ••• 1820',
                      style: TextStyle(
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
                onTap: _fillRemaining,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < _digits.length; i++)
                      _OtpBox(
                        digit: _digits[i],
                        active: i == _activeIndex,
                        caret: _caret,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontSize: 13,
                    ),
                    children: const [
                      TextSpan(text: 'Resend code in '),
                      TextSpan(
                        text: '0:42',
                        style: TextStyle(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              WBButton(
                label: filled ? 'Verify and go in' : 'Tap the code boxes to fill',
                size: WBButtonSize.lg,
                fullWidth: true,
                onPressed: filled
                    ? () => context.go(AppRoutes.roleSelect)
                    : _fillRemaining,
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
