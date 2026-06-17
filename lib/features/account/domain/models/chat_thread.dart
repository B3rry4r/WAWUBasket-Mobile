/// Lightweight chat thread for the inbox list. `id` is the chat id (or the
/// order id when the API hasn't materialised a chat row yet — `getInbox`
/// only returns chats that exist server-side).
class ChatThread {
  const ChatThread({
    required this.id,
    required this.orderId,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.updatedAt,
    this.counterpartId,
  });

  final String id;

  /// The order this thread belongs to. Drives chat-detail routing — null
  /// here means a support/system thread (rare; the inbox is order-keyed).
  final String? orderId;

  /// The counterpart's user id, when the inbox payload exposes it. Drives the
  /// blocked-user inbox filter and the "Block user" action in the thread
  /// header. Not persisted to the local cache (only present on the network
  /// path), so cached rows read it back as null.
  final String? counterpartId;

  final String title;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final DateTime updatedAt;

  factory ChatThread.fromInbox(Map<String, dynamic> j) {
    final cp = (j['counterpart'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final at = DateTime.tryParse('${j['lastMessageAt'] ?? ''}') ??
        DateTime.now();
    return ChatThread(
      id: (j['id'] ?? j['orderId'] ?? '').toString(),
      orderId: j['orderId']?.toString(),
      counterpartId: (cp['id'] ?? cp['userId'])?.toString(),
      title: (cp['name'] ?? 'Conversation').toString(),
      lastMessage: (j['lastMessage'] ?? '').toString(),
      lastMessageAt: at,
      unreadCount: (j['unreadCount'] is int)
          ? j['unreadCount'] as int
          : (j['unread'] == true ? 1 : 0),
      updatedAt: at,
    );
  }

  Map<String, Object?> toRow() => {
        'id': id,
        'orderId': orderId,
        'title': title,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
        'unreadCount': unreadCount,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory ChatThread.fromRow(Map<String, Object?> r) => ChatThread(
        id: r['id'] as String,
        orderId: r['orderId'] as String?,
        title: (r['title'] as String?) ?? 'Conversation',
        lastMessage: (r['lastMessage'] as String?) ?? '',
        lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
          (r['lastMessageAt'] as int?) ?? 0,
        ),
        unreadCount: (r['unreadCount'] as int?) ?? 0,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (r['updatedAt'] as int?) ?? 0,
        ),
      );

  ChatThread copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    DateTime? updatedAt,
  }) =>
      ChatThread(
        id: id,
        orderId: orderId,
        counterpartId: counterpartId,
        title: title,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
