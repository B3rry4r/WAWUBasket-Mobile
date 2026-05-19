import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

// The other rider screens have moved to one-file-per-screen modules so the
// flow is easier to extend (see rider_home_screen.dart,
// rider_delivery_screen.dart, rider_delivery_complete_screen.dart,
// rider_earnings_screen.dart). This file only carries the login.

class RiderLoginScreen extends StatelessWidget {
  const RiderLoginScreen({super.key});

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
              Text('Rider login', style: WBTypography.hero),
              const SizedBox(height: WBSpacing.sm),
              Text(
                "Hop on. Today's deliveries are stacking up.",
                style:
                    WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.xl),
              const WBInput(
                label: 'Rider ID',
                initialValue: 'WAWU-RD-0821',
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
                  RoleController.instance.completeKyc(AppRole.rider);
                  RoleController.instance.setRole(AppRole.rider);
                  context.go(AppRoutes.riderHome);
                },
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.riderKyc),
                  child: RichText(
                    text: TextSpan(
                      style: WBTypography.secondary,
                      children: const [
                        TextSpan(text: 'New here? '),
                        TextSpan(
                          text: 'Apply to ride',
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
