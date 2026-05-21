import '../../../core/network/api_client.dart';

/// Wraps the `/v1/chats` endpoints. Every chat thread is keyed by the
/// order id it belongs to.
class ChatApi {
  ChatApi._();
  static final ChatApi instance = ChatApi._();

  final _api = ApiClient.instance;

  /// Conversations the current role takes part in.
  Future<List<dynamic>> inbox() async {
    final res = await _api.get('/chats');
    return (res as List?) ?? const [];
  }

  /// Messages on an order's chat thread, oldest first.
  Future<List<dynamic>> messages(String orderId) async {
    final res = await _api.get('/chats/$orderId/messages');
    final m = (res as Map).cast<String, dynamic>();
    return (m['messages'] as List?) ?? const [];
  }

  /// Posts a message. [attachKey] is an uploaded R2 object key for an
  /// optional image attachment.
  Future<Map<String, dynamic>> sendMessage(
    String orderId, {
    required String body,
    String? attachKey,
  }) async {
    final payload = <String, dynamic>{'body': body};
    if (attachKey != null) payload['attachKey'] = attachKey;
    final res = await _api.post('/chats/$orderId/messages', body: payload);
    return (res as Map).cast<String, dynamic>();
  }
}
