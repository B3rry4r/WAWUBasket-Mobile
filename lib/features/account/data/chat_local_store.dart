import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/models/chat_message.dart';
import '../domain/models/chat_thread.dart';

/// Offline-first cache for the chat inbox and per-thread message history.
///
/// The inbox screen and the chat detail screen render from this store
/// immediately on open — no spinner — then reconcile against the API in
/// the background. WebSocket frames upsert here too, so a message that
/// arrives while the user is on another screen is still on disk when
/// they return to the conversation.
class ChatLocalStore {
  ChatLocalStore._();
  static final ChatLocalStore instance = ChatLocalStore._();

  static const _dbName = 'wb_chat.db';
  static const _dbVersion = 1;

  Database? _db;
  Future<Database>? _opening;

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null && existing.isOpen) return existing;
    return _opening ??= () async {
      final dir = await getDatabasesPath();
      final path = p.join(dir, _dbName);
      final db = await openDatabase(
        path,
        version: _dbVersion,
        onConfigure: (d) async {
          await d.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (d, _) async {
          await d.execute('''
            CREATE TABLE chats (
              id TEXT PRIMARY KEY,
              orderId TEXT,
              title TEXT,
              lastMessage TEXT,
              lastMessageAt INTEGER,
              unreadCount INTEGER NOT NULL DEFAULT 0,
              updatedAt INTEGER NOT NULL
            )
          ''');
          await d.execute('''
            CREATE TABLE messages (
              id TEXT PRIMARY KEY,
              chatId TEXT NOT NULL,
              senderId TEXT,
              senderRole TEXT,
              body TEXT,
              attachmentUrl TEXT,
              createdAt INTEGER NOT NULL,
              isPending INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await d.execute(
            'CREATE INDEX idx_messages_chat_time '
            'ON messages(chatId, createdAt DESC)',
          );
        },
      );
      _db = db;
      _opening = null;
      return db;
    }();
  }

  // ── chats ────────────────────────────────────────────────────────────

  Future<void> upsertChat(ChatThread chat) async {
    final db = await _open();
    await db.insert(
      'chats',
      chat.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Bulk replace the entire inbox (used after a successful API sync to
  /// drop chats that no longer exist on the server). Preserves per-row
  /// `unreadCount` from the inbound list.
  Future<void> replaceAllChats(List<ChatThread> chats) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('chats');
      for (final c in chats) {
        await txn.insert('chats', c.toRow(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<ChatThread>> listChats() async {
    final db = await _open();
    final rows = await db.query(
      'chats',
      orderBy: 'lastMessageAt DESC, updatedAt DESC',
    );
    return [for (final r in rows) ChatThread.fromRow(r)];
  }

  Future<ChatThread?> findChat(String id) async {
    final db = await _open();
    final rows = await db.query(
      'chats',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChatThread.fromRow(rows.first);
  }

  /// Resolve a thread by either its chatId or its orderId — the inbox
  /// payload only carries one of them depending on the API surface.
  Future<ChatThread?> findChatByAnyId(String id) async {
    final db = await _open();
    final rows = await db.query(
      'chats',
      where: 'id = ? OR orderId = ?',
      whereArgs: [id, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChatThread.fromRow(rows.first);
  }

  Future<void> deleteChat(String id) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('chats', where: 'id = ?', whereArgs: [id]);
      await txn.delete('messages', where: 'chatId = ?', whereArgs: [id]);
    });
  }

  // ── messages ─────────────────────────────────────────────────────────

  Future<void> upsertMessage(ChatMessage m) async {
    final db = await _open();
    await db.insert(
      'messages',
      m.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMessages(List<ChatMessage> messages) async {
    if (messages.isEmpty) return;
    final db = await _open();
    await db.transaction((txn) async {
      for (final m in messages) {
        await txn.insert(
          'messages',
          m.toRow(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Returns messages for [chatId] in chronological order (oldest first),
  /// most recent [limit] only, optionally older than [before].
  Future<List<ChatMessage>> messagesForChat(
    String chatId, {
    int limit = 50,
    DateTime? before,
  }) async {
    final db = await _open();
    final where = StringBuffer('chatId = ?');
    final args = <Object?>[chatId];
    if (before != null) {
      where.write(' AND createdAt < ?');
      args.add(before.millisecondsSinceEpoch);
    }
    final rows = await db.query(
      'messages',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    final out = [for (final r in rows) ChatMessage.fromRow(r)];
    // Chronological order for display.
    out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return out;
  }

  /// Drop a pending placeholder once the server has acknowledged the send
  /// (the server-issued id replaces our optimistic temp id).
  Future<void> removeMessage(String id) async {
    final db = await _open();
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  /// Wipes every chat + message — called on logout so the next user
  /// doesn't see the previous user's conversations.
  Future<void> clearAll() async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('messages');
      await txn.delete('chats');
    });
  }
}
