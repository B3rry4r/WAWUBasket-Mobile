import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Driver earnings dashboard. Per-trip / weekly / monthly toggles a
/// different hero amount + trip list. Withdraw opens a bottom sheet to
/// send to the driver's mobile-money wallet.
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  int _tab = 1;
  static const _tabs = ['Last trip', 'This week', 'This month'];

  static const _data = [
    (
      620000,
      'Kano → Cotonou',
      [
        (id: 'LOAD-0042', route: 'Kano → Cotonou', amount: 620000, when: 'Today'),
      ],
    ),
    (
      1480000,
      '3 trips this week',
      [
        (id: 'LOAD-0042', route: 'Kano → Cotonou', amount: 620000, when: 'Today'),
        (id: 'LOAD-0038', route: 'Lagos → Lomé', amount: 320000, when: 'Mon'),
        (id: 'LOAD-0034', route: 'Lagos → Niamey', amount: 540000, when: 'Sat'),
      ],
    ),
    (
      5320000,
      '11 trips this month',
      [
        (id: 'LOAD-0042', route: 'Kano → Cotonou', amount: 620000, when: 'Today'),
        (id: 'LOAD-0038', route: 'Lagos → Lomé', amount: 320000, when: 'Mon'),
        (id: 'LOAD-0034', route: 'Lagos → Niamey', amount: 540000, when: 'Sat'),
        (id: 'LOAD-0031', route: 'Calabar → Douala', amount: 480000, when: '8 days ago'),
        (id: 'LOAD-0028', route: 'Kano → Cotonou', amount: 600000, when: '11 days ago'),
        (id: 'LOAD-0022', route: 'Lagos → Lomé', amount: 290000, when: '15 days ago'),
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
            'Trips',
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
                                tab.$3[i].route,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#${tab.$3[i].id} · ${tab.$3[i].when}',
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
              fontSize: 13,
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
            const WBInput(
              label: 'Mobile money / wallet',
              initialValue: '+234 805 ••• 8090',
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
