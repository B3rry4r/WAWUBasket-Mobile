import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_logo.dart';
import '../../application/role_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1400), _route);
  }

  /// Cold-start routing: first-time users go to /welcome (onboarding);
  /// anyone who has signed in at least once goes to /login so biometrics
  /// can auto-trigger (even after an explicit sign-out).
  Future<void> _route() async {
    if (!mounted) return;
    context.go(
      RoleController.instance.hasEverSignedIn
          ? AppRoutes.login
          : AppRoutes.welcome,
    );
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const WBWMark(size: 108),
                  const SizedBox(height: WBSpacing.lg),
                  Text(context.l10n.appName, style: WBTypography.hero),
                  const SizedBox(height: WBSpacing.sm),
                  Text(
                    context.l10n.splashTagline,
                    style: WBTypography.secondary
                        .copyWith(color: WBColors.fgPlaceholder),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 64,
              child: AnimatedBuilder(
                animation: _dots,
                builder: (_, _) {
                  final t = _dots.value * 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final phase = (t - i).clamp(0.0, 1.0);
                      final opacity = 0.25 + 0.75 * phase;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: WBColors.fgDisabled
                                .withValues(alpha: opacity),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
