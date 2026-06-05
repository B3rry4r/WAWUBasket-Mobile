import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../data/vendor_api.dart';

/// One payout row mapped from the `/v1/vendor/payouts` payload. Mirrors the
/// mobile [VendorPayoutsScreen]'s private model, parsing and formatting exactly.
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
    final amount = raw is num ? raw.toInt() : int.tryParse('${raw ?? 0}') ?? 0;
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

/// Desktop-web layout for the vendor payouts screen. Mirrors
/// [VendorPayoutsScreen]'s data loading, money formatting, status logic and
/// empty/error handling exactly; only the layout is re-flowed for the desktop
/// dashboard (page header + summary cards + history card). Pushed surface —
/// wrapped in [OperatorDesktopScaffold] so the vendor sidebar stays visible.
/// Mobile build untouched.
class VendorPayoutsDesktopScreen extends StatefulWidget {
  const VendorPayoutsDesktopScreen({super.key});

  @override
  State<VendorPayoutsDesktopScreen> createState() =>
      _VendorPayoutsDesktopScreenState();
}

class _VendorPayoutsDesktopScreenState
    extends State<VendorPayoutsDesktopScreen> {
  List<_Payout>? _payouts;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
    return OperatorDesktopScaffold(
      role: AppRole.vendor,
      child: SingleChildScrollView(
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
                        Text(
                          context.l10n.vendorPayoutsEarnings,
                          style: WBTypography.page,
                        ),
                        const SizedBox(height: 2),
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
              const SizedBox(height: WBSpacing.xl),
              if (payouts != null && _error == null && payouts.isNotEmpty) ...[
                _SummaryRow(payouts: payouts),
                const SizedBox(height: WBSpacing.xl),
              ],
              Text(
                'Payout history',
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: WBSpacing.md),
              if (payouts == null && _error == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 56),
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
              else if (payouts!.isEmpty)
                const WBEmptyState(
                  illustration: WBEmptyIllustration.noTransaction,
                  label: 'No payouts yet.',
                  sub: 'Earnings are paid out automatically.',
                )
              else
                WBCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < payouts.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  payouts[i].amount,
                                  style: WBTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  payouts[i].date,
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
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

/// Summary stat cards derived from the loaded payouts — total paid out and the
/// count of payouts still pending/processing. Desktop-only density; uses the
/// same already-formatted data as the history list.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.payouts});

  final List<_Payout> payouts;

  @override
  Widget build(BuildContext context) {
    final pending = payouts.where((p) => p.kind == WBStatusKind.warning).length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total payouts',
            value: '${payouts.length}',
          ),
        ),
        const SizedBox(width: WBSpacing.md),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: '$pending',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: WBTypography.cardTitle.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
