import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/rider_controller.dart';
import '../widgets/rider_map_view.dart';

/// Active delivery screen, the rider walks the order through four stages:
/// Heading to vendor → At vendor → Picked up → En route → Delivered.
/// Vendor card carries the call action while we're pre-pickup; customer
/// card carries it once we're en route. A mini map (same widget as home,
/// in compact mode) sits at the top.
class RiderDeliveryScreen extends StatelessWidget {
  const RiderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: RiderController.instance.active,
          builder: (_, active, _) {
            if (active == null) return const _NoActive();
            return _Body(active: active);
          },
        ),
      ),
    );
  }
}

class _NoActive extends StatelessWidget {
  const _NoActive();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        12,
        WBSpacing.screenPadding,
        40,
      ),
      children: [
        Row(
          children: [
            WBBackChip(onPressed: () => context.go(AppRoutes.riderHome)),
            const SizedBox(width: 14),
            Text('No active delivery', style: WBTypography.page),
          ],
        ),
        const SizedBox(height: WBSpacing.xl),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(WBRadius.card),
          ),
          child: Text(
            'Head back to the map to pick up a new offer.',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.active});
  final ActiveDelivery active;

  bool get _prePickup =>
      active.stage == DeliveryStage.accepted ||
      active.stage == DeliveryStage.arrivedPickup;

  Future<void> _advance(BuildContext context) async {
    final next = active.stage.advance;
    if (next == null) return;
    try {
      await RiderController.instance.advance();
      if (!context.mounted) return;
      if (next.next == DeliveryStage.delivered) {
        // Hand off to the delivery-complete screen; it clears the active
        // delivery and routes back to the map when the rider closes it.
        context.push('${AppRoutes.riderDelivery}/complete');
      } else {
        wbShowSnack(context, next.next.label);
      }
    } on ApiException catch (e) {
      if (context.mounted) wbShowSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = active.offer;
    final next = active.stage.advance;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            160,
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
                      Text('#${offer.id}', style: WBTypography.page),
                      Text(
                        active.stage.label,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  wbNaira(offer.feeNaira),
                  style: WBTypography.cardTitle.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),

            // Mini map, same widget, scaled down.
            SizedBox(
              height: 200,
              child: RiderMapView(
                offers: [offer],
                route: offer,
                onTapOffer: (_) {},
              ),
            ),
            const SizedBox(height: 10),

            // Hands turn-by-turn off to the device maps app. Pre-pickup it
            // routes to the vendor; once picked up, to the customer.
            WBButton(
              label: _prePickup
                  ? 'Navigate to ${offer.vendorName}'
                  : 'Navigate to ${offer.customerName}',
              fullWidth: true,
              size: WBButtonSize.lg,
              variant: WBButtonVariant.secondary,
              trailingIcon: WBIconName.pin,
              onPressed: () => _prePickup
                  ? wbLaunchNavigation(
                      context,
                      offer.vendorLat,
                      offer.vendorLng,
                      label: offer.vendorName,
                    )
                  : wbLaunchNavigation(
                      context,
                      offer.dropLat,
                      offer.dropLng,
                      label: offer.customerName,
                    ),
            ),
            const SizedBox(height: WBSpacing.lg),

            _StagePillRow(stage: active.stage),
            const SizedBox(height: WBSpacing.lg),

            _PartyCard(
              tag: 'PICKUP',
              title: offer.vendorName,
              sub: offer.vendorAddress,
              phone: '+234 802 800 4400',
              callable: _prePickup,
              icon: WBIconName.home,
            ),
            const SizedBox(height: 10),
            _PartyCard(
              tag: 'DROPOFF',
              title: offer.customerName,
              sub: offer.dropAddress,
              phone: offer.customerPhone,
              callable: !_prePickup,
              icon: WBIconName.user,
            ),

            if (offer.specialInstructions.isNotEmpty) ...[
              const SizedBox(height: WBSpacing.lg),
              Text(
                'Customer note',
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              WBCard(
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
                        style: WBTypography.body.copyWith(
                          fontSize: 14,
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
                    label: 'Open chat',
                    variant: WBButtonVariant.secondary,
                    onPressed: () => context.push(
                      Uri(
                        path: AppRoutes.chatRider,
                        queryParameters: {
                          'orderId': offer.orderId,
                          'title': offer.customerName,
                        },
                      ).toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WBButton(
                    label: 'Report issue',
                    variant: WBButtonVariant.secondary,
                    onPressed: () =>
                        wbShowSnack(context, 'Support has been notified'),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                0,
                WBSpacing.screenPadding,
                18,
              ),
              child: WBButton(
                label: next?.label ?? 'Delivery complete',
                fullWidth: true,
                size: WBButtonSize.lg,
                trailingIcon: WBIconName.arrowRight,
                disabled: next == null,
                onPressed: next == null ? null : () => _advance(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StagePillRow extends StatelessWidget {
  const _StagePillRow({required this.stage});
  final DeliveryStage stage;

  @override
  Widget build(BuildContext context) {
    final stages = DeliveryStage.values;
    final activeIndex = stages.indexOf(stage);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < stages.length; i++) ...[
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= activeIndex
                          ? WBColors.surfaceDark
                          : WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i != stages.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stage.label,
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'Step ${activeIndex + 1} of ${stages.length}',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.tag,
    required this.title,
    required this.sub,
    required this.phone,
    required this.callable,
    required this.icon,
  });
  final String tag;
  final String title;
  final String sub;
  final String phone;
  final bool callable;
  final WBIconName icon;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: callable ? WBColors.surfaceDark : WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: Text(
              tag,
              style: WBTypography.label.copyWith(
                color: callable ? Colors.white : WBColors.fgPlaceholder,
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    const WBIcon(WBIconName.phone, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          WBButton(
            label: 'Call',
            size: WBButtonSize.sm,
            trailingIcon: WBIconName.phone,
            variant:
                callable ? WBButtonVariant.primary : WBButtonVariant.secondary,
            disabled: !callable,
            onPressed: callable
                ? () => wbShowSnack(context, 'Calling $title…')
                : null,
          ),
        ],
      ),
    );
  }
}
