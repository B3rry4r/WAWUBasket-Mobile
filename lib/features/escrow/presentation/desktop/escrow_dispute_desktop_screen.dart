import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/escrow_controller.dart';
import '../../domain/models/bulk_order.dart';

/// Desktop-web layout for the dispute-open form. Isolated from the mobile
/// build: re-lays the same data and logic into a centered form column inside
/// [CustomerWebScaffold]. Mirrors `EscrowDisputeScreen` exactly for data
/// loading, state, reason selection, submission, and navigation.
class EscrowDisputeDesktopScreen extends StatefulWidget {
  const EscrowDisputeDesktopScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<EscrowDisputeDesktopScreen> createState() =>
      _EscrowDisputeDesktopScreenState();
}

class _EscrowDisputeDesktopScreenState
    extends State<EscrowDisputeDesktopScreen> {
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
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
        child: Center(
          child: WBMaxWidth(
            maxWidth: 640,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.screenPadding,
              ),
              child: ValueListenableBuilder(
                valueListenable: EscrowController.instance.orders,
                builder: (_, _, _) {
                  final order =
                      EscrowController.instance.byId(widget.orderId);
                  if (order == null) return _notFound();
                  return _body(order);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notFound() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(height: WBSpacing.xl),
        Text(
          context.l10n.escrowDisputeOrderNotFound,
          style: WBTypography.page,
        ),
      ],
    );
  }

  Widget _body(BulkOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(height: WBSpacing.md),
        Text(context.l10n.escrowDisputeTitle, style: WBTypography.page),
        Text(
          "#${order.id} · we'll mediate within 48 hours.",
          style: WBTypography.caption.copyWith(
            color: WBColors.fgSecondary,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        Container(
          padding: const EdgeInsets.all(WBSpacing.lg),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: WBShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        onRemove: () => setState(() => _photos.removeAt(i)),
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
        ),
        const SizedBox(height: WBSpacing.lg),
        WBButton(
          label: 'Open dispute',
          fullWidth: true,
          size: WBButtonSize.lg,
          trailingIcon: WBIconName.arrowRight,
          loading: _submitting,
          onPressed: () => _submit(order),
        ),
      ],
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
