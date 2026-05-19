import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

class TraderLoginScreen extends StatelessWidget {
  const TraderLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: WBSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              WBBackChip(onPressed: () => context.go(AppRoutes.welcome)),
              const SizedBox(height: WBSpacing.xl),
              Text('Trader access', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'Bulk listings, corridor prices, ready buyers.',
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              const WBInput(
                label: 'Business email',
                initialValue: 'hauwa@bulktrade.ng',
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.md),
              const WBInput(
                label: 'Password',
                initialValue: '••••••••••',
                leadingIcon: WBIconName.card,
                obscureText: true,
              ),
              const Spacer(),
              WBButton(
                label: 'Sign in to dashboard',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () {
                  RoleController.instance.completeKyc(AppRole.trader);
                  RoleController.instance.setRole(AppRole.trader);
                  context.go(AppRoutes.traderHome);
                },
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.traderKyc),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: const [
                        TextSpan(text: 'New trader? '),
                        TextSpan(
                          text: 'Apply to list bulk goods',
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
