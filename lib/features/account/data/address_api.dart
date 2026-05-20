import '../../../core/network/api_client.dart';

/// Wraps the `/v1/addresses` CRUD endpoints.
class AddressApi {
  AddressApi._();
  static final AddressApi instance = AddressApi._();

  final _api = ApiClient.instance;

  Future<List<dynamic>> list() async {
    final res = await _api.get('/addresses');
    return (res as List?) ?? const [];
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> dto) async {
    final res = await _api.post('/addresses', body: dto);
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> update(String id, Map<String, dynamic> dto) =>
      _api.patch('/addresses/$id', body: dto);

  Future<void> setDefault(String id) =>
      _api.patch('/addresses/$id/default');

  Future<void> remove(String id) => _api.delete('/addresses/$id');
}
