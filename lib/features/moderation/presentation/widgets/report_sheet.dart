import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/moderation_api.dart';
import '../../domain/report_reason.dart';

/// Reusable "Report content" bottom sheet wired into every UGC surface.
///
/// Presents the eight canonical [ReportReason]s, an optional description
/// field, and a submit button that posts to `POST /v1/moderation/reports`
/// via [ModerationApi.reportContent]. On success it pops and shows a
/// confirmation snackbar.
class ReportSheet extends StatefulWidget {
  const ReportSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    this.reportedUserId,
    this.title,
  });

  /// One of [ReportTargetType] — `user`, `chat_message`, `catalog_item`,
  /// `rating`, `recipe`, `export_listing`.
  final String targetType;

  /// Id of the reported entity (message id, item id, …).
  final String targetId;

  /// The user behind the content, when one is known.
  final String? reportedUserId;

  /// Optional human label for what's being reported (shown in the header).
  final String? title;

  /// Opens the report sheet. Returns true when a report was filed.
  static Future<bool> show(
    BuildContext context, {
    required String targetType,
    required String targetId,
    String? reportedUserId,
    String? title,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => ReportSheet(
        targetType: targetType,
        targetId: targetId,
        reportedUserId: reportedUserId,
        title: title,
      ),
    );
    return result ?? false;
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  ReportReason? _reason;
  final _description = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ModerationApi.instance.reportContent(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reportedUserId: widget.reportedUserId,
        reason: reason.code,
        description: _description.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      // TODO(i18n): key=reportSubmitted
      wbShowSnack(context, 'Report submitted. Thank you for letting us know.');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        wbShowError(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        wbShowError(context, "Couldn't submit the report. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final what = widget.title?.trim();
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + WBSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          // TODO(i18n): key=reportTitle / reportSubtitle
          Text('Report', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            what == null || what.isEmpty
                ? 'Tell us what\'s wrong with this content.'
                : 'Tell us what\'s wrong with "$what".',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final r in ReportReason.values) ...[
                    _ReasonRow(
                      label: r.label,
                      selected: _reason == r,
                      onTap: () => setState(() => _reason = r),
                    ),
                    if (r != ReportReason.values.last)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBInput(
            controller: _description,
            // TODO(i18n): key=reportDetailsLabel / reportDetailsHint
            label: 'Add details (optional)',
            placeholder: 'Anything else we should know?',
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            // TODO(i18n): key=reportSubmit
            label: 'Submit report',
            size: WBButtonSize.lg,
            fullWidth: true,
            loading: _busy,
            disabled: _reason == null,
            onPressed: _reason == null ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? WBColors.bgSoft : WBColors.bgPrimary,
          borderRadius: BorderRadius.circular(WBRadius.card),
          border: Border.all(
            color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? WBColors.surfaceDark : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 12,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
