import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';

/// Desktop-web layout for the celebratory order confirmation surface shown
/// immediately after payment. Mirrors [OrderConfirmationScreen]'s data, copy,
/// and navigation precisely; only the layout is re-flowed into the persistent
/// customer web chrome with a calm, centered single column.
///
/// Desktop-only — the mobile build never imports this file.
class OrderConfirmationDesktopScreen extends StatelessWidget {
  const OrderConfirmationDesktopScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxReading,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              WBSpacing.xl,
              WBSpacing.screenPadding,
              WBSpacing.xxl,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: WBBackChip(
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ),
                const SizedBox(height: WBSpacing.xxl),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: const WBIcon(
                    WBIconName.basket,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: WBSpacing.xl),
                Text(
                  context.l10n.confirmTitle,
                  textAlign: TextAlign.center,
                  style: WBTypography.hero.copyWith(fontSize: 36, height: 1.1),
                ),
                const SizedBox(height: WBSpacing.sm),
                Text(
                  context.l10n.confirmSubtitle,
                  textAlign: TextAlign.center,
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                if (orderId != null) ...[
                  const SizedBox(height: WBSpacing.md),
                  Text(
                    () {
                      final cleaned = orderId!.replaceAll('-', '');
                      final short = cleaned.length >= 6
                          ? cleaned.substring(0, 6)
                          : cleaned;
                      return '#${short.toUpperCase()}';
                    }(),
                    textAlign: TextAlign.center,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
                const SizedBox(height: WBSpacing.xl),
                WBCard(
                  child: Column(
                    children: [
                      _ConfirmRow(
                        icon: WBIconName.bell,
                        text: context.l10n.confirmNotification,
                      ),
                      const SizedBox(height: 12),
                      _ConfirmRow(
                        icon: WBIconName.pin,
                        text: context.l10n.confirmTracking,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.xl),
                WBButton(
                  label: context.l10n.confirmTrackButton,
                  size: WBButtonSize.lg,
                  fullWidth: true,
                  trailingIcon: WBIconName.arrowRight,
                  onPressed: () => context.go(
                    orderId != null
                        ? '${AppRoutes.tracking}?orderId=$orderId'
                        : AppRoutes.tracking,
                  ),
                ),
                const SizedBox(height: WBSpacing.sm + 4),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.home),
                    child: Text(
                      context.l10n.confirmBackHome,
                      style: WBTypography.secondary.copyWith(
                        color: WBColors.fgSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.icon, required this.text});
  final WBIconName icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: WBIcon(icon, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: WBTypography.body.copyWith(
              fontSize: 14,
              color: WBColors.fgSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
