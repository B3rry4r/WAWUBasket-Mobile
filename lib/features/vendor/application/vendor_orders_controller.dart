import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/vendor_api.dart';

/// State machine an order moves through from the vendor's perspective.
/// Mirrors the lifecycle in the build-guide order service (pending →
/// confirmed → preparing → ready → picked_up → en_route → delivered).
/// Vehicle category the vendor picks when requesting a delivery rider.
/// Matched against the rider pool's KYC-declared vehicle so a hot soup
/// order doesn't end up on a bicycle.
enum RiderType { bicycle, motorbike, car }

extension RiderTypeX on RiderType {
  String get label => switch (this) {
        RiderType.bicycle => 'Bicycle',
        RiderType.motorbike => 'Motorbike',
        RiderType.car => 'Car',
      };

  String get hint => switch (this) {
        RiderType.bicycle => 'Small parcels, under 2 km',
        RiderType.motorbike => 'Standard food orders',
        RiderType.car => 'Bulky items, multi-vendor baskets',
      };

  /// The `VehicleType` enum value the API expects.
  String get apiValue => switch (this) {
        RiderType.bicycle => 'bicycle',
        RiderType.motorbike => 'motorbike',
        RiderType.car => 'car',
      };
}

enum OrderStage {
  pending,
  preparing,
  ready,
  handover,
  done,
  declined,
}

extension OrderStageX on OrderStage {
  String get label => switch (this) {
        OrderStage.pending => 'Pending',
        OrderStage.preparing => 'Preparing',
        OrderStage.ready => 'Ready',
        OrderStage.handover => 'Picked up',
        OrderStage.done => 'Delivered',
        OrderStage.declined => 'Declined',
      };

  /// What the next forward action does. `null` for terminal stages.
  ({String label, OrderStage next})? get advance => switch (this) {
        OrderStage.pending =>
          (label: 'Accept order', next: OrderStage.preparing),
        OrderStage.preparing =>
          (label: 'Mark ready', next: OrderStage.ready),
        OrderStage.ready =>
          (label: 'Handover to rider', next: OrderStage.handover),
        OrderStage.handover =>
          (label: 'Mark delivered', next: OrderStage.done),
        OrderStage.done || OrderStage.declined => null,
      };
}

/// Maps an API `OrderState` string onto the vendor-facing [OrderStage].
OrderStage _stageFromState(String state) => switch (state) {
      'placed' || 'paid' => OrderStage.pending,
      'accepted_by_vendor' || 'preparing' => OrderStage.preparing,
      'ready' => OrderStage.ready,
      'rider_assigned' || 'picked_up' || 'in_transit' => OrderStage.handover,
      'delivered' || 'confirmed' || 'settled' => OrderStage.done,
      'cancelled_by_customer' ||
      'cancelled_by_vendor' ||
      'refunded' ||
      'disputed' =>
        OrderStage.declined,
      _ => OrderStage.pending,
    };

RiderType? _riderTypeFromVehicle(String? vehicle) => switch (vehicle) {
      'bicycle' => RiderType.bicycle,
      'motorbike' || 'motorcycle' => RiderType.motorbike,
      'car' || 'van' || 'truck' => RiderType.car,
      _ => null,
    };

/// Money fields cross the wire as BigInt strings; coerce to a plain int.
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

List<String> _modifiers(dynamic raw) {
  if (raw is! List) return const [];
  return [
    for (final m in raw)
      if (m is String)
        m
      else if (m is Map)
        (m['label'] ?? m['name'] ?? m['value'] ?? '').toString()
      else
        m.toString(),
  ].where((s) => s.isNotEmpty).toList();
}

/// One line item inside a [VendorOrder]. `mods` is the free-text summary of
/// the modifiers the customer chose (e.g., "Hot · extra plantain").
class OrderItem {
  const OrderItem({
    required this.name,
    required this.qty,
    required this.priceNaira,
    this.mods = const [],
    this.note = '',
  });
  final String name;
  final int qty;
  final int priceNaira;
  final List<String> mods;
  final String note;

  int get lineTotal => qty * priceNaira;

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: (j['title'] ?? j['name'] ?? '').toString(),
        qty: (j['quantity'] as num?)?.toInt() ?? 1,
        priceNaira: _toInt(j['unitPrice']),
        mods: _modifiers(j['modifiers']),
        note: (j['note'] ?? '').toString(),
      );
}

class VendorOrder {
  VendorOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.placedMinsAgo,
    required this.stage,
    this.riderName,
    this.riderEta,
    this.riderType,
    this.specialInstructions = '',
    this.serviceFee = 200,
    this.deliveryFee = 600,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final List<OrderItem> items;
  final int placedMinsAgo;
  OrderStage stage;
  String? riderName;
  String? riderEta;

