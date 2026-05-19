import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

enum ChatContextKind { rider, support }

class _ChatMessage {
  const _ChatMessage(this.body, {required this.fromMe, required this.time});
  final String body;
  final bool fromMe;
  final String time;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.kind = ChatContextKind.support});
  final ChatContextKind kind;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _composer = TextEditingController();

  late final List<_ChatMessage> _messages = widget.kind == ChatContextKind.rider
      ? [
          const _ChatMessage(
            'Hi Brooks, I just picked up your order from Mama Cass.',
            fromMe: false,
            time: '12:34',
          ),
          const _ChatMessage(
            'Great — please use the gate on Akin Adesola, thank you!',
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

  String get _title =>
      widget.kind == ChatContextKind.rider ? 'Tunde · Rider' : 'Live chat';
  String get _sub => widget.kind == ChatContextKind.rider
      ? 'Honda CG · LAG 4892'
      : 'Replies usually in under 2 min';

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, fromMe: true, time: 'Now'));
      _composer.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            widget.kind == ChatContextKind.rider
                ? 'Got it 👍'
                : "Thanks — we'll follow up shortly.",
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
            Expanded(
              child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  WBSpacing.md,
                  WBSpacing.screenPadding,
                  WBSpacing.md,
                ),
                itemCount: _messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = _messages[_messages.length - 1 - i];
                  return Align(
                    alignment: m.fromMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.72,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: m.fromMe
                              ? WBColors.surfaceDark
                              : WBColors.bgSoft,
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
                            Text(
                              m.body,
                              style: WBTypography.body.copyWith(
                                color: m.fromMe
                                    ? Colors.white
                                    : WBColors.fgHeader,
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
                },
              ),
            ),
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
                      child: const WBIcon(
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
}
