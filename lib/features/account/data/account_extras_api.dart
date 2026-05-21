import '../../../core/network/api_client.dart';

/// Wraps the secondary account endpoints — notifications, favorites,
/// wallet, support and WAWU+ subscriptions.
class AccountExtrasApi {
  AccountExtrasApi._();
  static final AccountExtrasApi instance = AccountExtrasApi._();

  final _api = ApiClient.instance;

  // ─── Notifications ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> notifications() async {
    final res = await _api.get('/notifications');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> markNotificationRead(String id) =>
      _api.patch('/notifications/$id/read');

  Future<void> markAllNotificationsRead() =>
      _api.patch('/notifications/mark-all-read');

  // ─── Favorites ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> favorites() async {
    final res = await _api.get('/favorites');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> toggleFavoriteVendor(String id) =>
      _api.post('/favorites/vendors/$id');

  Future<void> toggleFavoriteItem(String id) =>
      _api.post('/favorites/items/$id');

  // ─── Wallet ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> wallet() async {
    final res = await _api.get('/wallet');
    return (res as Map).cast<String, dynamic>();
  }
}
