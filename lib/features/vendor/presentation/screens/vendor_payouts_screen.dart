import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorPayoutsScreen extends StatelessWidget {
  const VendorPayoutsScreen({super.key});

  static const _payouts = [
    (date: 'Today', amount: '₦68,400', status: 'Processing', kind: WBStatusKind.warning),
    (date: 'Yesterday', amount: '₦72,150', status: 'Completed', kind: WBStatusKind.success),
    (date: 'Sat 17 May', amount: '₦55,300', status: 'Completed', kind: WBStatusKind.success),
    (date: 'Fri 16 May', amount: '₦48,700', status: 'Completed', kind: WBStatusKind.success),
    (date: 'Thu 15 May', amount: '₦61,200', status: 'Completed', kind: WBStatusKind.success),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Text('Your earnings', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            'Money in the bank.',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Container(
            padding: const EdgeInsets.all(WBSpacing.lg),
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE BALANCE',
                  style: WBTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₦184,250',
                  style: WBTypography.hero.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pending ₦68,400 · WAWU fee 8%',
                  style: WBTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: WBButton(
                    label: 'Request payout',
                    size: WBButtonSize.md,
                    trailingIcon: WBIconName.arrowRight,
                    variant: WBButtonVariant.ghost,
                    onPressed: () => _openPayoutSheet(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Payout history',
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          WBCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _payouts.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _payouts[i].amount,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _payouts[i].date,
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        WBStatusPill(
                          label: _payouts[i].status,
                          kind: _payouts[i].kind,
                        ),
                      ],
                    ),
                  ),
                  if (i != _payouts.length - 1) const WBDivider(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _openPayoutSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Request payout',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'GTBank · 0123•••456 · Mama Cass Kitchen',
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const WBInput(
            label: 'Amount (₦)',
            initialValue: '184,250',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          WBButton(
            label: 'Request withdrawal',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout requested · arrives in 1–2 days'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
