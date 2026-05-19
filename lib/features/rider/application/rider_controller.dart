import 'package:flutter/foundation.dart';

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

/// One nearby delivery offer rendered on the rider's map + bottom-sheet
/// peek. After accepting, the offer is promoted to the active delivery.
class DeliveryOffer {
  const DeliveryOffer({
    required this.id,
    required this.vendorName,
    required this.vendorAddress,
    required this.vendorLat,
    required this.vendorLng,
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
  final String vendorName;
  final String vendorAddress;
  final double vendorLat;
  final double vendorLng;
  final String customerName;
  final String customerPhone;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double distanceKm;
  final int etaMin;
  final int feeNaira;
  final String specialInstructions;
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
        active = ValueNotifier<ActiveDelivery?>(null) {
    offers.value = _seedOffers();
  }
  static final RiderController instance = RiderController._();

  /// Rider's home coordinate — used to center the map and to give offer
  /// pins something to be offset from in the stylized fallback.
  static const riderLat = 6.4281; // Victoria Island, Lagos
  static const riderLng = 3.4216;

  final ValueNotifier<bool> online;
  final ValueNotifier<List<DeliveryOffer>> offers;
  final ValueNotifier<ActiveDelivery?> active;

  void toggleOnline() => online.value = !online.value;

  /// Promote an offer to the active delivery and pull it out of the
  /// nearby list. Idempotent — no-op if there's already an active.
  void accept(DeliveryOffer offer) {
    if (active.value != null) return;
    active.value = ActiveDelivery(offer: offer, stage: DeliveryStage.accepted);
    offers.value = [
      for (final o in offers.value)
        if (o.id != offer.id) o,
    ];
  }

  void advance() {
    final a = active.value;
    final next = a?.stage.advance;
    if (a == null || next == null) return;
    a.stage = next.next;
    active.value = ActiveDelivery(offer: a.offer, stage: a.stage);
  }

  /// Clear the active delivery after the rider closes the
  /// delivery-complete screen.
  void clearActive() {
    active.value = null;
  }

  List<DeliveryOffer> _seedOffers() => const [
        DeliveryOffer(
          id: 'WAWU-8821',
          vendorName: 'Mama Cass Kitchen',
          vendorAddress: '12 Adeola Odeku St, V/I',
          vendorLat: 6.4275,
          vendorLng: 3.4172,
          customerName: 'Adunni',
          customerPhone: '+234 803 421 1820',
          dropAddress: '7B Awolowo Rd, Ikoyi · Apt 12',
          dropLat: 6.4541,
          dropLng: 3.4326,
          distanceKm: 4.2,
          etaMin: 22,
          feeNaira: 600,
          specialInstructions: 'Call when you arrive — security will escort.',
        ),
        DeliveryOffer(
          id: 'WAWU-8822',
          vendorName: 'Suya & Smoke',
          vendorAddress: '24 Saka Tinubu St, V/I',
          vendorLat: 6.4309,
          vendorLng: 3.4234,
          customerName: 'Tobi',
          customerPhone: '+234 802 988 0421',
          dropAddress: '3 Sapele Rd, Lekki Phase 1',
          dropLat: 6.4474,
          dropLng: 3.4709,
          distanceKm: 6.1,
          etaMin: 28,
          feeNaira: 800,
        ),
        DeliveryOffer(
          id: 'WAWU-8825',
          vendorName: 'Iya Basira Buka',
          vendorAddress: '18 Kingsway Rd, Ikoyi',
          vendorLat: 6.4505,
          vendorLng: 3.4263,
          customerName: 'Kemi',
          customerPhone: '+234 805 117 7032',
          dropAddress: '5 Bourdillon Rd, Ikoyi',
          dropLat: 6.4577,
          dropLng: 3.4373,
          distanceKm: 2.8,
          etaMin: 16,
          feeNaira: 500,
        ),
        DeliveryOffer(
          id: 'WAWU-8830',
          vendorName: 'Chicken Republic',
          vendorAddress: '1 Akin Adesola, V/I',
          vendorLat: 6.4274,
          vendorLng: 3.4135,
          customerName: 'Daniel',
          customerPhone: '+234 802 244 9911',
          dropAddress: '20 Olosa St, V/I',
          dropLat: 6.4302,
          dropLng: 3.4187,
          distanceKm: 1.4,
          etaMin: 11,
          feeNaira: 450,
        ),
      ];
}
