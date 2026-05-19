import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

class DriverLoginScreen extends StatelessWidget {
  const DriverLoginScreen({super.key});

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
              Text('Driver login', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'Long-haul loads, transparent bids, fair pay.',
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              const WBInput(
                label: 'Union ID',
                initialValue: 'WAWU-DR-0044',
                leadingIcon: WBIconName.user,
              ),
              const SizedBox(height: WBSpacing.md),
              const WBInput(
                label: 'Password',
                initialValue: '••••••••',
                leadingIcon: WBIconName.card,
                obscureText: true,
              ),
              const Spacer(),
              WBButton(
                label: 'Sign in',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () {
                  RoleController.instance.completeKyc(AppRole.driver);
                  RoleController.instance.setRole(AppRole.driver);
                  context.go(AppRoutes.driverHome);
                },
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.driverKyc),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: const [
                        TextSpan(text: 'New driver? '),
                        TextSpan(
                          text: 'Apply with your union',
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
