import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../data/account_extras_api.dart';
import '../../data/chat_api.dart';
import '../../data/chat_local_store.dart';
import '../../domain/models/chat_thread.dart';

/// Desktop-web layout for the surfaced chat section. Mirrors
/// [ChatInboxScreen]'s data loading (local cache → live `/v1/chats` refresh →
/// WS updates), the WAWU Support universal entry point, and its error/empty
/// handling exactly — only the layout is re-flowed for desktop: a centered
/// single conversation column inside the shared customer web chrome.
class ChatInboxDesktopScreen extends StatefulWidget {
  const ChatInboxDesktopScreen({super.key});

  @override
  State<ChatInboxDesktopScreen> createState() => _ChatInboxDesktopScreenState();
}

class _ChatInboxDesktopScreenState extends State<ChatInboxDesktopScreen> {
  List<ChatThread>? _chats;
  String? _supportPreview;
  String? _supportTime;

  /// Set when the API call fails AND the local cache is empty — that's
  /// the only state where we surface a hint. With a populated cache we
  /// silently retry instead of taking the inbox offline.
  bool _showSilentError = false;
  String? _errorMessage;

  StreamSubscription<WsFrame>? _wsSub;

  @override
  void initState() {
    super.initState();
    _loadFromCache();
    _refreshFromApi();
    _loadSupport();
    _wsSub = WebSocketService.instance.chatFrames.listen(_onChatFrame);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await ChatLocalStore.instance.listChats();
      if (!mounted) return;
      setState(() => _chats = cached);
    } catch (_) {
      // sqflite unavailable — fall through to the network path.
    }
  }

  Future<void> _refreshFromApi() async {
    try {
      final fresh = await ChatApi.instance.listChats();
      await ChatLocalStore.instance.replaceAllChats(fresh);
      if (!mounted) return;
      setState(() {
        _chats = fresh;
        _showSilentError = false;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // Only surface the error when there's no cache to fall back on —
      // otherwise the inbox stays usable and we just retry next time.
      final hasCache = (_chats ?? const []).isNotEmpty;
      setState(() {
        _showSilentError = !hasCache;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      final hasCache = (_chats ?? const []).isNotEmpty;
      setState(() {
        _showSilentError = !hasCache;
        _errorMessage = context.l10n.chatInboxEmpty;
      });
    }
  }

  /// Best-effort: pull the latest support ticket so the support row shows a
  /// real last message. A failure just leaves the default prompt in place.
  Future<void> _loadSupport() async {
    try {
      final tickets = await AccountExtrasApi.instance.tickets();
      if (!mounted || tickets.isEmpty) return;
      final t = (tickets.first as Map).cast<String, dynamic>();
      final msgs = (t['messages'] as List?) ?? const [];
      final at = DateTime.tryParse('${t['updatedAt'] ?? ''}');
      setState(() {
        if (msgs.isNotEmpty) {
          final body = (msgs.first as Map)['body']?.toString() ?? '';
          if (body.isNotEmpty) _supportPreview = body;
        }
        _supportTime = _ago(at);
      });
    } catch (_) {
      // Support row still renders with its default prompt.
    }
  }

  void _onChatFrame(WsFrame frame) async {
    if (frame.type != 'chat.message') return;
    final orderId = frame.payload['orderId']?.toString();
    if (orderId == null || orderId.isEmpty) return;
    final msg = (frame.payload['message'] as Map?)?.cast<String, dynamic>();
    if (msg == null) return;
    final body = (msg['body'] ?? '').toString();
    final createdAt = DateTime.tryParse('${msg['createdAt'] ?? ''}') ??
        DateTime.now();

    final existing =
        await ChatLocalStore.instance.findChatByAnyId(orderId);
    final updated = (existing ??
            ChatThread(
              id: orderId,
              orderId: orderId,
              title: 'Conversation',
              lastMessage: '',
              lastMessageAt: createdAt,
              unreadCount: 0,
              updatedAt: createdAt,
            ))
        .copyWith(
      lastMessage: body,
      lastMessageAt: createdAt,
      unreadCount: (existing?.unreadCount ?? 0) + 1,
      updatedAt: DateTime.now(),
    );
    await ChatLocalStore.instance.upsertChat(updated);
    if (!mounted) return;
    final list = await ChatLocalStore.instance.listChats();
    if (!mounted) return;
    setState(() => _chats = list);
  }

  void _open(ChatThread c) {
    final id = c.orderId ?? c.id;
    if (id.isEmpty) {
      context.push(AppRoutes.chatSupport);
      return;
    }
    context.push(
      Uri(
        path: AppRoutes.chatRider,
        queryParameters: {'orderId': id, 'title': c.title},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportRow = _SupportRow(
      preview: _supportPreview ?? context.l10n.chatSupportPrompt,
      time: _supportTime ?? '',
      onTap: () => context.push(AppRoutes.chatSupport),
    );
    final chats = _chats;

    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
        child: WBMaxWidth(
          maxWidth: 720,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: WBSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.chatTitle,
                              style: WBTypography.page),
                          Text(
                            context.l10n.chatSubtitle,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                WBCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      supportRow,
                      const WBDivider(),
                      if (chats == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(
                                    WBColors.surfaceDark),
                              ),
                            ),
                          ),
                        )
                      else if (chats.isEmpty && _showSilentError)
                        _RetryHint(
                          message:
                              _errorMessage ?? context.l10n.chatInboxEmpty,
                          onRetry: _refreshFromApi,
                        )
                      else if (chats.isEmpty)
                        _InboxHint(text: context.l10n.chatInboxEmpty)
                      else
                        for (var i = 0; i < chats.length; i++) ...[
                          _ConversationRow(
                            thread: chats[i],
                            onTap: () => _open(chats[i]),
                          ),
                          if (i != chats.length - 1) const WBDivider(),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _ago(DateTime? t) {
  if (t == null) return '';
  final d = DateTime.now().difference(t.toLocal());
  if (d.inMinutes < 1) return 'Now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  return '${d.inDays}d';
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.preview,
    required this.time,
    required this.onTap,
  });
  final String preview;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                alignment: Alignment.center,
                child: const WBIcon(WBIconName.message, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAWU Support',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                time,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgPlaceholder,
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

class _InboxHint extends StatelessWidget {
  const _InboxHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
      ),
    );
  }
}

/// Subtle inline retry. Surfaces only when the local cache is empty AND
/// the API request failed — otherwise the inbox is rendered from cache
/// and the retry happens silently in the background.
class _RetryHint extends StatelessWidget {
  const _RetryHint({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onRetry,
              behavior: HitTestBehavior.opaque,
              child: Text(
                context.l10n.actionRetry,
                style: WBTypography.caption.copyWith(
                  color: WBColors.surfaceDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.thread, required this.onTap});
  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = thread.unreadCount > 0;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                alignment: Alignment.center,
                child: const WBIcon(WBIconName.message, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.title,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      thread.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _ago(thread.lastMessageAt),
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (unread)
                    Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: WBColors.statusError,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        thread.unreadCount > 99
                            ? '99+'
                            : thread.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
