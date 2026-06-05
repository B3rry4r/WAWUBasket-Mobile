import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';
import '../../../account/application/profile_controller.dart';

/// Desktop-web layout for the trade-agent home dashboard.
///
/// TAB screen: renders BODY CONTENT ONLY — the operator shell already wraps it
/// in the desktop scaffold (sidebar + content pane). Reuses the exact same
/// [AgentController] / [ProfileController] data, models, money formatting,
/// status/sync logic, navigation and l10n keys as the mobile [AgentHomeScreen];
/// only the layout is re-flowed for wide screens.
class AgentHomeDesktopScreen extends StatefulWidget {
  const AgentHomeDesktopScreen({super.key});

  @override
  State<AgentHomeDesktopScreen> createState() => _AgentHomeDesktopScreenState();
}

class _AgentHomeDesktopScreenState extends State<AgentHomeDesktopScreen> {
  @override
  void initState() {
    super.initState();
    AgentController.instance.loadTraders();
    AgentController.instance.loadTransactions();
    ProfileController.instance.load();
  }

  static String _ago(DateTime d) {
    final mins = DateTime.now().difference(d).inMinutes;
    if (mins < 60) return '$mins min ago';
    final hrs = mins ~/ 60;
    if (hrs < 24) return '$hrs hr ago';
    return '${hrs ~/ 24}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AgentController.instance;
    return ValueListenableBuilder(
      valueListenable: ctrl.transactions,
      builder: (_, txns, _) => ValueListenableBuilder(
        valueListenable: ctrl.traders,
        builder: (_, _, _) => ValueListenableBuilder(
          valueListenable: ctrl.payouts,
          builder: (_, _, _) {
            final pending = ctrl.pendingSyncCount;
            return ValueListenableBuilder(
              valueListenable: ProfileController.instance.profile,
              builder: (_, profile, _) {
                final displayName =
                    profile?.agentDisplayName?.isNotEmpty == true
                        ? profile!.agentDisplayName!
                        : profile?.fullName.isNotEmpty == true
                            ? profile!.fullName
                            : 'Trade Agent';
                final heroName = profile?.agentDisplayName?.isNotEmpty == true
                    ? profile!.agentDisplayName!
                    : profile?.fullName.isNotEmpty == true
                        ? profile!.fullName.split(' ').first
                        : null;
                final regionName = profile?.agentRegionName;
                final subtitle = regionName?.isNotEmpty == true
                    ? 'Trade agent · $regionName'
                    : 'Trade agent';

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
                        // Page header: title left, quick actions right.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayName, style: WBTypography.page),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: WBTypography.body.copyWith(
                                      color: WBColors.fgSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: WBSpacing.lg),
                            _DesktopActionButton(
                              icon: WBIconName.user,
                              label: 'Register',
                              onTap: () =>
                                  context.push(AppRoutes.agentRegisterTrader),
                            ),
                            const SizedBox(width: 10),
                            _DesktopActionButton(
                              icon: WBIconName.basket,
                              label: 'Traders',
                              onTap: () =>
                                  context.push(AppRoutes.agentTraders),
                            ),
                            const SizedBox(width: 10),
                            _DesktopActionButton(
                              icon: WBIconName.card,
                              label: 'Earnings',
                              onTap: () =>
                                  context.push(AppRoutes.agentEarnings),
                            ),
                          ],
                        ),
                        const SizedBox(height: WBSpacing.lg),
                        // Two-column working area: hero + transactions left,
                        // sync rail right.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Hero(
                                    transactionsToday: ctrl.transactionsToday,
                                    commissionToday: ctrl.commissionToday,
                                    pending: pending,
                                    displayName: heroName,
                                    regionName: regionName,
                                  ),
                                  const SizedBox(height: WBSpacing.xl),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Recent transactions',
                                          style: WBTypography.cardTitle
                                              .copyWith(fontSize: 17),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => context
                                            .push(AppRoutes.agentEarnings),
                                        child: Text(
                                          context.l10n.actionSeeAll,
                                          style: WBTypography.caption.copyWith(
                                            color: WBColors.fgSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (txns.isEmpty)
                                    const WBEmptyState(
                                      illustration:
                                          WBEmptyIllustration.noNewOrder,
                                      label: 'No transactions recorded yet.',
                                    )
                                  else
                                    _TxnGrid(
                                      children: [
                                        for (final t in txns.take(6))
                                          _TxnCard(txn: t, agoLabel: _ago(t.recordedAt)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: WBSpacing.xl),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quick actions',
                                    style: WBTypography.cardTitle
                                        .copyWith(fontSize: 17),
                                  ),
                                  const SizedBox(height: 12),
                                  _SyncBanner(pending: pending),
                                  const SizedBox(height: WBSpacing.md),
                                  _Quick(
                                    icon: WBIconName.user,
                                    label: 'Register a trader',
                                    onTap: () => context
                                        .push(AppRoutes.agentRegisterTrader),
                                  ),
                                  _Quick(
                                    icon: WBIconName.basket,
                                    label: 'View traders',
                                    onTap: () =>
                                        context.push(AppRoutes.agentTraders),
                                  ),
                                  _Quick(
                                    icon: WBIconName.card,
                                    label: 'Earnings',
                                    onTap: () =>
                                        context.push(AppRoutes.agentEarnings),
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
            );
          },
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.transactionsToday,
    required this.commissionToday,
    required this.pending,
    this.displayName,
    this.regionName,
  });
  final int transactionsToday;
  final int commissionToday;
  final int pending;
  final String? displayName;
  final String? regionName;

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
                displayName != null ? 'Hello, $displayName' : 'Hello',
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
          if (regionName?.isNotEmpty == true)
            Text(
              regionName!,
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
                    ? '$pending item${pending == 1 ? '' : 's'} waiting to sync, tap to sync now.'
                    : context.l10n.agentHomeOnline,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
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

/// Two-column responsive grid of equal-width transaction cards.
class _TxnGrid extends StatelessWidget {
  const _TxnGrid({required this.children});
  final List<Widget> children;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 560 ? 2 : 1;
        final itemWidth = (constraints.maxWidth - _gap * (cols - 1)) / cols;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _TxnCard extends StatelessWidget {
  const _TxnCard({required this.txn, required this.agoLabel});
  final AgentTransaction txn;
  final String agoLabel;

  @override
  Widget build(BuildContext context) {
    return WBCard(
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
                        txn.traderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!txn.synced)
                      const WBStatusPill(
                        label: 'Pending',
                        kind: WBStatusKind.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${txn.product} · ${txn.quantityKg} kg · $agoLabel',
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
          Text(
            wbNaira(txn.totalNaira),
            style: WBTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopActionButton extends StatelessWidget {
  const _DesktopActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WBIcon(icon, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
