import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/rider_controller.dart';

/// Bottom-sheet preview of a single delivery offer. Returns `true` when the
/// rider accepts, `null` on dismiss / decline.
class AcceptOfferSheet extends StatelessWidget {
  const AcceptOfferSheet({super.key, required this.offer});
  final DeliveryOffer offer;

  static Future<bool?> show(BuildContext context, DeliveryOffer offer) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WBRadius.sheet),
        ),
      ),
      builder: (_) => AcceptOfferSheet(offer: offer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + WBSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New offer · #${offer.id}',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wbNaira(offer.feeNaira),
                      style: WBTypography.hero.copyWith(
                        fontSize: 32,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Text(
                      '${offer.distanceKm.toStringAsFixed(1)} km · ${offer.etaMin} min',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const _OfferIcon(),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          _Leg(
            tag: 'PICKUP',
            title: offer.vendorName,
            sub: offer.vendorAddress,
          ),
          const SizedBox(height: 8),
          _Leg(
            tag: 'DROPOFF',
            title: offer.customerName,
            sub: offer.dropAddress,
          ),
          if (offer.specialInstructions.isNotEmpty) ...[
            const SizedBox(height: WBSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: WBIcon(WBIconName.message, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      offer.specialInstructions,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              Expanded(
                child: WBButton(
                  label: 'Skip',
                  size: WBButtonSize.lg,
                  variant: WBButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: WBButton(
                  label: 'Accept offer',
                  size: WBButtonSize.lg,
                  trailingIcon: WBIconName.arrowRight,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferIcon extends StatelessWidget {
  const _OfferIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      alignment: Alignment.center,
      child: const WBIcon(
        WBIconName.bike,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}

class _Leg extends StatelessWidget {
  const _Leg({
    required this.tag,
    required this.title,
    required this.sub,
  });
  final String tag;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: Text(
              tag,
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.66,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
