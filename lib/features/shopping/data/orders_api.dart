import '../../../core/network/api_client.dart';

/// Wraps the `/v1/orders` endpoints. All calls require a session.
class OrdersApi {
  OrdersApi._();
  static final OrdersApi instance = OrdersApi._();

  final _api = ApiClient.instance;

  /// Places an order from the current cart. Returns the raw payload —
  /// includes `id` and the escrow `checkoutUrl`.
  Future<Map<String, dynamic>> placeOrder({
    String? addressId,
    String? notes,
    String? promoCode,
    String? scheduledFor,
  }) async {
    final body = <String, dynamic>{};
    if (addressId != null) body['addressId'] = addressId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (promoCode != null && promoCode.isNotEmpty) body['promoCode'] = promoCode;
    if (scheduledFor != null) body['scheduledFor'] = scheduledFor;
    final res = await _api.post('/orders', body: body);
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
