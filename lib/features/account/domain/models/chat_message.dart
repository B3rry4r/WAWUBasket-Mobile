/// A single message in a chat thread.
///
/// Persisted to [ChatLocalStore] so the conversation renders instantly on
/// re-open. `isPending` flags messages the user has just sent but the API
/// hasn't acknowledged yet — they show in the UI with a subtle indicator
/// and are reconciled (matched by id) when the WS frame echoes back.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
    this.attachmentUrl,
    this.isPending = false,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String senderRole;
  final String body;
  final DateTime createdAt;
  final String? attachmentUrl;
  final bool isPending;

  /// Builds a message from the REST/WS payload. The API uses `attachUrl`
  /// for the resolved public URL; older payloads may include `attachKey`
  /// instead, in which case the screen layer is responsible for resolving.
  factory ChatMessage.fromJson(
    Map<String, dynamic> j, {
    required String chatId,
  }) {
    final created =
        DateTime.tryParse('${j['createdAt'] ?? ''}') ?? DateTime.now();
    final attach = (j['attachUrl'] ?? '').toString();
    return ChatMessage(
      id: (j['id'] ?? '').toString(),
      chatId: chatId,
      senderId: (j['senderId'] ?? '').toString(),
      senderRole: (j['senderRole'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
      createdAt: created,
      attachmentUrl: attach.isEmpty ? null : attach,
    );
  }

  Map<String, dynamic> toRow() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'senderRole': senderRole,
        'body': body,
        'attachmentUrl': attachmentUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'isPending': isPending ? 1 : 0,
      };

  factory ChatMessage.fromRow(Map<String, Object?> r) => ChatMessage(
        id: r['id'] as String,
        chatId: r['chatId'] as String,
        senderId: (r['senderId'] as String?) ?? '',
        senderRole: (r['senderRole'] as String?) ?? '',
        body: (r['body'] as String?) ?? '',
        attachmentUrl: r['attachmentUrl'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (r['createdAt'] as int?) ?? 0,
        ),
        isPending: ((r['isPending'] as int?) ?? 0) == 1,
      );

  ChatMessage copyWith({
    String? id,
    bool? isPending,
    String? attachmentUrl,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        chatId: chatId,
        senderId: senderId,
        senderRole: senderRole,
        body: body,
        createdAt: createdAt,
        attachmentUrl: attachmentUrl ?? this.attachmentUrl,
        isPending: isPending ?? this.isPending,
      );
}
