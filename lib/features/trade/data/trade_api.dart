import '../../../core/network/api_client.dart';

/// Wraps the trader-side `/v1/trader/export-listings` endpoints and the
/// public `/v1/trade` catalog + corridor-price reads.
class TradeApi {
  TradeApi._();
  static final TradeApi instance = TradeApi._();

  final _api = ApiClient.instance;

  /// The signed-in trader's own export listings.
  Future<List<dynamic>> myExportListings() async {
    final res = await _api.get('/trader/export-listings');
    return (res as List?) ?? const [];
  }

  /// All active export listings — the customer `/trade` browse.
  Future<List<dynamic>> publicExportListings({
    String? origin,
    String? destination,
  }) async {
    final res = await _api.get('/trade/export-listings', query: {
      'origin': ?origin,
      'destination': ?destination,
    });
    return (res as List?) ?? const [];
  }

  Future<Map<String, dynamic>> createExportListing(
      Map<String, dynamic> dto) async {
    final res = await _api.post('/trader/export-listings', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> updateExportListing(String id, Map<String, dynamic> dto) =>
      _api.patch('/trader/export-listings/$id', body: dto);

  Future<void> deleteExportListing(String id) =>
      _api.delete('/trader/export-listings/$id');

  /// Last-known corridor prices, grouped per produce + origin.
  Future<List<dynamic>> corridorPrices() async {
    final res = await _api.get('/trade/corridor-prices');
    return (res as List?) ?? const [];
  }
}
