import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../application/role_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), _route);
  }

  Future<void> _route() async {
    if (!mounted) return;
    context.go(
      RoleController.instance.hasEverSignedIn
          ? AppRoutes.login
          : AppRoutes.welcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: Stack(
        children: [
          // ── Logo + tagline (upper area) ──────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: WBSpacing.screenPadding,
            right: WBSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/logos/logo-splash.svg',
                  height: 36,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => const SizedBox(height: 36),
                ),
                SizedBox(height: screenH * 0.07),
                Text(
                  context.l10n.splashHeadline,
                  style: WBTypography.hero.copyWith(
                    fontSize: 42,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
          ),
          // ── Basket illustration (bottom half) ────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/logos/splash-basket.svg',
              width: double.infinity,
              height: screenH * 0.52,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
              placeholderBuilder: (_) => SizedBox(height: screenH * 0.52),
            ),
          ),
        ],
      ),
    );
  }
}
