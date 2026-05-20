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
        title: (j['title'] ?? '').toString(),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: int.tryParse('${j['unitPrice'] ?? 0}') ?? 0,
        note: j['note'] as String?,
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

  /// Short id for display, e.g. `#WBK-3F9A2C`.
  String get shortId => '#${id.replaceAll('-', '').substring(0, 6).toUpperCase()}';

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
    int money(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
    final escrow = (j['escrowHold'] as Map?)?.cast<String, dynamic>();
    final delivery = (j['delivery'] as Map?)?.cast<String, dynamic>();
    final rider = (delivery?['rider'] as Map?)?.cast<String, dynamic>();
    return OrderModel(
      id: (j['id'] ?? '').toString(),
      state: (j['state'] ?? 'placed').toString(),
      subtotal: money(j['subtotal']),
      deliveryFee: money(j['deliveryFee']),
      serviceFee: money(j['serviceFee']),
      total: money(j['total']),
      placedAt:
          DateTime.tryParse('${j['placedAt'] ?? ''}') ?? DateTime.now(),
      items: ((j['items'] as List?) ?? const [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      escrowStatus: escrow?['status'] as String?,
      deliveryState: delivery?['state'] as String?,
      riderName: rider?['displayName'] as String?,
      notes: j['notes'] as String?,
      scheduledFor: j['scheduledFor'] != null
          ? DateTime.tryParse('${j['scheduledFor']}')
          : null,
    );
  }
}
