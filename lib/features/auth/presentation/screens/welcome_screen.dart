import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _features = [
    _Feature(WBIconName.basket, 'Eat now, gather fresh, stock up, one basket.'),
    _Feature(WBIconName.bike, 'Watch your basket come to life in real time.'),
    _Feature(WBIconName.card, 'Pay your way, card, transfer, or wallet.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            28,
            WBSpacing.screenPadding,
            WBSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WBWMark(size: 56),
              const SizedBox(height: WBSpacing.xl),
              Text(
                'One basket.\nEverything.',
                style: WBTypography.hero.copyWith(
                  fontSize: 36,
                  letterSpacing: -0.9,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  'Restaurants, fresh produce, livestock and kitchen '
                  'essentials, all in one basket.',
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              for (final feature in _features) ...[
                _FeatureRow(feature: feature),
                const SizedBox(height: WBSpacing.sm + 4),
              ],
              const SizedBox(height: WBSpacing.lg),
              WBButton(
                label: 'Get started',
                fullWidth: true,
                size: WBButtonSize.lg,
                onPressed: () => context.push(AppRoutes.signup),
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              _SecondaryCta(
                label: 'Sign in',
                onPressed: () => context.push(AppRoutes.login),
              ),
              const SizedBox(height: WBSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => _showOperatorSheet(context),
                  style: TextButton.styleFrom(
                    foregroundColor: WBColors.fgPlaceholder,
                  ),
                  child: Text(
                    'Sign in as vendor, rider or trade agent',
                    style: WBTypography.secondary.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showOperatorSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Sign in as operator',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick the dashboard you need.',
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: 12),
          for (final r in const [
            (WBIconName.home, 'Vendor', 'Sell food, produce or essentials',
                AppRoutes.vendorLogin),
            (WBIconName.basket, 'Trader',
                'List bulk lots & corridor exports', AppRoutes.traderLogin),
            (WBIconName.bike, 'Rider', 'Deliver baskets in the city',
                AppRoutes.riderLogin),
            (WBIconName.bike, 'Driver',
                'Move long-haul corridor loads', AppRoutes.driverLogin),
            (WBIconName.card, 'Trade agent', 'Register traders, log sales',
                AppRoutes.agentLogin),
          ])
            _OperatorRow(icon: r.$1, label: r.$2, sub: r.$3, route: r.$4),
        ],
      ),
    ),
  );
}

class _OperatorRow extends StatelessWidget {
  const _OperatorRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.route,
  });
  final WBIconName icon;
  final String label;
  final String sub;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        context.push(route);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const WBIcon(
              WBIconName.chevronRight,
              size: 16,
              color: WBColors.fgPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.label);
  final WBIconName icon;
  final String label;
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.md - 2),
      decoration: BoxDecoration(
        color: WBColors.bgSecondary,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: WBColors.bgPrimary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: WBIcon(feature.icon, size: 18),
          ),
          const SizedBox(width: WBSpacing.md - 2),
          Expanded(
            child: Text(
              feature.label,
              style: WBTypography.secondary.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryCta extends StatelessWidget {
  const _SecondaryCta({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WBColors.bgPrimary,
          borderRadius: BorderRadius.circular(WBRadius.pill),
          border: Border.all(color: WBColors.bgDivider),
        ),
        child: Text(
          label,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w500,
            color: WBColors.fgHeader,
          ),
        ),
      ),
    );
  }
}
