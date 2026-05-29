import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/wb_permissions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../application/rider_controller.dart';
import '../widgets/accept_offer_sheet.dart';
import '../widgets/rider_map_view.dart';

/// Rider's home screen, full-bleed Mapbox map (or stylized fallback) with
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
  StreamSubscription<Position>? _locationSub;
  Timer? _locationHeartbeat;

  @override
  void initState() {
    super.initState();
    RiderController.instance.loadOffers();
    ProfileController.instance.load();
    ProfileController.instance.loadStats();
    // Sync the app's default-online=true to the server so the matcher can
    // find this rider even before the user manually toggles the switch.
    RiderController.instance.syncOnline();
    RiderController.instance.online.addListener(_onOnlineChanged);
    // Ask for location (always-on for background delivery tracking) once the
    // first build settles, then start the position stream if online.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLocation());
  }

  @override
  void dispose() {
    RiderController.instance.online.removeListener(_onOnlineChanged);
    _locationSub?.cancel();
    _locationHeartbeat?.cancel();
    super.dispose();
  }

  void _onOnlineChanged() {
    if (RiderController.instance.online.value) {
      _startTracking();
    } else {
      _stopTracking();
    }
  }

  Future<void> _ensureLocation() async {
    // If permission is already granted (previous session), start tracking
    // immediately without showing any system dialog.
    final alreadyGranted = await Permission.locationAlways.isGranted ||
        await Permission.locationWhenInUse.isGranted;
    if (alreadyGranted) {
      if (mounted && RiderController.instance.online.value) _startTracking();
      return;
    }
    // First time or permission was revoked — prompt once.
    final granted = await WBPermissions.requestLocationAlways();
    if (!granted || !mounted) return;
    if (RiderController.instance.online.value) _startTracking();
  }

  void _startTracking() {
    if (_locationSub != null) return;
    // Immediately prime the DB with current GPS so the matcher finds this
    // rider right away — the position stream only fires after 20 m of movement.
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).then((p) => RiderController.instance.updatePosition(p.latitude, p.longitude))
     .catchError((_) {});

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // metres — skip micro-jitter, update on real movement
      ),
    ).listen(
      (pos) => RiderController.instance.updatePosition(pos.latitude, pos.longitude),
      onError: (_) {},
    );
    // Heartbeat: re-ping the last known position every 3 minutes so the
    // server never considers the rider stale (matcher drops riders whose
    // last ping is > 5 min old). The stream only fires on movement, so
    // a stationary rider would go stale without this.
    _locationHeartbeat ??= Timer.periodic(
      const Duration(minutes: 3),
      (_) {
        final pos = RiderController.instance.currentPosition.value;
        if (pos != null) {
          RiderController.instance.updatePosition(pos.lat, pos.lng);
        } else {
          // No GPS fix yet — get a one-shot position to prime the record.
          Geolocator.getCurrentPosition().then(
            (p) => RiderController.instance.updatePosition(p.latitude, p.longitude),
          ).catchError((_) {});
        }
      },
    );
  }

  void _stopTracking() {
    _locationSub?.cancel();
    _locationSub = null;
    _locationHeartbeat?.cancel();
    _locationHeartbeat = null;
  }

  Future<void> _open(DeliveryOffer offer) async {
    final accepted = await AcceptOfferSheet.show(context, offer);
    if (!mounted || accepted != true) return;
    try {
      await RiderController.instance.accept(offer);
      if (!mounted) return;
      wbShowSnack(context, 'Offer accepted!');
      context.push(AppRoutes.riderDelivery);
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    }
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
                          // Float the recenter button above the collapsed
                          // offer sheet (~30% of the screen) so it is
                          // never hidden behind it.
                          bottomInset: (MediaQuery.of(context).size.height *
                                          0.30 -
                                      96)
                                  .clamp(0.0, double.infinity) +
                              8,
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
                        child: ValueListenableBuilder(
                          valueListenable: ProfileController.instance.profile,
                          builder: (_, profile, _) => ValueListenableBuilder(
                            valueListenable: ProfileController.instance.stats,
                            builder: (_, stats, _) => _StatusBar(
                              online: online,
                              onToggle: ctrl.toggleOnline,
                              displayName:
                                  profile?.riderDisplayName?.isNotEmpty == true
                                      ? profile!.riderDisplayName!.split(' ').first
                                      : profile?.fullName.isNotEmpty == true
                                          ? profile!.fullName.split(' ').first
                                          : null,
                              tripsToday: stats?.riderTripsToday,
                              earnedNairaToday: stats?.riderEarnedNaira != null
                                  ? int.tryParse(stats!.riderEarnedNaira!)
                                  : null,
                            ),
                          ),
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
  const _StatusBar({
    required this.online,
    required this.onToggle,
    this.displayName,
    this.tripsToday,
    this.earnedNairaToday,
  });
  final bool online;
  final VoidCallback onToggle;
  final String? displayName;
  final int? tripsToday;
  final int? earnedNairaToday;

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
                  displayName != null ? '$displayName · Today' : 'Today',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                Text(
                  earnedNairaToday != null && tripsToday != null
                      ? '${wbNaira(earnedNairaToday!)} · $tripsToday ${tripsToday == 1 ? 'delivery' : 'deliveries'}'
                      : '– · –',
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.chatInbox),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const WBIcon(WBIconName.message, size: 16),
            ),
          ),
          const SizedBox(width: 8),
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
                              : context.l10n.riderHomeOffline,
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
                                  'No offers right now. Hang tight, they spike at meal times.',
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
    return ValueListenableBuilder(
      valueListenable: RiderController.instance.currentPosition,
      builder: (_, pos, _) {
        final km = pos == null
            ? offer.distanceKm
            : offer.distanceKmFrom(pos.lat, pos.lng);
        final eta = pos == null
            ? offer.etaMin
            : offer.etaMinFrom(pos.lat, pos.lng);
        return _OfferRowBody(
          offer: offer,
          distanceKm: km,
          etaMin: eta,
          onTap: onTap,
        );
      },
    );
  }
}

class _OfferRowBody extends StatelessWidget {
  const _OfferRowBody({
    required this.offer,
    required this.distanceKm,
    required this.etaMin,
    required this.onTap,
  });
  final DeliveryOffer offer;
  final double distanceKm;
  final int etaMin;
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
                    '${distanceKm.toStringAsFixed(1)} km · $etaMin min · ${offer.dropAddress}',
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
