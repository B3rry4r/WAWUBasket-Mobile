import '../../../core/network/api_client.dart';

/// Wraps the `/v1/rider` delivery endpoints.
class RiderApi {
  RiderApi._();
  static final RiderApi instance = RiderApi._();

  final _api = ApiClient.instance;

  Future<List<dynamic>> offers() async {
    final res = await _api.get('/rider/offers');
    return (res as List?) ?? const [];
  }

  Future<void> acceptOffer(String id) =>
      _api.post('/rider/offers/$id/accept');

  Future<void> declineOffer(String id) =>
      _api.post('/rider/offers/$id/decline');

  Future<void> updateLocation(double lat, double lng) =>
      _api.post('/rider/location', body: {'lat': lat, 'lng': lng});

  Future<void> markPickedUp(String deliveryId) =>
      _api.post('/rider/deliveries/$deliveryId/picked-up');

  Future<void> markInTransit(String deliveryId) =>
      _api.post('/rider/deliveries/$deliveryId/mark-in-transit');

  Future<void> markDelivered(String deliveryId) =>
      _api.post('/rider/deliveries/$deliveryId/delivered');

  Future<void> setOnline(bool online) =>
      _api.post('/rider/online', body: {'online': online});

  Future<Map<String, dynamic>> earnings({String range = 'week'}) async {
    final res = await _api.get('/rider/earnings', query: {'range': range});
    return (res as Map).cast<String, dynamic>();
  }
}
