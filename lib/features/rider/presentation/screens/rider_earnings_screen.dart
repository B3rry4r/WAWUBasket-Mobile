import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Rider earnings dashboard. Today / Week / Month toggle a different
/// hero number + delivery list. Withdraw opens a bottom sheet to send
/// to the rider's mobile-money wallet.
class RiderEarningsScreen extends StatefulWidget {
  const RiderEarningsScreen({super.key});

  @override
  State<RiderEarningsScreen> createState() => _RiderEarningsScreenState();
}

class _RiderEarningsScreenState extends State<RiderEarningsScreen> {
  int _tab = 1;
  static const _tabs = ['Today', 'Week', 'Month'];

  static const _data = [
    // (heroAmount, deliveriesLabel, list)
    (
      4800,
      '6 deliveries',
      [
        (
          id: 'WAWU-8821',
          vendor: 'Mama Cass Kitchen',
          amount: 600,
          time: '12:34',
        ),
        (
          id: 'WAWU-8820',
          vendor: 'Suya & Smoke',
          amount: 800,
          time: '11:20',
        ),
        (
          id: 'WAWU-8819',
          vendor: 'Iya Basira Buka',
          amount: 500,
          time: '10:14',
        ),
        (id: 'WAWU-8817', vendor: 'Chicken Republic', amount: 700, time: '09:48'),
        (id: 'WAWU-8816', vendor: 'Pantry Plus', amount: 1100, time: '09:02'),
        (id: 'WAWU-8810', vendor: 'Mama Cass Kitchen', amount: 1100, time: '08:21'),
      ],
    ),
    (
      28400,
      '42 deliveries',
      [
        (id: 'WAWU-8821', vendor: 'Mama Cass Kitchen', amount: 600, time: 'Today'),
        (id: 'WAWU-8817', vendor: 'Chicken Republic', amount: 700, time: 'Today'),
        (id: 'WAWU-8810', vendor: 'Suya & Smoke', amount: 800, time: 'Today'),
        (id: 'WAWU-8801', vendor: 'Mama Cass Kitchen', amount: 1100, time: 'Yesterday'),
        (id: 'WAWU-8798', vendor: 'Iya Basira Buka', amount: 500, time: 'Yesterday'),
        (id: 'WAWU-8788', vendor: 'Pantry Plus', amount: 1100, time: '2 days ago'),
      ],
    ),
    (
      118500,
      '162 deliveries',
      [
        (id: 'WAWU-8821', vendor: 'Mama Cass Kitchen', amount: 600, time: 'Today'),
        (id: 'WAWU-8770', vendor: 'Suya & Smoke', amount: 800, time: 'Last week'),
        (id: 'WAWU-8702', vendor: 'Pantry Plus', amount: 1100, time: '2 weeks ago'),
        (id: 'WAWU-8644', vendor: 'Iya Basira Buka', amount: 500, time: '3 weeks ago'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = _data[_tab];
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
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                _RangeTab(
                  label: _tabs[i],
                  active: i == _tab,
                  onTap: () => setState(() => _tab = i),
                ),
                if (i != _tabs.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: WBSpacing.md),
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
                  _tabs[_tab].toUpperCase(),
                  style: WBTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wbNaira(tab.$1),
                  style: WBTypography.hero.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tab.$2,
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
                    label: 'Withdraw to wallet',
                    size: WBButtonSize.md,
                    trailingIcon: WBIconName.arrowRight,
                    variant: WBButtonVariant.ghost,
                    onPressed: () => _openWithdraw(context, tab.$1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Deliveries',
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          WBCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < tab.$3.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tab.$3[i].vendor,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#${tab.$3[i].id} · ${tab.$3[i].time}',
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          wbNaira(tab.$3[i].amount),
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != tab.$3.length - 1) const WBDivider(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  const _RangeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? WBColors.surfaceDark : WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.pill),
            boxShadow: active ? null : WBShadows.card,
          ),
          child: Text(
            label,
            style: WBTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : WBColors.fgHeader,
            ),
          ),
        ),
      ),
    );
  }
}

void _openWithdraw(BuildContext context, int balance) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: WBColors.bgPrimary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
    ),
    builder: (sheetCtx) {
      return Padding(
        padding: EdgeInsets.only(
          left: WBSpacing.screenPadding,
          right: WBSpacing.screenPadding,
          top: WBSpacing.lg,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + WBSpacing.xl,
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
            Text(
              'Withdraw to wallet',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBInput(
              label: 'Amount (₦)',
              initialValue: '$balance',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Mobile money / wallet',
              initialValue: '+234 805 ••• 2114',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Send',
              fullWidth: true,
              size: WBButtonSize.lg,
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${wbNaira(balance)} sent')),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
