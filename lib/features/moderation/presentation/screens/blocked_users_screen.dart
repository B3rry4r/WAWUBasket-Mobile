import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/blocked_users_controller.dart';

/// Lists the users the current account has blocked, with an unblock action
/// per row. Backed by `GET /v1/moderation/blocks` (hydrated into
/// [blockedUsersProvider]); unblocking calls
/// `DELETE /v1/moderation/blocks/:id` and removes the row instantly.
class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  bool _loading = true;
  final Set<String> _working = <String>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await ref.read(blockedUsersProvider.notifier).hydrate();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _unblock(String userId) async {
    setState(() => _working.add(userId));
    try {
      await ref.read(blockedUsersProvider.notifier).unblock(userId);
      if (mounted) {
        // TODO(i18n): key=unblockDone
        wbShowSnack(context, 'Unblocked.');
      }
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (_) {
      if (mounted) {
        wbShowError(context, "Couldn't unblock. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _working.remove(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocked = ref.watch(blockedUsersProvider).toList();
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
                      // TODO(i18n): key=blockedUsersTitle / blockedUsersSub
                      Text('Blocked users', style: WBTypography.page),
                      Text(
                        "People you've blocked won't appear in the app.",
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
            if (_loading && blocked.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 56),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  ),
                ),
              )
            else if (blocked.isEmpty)
              const WBEmptyState(
                illustration: WBEmptyIllustration.noOrders,
                label: 'No blocked users',
                sub: "When you block someone, they'll show up here.",
              )
            else
              WBCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < blocked.length; i++) ...[
                      _BlockedRow(
                        userId: blocked[i],
                        busy: _working.contains(blocked[i]),
                        onUnblock: () => _unblock(blocked[i]),
                      ),
                      if (i != blocked.length - 1) const WBDivider(),
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

class _BlockedRow extends StatelessWidget {
  const _BlockedRow({
    required this.userId,
    required this.busy,
    required this.onUnblock,
  });
  final String userId;
  final bool busy;
  final VoidCallback onUnblock;

  String get _short =>
      userId.length > 10 ? '${userId.substring(0, 8)}…' : userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: WBColors.bgSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const WBIcon(WBIconName.user, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              // TODO(i18n): key=blockedUserLabel — the server returns ids only.
              'User $_short',
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          WBButton(
            // TODO(i18n): key=unblockAction
            label: 'Unblock',
            size: WBButtonSize.sm,
            variant: WBButtonVariant.secondary,
            loading: busy,
            onPressed: onUnblock,
          ),
        ],
      ),
    );
  }
}
