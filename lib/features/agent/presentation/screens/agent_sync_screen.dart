import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../application/agent_controller.dart';

String _fmtAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays}d ago';
}

class AgentSyncScreen extends StatefulWidget {
  const AgentSyncScreen({super.key});

  @override
  State<AgentSyncScreen> createState() => _AgentSyncScreenState();
}

class _AgentSyncScreenState extends State<AgentSyncScreen> {
  double _progress = 0;
  bool _syncing = false;
  bool _done = false;

  Future<void> _runSync() async {
    setState(() {
      _syncing = true;
      _done = false;
      _progress = 0;
    });
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    if (!mounted) return;
    await AgentController.instance.runSync();
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _done = true;
    });
    // Surface the conflict resolver if anything came back contested.
    final pending = AgentController.instance.conflicts.value;
    if (pending.isNotEmpty) {
      _openConflictResolver(pending.first.id);
    }
  }

  Future<void> _openConflictResolver(String id) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => _ConflictSheet(conflictId: id),
    );
    // If there are more conflicts, chain through them.
    if (!mounted) return;
    final next = AgentController.instance.conflicts.value;
    if (next.isNotEmpty) _openConflictResolver(next.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AgentController.instance;
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: ctrl.transactions,
          builder: (_, txns, _) => ValueListenableBuilder(
            valueListenable: ctrl.traders,
            builder: (_, traders, _) => ValueListenableBuilder(
              valueListenable: ctrl.payouts,
              builder: (_, payouts, _) {
                final pendingTraders = traders.where((t) => !t.synced).length;
                final pendingTxns = txns.where((t) => !t.synced).length;
                final pendingPayouts =
                    payouts.where((p) => !p.synced).length;

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
                              Text('Sync with WAWU', style: WBTypography.page),
                              Text(
                                'Send your offline data to the cloud.',
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
                    WBCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SyncRow(
                            label: 'Pending traders',
                            value: '$pendingTraders',
                          ),
                          const SizedBox(height: 12),
                          _SyncRow(
                            label: 'Pending transactions',
                            value: '$pendingTxns',
                          ),
                          const SizedBox(height: 12),
                          _SyncRow(
                            label: 'Pending payouts',
                            value: '$pendingPayouts',
                          ),
                          const SizedBox(height: 12),
                          _SyncRow(
                            label: 'Last sync',
                            value: _done
                                ? 'Just now'
                                : AgentController.instance.lastSyncAt != null
                                    ? _fmtAgo(AgentController.instance.lastSyncAt!)
                                    : 'Never',
                            valueColor: WBColors.fgSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    if (_syncing) ...[
                      Text(
                        'Syncing… ${(_progress * 100).toInt()}%',
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(WBRadius.pill),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 6,
                          backgroundColor: WBColors.bgSoft,
                          valueColor: const AlwaysStoppedAnimation(
                            WBColors.surfaceDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: WBSpacing.lg),
                    ] else if (_done) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x1410B981),
                          borderRadius: BorderRadius.circular(WBRadius.card),
                          border: Border.all(
                            color: const Color(0x3310B981),
                          ),
                        ),
                        child: Row(
                          children: [
                            const WBIcon(WBIconName.check, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'All done! Your data is safe.',
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: WBSpacing.lg),
                    ],
                    WBButton(
                      label: _syncing ? 'Syncing…' : 'Sync now',
                      fullWidth: true,
                      size: WBButtonSize.lg,
                      trailingIcon: WBIconName.arrowRight,
                      onPressed: _syncing ? null : _runSync,
                    ),
                    const SizedBox(height: WBSpacing.md),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          RoleController.instance.signOut();
                          context.go(AppRoutes.welcome);
                        },
                        child: Text(
                          context.l10n.operatorSignOut,
                          style: WBTypography.caption.copyWith(
                            color: WBColors.statusError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WBTypography.body.copyWith(fontSize: 14)),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? WBColors.fgHeader,
          ),
        ),
      ],
    );
  }
}

class _ConflictSheet extends StatelessWidget {
  const _ConflictSheet({required this.conflictId});
  final String conflictId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AgentController.instance.conflicts,
      builder: (_, conflicts, _) {
        final c =
            conflicts.where((c) => c.id == conflictId).firstOrNull;
        if (c == null) {
          // Already resolved, close the sheet.
          WidgetsBinding.instance
              .addPostFrameCallback((_) => Navigator.of(context).pop());
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(
            left: WBSpacing.screenPadding,
            right: WBSpacing.screenPadding,
            top: WBSpacing.lg,
            bottom: MediaQuery.of(context).padding.bottom + WBSpacing.xl,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x14F59E0B),
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  'SYNC CONFLICT',
                  style: WBTypography.label.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.66,
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.md),
              Text(
                'Server saved different values for this transaction. Pick which version to keep.',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: WBSpacing.md),
              Text(
                '${c.product} · ${c.traderName}',
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: WBSpacing.md),
              _Version(
                label: 'Your offline copy',
                qty: c.localQty,
                price: c.localPrice,
                onKeep: () {
                  AgentController.instance
                      .resolveConflict(c.id, keepLocal: true);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
              _Version(
                label: 'WAWU server',
                qty: c.serverQty,
                price: c.serverPrice,
                emphasised: true,
                onKeep: () {
                  AgentController.instance
                      .resolveConflict(c.id, keepLocal: false);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({
    required this.label,
    required this.qty,
    required this.price,
    required this.onKeep,
    this.emphasised = false,
  });
  final String label;
  final int qty;
  final int price;
  final VoidCallback onKeep;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final total = qty * price;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emphasised ? WBColors.surfaceDark : WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        border: Border.all(
          color: emphasised ? WBColors.surfaceDark : WBColors.bgDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: WBTypography.label.copyWith(
              color: emphasised
                  ? Colors.white.withValues(alpha: 0.55)
                  : WBColors.fgPlaceholder,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$qty kg × ${wbNaira(price)} = ${wbNaira(total)}',
            style: WBTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: emphasised ? Colors.white : WBColors.fgHeader,
            ),
          ),
          const SizedBox(height: 10),
          WBButton(
            label: 'Keep this version',
            fullWidth: true,
            size: WBButtonSize.sm,
            variant: emphasised ? WBButtonVariant.ghost : WBButtonVariant.secondary,
            onPressed: onKeep,
          ),
        ],
      ),
    );
  }
}
