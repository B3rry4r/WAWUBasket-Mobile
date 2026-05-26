import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../auth/application/role_controller.dart';
import '../../data/account_extras_api.dart';
import '../../data/chat_api.dart';

enum ChatContextKind { rider, support }

class _ChatMessage {
  const _ChatMessage(
    this.body, {
    required this.fromMe,
    required this.time,
    this.attachUrl,
  });
  final String body;
  final bool fromMe;
  final String time;
  final String? attachUrl;

  /// An order chat message. "From me" when the sender role matches the
  /// active role — each order thread has one participant per role.
  factory _ChatMessage.fromChat(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? ''}');
    final attach = (j['attachUrl'] ?? '').toString();
    return _ChatMessage(
      (j['body'] ?? '').toString(),
      fromMe: (j['senderRole'] ?? '').toString() ==
          RoleController.instance.role.name,
      time: _fmtTime(created),
      attachUrl: attach.isEmpty ? null : attach,
    );
  }

  /// A support-ticket message. "From me" unless it came from an admin.
  factory _ChatMessage.fromTicket(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? ''}');
    return _ChatMessage(
      (j['body'] ?? '').toString(),
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

  List<_ChatMessage>? _messages;
  String? _error;
  bool _busy = false;

  /// The support ticket backing this thread, once one exists.
  String? _ticketId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _composer.dispose();
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

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      if (_isSupport) {
        await _loadSupport();
      } else if (_isOrder) {
        final raw = await ChatApi.instance.messages(widget.orderId!);
        // Mark messages as read — fire and forget, non-critical
        ChatApi.instance.markRead(widget.orderId!).ignore();
        if (!mounted) return;
        setState(() => _messages = [
              for (final e in raw)
                _ChatMessage.fromChat((e as Map).cast<String, dynamic>()),
            ]);
      } else {
        setState(() => _messages = []);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  /// Opens the user's most recent support ticket, if any.
  Future<void> _loadSupport() async {
    final tickets = await AccountExtrasApi.instance.tickets();
    if (tickets.isEmpty) {
      if (mounted) setState(() => _messages = []);
      return;
    }
    final latest = (tickets.first as Map).cast<String, dynamic>();
    final id = latest['id']?.toString();
    if (id == null) {
      if (mounted) setState(() => _messages = []);
      return;
    }
    final ticket = await AccountExtrasApi.instance.ticket(id);
    final msgs = (ticket['messages'] as List?) ?? const [];
    if (!mounted) return;
    setState(() {
      _ticketId = id;
      _messages = [
        for (final e in msgs)
          _ChatMessage.fromTicket((e as Map).cast<String, dynamic>()),
      ];
    });
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _busy || (!_isSupport && !_isOrder)) return;
    setState(() => _busy = true);
    try {
      if (_isSupport) {
        await _sendSupport(text);
      } else {
        final m =
            await ChatApi.instance.sendMessage(widget.orderId!, body: text);
        if (!mounted) return;
        setState(() {
          _error = null;
          (_messages ??= [])
              .add(_ChatMessage.fromChat(m.cast<String, dynamic>()));
          _composer.clear();
        });
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Sends on the support thread — opening a ticket on the first message,
  /// replying to it afterwards.
  Future<void> _sendSupport(String text) async {
    if (_ticketId == null) {
      final ticket =
          await AccountExtrasApi.instance.createTicket('Live chat', text);
      final msgs = (ticket['messages'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _error = null;
        _ticketId = ticket['id']?.toString();
        _messages = [
          for (final e in msgs)
            _ChatMessage.fromTicket((e as Map).cast<String, dynamic>()),
        ];
        _composer.clear();
      });
    } else {
      final m = await AccountExtrasApi.instance.replyTicket(_ticketId!, text);
      if (!mounted) return;
      setState(() {
        _error = null;
        (_messages ??= [])
            .add(_ChatMessage.fromTicket(m.cast<String, dynamic>()));
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
      final m = await ChatApi.instance.sendMessage(
        widget.orderId!,
        body: _composer.text.trim(),
        attachKey: up.key,
      );
      if (!mounted) return;
      setState(() {
        _error = null;
        (_messages ??= [])
            .add(_ChatMessage.fromChat(m.cast<String, dynamic>()));
        _composer.clear();
      });
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } catch (_) {
      if (mounted) {
        wbShowSnack(context, context.l10n.chatAttachmentFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
            Padding(
              padding: EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                10,
                WBSpacing.screenPadding,
                10 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
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
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  if (_isOrder) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _attach,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: WBColors.bgSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(WBIconName.plus, size: 18),
                      ),
                    ),
                  ],
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_messages == null && _error == null) {
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
    if (_error != null) return _stateHint(_error!);
    final msgs = _messages!;
    if (msgs.isEmpty) {
      return _stateHint(context.l10n.chatEmpty);
    }
    return _messageList(msgs);
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

  Widget _messageList(List<_ChatMessage> messages) {
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

  Widget _bubble(_ChatMessage m) {
    return Align(
      alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
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
                  child: SizedBox(
                    width: 200,
                    height: 200,
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
              Text(
                m.time,
                style: WBTypography.caption.copyWith(
                  color: m.fromMe
                      ? Colors.white.withValues(alpha: 0.6)
                      : WBColors.fgPlaceholder,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
