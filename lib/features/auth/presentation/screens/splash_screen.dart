import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/notification_service.dart';
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

  /// After the splash animation, drop the user into the right place:
  /// signed-out users hit `/welcome`, signed-in users land in the home
  /// of whatever role they were last using.
  Future<void> _route() async {
    if (!mounted) return;
    final ctrl = RoleController.instance;
    if (!ctrl.signedIn) {
      context.go(AppRoutes.welcome);
      return;
    }
    // Refresh FCM token on every app launch for returning users.
    NotificationService.instance.registerToken();
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboardingDone') ?? false;
    if (!mounted) return;
    final role = ctrl.role;
    final canResume = role == AppRole.customer ||
        (role.shellReady && ctrl.statusOf(role) == RoleStatus.approved);
    if (!canResume) {
      // Saved role lost its approval or its shell isn't built yet, fall
      // back to customer so we never strand the user on a dead route.
      ctrl.setRole(AppRole.customer);
      // Only skip onboarding if the user has already completed it.
      context.go(onboardingDone ? AppRoutes.home : AppRoutes.onboarding);
      return;
    }
    // For the customer role, check whether onboarding has been completed.
    if (role == AppRole.customer && !onboardingDone) {
      context.go(AppRoutes.onboarding);
      return;
    }
    context.go(role.homeRoute);
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
