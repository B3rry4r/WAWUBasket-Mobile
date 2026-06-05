import '../../../../core/network/api_parse.dart';

/// One line of an order as returned by the API.
class OrderItemModel {
  const OrderItemModel({
    required this.title,
    required this.quantity,
    required this.unitPrice,
    this.note,
  });

  final String title;
  final int quantity;
  final int unitPrice;
  final String? note;

  int get lineTotal => unitPrice * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        title: safeString(j['title']),
        quantity: safeInt(j['quantity'], fallback: 1),
        unitPrice: safeMoney(j['unitPrice'], field: 'unitPrice'),
        note: safeStringOrNull(j['note']),
      );
}

/// A customer order. Mirrors the API `orders` payload (list + detail).
class OrderModel {
  const OrderModel({
    required this.id,
    required this.state,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.placedAt,
    required this.items,
    this.escrowStatus,
    this.deliveryState,
    this.riderName,
    this.notes,
    this.scheduledFor,
    this.parentOrderId,
    this.orderType,
    this.recipeId,
    this.recipeSizeId,
    this.childOrders = const [],
    this.vendorName,
  });

  final String id;
  final String state;
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int total;
  final DateTime placedAt;
  final List<OrderItemModel> items;
  final String? escrowStatus;
  final String? deliveryState;
  final String? riderName;
  final String? notes;
  final DateTime? scheduledFor;

  /// Parent order id when this is a child of a multi-vendor recipe order.
  final String? parentOrderId;

  /// `'recipe'` for the parent of a multi-vendor recipe pickup, otherwise
  /// `null` (regular single-vendor order).
  final String? orderType;
  final String? recipeId;
  final String? recipeSizeId;

  /// Populated on the parent recipe order — one per vendor we're sourcing
  /// ingredients from.
  final List<OrderModel> childOrders;

  /// Display name of the vendor fulfilling this (child) order.
  final String? vendorName;

  /// Convenience: this order is the parent of a multi-vendor recipe combo.
  bool get isRecipeParent =>
      orderType == 'recipe' && childOrders.isNotEmpty;

  /// Short id for display, e.g. `#WBK-3F9A2C`.
  String get shortId {
    final cleaned = id.replaceAll('-', '');
    final short = cleaned.length >= 6 ? cleaned.substring(0, 6) : cleaned;
    return '#${short.toUpperCase()}';
  }

  String get itemsSummary => items.map((i) => i.title).join(', ');

  /// Customer-facing status label derived from the order state machine.
  String get statusLabel => switch (state) {
        'placed' => 'Awaiting payment',
        'paid' => 'Paid',
        'accepted_by_vendor' => 'Accepted',
        'preparing' => 'Preparing',
        'ready' => 'Ready',
        'rider_assigned' => 'Rider assigned',
        'picked_up' => 'Picked up',
        'in_transit' => 'On the way',
        'delivered' => 'Delivered',
        'confirmed' => 'Completed',
        'settled' => 'Completed',
        'cancelled_by_customer' => 'Cancelled',
        'cancelled_by_vendor' => 'Cancelled',
        'refunded' => 'Refunded',
        'disputed' => 'Under review',
        _ => state,
      };

  bool get isActive => const [
        'placed',
        'paid',
        'accepted_by_vendor',
        'preparing',
        'ready',
        'rider_assigned',
        'picked_up',
        'in_transit',
      ].contains(state);

  bool get isCancelled => const [
        'cancelled_by_customer',
        'cancelled_by_vendor',
        'refunded',
      ].contains(state);

  bool get isDelivered =>
      const ['delivered', 'confirmed', 'settled'].contains(state);

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    final escrow = safeMap(j['escrowHold'], context: 'escrowHold');
    final delivery = safeMap(j['delivery'], context: 'delivery');
    final rider = safeMap(delivery['rider'], context: 'rider');
    final vendor = safeMap(j['vendor'], context: 'vendor');
    return OrderModel(
      id: safeString(j['id']),
      state: safeString(j['state'], fallback: 'placed'),
      // Core amounts are strict — a malformed value surfaces an error rather
      // than silently rendering a wrong total. Fees may legitimately be 0.
      subtotal: safeMoney(j['subtotal'], field: 'subtotal'),
      deliveryFee: safeMoney(j['deliveryFee'], field: 'deliveryFee', orZero: true),
      serviceFee: safeMoney(j['serviceFee'], field: 'serviceFee', orZero: true),
      total: safeMoney(j['total'], field: 'total'),
      placedAt: safeDate(j['placedAt']) ?? DateTime.now(),
      items: safeMapList(j['items'], context: 'orderItems')
          .map(OrderItemModel.fromJson)
          .toList(),
      escrowStatus: safeStringOrNull(escrow['status']),
      deliveryState: safeStringOrNull(delivery['state']),
      riderName: safeStringOrNull(rider['displayName']),
      notes: safeStringOrNull(j['notes']),
      scheduledFor: safeDate(j['scheduledFor']),
      parentOrderId: safeStringOrNull(j['parentOrderId']),
      orderType: safeStringOrNull(j['orderType']),
      recipeId: safeStringOrNull(j['recipeId']),
      recipeSizeId: safeStringOrNull(j['recipeSizeId']),
      vendorName:
          safeStringOrNull(vendor['displayName']) ?? safeStringOrNull(j['vendorName']),
      childOrders: safeMapList(j['childOrders'], context: 'childOrders')
          .map(OrderModel.fromJson)
          .toList(),
    );
  }
}
