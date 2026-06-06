import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/token_store.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/services/guest_mode.dart';
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
    // Clean, centred brand mark + spinner + loading text on every breakpoint.
    return const Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WBWMark(size: 96),
            SizedBox(height: 48),
            _SplashLoading(),
          ],
        ),
      ),
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(WBColors.surfaceDark),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading...',
          style: WBTypography.secondary.copyWith(color: WBColors.fgSecondary),
        ),
      ],
    );
  }
}
