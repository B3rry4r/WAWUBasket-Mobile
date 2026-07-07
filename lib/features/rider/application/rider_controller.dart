import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/rider_api.dart';

/// Stage the active delivery is in. Mirrors the customer-facing tracking
/// progression but from the rider's perspective.
enum DeliveryStage {
  accepted,
  arrivedPickup,
  pickedUp,
  enRoute,
  delivered,
}

extension DeliveryStageX on DeliveryStage {
  String get label => switch (this) {
        DeliveryStage.accepted => 'Heading to vendor',
        DeliveryStage.arrivedPickup => 'At vendor',
        DeliveryStage.pickedUp => 'Picked up',
        DeliveryStage.enRoute => 'En route',
        DeliveryStage.delivered => 'Delivered',
      };

  /// Next-action button label. `null` once we're at [delivered].
  ({String label, DeliveryStage next})? get advance => switch (this) {
        DeliveryStage.accepted =>
          (label: "I'm at the vendor", next: DeliveryStage.arrivedPickup),
        DeliveryStage.arrivedPickup =>
          (label: 'Mark picked up', next: DeliveryStage.pickedUp),
        DeliveryStage.pickedUp =>
          (label: "I'm on the way", next: DeliveryStage.enRoute),
        DeliveryStage.enRoute =>
          (label: 'Mark delivered', next: DeliveryStage.delivered),
        DeliveryStage.delivered => null,
      };
}

int _riderInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

/// One nearby delivery offer rendered on the rider's map + bottom-sheet
/// peek. After accepting, the offer is promoted to the active delivery.
class DeliveryOffer {
  const DeliveryOffer({
    required this.id,
    required this.deliveryId,
    required this.orderId,
    required this.vendorName,
    required this.vendorAddress,
    required this.vendorLat,
    required this.vendorLng,
    required this.vendorPhone,
    required this.customerName,
    required this.customerPhone,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.distanceKm,
    required this.etaMin,
    required this.feeNaira,
    this.specialInstructions = '',
  });

  final String id;

  /// The underlying delivery id — what the picked-up / delivered
  /// endpoints key on (distinct from the offer [id]).
  final String deliveryId;

  /// The order this delivery belongs to — the key the chat thread uses.
  final String orderId;
  final String vendorName;
  final String vendorAddress;
  final double vendorLat;
  final double vendorLng;
  final String vendorPhone;
  final String customerName;
  final String customerPhone;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double distanceKm;
  final int etaMin;
  final int feeNaira;
  final String specialInstructions;

  /// Haversine distance (km) from an arbitrary point to this offer's
  /// pickup. Used to recompute the cards once we have the rider's GPS.
  double distanceKmFrom(double lat, double lng) =>
      _haversineKm(lat, lng, vendorLat, vendorLng);

  /// Rough ETA in minutes for the full pickup→drop journey from a given
  /// rider position, assuming a 25 km/h average across city traffic
  /// (15 minutes per 6 km, plus 5 minutes pickup handling).
  int etaMinFrom(double lat, double lng) {
    final pickup = distanceKmFrom(lat, lng);
    final delivery = _haversineKm(vendorLat, vendorLng, dropLat, dropLng);
    final hours = (pickup + delivery) / 25.0;
    return (hours * 60).round() + 5;
  }

