import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void _submit(BulkOrder order) {
    final body = _notes.text.trim().isEmpty
        ? _reason
        : '$_reason, ${_notes.text.trim()}';
    EscrowController.instance.dispute(order.id, body);
    wbShowSnack(
      context,
      context.l10n.escrowDisputeOpened,
    );
    context.pop();
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
              GestureDetector(
                onTap: () => wbShowSnack(
                  context,
                  context.l10n.escrowPhotoUploadSoon,
                ),
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
                        child: const WBIcon(WBIconName.plus, size: 16),
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
          onPressed: () => _submit(order),
        ),
      ],
    );
  }
}
