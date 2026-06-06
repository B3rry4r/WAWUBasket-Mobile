import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../data/account_extras_api.dart';
import '../../data/chat_api.dart';
import '../../data/chat_local_store.dart';
import '../../domain/models/chat_message.dart';

enum ChatContextKind { rider, support }

/// View-model wrapper used by the message list. Order threads carry a real
/// [ChatMessage] from the local store + WS; support threads are still
/// hand-rolled because they live on the support-ticket endpoint and don't
/// flow through the chat WS.
class _DisplayMessage {
  const _DisplayMessage({
    required this.body,
    required this.fromMe,
    required this.time,
    this.attachUrl,
    this.id,
    this.isPending = false,
  });

  final String body;
  final bool fromMe;
  final String time;
  final String? attachUrl;
  final String? id;
  final bool isPending;

  factory _DisplayMessage.fromOrderMessage(ChatMessage m) => _DisplayMessage(
        id: m.id,
        body: m.body,
        attachUrl: m.attachmentUrl,
        fromMe: m.senderRole == RoleController.instance.role.name,
        time: _fmtTime(m.createdAt),
        isPending: m.isPending,
      );

  factory _DisplayMessage.fromTicket(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? ''}');
    return _DisplayMessage(
      body: (j['body'] ?? '').toString(),
      fromMe: j['fromAdmin'] != true,
      time: _fmtTime(created),
    );
  }
}

