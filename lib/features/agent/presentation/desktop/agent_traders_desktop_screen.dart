import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../application/agent_controller.dart';

/// Desktop-web layout for the agent's trader directory. Mirrors
/// [AgentTradersScreen]'s data loading ([AgentController.loadTraders] on init,
/// listening to its [traders] notifier), the live [searchTraders] filtering,
/// the registered-count subtitle, the Register action, the empty / no-match
/// states, the per-trader pending-sync pill and the row-tap navigation to the
/// trader detail screen — re-laid out as a page header + search field above a
/// comfortable multi-column grid of trader cards. Desktop-only — the mobile
/// build never imports this file.
class AgentTradersDesktopScreen extends StatefulWidget {
  const AgentTradersDesktopScreen({super.key});

  @override
  State<AgentTradersDesktopScreen> createState() =>
      _AgentTradersDesktopScreenState();
}

class _AgentTradersDesktopScreenState extends State<AgentTradersDesktopScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    AgentController.instance.loadTraders();
  }

  @override
  Widget build(BuildContext context) {
    return OperatorDesktopScaffold(
      role: AppRole.agent,
      child: ValueListenableBuilder(
        valueListenable: AgentController.instance.traders,
        builder: (_, _, _) {
          final results = AgentController.instance.searchTraders(_query);
          return SingleChildScrollView(
            child: WBMaxWidth(
              maxWidth: WBBreakpoints.maxContent,
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                WBSpacing.lg,
                WBSpacing.screenPadding,
                WBSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: WBBackChip(onPressed: () => context.pop()),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  // Page header: title + count left, Register action right.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.agentTradersPageTitle,
                              style: WBTypography.page,
                            ),
                            const SizedBox(height: 2),
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
                        size: WBButtonSize.md,
                        trailingIcon: WBIconName.plus,
                        onPressed: () =>
                            context.push(AppRoutes.agentRegisterTrader),
                      ),
                    ],
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  SizedBox(
                    width: 420,
                    child: WBInput(
                      placeholder:
                          context.l10n.agentTradersSearchPlaceholder,
                      leadingIcon: WBIconName.search,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(height: WBSpacing.xl),
                  if (results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: WBSpacing.xxl),
                      child: WBEmptyState(
                        illustration: WBEmptyIllustration.noOrders,
                        label: _query.isEmpty
                            ? context.l10n.agentTradersEmpty
                            : 'No traders match "$_query".',
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: WBSpacing.lg,
                        mainAxisSpacing: WBSpacing.lg,
                        mainAxisExtent: 84,
                      ),
                      itemBuilder: (_, i) => _TraderRow(trader: results[i]),
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
                mainAxisSize: MainAxisSize.min,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
