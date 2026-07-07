import '../../../core/network/api_client.dart';
import '../../../core/network/api_parse.dart';

/// The server-computed charge for the current cart against a delivery address.
///
/// This is the authoritative preview of what checkout will bill: the backend
/// uses distance-tiered delivery + an uncapped service fee, which the local
/// [WbPricing] estimate deliberately does not model. Money fields arrive as
/// BigInt-serialised strings and are parsed with [safeMoney].
class OrderQuote {
  const OrderQuote({
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
    required this.currency,
  });

  final int subtotal;
  final int serviceFee;
  final int deliveryFee;
  final int total;
  final String currency;

  factory OrderQuote.fromJson(Map<String, dynamic> j) => OrderQuote(
        subtotal: safeMoney(j['subtotal'], field: 'subtotal'),
        serviceFee: safeMoney(j['serviceFee'], field: 'serviceFee', orZero: true),
        deliveryFee: safeMoney(j['deliveryFee'], field: 'deliveryFee', orZero: true),
        total: safeMoney(j['total'], field: 'total'),
        currency: safeString(j['currency'], fallback: 'NGN'),
      );
}

/// Wraps the `/v1/orders` endpoints. All calls require a session.
class OrdersApi {
  OrdersApi._();
  static final OrdersApi instance = OrdersApi._();

  final _api = ApiClient.instance;

  /// Fetches the exact charge for the current cart delivered to [addressId] —
  /// the source of truth for the total shown at checkout. See [OrderQuote].
  Future<OrderQuote> quote({required String addressId}) async {
    final res = await _api.get('/orders/quote', query: {'addressId': addressId});
    return OrderQuote.fromJson(safeMap(res, context: 'orderQuote'));
  }

  /// Places an order from the current cart. Returns the raw payload —
  /// includes `id` and the escrow `checkoutUrl`.
  Future<Map<String, dynamic>> placeOrder({
    String? addressId,
    String? notes,
    String? promoCode,
    String? scheduledFor,
    String? paymentMethod,
    String? recipientName,
    String? recipientPhone,
    String? platform,
  }) async {
    final body = <String, dynamic>{};
    if (addressId != null) body['addressId'] = addressId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (promoCode != null && promoCode.isNotEmpty) body['promoCode'] = promoCode;
    if (scheduledFor != null) body['scheduledFor'] = scheduledFor;
    if (paymentMethod != null) body['paymentMethod'] = paymentMethod;
    if (recipientName != null && recipientName.isNotEmpty) body['recipientName'] = recipientName;
    if (recipientPhone != null && recipientPhone.isNotEmpty) body['recipientPhone'] = recipientPhone;
    if (platform != null) body['platform'] = platform;
    final res = await _api.post('/orders', body: body);
    return (res as Map).cast<String, dynamic>();
  }

  /// Asks the backend to confirm payment with Flutterwave and advance the order
  /// to `paid` if the charge succeeded — used on return from checkout so the
  /// order isn't stuck on "Awaiting payment" when the webhook is delayed or
  /// never arrives. Idempotent; returns the (possibly updated) order.
  Future<Map<String, dynamic>> verifyPayment(String id) async {
    final res = await _api.post('/orders/$id/verify-payment');
    return (res as Map).cast<String, dynamic>();
  }

  /// All of the signed-in customer's orders, newest first.
  Future<List<dynamic>> myOrders() async {
    final res = await _api.get('/orders');
    return (res as List?) ?? const [];
  }

  /// One order with its items, escrow, delivery, chat and dispute.
  Future<Map<String, dynamic>> orderDetail(String id) async {
    final res = await _api.get('/orders/$id');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> confirmDelivery(String id) =>
      _api.post('/orders/$id/confirm-delivery');

  Future<void> dispute(String id, String reason) =>
      _api.post('/orders/$id/dispute', body: {'reason': reason});

  Future<void> rate(String id, int score, {String? review}) =>
      _api.post('/orders/$id/rate', body: {
        'score': score,
        if (review != null && review.isNotEmpty) 'review': review,
      });

  Future<void> reorder(String id) => _api.post('/orders/$id/reorder');

  Future<void> reportIssue(String id, String type, {String? description}) {
    final body = <String, dynamic>{'type': type};
    if (description != null) body['description'] = description;
    return _api.post('/orders/$id/issues', body: body);
  }

  /// Available scheduled-delivery date + time slots.
  Future<List<dynamic>> deliverySlots() async {
    final res = await _api.get('/delivery-slots') as Map<String, dynamic>;
    return (res['dates'] as List?) ?? const [];
  }
}