  factory DeliveryOffer.fromJson(Map<String, dynamic> j) {
    final delivery = (j['delivery'] as Map?)?.cast<String, dynamic>() ?? const {};
    final order = (delivery['order'] as Map?)?.cast<String, dynamic>() ?? const {};
    final vendor = (order['vendor'] as Map?)?.cast<String, dynamic>() ?? const {};
    final address =
        (order['address'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DeliveryOffer(
      id: (j['id'] ?? '').toString(),
      deliveryId: (delivery['id'] ?? '').toString(),
      orderId: (order['id'] ?? '').toString(),
      vendorName: (vendor['businessName'] ?? 'Vendor').toString(),
      vendorAddress: (vendor['addressLine'] ?? '').toString(),
      vendorLat:
          (vendor['lat'] as num?)?.toDouble() ?? RiderController.riderLat,
      vendorLng:
          (vendor['lng'] as num?)?.toDouble() ?? RiderController.riderLng,
      vendorPhone: ((vendor['user'] as Map?)?.cast<String, dynamic>()?['phone'] ?? '').toString(),
      customerName: (order['recipientName'] ?? 'Customer').toString(),
      customerPhone: (order['recipientPhone'] ?? '').toString(),
      dropAddress:
          (address['line'] ?? order['dropoffAddress'] ?? '').toString(),
      dropLat:
          (address['lat'] as num?)?.toDouble() ?? RiderController.riderLat,
      dropLng:
          (address['lng'] as num?)?.toDouble() ?? RiderController.riderLng,
      distanceKm: (delivery['distanceKm'] as num?)?.toDouble() ?? 0,
      etaMin: (delivery['etaMin'] as num?)?.toInt() ?? 0,
      feeNaira: _riderInt(delivery['fee']),
      specialInstructions:
          (order['notes'] ?? address['noteForRider'] ?? '').toString(),
    );
  }
}

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180.0;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

class ActiveDelivery {
  ActiveDelivery({required this.offer, required this.stage});
  final DeliveryOffer offer;
  DeliveryStage stage;
}

class RiderController {
  RiderController._()
      : online = ValueNotifier(true),
        offers = ValueNotifier<List<DeliveryOffer>>([]),
        active = ValueNotifier<ActiveDelivery?>(null),
        mutationError = ValueNotifier<String?>(null);
  static final RiderController instance = RiderController._();

  /// Rider's home coordinate, used to center the map and to give offer
  /// pins something to be offset from in the stylized fallback.
  static const riderLat = 6.4281; // Victoria Island, Lagos
  static const riderLng = 3.4216;

  final ValueNotifier<bool> online;
  final ValueNotifier<List<DeliveryOffer>> offers;
  final ValueNotifier<ActiveDelivery?> active;

  /// Set to a non-null message when a mutation fails; screens can listen and
  /// show a snackbar, then reset to null.
  final ValueNotifier<String?> mutationError;

  final _api = RiderApi.instance;

  /// The rider's last known GPS reading. Null until permission is
  /// granted + a Geolocator one-shot returns. Drives the offer cards'
  /// distance + ETA labels so they reflect where the rider actually is.
  final ValueNotifier<({double lat, double lng})?> currentPosition =
      ValueNotifier(null);

  void updatePosition(double lat, double lng) {
    currentPosition.value = (lat: lat, lng: lng);
    // Best-effort server ping. Failures are non-fatal (the next fix retries)
    // but we log them so a persistently-failing uplink is diagnosable rather
    // than silently dropping the rider's location.
    _api.updateLocation(lat, lng).catchError(
      (Object e) => debugPrint('[rider] updateLocation failed: $e'),
    );
  }

  /// Pushes the current online state to the server. Called on screen init so
  /// the DB record matches the app's default-online state without waiting for
  /// the user to toggle.
  void syncOnline() {
    _api.setOnline(online.value).catchError(
      (Object e) => debugPrint('[rider] syncOnline failed: $e'),
    );
  }

  /// Pulls the rider's pending delivery offers from the API.
  Future<void> loadOffers() async {
    try {
      final raw = await _api.offers();
      offers.value = [
        for (final e in raw)
          DeliveryOffer.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh retries.
    }
  }

  void toggleOnline() {
    online.value = !online.value;
    _api.setOnline(online.value).catchError((Object e) {
      // Revert toggle and surface the error to listeners.
      online.value = !online.value;
      if (e is ApiException) mutationError.value = e.message;
    });
  }

  /// Promote an offer to the active delivery and pull it out of the nearby
  /// list. Throws [ApiException] if the server rejects the acceptance so the
  /// caller can show the error and the optimistic state is reverted.
  Future<void> accept(DeliveryOffer offer) async {
    if (active.value != null) return;
    active.value = ActiveDelivery(offer: offer, stage: DeliveryStage.accepted);
    offers.value = [for (final o in offers.value) if (o.id != offer.id) o];
    try {
      await _api.acceptOffer(offer.id);
    } on ApiException {
      active.value = null;
      offers.value = [offer, ...offers.value];
      rethrow;
    }
  }

  /// Advances the active delivery stage and notifies the server. Throws
  /// [ApiException] on server failure so the caller can show the error and
  /// the optimistic stage change is reverted.
  Future<void> advance() async {
    final a = active.value;
    final next = a?.stage.advance;
    if (a == null || next == null) return;
    final prevStage = a.stage;
    a.stage = next.next;
    active.value = ActiveDelivery(offer: a.offer, stage: a.stage);
    if (a.offer.deliveryId.isEmpty) return;
    try {
      if (a.stage == DeliveryStage.pickedUp) {
        await _api.markPickedUp(a.offer.deliveryId);
      } else if (a.stage == DeliveryStage.enRoute) {
        await _api.markInTransit(a.offer.deliveryId);
      } else if (a.stage == DeliveryStage.delivered) {
        await _api.markDelivered(a.offer.deliveryId);
      }
    } on ApiException {
      a.stage = prevStage;
      active.value = ActiveDelivery(offer: a.offer, stage: prevStage);
      rethrow;
    }
  }

  /// Clear the active delivery after the rider closes the
  /// delivery-complete screen.
  void clearActive() {
    active.value = null;
  }
}
