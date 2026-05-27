import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                    GestureDetector(
                      onTap: () =>
                          wbShowSnack(context, context.l10n.escrowPhotoUploadSoon),
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
