import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/escrow_api.dart';
import '../domain/models/bulk_order.dart';

class EscrowController {
  EscrowController._() : orders = ValueNotifier<List<BulkOrder>>([]);
  static final EscrowController instance = EscrowController._();

  final ValueNotifier<List<BulkOrder>> orders;
  bool _loaded = false;

  final _api = EscrowApi.instance;

  BulkOrder? byId(String id) {
    for (final o in orders.value) {
      if (o.id == id) return o;
    }
    return null;
  }

  Future<void> load() async {
    try {
      final raw = await _api.listOrders();
      orders.value = [
        for (final e in raw)
          BulkOrder.fromApi((e as Map).cast<String, dynamic>()),
      ];
      _loaded = true;
    } on ApiException {
      // Keep existing list; a later refresh retries.
    }
  }

  Future<void> loadOnce() async {
    if (!_loaded) await load();
  }

  /// Places the order via the API and returns the created [BulkOrder]
  /// including the Flutterwave [checkoutUrl].
  Future<BulkOrder> place({
    required String listingId,
    required int quantityKg,
    required String dropoffAddress,
  }) async {
    final res = await _api.placeOrder(
      listingId: listingId,
      quantityKg: quantityKg,
      dropoffAddress: dropoffAddress,
    );

    final order = BulkOrder(
      id: (res['orderId'] ?? '').toString(),
      listingId: listingId,
      produce: (res['produce'] ?? 'Goods').toString(),
      quantityKg: quantityKg,
      pricePerKgNaira: _money(res['subtotalNaira']) ~/ (quantityKg > 0 ? quantityKg : 1),
      feeNaira: _money(res['feeNaira']),
      imageUrl: '',
      buyerName: '',
      buyerPhone: '',
      dropoffAddress: dropoffAddress,
      sellerName: (res['sellerName'] ?? '').toString(),
      sellerRegion: (res['sellerRegion'] ?? '').toString(),
      method: PaymentMethod.bankTransfer,
      status: EscrowStatus.held,
      placedAt: DateTime.now(),
      checkoutUrl: res['checkoutUrl']?.toString(),
    );

    orders.value = [order, ...orders.value];
    return order;
  }

  Future<void> release(String id) async {
    await _api.release(id);
    _setStatus(id, EscrowStatus.released);
  }

  Future<void> dispute(String id, String reason) async {
    try {
      await _api.dispute(id, reason: reason);
      final o = byId(id);
      if (o == null) return;
      o.disputeReason = reason;
      o.status = EscrowStatus.disputed;
      _bump();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> markDeliveredBySeller(String id) async {
    try {
      await _api.markDelivered(id);
      final o = byId(id);
      if (o == null) return;
      o.markedDeliveredBySeller = true;
      _bump();
    } on ApiException {
      rethrow;
    }
  }

  void _setStatus(String id, EscrowStatus next) {
    final o = byId(id);
    if (o == null) return;
    o.status = next;
    _bump();
  }

  void _bump() => orders.value = List.of(orders.value);

  static int _money(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
