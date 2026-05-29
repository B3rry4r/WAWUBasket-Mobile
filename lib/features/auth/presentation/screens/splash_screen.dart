import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: Stack(
        // Stack clips to screen bounds — basket bottom bleeds off naturally.
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Basket illustration: fills screen width, anchored bottom,
          //    pushed down so the wicker bottom is cut off like the reference.
          Positioned(
            left: 0,
            right: 0,
            // Negative bottom pushes the SVG down so only the top portion
            // (groceries + upper basket rim) is visible; wicker base bleeds off.
            bottom: -(screenH * 0.08),
            child: SvgPicture.asset(
              'assets/logos/splash-basket.svg',
              width: screenW,
              height: screenH * 0.60,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              placeholderBuilder: (_) => SizedBox(
                width: screenW,
                height: screenH * 0.60,
              ),
            ),
          ),
          // ── Logo + tagline centred in the upper half ─────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: WBSpacing.screenPadding,
            right: WBSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const WBWordmark(height: 28),
                SizedBox(height: screenH * 0.06),
                Text(
                  context.l10n.splashHeadline,
                  textAlign: TextAlign.center,
                  style: WBTypography.hero.copyWith(
                    fontSize: 40,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
