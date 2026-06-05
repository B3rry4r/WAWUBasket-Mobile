import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../application/agent_controller.dart';

/// Desktop-web layout for [AgentEarningsScreen]. Mirrors the mobile screen's
/// data loading ([AgentController.loadTransactions] + the transactions
/// [ValueNotifier]), Today/Week/Month windowing, commission/volume folding,
/// money formatting ([wbNaira]) and empty handling exactly; only the layout is
/// re-flowed for the desktop dashboard (page header + range tabs + hero summary
/// card on the left, transactions list on the right). Pushed surface — wrapped
/// in [OperatorDesktopScaffold] so the agent sidebar stays visible. Mobile
/// build untouched.
class AgentEarningsDesktopScreen extends StatefulWidget {
  const AgentEarningsDesktopScreen({super.key});

  @override
  State<AgentEarningsDesktopScreen> createState() =>
      _AgentEarningsDesktopScreenState();
}

class _AgentEarningsDesktopScreenState
    extends State<AgentEarningsDesktopScreen> {
  int _tab = 0;
  static const _tabs = ['Today', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    AgentController.instance.loadTransactions();
  }

  Duration _windowFor(int tab) => switch (tab) {
        0 => const Duration(hours: 24),
        1 => const Duration(days: 7),
        _ => const Duration(days: 30),
      };

  @override
  Widget build(BuildContext context) {
    return OperatorDesktopScaffold(
      role: AppRole.agent,
      child: ValueListenableBuilder(
        valueListenable: AgentController.instance.transactions,
        builder: (_, txns, _) {
          final cutoff = DateTime.now().subtract(_windowFor(_tab));
          final filtered = [
            for (final t in txns)
              if (t.recordedAt.isAfter(cutoff)) t,
          ];
          final totalCommission = filtered.fold<int>(
            0,
            (s, t) => s + t.commissionNaira,
          );
          final totalVolume = filtered.fold<int>(
            0,
            (s, t) => s + t.totalNaira,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: WBSpacing.xl,
              vertical: WBSpacing.xl,
            ),
            child: WBMaxWidth(
              maxWidth: WBBreakpoints.maxContent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page header: back chip + title/sub on the left.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WBBackChip(onPressed: () => context.pop()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your earnings', style: WBTypography.page),
                            const SizedBox(height: 2),
                            Text(
                              'Commission @ 0.5% of trade volume.',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: WBSpacing.xl),
                  // Two-column dashboard: hero summary left, transactions right.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 360,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                for (var i = 0; i < _tabs.length; i++) ...[
                                  _RangeTab(
                                    label: _tabs[i],
                                    active: i == _tab,
                                    onTap: () => setState(() => _tab = i),
                                  ),
                                  if (i != _tabs.length - 1)
                                    const SizedBox(width: 8),
                                ],
                              ],
                            ),
                            const SizedBox(height: WBSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(WBSpacing.lg),
                              decoration: BoxDecoration(
                                color: WBColors.surfaceDark,
                                borderRadius:
                                    BorderRadius.circular(WBRadius.card),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_tabs[_tab].toUpperCase()} COMMISSION',
                                    style: WBTypography.label.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    wbNaira(totalCommission),
                                    style: WBTypography.hero.copyWith(
                                      color: Colors.white,
                                      fontSize: 36,
                                      letterSpacing: -0.9,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${filtered.length} transactions · ${wbNaira(totalVolume)} volume',
                                    style: WBTypography.caption.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: WBSpacing.xl),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transactions',
                              style:
                                  WBTypography.cardTitle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            if (filtered.isEmpty)
                              const WBEmptyState(
                                illustration:
                                    WBEmptyIllustration.noTransaction,
                                label: 'No transactions in this window.',
                              )
                            else
                              WBCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    for (var i = 0; i < filtered.length; i++) ...[
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${filtered[i].product} · ${filtered[i].traderName}',
                                                    style: WBTypography.body
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${filtered[i].quantityKg} kg × ${wbNaira(filtered[i].pricePerKgNaira)} = ${wbNaira(filtered[i].totalNaira)}',
                                                    style: WBTypography.caption
                                                        .copyWith(
                                                      color:
                                                          WBColors.fgSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '+${wbNaira(filtered[i].commissionNaira)}',
                                              style:
                                                  WBTypography.body.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: const Color(0xFF047857),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (i != filtered.length - 1)
                                        const WBDivider(),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
