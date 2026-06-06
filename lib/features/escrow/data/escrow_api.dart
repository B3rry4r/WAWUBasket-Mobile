import '../../../core/network/api_client.dart';

class EscrowApi {
  EscrowApi._();
  static final EscrowApi instance = EscrowApi._();

  final _api = ApiClient.instance;

  Future<List<dynamic>> listOrders() async {
    final res = await _api.get('/escrow/orders');
    return (res as List?) ?? const [];
  }

  /// Returns the placed order with checkoutUrl from the Flutterwave escrow.
  Future<Map<String, dynamic>> placeOrder({
    required String listingId,
    required int quantityKg,
    required String dropoffAddress,
    String method = 'bank_transfer',
  }) async {
    final res = await _api.post('/escrow/orders', body: {
      'listingId': listingId,
      'quantityKg': quantityKg,
      'dropoffAddress': dropoffAddress,
      'method': method,
    });
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> markDelivered(String orderId) =>
      _api.post('/escrow/orders/$orderId/mark-delivered', body: {});

  Future<void> release(String orderId) =>
      _api.post('/escrow/orders/$orderId/release', body: {});

  Future<void> dispute(
    String orderId, {
    String? reason,
    List<String> photoKeys = const [],
  }) =>
      _api.post('/escrow/orders/$orderId/dispute', body: {
        'reason': reason ?? 'Disputed by buyer',
        // Object keys for any photo evidence the buyer attached, uploaded to
        // R2 via the storage presign flow. Followup: confirm the backend
        // persists `photoKeys` on the dispute record.
        if (photoKeys.isNotEmpty) 'photoKeys': photoKeys,
      });
}
