import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';

/// Searchable directory of every trader the agent has registered. Tap
/// "+ Register" to start a new registration; tap a row to … (future
/// trader-detail screen). For now we just stay on the list.
class AgentTradersScreen extends StatefulWidget {
  const AgentTradersScreen({super.key});

  @override
  State<AgentTradersScreen> createState() => _AgentTradersScreenState();
}

class _AgentTradersScreenState extends State<AgentTradersScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    AgentController.instance.loadTraders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: AgentController.instance.traders,
          builder: (_, _, _) {
            final results = AgentController.instance.searchTraders(_query);
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                40,
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
                          Text('Your traders', style: WBTypography.page),
                          Text(
                            '${AgentController.instance.traders.value.length} registered',
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WBButton(
                      label: 'Register',
                      size: WBButtonSize.sm,
                      trailingIcon: WBIconName.plus,
                      onPressed: () =>
                          context.push(AppRoutes.agentRegisterTrader),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                WBInput(
                  placeholder: 'Search by name or phone…',
                  leadingIcon: WBIconName.search,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: WBSpacing.lg),
                if (results.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                    ),
                    child: Text(
                      _query.isEmpty
                          ? 'No traders registered yet. Tap "Register" to add one.'
                          : 'No traders match "$_query".',
                      style: WBTypography.body.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  for (final t in results)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TraderRow(trader: t),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TraderRow extends StatelessWidget {
  const _TraderRow({required this.trader});
  final Trader trader;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.agentTraderDetail}/${trader.id}'),
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const WBIcon(WBIconName.user, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trader.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!trader.synced)
                        const WBStatusPill(
                          label: 'Pending sync',
                          kind: WBStatusKind.warning,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trader.type.label} · ${trader.location} · ${trader.phone}',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const WBIcon(
              WBIconName.chevronRight,
              size: 16,
              color: WBColors.fgPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}
