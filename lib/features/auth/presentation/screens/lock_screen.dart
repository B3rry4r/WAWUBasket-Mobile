import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/biometric_service.dart';
import '../../../../core/network/token_store.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';

/// Biometric unlock gate shown on reopen for a returning, still-authenticated
/// user who opted into Face ID / fingerprint. This is NOT sign-in: the session
/// already exists on disk; biometrics just confirm it's the same person before
/// the app is revealed. If verification is cancelled or fails, the user can
/// retry or fall back to a password sign-in.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _busy = false;
  String _label = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadLabel();
    // Auto-prompt once the first frame settles so the gate feels instant.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _loadLabel() async {
    final label = await BiometricService.instance.label();
    if (!mounted) return;
    setState(() => _label = label);
  }

  void _enterApp() {
    final role = RoleController.instance;
    GuestModeController.instance.exit();
    context.go(role.role.homeRoute);
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    final bio = BiometricService.instance;

    // Safety: if biometrics became unavailable or the session is no longer
    // restorable since splash routed here, don't trap the user — fall back.
    final restorable = (TokenStore.instance.refreshToken ?? '').isNotEmpty ||
        TokenStore.instance.hasSession;
    if (!restorable) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }
    if (!await bio.isAvailable() || !await bio.isEnabled()) {
      if (mounted) _enterApp();
      return;
    }

    final ok = await bio.authenticate(reason: 'Unlock WAWUBasket');
    if (!mounted) return;
    if (ok) {
      _enterApp();
    } else {
      setState(() => _busy = false);
    }
  }

  void _usePassword() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: WBWMark(size: 56)),
              const SizedBox(height: WBSpacing.xl),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: WBTypography.hero.copyWith(fontSize: 28),
              ),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'Unlock with $_label to continue.',
                textAlign: TextAlign.center,
                style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const Spacer(),
              WBButton(
                label: 'Unlock with $_label',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                loading: _busy,
                onPressed: _unlock,
              ),
              const SizedBox(height: WBSpacing.md),
              Center(
                child: TextButton(
                  onPressed: _usePassword,
                  child: Text(
                    'Use password instead',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w600,
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
