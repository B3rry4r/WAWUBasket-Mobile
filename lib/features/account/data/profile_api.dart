import '../../../core/network/api_client.dart';

/// Wraps the `/v1/profile` endpoints.
class ProfileApi {
  ProfileApi._();
  static final ProfileApi instance = ProfileApi._();

  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> get() async {
    final res = await _api.get('/profile');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> update(Map<String, dynamic> dto) =>
      _api.patch('/profile', body: dto);

  Future<Map<String, dynamic>> stats() async {
    final res = await _api.get('/profile/stats');
    return (res as Map).cast<String, dynamic>();
  }
}
