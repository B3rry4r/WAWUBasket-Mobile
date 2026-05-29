import 'dart:async';

import 'package:flutter/material.dart';
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
    final screenW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Basket PNG: covers its container, bottom bleeds off screen.
            //    Container top starts at ~50% screen height, bottom pushed
            //    15% below screen edge so the wicker base is cut off.
            Positioned(
              left: 0,
              right: 0,
              bottom: -(screenH * 0.22),
              child: SizedBox(
                width: screenW,
                height: screenH * 0.65,
                child: Image.asset(
                  'assets/logos/splash-basket.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            // ── Logo + tagline centred in the upper half ─────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: WBSpacing.screenPadding,
              right: WBSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/Logo 1.png',
                    height: 22,
                  ),
                  SizedBox(height: screenH * 0.05),
                  Text(
                    context.l10n.splashHeadline,
                    textAlign: TextAlign.center,
                    style: WBTypography.hero.copyWith(
                      fontSize: 32,
                      height: 1.15,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
