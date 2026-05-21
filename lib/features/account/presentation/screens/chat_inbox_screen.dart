import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/chat_api.dart';

/// Surfaced chat section. WAWU Support is a universal entry point; the
/// order conversations below it come live from `/v1/chats` — everyone the
/// current role can message on its active orders.
class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  List<_Conversation>? _chats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final raw = await ChatApi.instance.inbox();
      if (!mounted) return;
      setState(() => _chats = [
            for (final e in raw)
              _Conversation.fromJson((e as Map).cast<String, dynamic>()),
          ]);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  void _open(_Conversation c) {
    final id = c.orderId;
    if (id == null) {
      context.push(AppRoutes.chatSupport);
      return;
    }
    context.push(
      Uri(
        path: AppRoutes.chatRider,
        queryParameters: {'orderId': id, 'title': c.name},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const support = _Conversation(
      name: 'WAWU Support',
      preview: 'Hey 👋 how can we help?',
      time: 'Now',
      unread: false,
      orderId: null,
    );
    final chats = _chats;

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chats', style: WBTypography.page),
                      Text(
                        'Talk to support and anyone on your active orders.',
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
                  _ConversationRow(
                    conversation: support,
                    onTap: () => _open(support),
                  ),
                  const WBDivider(),
                  if (chats == null && _error == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation(WBColors.surfaceDark),
                          ),
                        ),
                      ),
                    )
                  else if (_error != null)
                    _InboxHint(text: _error!)
                  else if (chats!.isEmpty)
                    const _InboxHint(
                      text: 'No order chats yet. They show up here once '
                          'you have an active order.',
                    )
                  else
                    for (var i = 0; i < chats.length; i++) ...[
                      _ConversationRow(
                        conversation: chats[i],
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

class _Conversation {
  const _Conversation({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.orderId,
  });

  final String name;
  final String preview;
  final String time;
  final bool unread;

  /// The order this thread belongs to. Null for the static support row.
  final String? orderId;

  factory _Conversation.fromJson(Map<String, dynamic> j) {
    final cp = (j['counterpart'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final at = DateTime.tryParse('${j['lastMessageAt'] ?? ''}');
    return _Conversation(
      name: (cp['name'] ?? 'Conversation').toString(),
      preview: (j['lastMessage'] ?? '').toString(),
      time: _ago(at),
      unread: j['unread'] == true,
      orderId: j['orderId']?.toString(),
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

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation, required this.onTap});
  final _Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    conversation.name,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.preview,
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
                  conversation.time,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgPlaceholder,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                if (conversation.unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: WBColors.statusError,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
