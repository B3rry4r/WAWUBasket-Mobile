import '../../../core/network/api_client.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/chat_thread.dart';

/// Wraps the `/v1/chats` endpoints. Every chat thread is keyed by the
/// order id it belongs to.
class ChatApi {
  ChatApi._();
  static final ChatApi instance = ChatApi._();

  final _api = ApiClient.instance;

  /// Conversations the current role takes part in (raw payloads).
  Future<List<dynamic>> inbox() async {
    final res = await _api.get('/chats');
    return (res as List?) ?? const [];
  }

  /// Typed inbox — preferred over [inbox] for new call sites.
  Future<List<ChatThread>> listChats() async {
    final raw = await inbox();
    return [
      for (final e in raw)
        ChatThread.fromInbox((e as Map).cast<String, dynamic>()),
    ];
  }

  /// Messages on an order's chat thread, oldest first.
  Future<List<dynamic>> messages(String orderId) async {
    final res = await _api.get('/chats/$orderId/messages');
    final m = (res as Map).cast<String, dynamic>();
    return (m['messages'] as List?) ?? const [];
  }

  /// Typed message list — uses [orderId] as the local chat id so the
  /// local store and the inbox row stay in sync (the API materialises
  /// `chat.id` lazily on first send).
  Future<List<ChatMessage>> messagesTyped(String orderId) async {
    final raw = await messages(orderId);
    return [
      for (final e in raw)
        ChatMessage.fromJson(
          (e as Map).cast<String, dynamic>(),
          chatId: orderId,
        ),
    ];
  }

  /// Marks all messages in this thread as read for the current user.
  Future<void> markRead(String orderId) =>
      _api.patch('/chats/$orderId/read');

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

  /// Typed send — convenience over [sendMessage] that returns a parsed
  /// [ChatMessage] keyed by [orderId].
  Future<ChatMessage> sendTyped(
    String orderId, {
    required String body,
    String? attachKey,
  }) async {
    final m = await sendMessage(orderId, body: body, attachKey: attachKey);
    return ChatMessage.fromJson(m, chatId: orderId);
  }
}
