import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AgentController.instance;
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: ctrl.transactions,
        builder: (_, txns, _) => ValueListenableBuilder(
          valueListenable: ctrl.traders,
          builder: (_, _, _) => ValueListenableBuilder(
            valueListenable: ctrl.payouts,
            builder: (_, _, _) {
              final pending = ctrl.pendingSyncCount;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  12,
                  WBSpacing.screenPadding,
                  140,
                ),
                children: [
                  _Hero(
                    transactionsToday: ctrl.transactionsToday,
                    commissionToday: ctrl.commissionToday,
                    pending: pending,
                  ),
                  const SizedBox(height: WBSpacing.md),
                  _SyncBanner(pending: pending),
                  const SizedBox(height: WBSpacing.lg),
                  Text(
                    'Quick actions',
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Quick(
                        icon: WBIconName.user,
                        label: 'Register',
                        onTap: () =>
                            context.push(AppRoutes.agentRegisterTrader),
                      ),
                      const SizedBox(width: 10),
                      _Quick(
                        icon: WBIconName.basket,
                        label: 'Traders',
                        onTap: () => context.push(AppRoutes.agentTraders),
                      ),
                      const SizedBox(width: 10),
                      _Quick(
                        icon: WBIconName.card,
                        label: 'Earnings',
                        onTap: () => context.push(AppRoutes.agentEarnings),
                      ),
                    ],
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent transactions',
                          style: WBTypography.cardTitle.copyWith(fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.agentEarnings),
                        child: Text(
                          'See all',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final t in txns.take(4))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
                              child: const WBIcon(WBIconName.basket, size: 16),
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
                                          t.traderName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: WBTypography.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (!t.synced)
                                        const WBStatusPill(
                                          label: 'Pending',
                                          kind: WBStatusKind.warning,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${t.product} · ${t.quantityKg} kg · ${_ago(t.recordedAt)}',
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              wbNaira(t.totalNaira),
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _ago(DateTime d) {
    final mins = DateTime.now().difference(d).inMinutes;
    if (mins < 60) return '$mins min ago';
    final hrs = mins ~/ 60;
    if (hrs < 24) return '$hrs hr ago';
    return '${hrs ~/ 24}d ago';
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.transactionsToday,
    required this.commissionToday,
    required this.pending,
  });
  final int transactionsToday;
  final int commissionToday;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.lg),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hello, Musa',
                style: WBTypography.hero.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: WBTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Zone B · Mile 12 Market',
            style: WBTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Today', value: '$transactionsToday txns'),
              const SizedBox(width: 10),
              _Stat(label: 'Commission', value: wbNaira(commissionToday)),
              const SizedBox(width: 10),
              _Stat(label: 'To sync', value: '$pending'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.pending});
  final int pending;

  @override
  Widget build(BuildContext context) {
    final dirty = pending > 0;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.agentSync),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: dirty ? const Color(0x14F59E0B) : const Color(0x1410B981),
          borderRadius: BorderRadius.circular(WBRadius.card),
          border: Border.all(
            color: dirty ? const Color(0x33F59E0B) : const Color(0x3310B981),
          ),
        ),
        child: Row(
          children: [
            WBIcon(
              dirty ? WBIconName.bell : WBIconName.check,
              size: 14,
              color: dirty
                  ? const Color(0xFFB45309)
                  : const Color(0xFF047857),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dirty
                    ? '$pending item${pending == 1 ? '' : 's'} waiting to sync — tap to sync now.'
                    : "You're online — transactions sync as you record them.",
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              dirty ? 'Sync' : 'Done',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: WBShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: WBIcon(icon, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
