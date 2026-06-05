import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/presentation/widgets/search_field.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../data/account_extras_api.dart';

/// Desktop-web layout for the customer wallet. Mirrors [WalletScreen]'s data
/// loading, money formatting, and error/empty handling exactly; only the layout
/// is re-flowed into a centered column with the dark balance hero as a card.
/// Pushed surface — wrapped in [CustomerWebScaffold]. Mobile build untouched.
class WalletDesktopScreen extends StatefulWidget {
  const WalletDesktopScreen({super.key});

  @override
  State<WalletDesktopScreen> createState() => _WalletDesktopScreenState();
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

int _money(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _txnTime(DateTime? t) {
  if (t == null) return '';
  final l = t.toLocal();
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day)
      .difference(DateTime(l.year, l.month, l.day))
      .inDays;
  final hm =
      '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  if (d == 0) return 'Today $hm';
  if (d == 1) return 'Yesterday';
  return '${_days[l.weekday - 1]} ${l.day} ${_months[l.month - 1]}';
}

class _Txn {
  const _Txn({
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

  factory _Txn.fromJson(Map<String, dynamic> j) {
    final out = '${j['direction'] ?? 'out'}' == 'out';
    final n = _money(j['amountNaira']);
    return _Txn(
      label: (j['label'] ?? '').toString(),
      sub: (j['sub'] ?? '').toString(),
      amount: '${out ? '-' : '+'}${wbNaira(n)}',
      time: _txnTime(DateTime.tryParse('${j['createdAt'] ?? ''}')),
      out: out,
    );
  }
}

class _WalletDesktopScreenState extends State<WalletDesktopScreen> {
  int _balance = 0;
  int _escrow = 0;
  List<_Txn>? _txns;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final res = await AccountExtrasApi.instance.wallet();
      final raw = (res['transactions'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _balance = _money(res['balanceNaira']);
        _escrow = _money(res['escrowHeldNaira']);
        _txns = [
          for (final e in raw)
            _Txn.fromJson((e as Map).cast<String, dynamic>()),
        ];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txns = _txns;
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.xl,
          vertical: WBSpacing.xl,
        ),
        child: WBMaxWidth(
          maxWidth: 880,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BalanceHero(
                title: context.l10n.walletTitle,
                amount: txns == null && _error == null ? '—' : wbNaira(_balance),
                escrow: _escrow,
              ),
              const SizedBox(height: WBSpacing.xl),
              SectionHeader(
                title: context.l10n.walletRecentTxns,
                action: context.l10n.actionSeeAll,
              ),
              const SizedBox(height: WBSpacing.md),
              if (txns == null && _error == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation(WBColors.surfaceDark),
                      ),
                    ),
                  ),
                )
              else if (_error != null)
                _hint(_error!)
              else if (txns!.isEmpty)
                _hint(context.l10n.walletNoTxns)
              else
                Container(
                  decoration: BoxDecoration(
                    color: WBColors.surfaceCard,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                    boxShadow: WBShadows.card,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < txns.length; i++) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => wbShowSnack(
                            context,
                            '${txns[i].label} · ${txns[i].amount}',
                          ),
                          child: _TxnRow(
                            label: txns[i].label,
                            sub: txns[i].sub,
                            amount: txns[i].amount,
                            time: txns[i].time,
                            out: txns[i].out,
                          ),
                        ),
                        if (i != txns.length - 1) const WBDivider(),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hint(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(WBSpacing.md + 4),
        decoration: BoxDecoration(
          color: WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Text(
          text,
          style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
        ),
      );
}

/// Dark balance card — the desktop equivalent of the mobile hero, framed as a
/// rounded card inside the centered column instead of a full-bleed header.
class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.title,
    required this.amount,
    required this.escrow,
  });

  final String title;
  final String amount;
  final int escrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.xl,
        WBSpacing.xl,
        WBSpacing.xl,
        WBSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WBTypography.cardTitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'TOTAL PAID',
            style: WBTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: WBTypography.hero.copyWith(
              fontSize: 48,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          if (escrow > 0) ...[
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const WBIcon(
                    WBIconName.clock,
                    size: 15,
                    color: WBColors.statusWarning,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      context.l10n.walletEscrowHeld(wbNaira(escrow)),
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
