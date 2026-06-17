import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/blocked_users_controller.dart';
import 'report_sheet.dart';

/// Shared entry points for the moderation actions wired into every UGC
/// surface. Kept as free functions so both `StatefulWidget` (via a captured
/// [WidgetRef]) and `ConsumerWidget` call sites can reuse them.
abstract final class ModerationActions {
  /// Opens an overflow sheet offering "Report" and — when [reportedUserId]
  /// is known — "Block user". Used by the header overflow menus on screens
  /// that involve a counterpart user (vendor storefront, export listing,
  /// chat thread).
  ///
  /// [onBlocked] fires after a successful block so the caller can pop or
  /// refresh the current view.
  static Future<void> showOverflow(
    BuildContext context,
    WidgetRef ref, {
    required String targetType,
    required String targetId,
    String? reportedUserId,
    String? title,
    VoidCallback? onBlocked,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (ctx) => _OverflowSheet(
        canBlock: reportedUserId != null && reportedUserId.isNotEmpty,
      ),
    );
    if (action == null || !context.mounted) return;

    if (action == 'report') {
      await ReportSheet.show(
        context,
        targetType: targetType,
        targetId: targetId,
        reportedUserId: reportedUserId,
        title: title,
      );
    } else if (action == 'block' && reportedUserId != null) {
      await confirmBlock(
        context,
        ref,
        userId: reportedUserId,
        title: title,
        onBlocked: onBlocked,
      );
    }
  }

  /// Shows a confirmation dialog, then blocks [userId] via the
  /// [blockedUsersProvider]. The set updates optimistically so the user's
  /// content disappears instantly; [onBlocked] runs on success.
  static Future<void> confirmBlock(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    String? title,
    VoidCallback? onBlocked,
  }) async {
    final who = (title == null || title.trim().isEmpty) ? 'this user' : title;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WBColors.bgPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        // TODO(i18n): key=blockTitle / blockBody / blockConfirm
        title: Text('Block $who?', style: WBTypography.cardTitle),
        content: Text(
          "You won't see their content or messages anymore. You can "
          'unblock them later from Settings.',
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Block',
              style: WBTypography.body.copyWith(
                color: WBColors.statusError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(blockedUsersProvider.notifier).block(userId);
      if (context.mounted) {
        // TODO(i18n): key=blockDone
        wbShowSnack(context, 'Blocked. Their content is now hidden.');
      }
      onBlocked?.call();
    } on ApiException catch (e) {
      if (context.mounted) wbShowError(context, e.message);
    } catch (_) {
      if (context.mounted) {
        wbShowError(context, "Couldn't block this user. Please try again.");
      }
    }
  }
}

class _OverflowSheet extends StatelessWidget {
  const _OverflowSheet({required this.canBlock});
  final bool canBlock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + WBSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.md),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          _ActionRow(
            icon: WBIconName.more,
            // TODO(i18n): key=reportAction
            label: 'Report',
            onTap: () => Navigator.of(context).pop('report'),
          ),
          if (canBlock) ...[
            const WBDivider(),
            _ActionRow(
              icon: WBIconName.close,
              // TODO(i18n): key=blockAction
              label: 'Block user',
              danger: true,
              onTap: () => Navigator.of(context).pop('block'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? WBColors.statusError : WBColors.fgHeader;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            WBIcon(icon, size: 18, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: WBTypography.body.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
