import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/token_store.dart';
import '../../../../core/responsive/wb_responsive.dart';
import '../../../../core/services/guest_mode.dart';
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
    final role = RoleController.instance;

    // A returning user whose session can still be restored reopens straight
    // into the app as authenticated. The session is "restorable" when a
    // refresh token is on disk (the interceptor mints a fresh access token on
    // the first request); if that refresh is rejected, `onSessionExpired`
    // bounces the user to /login at that point.
    final restorable =
        (TokenStore.instance.refreshToken ?? '').isNotEmpty ||
            TokenStore.instance.hasSession;

    if (restorable && role.signedIn) {
      GuestModeController.instance.exit();
      context.go(role.role.homeRoute);
      return;
    }

    // No restorable session — launch guest-first. The app opens directly to
    // home in a guest (no-token) state; sign-in is demanded only at the moment
    // of a gated interaction (see GuestModeController.requireAccount), never at
    // cold start.
    GuestModeController.instance.enter();
    context.go(role.role.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Desktop/web: the basket PNG + wordmark lock-up is a portrait, mobile-only
    // composition. On a wide browser show just the brand mark, centred.
    if (context.isDesktop) {
      return const Scaffold(
        backgroundColor: WBColors.bgPrimary,
        body: Center(child: WBWMark(size: 96)),
      );
    }

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
                    'assets/logos/wordmark.png',
                    height: 26,
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
