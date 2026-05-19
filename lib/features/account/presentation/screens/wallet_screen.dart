import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/presentation/widgets/search_field.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _actions = [
    (icon: WBIconName.plus, label: 'Top up', route: AppRoutes.walletTopUp),
    (icon: WBIconName.arrowRight, label: 'Send', route: AppRoutes.walletSend),
    (icon: WBIconName.arrowLeft, label: 'Withdraw', route: AppRoutes.walletWithdraw),
    (icon: WBIconName.card, label: 'Cards', route: AppRoutes.walletCards),
  ];

  static const _txns = [
    (
      label: 'Mama Cass Kitchen',
      sub: 'Order #8821',
      amount: '-₦14,600',
      time: 'Today 12:31',
      out: true,
    ),
    (
      label: 'Wallet top-up',
      sub: 'Via Paystack',
      amount: '+₦20,000',
      time: 'Today 09:15',
      out: false,
    ),
    (
      label: 'The Daily Grain',
      sub: 'Order #8804',
      amount: '-₦7,400',
      time: 'Yesterday',
      out: true,
    ),
    (
      label: 'Escrow released',
      sub: 'Trade #TR-0041',
      amount: '+₦3,000',
      time: 'Mon 12 May',
      out: false,
    ),
    (
      label: 'Hako Sushi',
      sub: 'Order #8790',
      amount: '-₦9,800',
      time: 'Sat 10 May',
      out: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Dark hero
          Container(
            color: WBColors.surfaceDark,
            padding: EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              12 + MediaQuery.of(context).padding.top,
              WBSpacing.screenPadding,
              WBSpacing.xl,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    WBCircleIconButton(
                      icon: WBIconName.chevronLeft,
                      background: Colors.white.withValues(alpha: 0.12),
                      iconColor: Colors.white,
                      shadow: const [],
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Wallet',
                      style: WBTypography.cardTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'AVAILABLE BALANCE',
                  style: WBTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₦12,500',
                  style: WBTypography.hero.copyWith(
                    fontSize: 48,
                    color: Colors.white,
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: WBColors.statusWarning.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WBColors.statusWarning.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const WBIcon(
                        WBIconName.clock,
                        size: 15,
                        color: WBColors.statusWarning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '₦3,000 held in escrow, releases in 48 hrs',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.statusWarning,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick actions
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              WBSpacing.lg,
              WBSpacing.screenPadding,
              0,
            ),
            child: Row(
              children: [
                for (final a in _actions) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(a.route),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: WBColors.bgPrimary,
                              shape: BoxShape.circle,
                              boxShadow: WBShadows.card,
                            ),
                            alignment: Alignment.center,
                            child: WBIcon(a.icon, size: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.label,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Transactions
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              WBSpacing.lg,
              WBSpacing.screenPadding,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Recent transactions',
                  action: 'See all',
                ),
                const SizedBox(height: WBSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: WBColors.surfaceCard,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                    boxShadow: WBShadows.card,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < _txns.length; i++) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => wbShowSnack(
                            context,
                            '${_txns[i].label} · ${_txns[i].amount}',
                          ),
                          child: _TxnRow(
                            label: _txns[i].label,
                            sub: _txns[i].sub,
                            amount: _txns[i].amount,
                            time: _txns[i].time,
                            out: _txns[i].out,
                          ),
                        ),
                        if (i != _txns.length - 1) const WBDivider(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({
    required this.label,
    required this.sub,
    required this.amount,
    required this.time,
    required this.out,
  });

  final String label;
  final String sub;
  final String amount;
  final String time;
  final bool out;

  @override
  Widget build(BuildContext context) {
    final color = out ? WBColors.statusError : WBColors.statusSuccess;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: WBIcon(
              out ? WBIconName.arrowRight : WBIconName.arrowLeft,
              size: 17,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                time,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
