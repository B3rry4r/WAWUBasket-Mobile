import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/orders_api.dart';

/// Celebratory order confirmation screen shown immediately after payment.
/// Tapping "Track my order" pushes the live tracking screen.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Every post-checkout return path (mobile deep link and the web redirect)
    // lands here — confirm the payment server-side so the order advances to
    // `paid` even when the async webhook is delayed or never arrives.
    final id = widget.orderId;
    if (id != null && id.isNotEmpty) {
      OrdersApi.instance
          .verifyPayment(id)
          .catchError((_) => <String, dynamic>{});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.xl,
            WBSpacing.screenPadding,
            WBSpacing.xl,
          ),
          child: Column(
            children: [
              const Spacer(),
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
              if (widget.orderId != null) ...[
                const SizedBox(height: WBSpacing.md),
                Text(
                  () {
                    final cleaned = widget.orderId!.replaceAll('-', '');
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
              const Spacer(),
              WBButton(
                label: context.l10n.confirmTrackButton,
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () => context.go(
                  widget.orderId != null
                      ? '${AppRoutes.tracking}?orderId=${widget.orderId}'
                      : AppRoutes.tracking,
                ),
              ),
              const SizedBox(height: WBSpacing.sm + 4),
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Text(
                  context.l10n.confirmBackHome,
                  style: WBTypography.secondary.copyWith(
                    color: WBColors.fgSecondary,
                    fontWeight: FontWeight.w500,
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
