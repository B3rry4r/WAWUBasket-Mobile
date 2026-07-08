import '../../../core/network/api_client.dart';
import '../../../core/network/api_parse.dart';

/// Wraps the secondary account endpoints — notifications, favorites,
/// wallet and support.
class AccountExtrasApi {
  AccountExtrasApi._();
  static final AccountExtrasApi instance = AccountExtrasApi._();

  final _api = ApiClient.instance;

  // ─── Notifications ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> notifications() async {
    final res = await _api.get('/notifications');
    return safeMap(res, context: 'notifications');
  }

  Future<void> markNotificationRead(String id) =>
      _api.patch('/notifications/$id/read');

  Future<void> markAllNotificationsRead() =>
      _api.patch('/notifications/mark-all-read');

  // ─── Favorites ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> favorites() async {
    final res = await _api.get('/favorites');
    return safeMap(res, context: 'favorites');
  }

  Future<void> toggleFavoriteVendor(String id) =>
      _api.post('/favorites/vendors/$id');

  Future<void> toggleFavoriteItem(String id) =>
      _api.post('/favorites/items/$id');

  // ─── Wallet ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> wallet() async {
    final res = await _api.get('/wallet');
    return safeMap(res, context: 'wallet');
  }

  // ─── Support ───────────────────────────────────────────────────────────

  Future<List<dynamic>> faqs({String? query}) async {
    final q = query?.trim() ?? '';
    final res = await _api.get(
      '/support/faqs',
      query: q.isEmpty ? null : {'q': q},
    );
    return safeList(res, context: 'faqs');
  }

  Future<List<dynamic>> tickets() async {
    final res = await _api.get('/support/tickets');
    return safeList(res, context: 'tickets');
  }

  Future<Map<String, dynamic>> createTicket(
      String subject, String body) async {
    final res = await _api.post('/support/tickets',
        body: {'subject': subject, 'body': body});
    return safeMap(res, context: 'createTicket');
  }

  /// A single support ticket with its full message thread.
  Future<Map<String, dynamic>> ticket(String id) async {
    final res = await _api.get('/support/tickets/$id');
    return safeMap(res, context: 'ticket');
  }

  /// Posts a reply onto an existing support ticket.
  Future<Map<String, dynamic>> replyTicket(String id, String body) async {
    final res = await _api.post('/support/tickets/$id/reply',
        body: {'body': body});
    return safeMap(res, context: 'replyTicket');
  }
}
