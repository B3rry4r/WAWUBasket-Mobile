import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/rider_controller.dart';
import '../widgets/accept_offer_sheet.dart';
import '../widgets/rider_map_view.dart';

/// Rider's home screen — full-bleed Mapbox map (or stylized fallback) with
/// floating offer pins, a top status banner (online toggle + today's
/// earnings), and a draggable offer sheet pinned to the bottom.
///
/// Tapping a pin or an offer row opens the [AcceptOfferSheet]; accepting
/// promotes the offer to an active delivery and pushes the active
/// delivery screen.
class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  Future<void> _open(DeliveryOffer offer) async {
    final accepted = await AcceptOfferSheet.show(context, offer);
    if (!mounted || accepted != true) return;
    RiderController.instance.accept(offer);
    wbShowSnack(context, 'Offer ${offer.id} accepted');
    context.push(AppRoutes.riderDelivery);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = RiderController.instance;
    return ValueListenableBuilder(
      valueListenable: ctrl.online,
      builder: (_, online, _) {
        return ValueListenableBuilder(
          valueListenable: ctrl.offers,
          builder: (_, offers, _) {
            return ValueListenableBuilder(
              valueListenable: ctrl.active,
              builder: (_, active, _) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        // Leave room for the floating bottom-nav so the
                        // map never sits under it.
                        padding: const EdgeInsets.only(bottom: 96),
                        child: RiderMapView(
                          offers: online ? offers : const [],
                          onTapOffer: _open,
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          WBSpacing.screenPadding,
                          10,
                          WBSpacing.screenPadding,
                          0,
                        ),
                        child: _StatusBar(
                          online: online,
                          onToggle: ctrl.toggleOnline,
                        ),
                      ),
                    ),
                    if (active != null)
                      Positioned(
                        left: WBSpacing.screenPadding,
                        right: WBSpacing.screenPadding,
                        bottom: 120,
                        child: _ResumeActiveBanner(
                          stageLabel: active.stage.label,
                          orderId: active.offer.id,
                          onTap: () => context.push(AppRoutes.riderDelivery),
                        ),
                      )
                    else
                      _OfferDrawer(offers: offers, online: online, onTap: _open),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.online, required this.onToggle});
  final bool online;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.pill),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const WBIcon(WBIconName.user, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tunde · Today',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                Text(
                  '${wbNaira(4800)} · 6 deliveries',
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: WBMotion.base,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: online ? WBColors.surfaceDark : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: online
                          ? const Color(0xFF10B981)
                          : WBColors.fgPlaceholder,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    online ? 'Online' : 'Offline',
                    style: WBTypography.caption.copyWith(
                      color: online ? Colors.white : WBColors.fgHeader,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferDrawer extends StatelessWidget {
  const _OfferDrawer({
    required this.offers,
    required this.online,
    required this.onTap,
  });
  final List<DeliveryOffer> offers;
  final bool online;
  final ValueChanged<DeliveryOffer> onTap;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.16,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: WBColors.bgPrimary,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 20,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: WBColors.bgDivider,
                      borderRadius: BorderRadius.circular(WBRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WBSpacing.screenPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          online
                              ? '${offers.length} offer${offers.length == 1 ? '' : 's'} nearby'
                              : "You're offline",
                          style: WBTypography.cardTitle.copyWith(fontSize: 17),
                        ),
                      ),
                      Text(
                        'Pull up to see more',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgPlaceholder,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: !online
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: WBSpacing.screenPadding,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: WBColors.bgSoft,
                              borderRadius:
                                  BorderRadius.circular(WBRadius.card),
                            ),
                            child: Text(
                              'Toggle online to start receiving delivery offers.',
                              style: WBTypography.body.copyWith(
                                color: WBColors.fgSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : offers.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: WBSpacing.screenPadding,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: WBColors.bgSoft,
                                  borderRadius:
                                      BorderRadius.circular(WBRadius.card),
                                ),
                                child: Text(
                                  'No offers right now. Hang tight — they spike at meal times.',
                                  style: WBTypography.body.copyWith(
                                    color: WBColors.fgSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                WBSpacing.screenPadding,
                                4,
                                WBSpacing.screenPadding,
                                40,
                              ),
                              itemCount: offers.length,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _OfferRow(
                                  offer: offers[i],
                                  onTap: () => onTap(offers[i]),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer, required this.onTap});
  final DeliveryOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: WBCard(
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
              child: const WBIcon(WBIconName.basket, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          offer.vendorName,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        wbNaira(offer.feeNaira),
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offer.distanceKm.toStringAsFixed(1)} km · ${offer.etaMin} min · ${offer.dropAddress}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
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

class _ResumeActiveBanner extends StatelessWidget {
  const _ResumeActiveBanner({
    required this.stageLabel,
    required this.orderId,
    required this.onTap,
  });
  final String stageLabel;
  final String orderId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WBColors.surfaceDark,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const WBIcon(
                WBIconName.bike,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active delivery · #$orderId',
                    style: WBTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stageLabel,
                    style: WBTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const WBIcon(
              WBIconName.arrowRight,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
