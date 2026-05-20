import '../../../core/network/api_client.dart';

/// Wraps the `/v1/vendor` endpoints. Every call needs a vendor session.
class VendorApi {
  VendorApi._();
  static final VendorApi instance = VendorApi._();

  final _api = ApiClient.instance;

  // ─── Orders ────────────────────────────────────────────────────────────

  Future<List<dynamic>> listOrders({String? state}) async {
    final res = await _api.get(
      '/vendor/orders',
      query: state == null ? null : {'state': state},
    );
    return (res as List?) ?? const [];
  }

  Future<void> acceptOrder(String id) =>
      _api.post('/vendor/orders/$id/accept');

  Future<void> rejectOrder(String id) =>
      _api.post('/vendor/orders/$id/reject');

  Future<void> markPreparing(String id) =>
      _api.post('/vendor/orders/$id/prepare');

  Future<void> markReady(String id) =>
      _api.post('/vendor/orders/$id/ready');

  Future<void> requestRider(String id, String vehicleType) =>
      _api.post('/vendor/orders/$id/request-rider',
          body: {'vehicleType': vehicleType});

  // ─── Products ──────────────────────────────────────────────────────────

  Future<List<dynamic>> listProducts() async {
    final res = await _api.get('/vendor/products');
    return (res as List?) ?? const [];
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> dto) async {
    final res = await _api.post('/vendor/products', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> dto) =>
      _api.patch('/vendor/products/$id', body: dto);

  Future<void> deleteProduct(String id) =>
      _api.delete('/vendor/products/$id');

  // ─── Inventory ─────────────────────────────────────────────────────────

  Future<List<dynamic>> listInventory({String? filter}) async {
    final res = await _api.get(
      '/vendor/inventory',
      query: filter == null ? null : {'filter': filter},
    );
    return (res as List?) ?? const [];
  }

  Future<Map<String, dynamic>> createInventoryItem(
      Map<String, dynamic> dto) async {
    final res = await _api.post('/vendor/inventory', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> updateInventoryItem(String id, Map<String, dynamic> dto) =>
      _api.patch('/vendor/inventory/$id', body: dto);

  // ─── Extras ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> analytics({String range = '7d'}) async {
    final res = await _api.get('/vendor/analytics', query: {'range': range});
    return (res as Map).cast<String, dynamic>();
  }

  Future<List<dynamic>> reviews() async {
    final res = await _api.get('/vendor/reviews');
    return (res as List?) ?? const [];
  }

  Future<void> replyReview(String id, String reply) =>
      _api.post('/vendor/reviews/$id/reply', body: {'reply': reply});

  Future<Map<String, dynamic>> settings() async {
    final res = await _api.get('/vendor/settings');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> updateSettings(Map<String, dynamic> dto) =>
      _api.patch('/vendor/settings', body: dto);

  Future<List<dynamic>> alerts() async {
    final res = await _api.get('/vendor/alerts');
    return (res as List?) ?? const [];
  }

  Future<List<dynamic>> payouts() async {
    final res = await _api.get('/vendor/payouts');
    return (res as List?) ?? const [];
  }
}
