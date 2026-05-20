import '../../../core/network/api_client.dart';

/// Wraps the `/v1/driver` freight endpoints.
class DriverApi {
  DriverApi._();
  static final DriverApi instance = DriverApi._();

  final _api = ApiClient.instance;

  /// Open loads across the network the driver can bid on.
  Future<List<dynamic>> openLoads() async {
    final res = await _api.get('/driver/loads');
    return (res as List?) ?? const [];
  }

  Future<void> submitBid(
    String loadId,
    int priceNaira,
    int etaHours,
    String notes,
  ) =>
      _api.post('/driver/loads/$loadId/bid', body: {
        'priceNaira': priceNaira,
        'etaHours': etaHours,
        'notes': ?(notes.isEmpty ? null : notes),
      });

  Future<void> logCheckpoint(String loadId) =>
      _api.post('/driver/loads/$loadId/checkpoint');

  /// The driver's currently assigned load, or null when idle.
  Future<Map<String, dynamic>?> activeTrip() async {
    final res = await _api.get('/driver/active-trip');
    if (res == null) return null;
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> earnings({String range = 'week'}) async {
    final res = await _api.get('/driver/earnings', query: {'range': range});
    return (res as Map).cast<String, dynamic>();
  }
}
