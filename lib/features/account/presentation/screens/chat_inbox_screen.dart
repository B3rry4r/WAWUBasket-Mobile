import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import 'chat_screen.dart';

/// Surfaced chat section. Lists everyone the current role can message —
/// WAWU Support is universal; the contextual contact changes with the
/// role (customer ↔ rider, vendor ↔ rider, agent ↔ trader, etc).
class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  List<_Conversation> _conversationsFor(AppRole role) {
    final support = const _Conversation(
      name: 'WAWU Support',
      preview: 'Hey 👋 how can we help?',
      time: 'Now',
      kind: ChatContextKind.support,
      unread: true,
    );
    switch (role) {
      case AppRole.customer:
        return [
          const _Conversation(
            name: 'Tunde · Rider',
            preview: 'On my way, ETA 12 min.',
            time: '12:35',
            kind: ChatContextKind.rider,
            unread: true,
          ),
          support,
        ];
      case AppRole.vendor:
        return [
          const _Conversation(
            name: 'Tunde · Rider',
            preview: "I'm outside for order WAWU-8821.",
            time: '12:31',
            kind: ChatContextKind.rider,
          ),
          support,
        ];
      case AppRole.rider:
        return [
          const _Conversation(
            name: 'Adunni · Customer',
            preview: 'Please use the Akin Adesola gate.',
            time: '12:35',
            kind: ChatContextKind.rider,
            unread: true,
          ),
          support,
        ];
      case AppRole.trader:
      case AppRole.agent:
      case AppRole.driver:
        return [
          const _Conversation(
            name: 'Hauwa · Trader',
            preview: 'Load is ready for pickup at the depot.',
            time: '11:02',
            kind: ChatContextKind.rider,
          ),
          support,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = RoleController.instance.role;
    final conversations = _conversationsFor(role);

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
                  for (var i = 0; i < conversations.length; i++) ...[
                    _ConversationRow(
                      conversation: conversations[i],
                      onTap: () => context.push(
                        conversations[i].kind == ChatContextKind.rider
                            ? AppRoutes.chatRider
                            : AppRoutes.chatSupport,
                      ),
                    ),
                    if (i != conversations.length - 1) const WBDivider(),
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

class _Conversation {
  const _Conversation({
    required this.name,
    required this.preview,
    required this.time,
    required this.kind,
    this.unread = false,
  });
  final String name;
  final String preview;
  final String time;
  final ChatContextKind kind;
  final bool unread;
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
