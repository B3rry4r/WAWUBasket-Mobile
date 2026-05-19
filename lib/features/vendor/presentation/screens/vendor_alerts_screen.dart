import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorAlertsScreen extends StatelessWidget {
  const VendorAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alerts', style: WBTypography.page),
                      Text(
                        '3 things need your attention.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            _AlertRow(
              icon: WBIconName.basket,
              label: 'Goat meat is out of stock',
              sub: 'Restock to keep accepting orders',
              kind: WBStatusKind.error,
              cta: 'Restock',
              onTap: () => context.push(AppRoutes.vendorInventory),
            ),
            _AlertRow(
              icon: WBIconName.bell,
              label: 'Tomatoes running low',
              sub: '6 baskets left · low at 8',
              kind: WBStatusKind.warning,
              cta: 'Restock',
              onTap: () => context.push(AppRoutes.vendorInventory),
            ),
            _AlertRow(
              icon: WBIconName.star,
              label: '1 new review needs a reply',
              sub: 'Daniel U. · ★★★☆☆',
              kind: WBStatusKind.info,
              cta: 'Reply',
              onTap: () => context.push(AppRoutes.vendorReviews),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.kind,
    required this.cta,
    required this.onTap,
  });

  final WBIconName icon;
  final String label;
  final String sub;
  final WBStatusKind kind;
  final String cta;
  final VoidCallback onTap;

  Color get _accent => switch (kind) {
        WBStatusKind.error => const Color(0xFFEF4444),
        WBStatusKind.warning => const Color(0xFFB45309),
        WBStatusKind.info => WBColors.fgHeader,
        WBStatusKind.success => const Color(0xFF065F46),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WBCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16, color: _accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
            WBButton(
              label: cta,
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
