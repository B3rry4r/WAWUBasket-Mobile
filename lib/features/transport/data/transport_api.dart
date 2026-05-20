import '../../../core/network/api_client.dart';

/// Wraps the trader-side `/v1/trader/loads` freight endpoints.
class TransportApi {
  TransportApi._();
  static final TransportApi instance = TransportApi._();

  final _api = ApiClient.instance;

  /// The signed-in trader's posted loads, newest first.
  Future<List<dynamic>> myLoads() async {
    final res = await _api.get('/trader/loads');
    return (res as List?) ?? const [];
  }

  Future<Map<String, dynamic>> postLoad(Map<String, dynamic> dto) async {
    final res = await _api.post('/trader/loads', body: dto);
    return (res as Map).cast<String, dynamic>();
  }
}
