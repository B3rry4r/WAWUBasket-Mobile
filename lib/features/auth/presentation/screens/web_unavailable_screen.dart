import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';

/// Shown when a user tries to enter the rider or driver shell on Flutter
/// web. These roles need native GPS, background location and push, none
/// of which the browser can be trusted with — so we redirect them to the
/// mobile app.
class WebUnavailableScreen extends StatelessWidget {
  const WebUnavailableScreen({super.key, required this.role});

  final AppRole role;

  String get _title => role == AppRole.rider
      ? 'Riding lives on the app'
      : 'Driving lives on the app';

  String get _body => role == AppRole.rider
      ? 'WAWUBasket Rider needs live GPS, background location and instant '
          "offers — things browsers can't do reliably. Grab the mobile app "
          'to go online.'
      : 'WAWUBasket Driver needs live GPS, background location and instant '
          "job alerts — things browsers can't do reliably. Grab the mobile "
          'app to start hauling.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: context.isDesktop ? _buildDesktop(context) : _buildMobile(context),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: WBSpacing.screenPadding,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: WBBackChip(onPressed: () => _back(context)),
          ),
          const SizedBox(height: WBSpacing.xl),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Glyph(role: role),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  _title,
                  style: WBTypography.hero.copyWith(
                    fontSize: 30,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: WBSpacing.sm + 2),
                Text(
                  _body,
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: WBSpacing.xl),
                _StoreRow(
                  label: 'Get it on Google Play',
                  icon: WBIconName.basket,
                ),
                const SizedBox(height: 10),
                _StoreRow(
                  label: 'Download on the App Store',
                  icon: WBIconName.basket,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: WBSpacing.lg),
            child: WBButton(
              label: 'Pick a different role',
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () => context.go(AppRoutes.roleSelect),
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop-web layout: the same content centered in a capped reading-width
  /// column on the wide backdrop, so it no longer renders as a cramped
  /// edge-to-edge mobile strip on a desktop browser.
  Widget _buildDesktop(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: WBBackChip(onPressed: () => _back(context)),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
              child: WBMaxWidth(
                maxWidth: WBBreakpoints.maxReading,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: WBSpacing.screenPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Glyph(role: role),
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      _title,
                      style: WBTypography.hero.copyWith(
                        fontSize: 40,
                        letterSpacing: -0.9,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.sm + 2),
                    Text(
                      _body,
                      style: WBTypography.body.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.xl),
                    _StoreRow(
                      label: 'Get it on Google Play',
                      icon: WBIconName.basket,
                    ),
                    const SizedBox(height: 10),
                    _StoreRow(
                      label: 'Download on the App Store',
                      icon: WBIconName.basket,
                    ),
                    const SizedBox(height: WBSpacing.xl),
                    WBButton(
                      label: 'Pick a different role',
                      size: WBButtonSize.lg,
                      fullWidth: true,
                      variant: WBButtonVariant.secondary,
                      onPressed: () => context.go(AppRoutes.roleSelect),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.roleSelect);
    }
  }
}

/// The role glyph shown above the headline, shared by both layouts.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.role});
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: WBIcon(
        role == AppRole.rider ? WBIconName.bike : WBIconName.bike,
        size: 26,
        color: WBColors.fgHeader,
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.label, required this.icon});
  final String label;
  final WBIconName icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WBSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: WBIcon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: WBTypography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