String _fmtTime(DateTime? t) {
  if (t == null) return '';
  final l = t.toLocal();
  final h = l.hour.toString().padLeft(2, '0');
  final m = l.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.kind = ChatContextKind.support,
    this.orderId,
    this.title,
  });

  final ChatContextKind kind;

  /// The order whose chat thread to open (rider chats only).
  final String? orderId;

  /// Counterpart name shown in the header (passed by the inbox / call site).
  final String? title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _composer = TextEditingController();

  /// Support thread — a /v1/support ticket conversation.
  bool get _isSupport => widget.kind == ChatContextKind.support;

  /// Order thread — a /v1/chats conversation keyed by an order id.
  bool get _isOrder =>
      widget.kind == ChatContextKind.rider && widget.orderId != null;

  /// Order messages live in the local store. Support messages render
  /// straight from the ticket endpoint (kept in memory).
  List<ChatMessage> _orderMessages = const [];
  List<_DisplayMessage>? _supportMessages;

  /// True until the first paint of the message list has data (cache or
  /// API). After that we never block on loading again.
  bool _initialLoadDone = false;

  String? _error;
  bool _busy = false;

  /// The support ticket backing this thread, once one exists.
  String? _ticketId;

  StreamSubscription<WsFrame>? _wsSub;

  @override
  void initState() {
    super.initState();
    _load();
    if (_isOrder) {
      // Subscribe to the order's chat channel so we receive both sides of
      // the conversation in real time.
      WebSocketService.instance.subscribe(['order:${widget.orderId}']);
      _wsSub = WebSocketService.instance.chatFrames.listen(_onChatFrame);
    }
  }

  @override
  void dispose() {
    _composer.dispose();
    _wsSub?.cancel();
    if (_isOrder) {
      WebSocketService.instance.unsubscribe(['order:${widget.orderId}']);
    }
    super.dispose();
  }

  String _title(BuildContext context) {
    if (_isSupport) return context.l10n.chatLiveChat;
    final t = widget.title?.trim() ?? '';
    return t.isEmpty ? context.l10n.chatTitle : t;
  }

  String _sub(BuildContext context) {
    if (_isSupport) return context.l10n.chatRepliesIn;
    final id = widget.orderId;
    if (id == null) return '';
    return 'Order #${id.length > 8 ? id.substring(0, 8) : id}';
  }

  // ── load ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    if (_isSupport) {
      await _loadSupport();
      return;
    }
    if (!_isOrder) {
      setState(() => _initialLoadDone = true);
      return;
    }

    // Local cache first — instant paint.
    try {
      final cached = await ChatLocalStore.instance
          .messagesForChat(widget.orderId!);
      if (mounted) {
        setState(() {
          _orderMessages = cached;
          _initialLoadDone = true;
        });
      }
    } catch (_) {/* sqflite unavailable — fall through */}

    // Background reconcile.
    try {
      final fresh = await ChatApi.instance.messagesTyped(widget.orderId!);
      await ChatLocalStore.instance.upsertMessages(fresh);
      // Drop any local-pending messages that the server now knows about
      // — they'll be back via the fresh list with a real id.
      if (mounted) {
        setState(() {
          _orderMessages = fresh;
          _initialLoadDone = true;
          _error = null;
        });
      }
      ChatApi.instance.markRead(widget.orderId!).ignore();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (_orderMessages.isEmpty) {
        setState(() {
          _error = e.message;
          _initialLoadDone = true;
        });
      }
      // Otherwise keep the cached view; the user can scroll/send fine.
    } catch (_) {
      if (!mounted) return;
      setState(() => _initialLoadDone = true);
    }
  }

  /// Opens the user's most recent support ticket, if any.
  Future<void> _loadSupport() async {
    try {
      final tickets = await AccountExtrasApi.instance.tickets();
      if (tickets.isEmpty) {
        if (mounted) {
          setState(() {
            _supportMessages = const [];
            _initialLoadDone = true;
          });
        }
        return;
      }
      final latest = (tickets.first as Map).cast<String, dynamic>();
      final id = latest['id']?.toString();
      if (id == null) {
        if (mounted) {
          setState(() {
            _supportMessages = const [];
            _initialLoadDone = true;
          });
        }
        return;
      }
      final ticket = await AccountExtrasApi.instance.ticket(id);
      final msgs = (ticket['messages'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _ticketId = id;
        _supportMessages = [
          for (final e in msgs)
            _DisplayMessage.fromTicket((e as Map).cast<String, dynamic>()),
        ];
        _initialLoadDone = true;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _initialLoadDone = true;
        });
      }
    }
  }

  // ── real-time inbound ────────────────────────────────────────────────

  Future<void> _onChatFrame(WsFrame frame) async {
    if (!_isOrder) return;
    if (frame.type != 'chat.message') return;
    final orderId = frame.payload['orderId']?.toString();
    if (orderId != widget.orderId) return;

    final raw = (frame.payload['message'] as Map?)?.cast<String, dynamic>();
    if (raw == null) return;
    final incoming = ChatMessage.fromJson(raw, chatId: widget.orderId!);

    await ChatLocalStore.instance.upsertMessage(incoming);
    if (!mounted) return;

    setState(() {
      final next = [..._orderMessages];
      // Reconcile against any optimistic placeholder: same body + sender
      // and our pending flag set → replace with the server-confirmed row.
      final pendingIx = next.indexWhere(
        (m) =>
            m.isPending &&
            m.senderId == incoming.senderId &&
            m.body == incoming.body,
      );
      if (pendingIx >= 0) {
        next[pendingIx] = incoming;
      } else if (!next.any((m) => m.id == incoming.id)) {
        next.add(incoming);
      }
      next.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _orderMessages = next;
    });

    // We're currently viewing this thread — server-side read receipt.
    ChatApi.instance.markRead(widget.orderId!).ignore();
  }

  // ── outbound ─────────────────────────────────────────────────────────

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _busy || (!_isSupport && !_isOrder)) return;
    setState(() => _busy = true);
    try {
      if (_isSupport) {
        await _sendSupport(text);
      } else {
        await _sendOrderMessage(text);
      }
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendOrderMessage(String text, {String? attachKey}) async {
    // Optimistic insert with a temp id so the bubble appears immediately.
    final tempId =
        'pending-${DateTime.now().microsecondsSinceEpoch}';
    final pending = ChatMessage(
      id: tempId,
      chatId: widget.orderId!,
      senderId: 'me',
      senderRole: RoleController.instance.role.name,
      body: text,
      createdAt: DateTime.now(),
      isPending: true,
    );
    setState(() {
      _orderMessages = [..._orderMessages, pending];
      _composer.clear();
      _error = null;
    });
    await ChatLocalStore.instance.upsertMessage(pending);

    try {
      final sent = await ChatApi.instance.sendTyped(
        widget.orderId!,
        body: text,
        attachKey: attachKey,
      );
      // Swap the placeholder for the server-confirmed message.
      await ChatLocalStore.instance.removeMessage(tempId);
      await ChatLocalStore.instance.upsertMessage(sent);
      if (!mounted) return;
      setState(() {
        final next = _orderMessages.where((m) => m.id != tempId).toList();
        if (!next.any((m) => m.id == sent.id)) next.add(sent);
        next.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _orderMessages = next;
      });
    } catch (_) {
      // Leave the pending bubble in place so the user sees it didn't
      // confirm — they can tap to retry later. (For now, just surface.)
      rethrow;
    }
  }

  Future<void> _sendSupport(String text) async {
    if (_ticketId == null) {
      final ticket =
          await AccountExtrasApi.instance.createTicket('Live chat', text);
      final msgs = (ticket['messages'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _error = null;
        _ticketId = ticket['id']?.toString();
        _supportMessages = [
          for (final e in msgs)
            _DisplayMessage.fromTicket((e as Map).cast<String, dynamic>()),
        ];
        _composer.clear();
      });
    } else {
      final m = await AccountExtrasApi.instance.replyTicket(_ticketId!, text);
      if (!mounted) return;
      setState(() {
        _error = null;
        (_supportMessages ??= [])
            .add(_DisplayMessage.fromTicket(m.cast<String, dynamic>()));
        _composer.clear();
      });
    }
  }

  Future<void> _attach() async {
    if (_busy || !_isOrder) return;
    setState(() => _busy = true);
    try {
      final up = await UploadService.instance.pickAndUpload(
        folder: UploadFolder.chatAttachments,
      );
      if (up == null) return;
      // Body can be blank when the message is image-only.
      await _sendOrderMessage(_composer.text.trim(), attachKey: up.key);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (_) {
      if (mounted) {
        wbShowSnack(context, context.l10n.chatAttachmentFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── render ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                8,
              ),
              child: Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: WBColors.bgSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: WBIcon(
                      _isSupport ? WBIconName.message : WBIconName.bike,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title(context),
                          style: WBTypography.cardTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _sub(context),
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const WBDivider(),
            Expanded(child: _buildBody()),
            _buildComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        10,
        WBSpacing.screenPadding,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          if (_isOrder) ...[
            // Attachment button sits leading the composer so it's obvious
            // — the previous layout buried it past the send button.
            GestureDetector(
              onTap: _attach,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: WBColors.bgSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const WBIcon(WBIconName.plus, size: 18),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: WBColors.surfaceInput,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
              child: TextField(
                controller: _composer,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context.l10n.chatMessageHint,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: WBColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const WBIcon(
                      WBIconName.arrowRight,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_initialLoadDone) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
          ),
        ),
      );
    }
    final view = _isSupport
        ? (_supportMessages ?? const <_DisplayMessage>[])
        : [
            for (final m in _orderMessages) _DisplayMessage.fromOrderMessage(m),
          ];
    if (view.isEmpty) {
      if (_error != null) return _stateHint(_error!);
      return _stateHint(context.l10n.chatEmpty);
    }
    return _messageList(view);
  }

  Widget _stateHint(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WBSpacing.screenPadding),
        child: Container(
          padding: const EdgeInsets.all(WBSpacing.md + 4),
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(WBRadius.card),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
        ),
      ),
    );
  }

  Widget _messageList(List<_DisplayMessage> messages) {
    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.md,
        WBSpacing.screenPadding,
        WBSpacing.md,
      ),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _bubble(messages[messages.length - 1 - i]),
    );
  }

  Widget _bubble(_DisplayMessage m) {
    return Align(
      alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: m.isPending ? 0.65 : 1.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: m.fromMe ? WBColors.surfaceDark : WBColors.bgSoft,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(m.fromMe ? 18 : 4),
                bottomRight: Radius.circular(m.fromMe ? 4 : 18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.attachUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 240,
                        maxHeight: 240,
                      ),
                      child: WBNetworkImage(url: m.attachUrl!),
                    ),
                  ),
                  if (m.body.isNotEmpty) const SizedBox(height: 8),
                ],
                if (m.body.isNotEmpty)
                  Text(
                    m.body,
                    style: WBTypography.body.copyWith(
                      color: m.fromMe ? Colors.white : WBColors.fgHeader,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m.time,
                      style: WBTypography.caption.copyWith(
                        color: m.fromMe
                            ? Colors.white.withValues(alpha: 0.6)
                            : WBColors.fgPlaceholder,
                        fontSize: 11,
                      ),
                    ),
                    if (m.isPending) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: m.fromMe
                            ? Colors.white.withValues(alpha: 0.6)
                            : WBColors.fgPlaceholder,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
