import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../application/agent_controller.dart';

/// Desktop-web layout for one registered trader's profile. Mirrors
/// [AgentTraderDetailScreen] exactly — same [AgentController] value listeners,
/// the trader-not-found state, the per-trader transaction/payout filtering,
/// the lifetime volume + commission folds, the record-sale / cash-payout
/// actions and the same date/money formatting — re-laid out as a two-column
/// dashboard detail: identity + lifetime card + info + actions on the LEFT,
/// recent sales and payouts on the RIGHT. Desktop-only — the mobile build
/// never imports this file.
class AgentTraderDetailDesktopScreen extends StatelessWidget {
  const AgentTraderDetailDesktopScreen({super.key, required this.traderId});

  final String traderId;

  @override
  Widget build(BuildContext context) {
    final ctrl = AgentController.instance;
    return OperatorDesktopScaffold(
      role: AppRole.agent,
      child: ValueListenableBuilder(
        valueListenable: ctrl.transactions,
        builder: (_, txns, _) => ValueListenableBuilder(
          valueListenable: ctrl.payouts,
          builder: (_, payouts, _) {
            final trader = ctrl.traderById(traderId);
            if (trader == null) {
              return WBMaxWidth(
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
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(height: WBSpacing.xl),
                    Text(context.l10n.agentTraderNotFound,
                        style: WBTypography.page),
                  ],
                ),
              );
            }

            final traderTxns = [
              for (final t in txns)
                if (t.traderId == traderId) t,
            ];
            final traderPayouts = [
              for (final p in payouts)
                if (p.traderId == traderId) p,
            ];
            final lifetimeVolume =
                traderTxns.fold<int>(0, (s, t) => s + t.totalNaira);
            final lifetimeCommission =
                traderTxns.fold<int>(0, (s, t) => s + t.commissionNaira);

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
                    // Page header: title left, sync state right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trader.name, style: WBTypography.page),
                              const SizedBox(height: 2),
                              Text(
                                '${trader.type.label} · ${trader.location}',
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!trader.synced)
                          const WBStatusPill(
                            label: 'Pending sync',
                            kind: WBStatusKind.warning,
                          ),
                      ],
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column: lifetime card, info, actions.
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      'LIFETIME VOLUME',
                                      style: WBTypography.label.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      wbNaira(lifetimeVolume),
                                      style: WBTypography.hero.copyWith(
                                        color: Colors.white,
                                        fontSize: 32,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${traderTxns.length} sales · ${wbNaira(lifetimeCommission)} commission earned',
                                      style: WBTypography.caption.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: WBSpacing.md),
                              WBCard(
                                child: Column(
                                  children: [
                                    _InfoRow(
                                      icon: WBIconName.phone,
                                      label: 'Phone',
                                      value: trader.phone,
                                    ),
                                    const SizedBox(height: 12),
                                    const WBDivider(),
                                    const SizedBox(height: 12),
                                    _InfoRow(
                                      icon: WBIconName.pin,
                                      label: 'Location',
                                      value: trader.location,
                                    ),
                                    const SizedBox(height: 12),
                                    const WBDivider(),
                                    const SizedBox(height: 12),
                                    _InfoRow(
                                      icon: WBIconName.user,
                                      label: 'Registered',
                                      value: _fmtDate(trader.registeredAt),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: WBSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: WBButton(
                                      label: 'Record sale',
                                      size: WBButtonSize.md,
                                      onPressed: () => context
                                          .push(AppRoutes.agentRecordTxn),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: WBButton(
                                      label: 'Cash payout',
                                      size: WBButtonSize.md,
                                      variant: WBButtonVariant.secondary,
                                      onPressed: () => context
                                          .push(AppRoutes.agentCashPayout),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: WBSpacing.xl),
                        // Right column: recent sales + payouts.
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent sales',
                                style: WBTypography.cardTitle
                                    .copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              if (traderTxns.isEmpty)
                                const WBEmptyState(
                                  illustration:
                                      WBEmptyIllustration.noTransaction,
                                  label: 'No sales logged for this trader yet.',
                                )
                              else
                                WBCard(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      for (var i = 0;
                                          i < traderTxns.length;
                                          i++) ...[
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
                                                      '${traderTxns[i].product} · ${traderTxns[i].quantityKg} kg',
                                                      style: WBTypography.body
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _fmtDate(traderTxns[i]
                                                          .recordedAt),
                                                      style: WBTypography.caption
                                                          .copyWith(
                                                        color: WBColors
                                                            .fgSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                wbNaira(
                                                    traderTxns[i].totalNaira),
                                                style: WBTypography.body
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (i != traderTxns.length - 1)
                                          const WBDivider(),
                                      ],
                                    ],
                                  ),
                                ),
                              const SizedBox(height: WBSpacing.lg),
                              Text(
                                'Payouts',
                                style: WBTypography.cardTitle
                                    .copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              if (traderPayouts.isEmpty)
                                const WBEmptyState(
                                  illustration:
                                      WBEmptyIllustration.noTransaction,
                                  label: 'No cash payouts recorded yet.',
                                )
                              else
                                WBCard(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      for (var i = 0;
                                          i < traderPayouts.length;
                                          i++) ...[
                                        Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _fmtDate(traderPayouts[i]
                                                      .recordedAt),
                                                  style: WBTypography.body
                                                      .copyWith(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                wbNaira(traderPayouts[i]
                                                    .amountNaira),
                                                style: WBTypography.body
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (i != traderPayouts.length - 1)
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
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final WBIconName icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: WBIcon(icon, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
