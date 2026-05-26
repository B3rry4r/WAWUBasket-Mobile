import '../../../core/network/api_client.dart';

/// Wraps the `/v1/agent` field-officer endpoints.
class AgentApi {
  AgentApi._();
  static final AgentApi instance = AgentApi._();

  final _api = ApiClient.instance;

  Future<List<dynamic>> linkedTraders({String? query}) async {
    final res = await _api.get('/agent/linked-traders',
        query: {'q': ?query});
    return (res as List?) ?? const [];
  }

  Future<Map<String, dynamic>> registerTrader(
      Map<String, dynamic> dto) async {
    final res = await _api.post('/agent/linked-traders', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> recordTransaction(
      Map<String, dynamic> dto) async {
    final res = await _api.post('/agent/transactions', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> recordPayout(Map<String, dynamic> dto) async {
    final res = await _api.post('/agent/payouts', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> commission() async {
    final res = await _api.get('/agent/commission');
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> earnings({String range = 'today'}) async {
    final res = await _api.get('/agent/earnings', query: {'range': range});
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> syncStatus() async {
    final res = await _api.get('/agent/sync-status');
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> dto) async {
    final res = await _api.post('/agent/orders', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<List<dynamic>> listPayouts() async {
    final res = await _api.get('/agent/payouts');
    return (res as List?) ?? const [];
  }
}
