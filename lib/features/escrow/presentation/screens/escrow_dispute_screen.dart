import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/escrow_controller.dart';
import '../../domain/models/bulk_order.dart';

/// Dispute-open form for one bulk order. Captures a reason, optionally a
/// short note, and flips the escrow into [EscrowStatus.disputed].
class EscrowDisputeScreen extends StatefulWidget {
  const EscrowDisputeScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<EscrowDisputeScreen> createState() => _EscrowDisputeScreenState();
}

class _EscrowDisputeScreenState extends State<EscrowDisputeScreen> {
  String _reason = 'Wrong quantity';
  final _notes = TextEditingController();

  /// Uploaded R2 object keys + preview URLs for the attached photo evidence.
  final _photos = <UploadResult>[];
  bool _uploading = false;
  bool _submitting = false;

  static const _reasons = [
    'Wrong quantity',
    'Wrong produce',
    'Quality issues',
    'Late delivery',
    'Other',
  ];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final up = await UploadService.instance.pickAndUpload(
        folder: UploadFolder.disputes,
      );
      if (up == null) return;
      if (mounted) setState(() => _photos.add(up));
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (_) {
      if (mounted) wbShowError(context, context.l10n.escrowPhotoUploadFailed);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit(BulkOrder order) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final body = _notes.text.trim().isEmpty
        ? _reason
        : '$_reason, ${_notes.text.trim()}';
    try {
      await EscrowController.instance.dispute(
        order.id,
        body,
        photoKeys: [for (final p in _photos) p.key],
      );
      if (!mounted) return;
      wbShowSnack(context, context.l10n.escrowDisputeOpened);
      context.pop();
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: EscrowController.instance.orders,
          builder: (_, _, _) {
            final order = EscrowController.instance.byId(widget.orderId);
            if (order == null) {
              return Padding(
                padding: const EdgeInsets.all(WBSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(height: WBSpacing.xl),
                    Text(context.l10n.escrowDisputeOrderNotFound, style: WBTypography.page),
                  ],
                ),
              );
            }
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding,
                    12,
                    WBSpacing.screenPadding,
                    140,
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
                              Text(context.l10n.escrowDisputeTitle, style: WBTypography.page),
                              Text(
                                "#${order.id} · we'll mediate within 48 hours.",
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
                    Text(
                      'WHAT WENT WRONG?',
                      style: WBTypography.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: WBColors.fgPlaceholder,
                        letterSpacing: 0.66,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in _reasons)
                          WBTag(
                            label: r,
                            active: r == _reason,
                            onTap: () => setState(() => _reason = r),
                          ),
                      ],
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    WBInput(
                      label: 'Notes (optional)',
                      placeholder: context.l10n.escrowDisputeDetailsHint,
                      controller: _notes,
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    if (_photos.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _photos.length; i++)
                            _PhotoThumb(
                              url: _photos[i].publicUrl,
                              onRemove: () =>
                                  setState(() => _photos.removeAt(i)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    GestureDetector(
                      onTap: _uploading ? null : _addPhoto,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: WBColors.bgSoft,
                          borderRadius: BorderRadius.circular(WBRadius.card),
                          border: Border.all(color: WBColors.bgDivider),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: WBColors.bgPrimary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: _uploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const WBIcon(WBIconName.plus, size: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attach photo evidence',
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        WBSpacing.screenPadding,
                        0,
                        WBSpacing.screenPadding,
                        20,
                      ),
                      child: WBButton(
                        label: 'Open dispute',
                        fullWidth: true,
                        size: WBButtonSize.lg,
                        trailingIcon: WBIconName.arrowRight,
                        loading: _submitting,
                        onPressed: () => _submit(order),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A square preview of an attached evidence photo with a remove affordance.
class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.url, required this.onRemove});
  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(WBRadius.card),
          child: SizedBox(
            width: 84,
            height: 84,
            child: WBNetworkImage(url: url),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const WBIcon(
                WBIconName.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