  /// The vehicle category the vendor requested when handing off. Drives
  /// which rider pool the dispatch service can match against.
  RiderType? riderType;
  final String specialInstructions;
  final int serviceFee;
  final int deliveryFee;

  int get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  int get total => subtotal + serviceFee + deliveryFee;

  factory VendorOrder.fromJson(Map<String, dynamic> j) {
    final placedAt = DateTime.tryParse('${j['placedAt'] ?? ''}')?.toLocal();
    final mins =
        placedAt == null ? 0 : DateTime.now().difference(placedAt).inMinutes;
    final customer = (j['customer'] as Map?)?.cast<String, dynamic>();
    final address = (j['address'] as Map?)?.cast<String, dynamic>();
    final delivery = (j['delivery'] as Map?)?.cast<String, dynamic>();
    final items = (j['items'] as List?)
            ?.map((e) =>
                OrderItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList() ??
        const <OrderItem>[];

    return VendorOrder(
      id: (j['id'] ?? '').toString(),
      customerName: (customer?['fullName'] ?? 'Customer').toString(),
      customerPhone: (customer?['phone'] ?? '').toString(),
      address: _addressLabel(address, j['dropoffAddress']),
      items: items,
      placedMinsAgo: mins < 0 ? 0 : mins,
      stage: _stageFromState('${j['state'] ?? ''}'),
      riderType: _riderTypeFromVehicle(delivery?['vehicleType']?.toString()),
      specialInstructions: (j['notes'] ?? '').toString(),
      serviceFee: _toInt(j['serviceFee']),
      deliveryFee: _toInt(j['deliveryFee']),
    );
  }
}

String _addressLabel(Map<String, dynamic>? address, dynamic fallback) {
  if (address != null) {
    final line = (address['line'] ?? '').toString();
    final apt = (address['apartment'] ?? '').toString();
    final note = (address['noteForRider'] ?? '').toString();
    return [line, apt, note].where((s) => s.isNotEmpty).join(' · ');
  }
  return (fallback ?? '').toString();
}

/// Live state for the vendor's order board, backed by `/v1/vendor/orders`.
/// Screens listen to [orders]; mutations update optimistically and then
/// reconcile against the server.
class VendorOrdersController {
  VendorOrdersController._()
      : orders = ValueNotifier<List<VendorOrder>>([]) {
    load();
  }
  static final VendorOrdersController instance = VendorOrdersController._();

  final ValueNotifier<List<VendorOrder>> orders;
  final _api = VendorApi.instance;

  VendorOrder? byId(String id) {
    for (final o in orders.value) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Pulls the latest order board from the API.
  Future<void> load() async {
    try {
      final raw = await _api.listOrders();
      orders.value = [
        for (final e in raw)
          VendorOrder.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current board in place — a later refresh will retry.
    }
  }

  /// Advance an order to the next stage. No-op if it's already terminal.
  void advance(String id) {
    final o = byId(id);
    final next = o?.stage.advance;
    if (o == null || next == null) return;
    final from = o.stage;
    o.stage = next.next;
    if (next.next == OrderStage.handover && o.riderName == null) {
      o.riderEta = 'Finding a rider…';
    }
    _bump();
    _syncAdvance(o, from);
  }

  Future<void> _syncAdvance(VendorOrder o, OrderStage from) async {
    try {
      switch (from) {
        case OrderStage.pending:
          await _api.acceptOrder(o.id);
          await load();
        case OrderStage.preparing:
          // The API state might be accepted_by_vendor (needs start_preparing)
          // or already preparing (skip straight to mark_ready). Attempt the
          // intermediate step and ignore the error if already past it.
          try {
            await _api.markPreparing(o.id);
          } on ApiException {
            // already in preparing state — proceed
          }
          await _api.markReady(o.id);
          await load();
        case OrderStage.ready:
          await _api.requestRider(
            o.id,
            (o.riderType ?? RiderType.motorbike).apiValue,
          );
          await load();
        case OrderStage.handover:
        case OrderStage.done:
        case OrderStage.declined:
          break;
      }
    } on ApiException {
      // Keep the optimistic stage; the next refresh reconciles it.
    }
  }

  void decline(String id) {
    final o = byId(id);
    if (o == null) return;
    o.stage = OrderStage.declined;
    _bump();
    _syncDecline(id);
  }

  Future<void> _syncDecline(String id) async {
    try {
      await _api.rejectOrder(id);
      await load();
    } on ApiException {
      // Keep the optimistic decline.
    }
  }

  void _bump() => orders.value = List.of(orders.value);
}
