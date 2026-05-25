import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../data/vendor_api.dart';

/// One payout row mapped from the `/v1/vendor/payouts` payload.
class _Payout {
  const _Payout({
    required this.date,
    required this.amount,
    required this.status,
    required this.kind,
  });

  final String date;
  final String amount;
  final String status;
  final WBStatusKind kind;

  factory _Payout.fromJson(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal();
    final raw = j['amount'];
    final amount = raw is num
        ? raw.toInt()
        : int.tryParse('${raw ?? 0}') ?? 0;
    final (label, kind) = switch ('${j['state'] ?? ''}') {
      'paid' => ('Completed', WBStatusKind.success),
      'failed' => ('Failed', WBStatusKind.error),
      'processing' => ('Processing', WBStatusKind.warning),
      _ => ('Pending', WBStatusKind.warning),
    };
    return _Payout(
      date: _payoutDate(created),
      amount: wbNaira(amount),
      status: label,
      kind: kind,
    );
  }
}

String _payoutDate(DateTime? t) {
  if (t == null) return '—';
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day)
      .difference(DateTime(t.year, t.month, t.day))
      .inDays;
  if (d == 0) return 'Today';
  if (d == 1) return 'Yesterday';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[t.weekday - 1]} ${t.day} ${months[t.month - 1]}';
}

class VendorPayoutsScreen extends StatefulWidget {
  const VendorPayoutsScreen({super.key});

  @override
  State<VendorPayoutsScreen> createState() => _VendorPayoutsScreenState();
}

class _VendorPayoutsScreenState extends State<VendorPayoutsScreen> {
  List<_Payout>? _payouts;
  String? _error;
  int? _balance;
  int _escrow = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final w = await VendorApi.instance.wallet();
      final bal = w['balanceNaira'];
      final esc = w['escrowHeldNaira'];
      if (!mounted) return;
      setState(() {
        _balance = bal is num ? bal.toInt() : int.tryParse('${bal ?? 0}') ?? 0;
        _escrow = esc is num ? esc.toInt() : int.tryParse('${esc ?? 0}') ?? 0;
      });
    } on ApiException {
      // Non-critical — the hero falls back to a dash.
    }
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final raw = await VendorApi.instance.payouts();
      if (!mounted) return;
      setState(() => _payouts = [
            for (final e in raw)
              _Payout.fromJson((e as Map).cast<String, dynamic>()),
          ]);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payouts = _payouts;
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ListView(
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
                      Text('Your earnings', style: WBTypography.page),
                      Text(
                        'Money in the bank.',
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
                    'AVAILABLE BALANCE',
                    style: WBTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _balance == null ? '₦—' : wbNaira(_balance!),
                    style: WBTypography.hero.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Held in escrow ${wbNaira(_escrow)} · WAWU fee 8%',
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
                      label: 'Request payout',
                      size: WBButtonSize.md,
                      trailingIcon: WBIconName.arrowRight,
                      variant: WBButtonVariant.ghost,
                      onPressed: () => _openPayoutSheet(context, _balance),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Payout history',
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (payouts == null && _error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(WBSpacing.md + 4),
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Text(
                  _error!,
                  style: WBTypography.caption
                      .copyWith(color: WBColors.fgSecondary),
                ),
              )
            else if (payouts!.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(WBSpacing.md + 4),
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Text(
                  'No payouts yet. Earnings land here once you request one.',
                  style: WBTypography.caption
                      .copyWith(color: WBColors.fgSecondary),
                ),
              )
            else
              WBCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < payouts.length; i++) ...[
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
                                    payouts[i].amount,
                                    style: WBTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    payouts[i].date,
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            WBStatusPill(
                              label: payouts[i].status,
                              kind: payouts[i].kind,
                            ),
                          ],
                        ),
                      ),
                      if (i != payouts.length - 1) const WBDivider(),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _openPayoutSheet(BuildContext context, int? availableBalance) {
  final profile = ProfileController.instance.profile.value;
  final vendorName = profile?.vendorBusinessName ?? profile?.fullName ?? 'Vendor';
  final balanceStr = availableBalance != null ? availableBalance.toString() : '';

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Request payout',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            vendorName,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: 14),
          WBInput(
            label: 'Amount (₦)',
            initialValue: balanceStr,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          WBButton(
            label: 'Request withdrawal',
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout requested · arrives in 1–2 days'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
