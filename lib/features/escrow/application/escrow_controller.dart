import 'package:flutter/foundation.dart';

import '../domain/models/bulk_order.dart';

/// In-memory store of every escrow-backed bulk order. The buyer's status
/// screen and the seller's order dashboard both subscribe to the same
/// list, so a single transition (release / refund / dispute) updates
/// every surface.
class EscrowController {
  EscrowController._()
      : orders = ValueNotifier<List<BulkOrder>>([]) {
    orders.value = _seed();
  }
  static final EscrowController instance = EscrowController._();

  final ValueNotifier<List<BulkOrder>> orders;

  BulkOrder? byId(String id) {
    for (final o in orders.value) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Stage a new escrow order from the buyer checkout. Returns the new
  /// id so the caller can navigate straight into the status screen.
  String place(BulkOrder order) {
    orders.value = [order, ...orders.value];
    return order.id;
  }

  /// Buyer confirms receipt — releases the held amount to the seller.
  void release(String id) => _setStatus(id, EscrowStatus.released);

  /// Admin sided with the buyer (or buyer cancelled before delivery).
  void refund(String id) => _setStatus(id, EscrowStatus.refunded);

  /// Open a dispute with a reason. Stays in [EscrowStatus.disputed]
  /// until manual resolution.
  void dispute(String id, String reason) {
    final o = byId(id);
    if (o == null) return;
    o.disputeReason = reason;
    o.status = EscrowStatus.disputed;
    _bump();
  }

  /// Seller flags shipment ready so the buyer is nudged to confirm.
  void markDeliveredBySeller(String id) {
    final o = byId(id);
    if (o == null) return;
    o.markedDeliveredBySeller = true;
    _bump();
  }

  void _setStatus(String id, EscrowStatus next) {
    final o = byId(id);
    if (o == null) return;
    o.status = next;
    _bump();
  }

  void _bump() => orders.value = List.of(orders.value);

  /// One pre-existing order so the trader dashboard isn't empty on first
  /// run. Buyer/seller-side flows still work without it.
  List<BulkOrder> _seed() => [
        BulkOrder(
          id: 'ESC-${DateTime.now().millisecondsSinceEpoch}',
          listingId: 'EXP-1031',
          produce: 'Maize',
          quantityKg: 2000,
          pricePerKgNaira: 410,
          feeNaira: 12000,
          imageUrl:
              'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=600&q=80&auto=format&fit=crop',
          buyerName: 'Adunni Adesanya',
          buyerPhone: '+234 803 421 1820',
          dropoffAddress: 'Kano Central Market · Warehouse 14',
          sellerName: 'Sahel Grain Union',
          sellerRegion: 'Sokoto',
          method: PaymentMethod.bankTransfer,
          status: EscrowStatus.held,
          placedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];
}
