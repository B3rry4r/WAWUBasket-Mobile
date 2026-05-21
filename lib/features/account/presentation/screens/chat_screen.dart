import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
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

  /// Maps a `/v1/chats` message payload. A message is "from me" when its
  /// sender role matches the active role — each order chat has one
  /// participant per role (customer / vendor / rider).
  factory _ChatMessage.fromJson(Map<String, dynamic> j) {
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

  /// The order whose chat thread to open. When set, the screen loads
  /// messages from the live API instead of showing the static placeholder.
  final String? orderId;

  /// Counterpart name shown in the header (passed by the inbox / call site).
  final String? title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _composer = TextEditingController();

  /// Live mode = a rider/order thread with an order id. Otherwise the
  /// screen falls back to the static support placeholder.
  bool get _live =>
      widget.kind == ChatContextKind.rider && widget.orderId != null;

  // Live-mode state.
  List<_ChatMessage>? _messages;
  String? _error;
  bool _busy = false;

  // Static fallback (support live-chat placeholder).
  late final List<_ChatMessage> _staticMessages =
      widget.kind == ChatContextKind.rider
          ? [
              const _ChatMessage(
                'Hi Brooks, I just picked up your order from Mama Cass.',
                fromMe: false,
                time: '12:34',
              ),
              const _ChatMessage(
                'Great, please use the gate on Akin Adesola, thank you!',
                fromMe: true,
                time: '12:35',
              ),
              const _ChatMessage(
                "On my way, ETA 12 min.",
                fromMe: false,
                time: '12:35',
              ),
            ]
          : [
              const _ChatMessage(
                'Hey 👋 thanks for reaching out. How can we help?',
                fromMe: false,
                time: 'Just now',
              ),
            ];

  @override
  void initState() {
    super.initState();
    if (_live) _load();
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  String get _title {
    if (_live) {
      final t = widget.title?.trim() ?? '';
      return t.isEmpty ? 'Conversation' : t;
    }
    return widget.kind == ChatContextKind.rider ? 'Tunde · Rider' : 'Live chat';
  }

  String get _sub {
    if (_live) {
      final id = widget.orderId!;
      return 'Order #${id.length > 8 ? id.substring(0, 8) : id}';
    }
    return widget.kind == ChatContextKind.rider
        ? 'Honda CG · LAG 4892'
        : 'Replies usually in under 2 min';
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final raw = await ChatApi.instance.messages(widget.orderId!);
      if (!mounted) return;
      setState(() => _messages = [
            for (final e in raw)
              _ChatMessage.fromJson((e as Map).cast<String, dynamic>()),
          ]);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final m = await ChatApi.instance.sendMessage(widget.orderId!, body: text);
      if (!mounted) return;
      setState(() {
        _error = null;
        (_messages ??= []).add(
          _ChatMessage.fromJson(m.cast<String, dynamic>()),
        );
        _composer.clear();
      });
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _attach() async {
    if (_busy) return;
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
        (_messages ??= []).add(
          _ChatMessage.fromJson(m.cast<String, dynamic>()),
        );
        _composer.clear();
      });
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } catch (_) {
      if (mounted) wbShowSnack(context, 'Could not send the attachment.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Static echo used by the support placeholder thread.
  void _sendStatic() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _staticMessages.add(_ChatMessage(text, fromMe: true, time: 'Now'));
      _composer.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _staticMessages.add(
          _ChatMessage(
            widget.kind == ChatContextKind.rider
                ? 'Got it 👍'
                : "Thanks, we'll follow up shortly.",
            fromMe: false,
            time: 'Now',
          ),
        );
      });
    });
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
                      widget.kind == ChatContextKind.rider
                          ? WBIconName.bike
                          : WBIconName.message,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: WBTypography.cardTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _sub,
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
                        onSubmitted: (_) => _live ? _send() : _sendStatic(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Message',
                          isCollapsed: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  if (_live) ...[
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
                    onTap: _live ? _send : _sendStatic,
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
    if (!_live) return _messageList(_staticMessages);
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
      return _stateHint('No messages yet. Send the first one below.');
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
