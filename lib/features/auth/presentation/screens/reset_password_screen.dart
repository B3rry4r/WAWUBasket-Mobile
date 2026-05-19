import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  static const _rules = [
    (true, 'At least 8 characters'),
    (true, 'One uppercase letter'),
    (true, 'One number'),
    (false, 'One symbol'),
  ];

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
              Text('Choose a new\npassword', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm + 2),
              Text(
                'Make it different from your last one.',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: WBSpacing.lg + 4),
              WBInput(
                label: 'New password',
                initialValue: '••••••••••••',
                trailing: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    'Show',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.sm + 6),
              const WBInput(
                label: 'Confirm password',
                initialValue: '••••••••••••',
              ),
              const SizedBox(height: WBSpacing.lg),
              Container(
                padding: const EdgeInsets.all(WBSpacing.md),
                decoration: BoxDecoration(
                  color: WBColors.bgSecondary,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Column(
                  children: [
                    for (final (ok, label) in _rules) ...[
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ok ? WBColors.surfaceDark : WBColors.bgDivider,
                            ),
                            alignment: Alignment.center,
                            child: ok
                                ? const WBIcon(
                                    WBIconName.check,
                                    size: 11,
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  )
                                : Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: WBColors.bgPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: WBTypography.caption.copyWith(
                              color: ok
                                  ? WBColors.fgHeader
                                  : WBColors.fgPlaceholder,
                              fontWeight: ok ? FontWeight.w500 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (label != _rules.last.$2) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              WBButton(
                label: 'Save password',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () => context.go(AppRoutes.home),
              ),
              const SizedBox(height: WBSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
