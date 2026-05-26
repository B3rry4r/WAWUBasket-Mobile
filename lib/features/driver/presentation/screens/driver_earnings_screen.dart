import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/driver_api.dart';

/// Driver earnings dashboard. Per-trip / weekly / monthly toggles a
/// different hero amount + trip list. Withdraw opens a bottom sheet to
/// send to the driver's mobile-money wallet.
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _TripRow {
  const _TripRow({
    required this.id,
    required this.route,
    required this.amountNaira,
    required this.completedAt,
  });
  final String id;
  final String route;
  final int amountNaira;
  final DateTime completedAt;

  factory _TripRow.fromJson(Map<String, dynamic> j) => _TripRow(
        id: '${j['id'] ?? ''}',
        route: '${j['route'] ?? 'Route'}',
        amountNaira: int.tryParse('${j['amountNaira'] ?? 0}') ?? 0,
        completedAt:
            DateTime.tryParse('${j['completedAt'] ?? ''}') ?? DateTime.now(),
      );

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(completedAt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[completedAt.weekday - 1];
    }
    return '${diff.inDays} days ago';
  }
}

class _EarningsData {
  const _EarningsData({
    required this.totalNaira,
    required this.count,
    required this.trips,
  });
  final int totalNaira;
  final int count;
  final List<_TripRow> trips;

  factory _EarningsData.fromJson(Map<String, dynamic> j) => _EarningsData(
        totalNaira: int.tryParse('${j['totalNaira'] ?? 0}') ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
        trips: [
          for (final t in (j['trips'] as List?) ?? const [])
            _TripRow.fromJson((t as Map).cast<String, dynamic>()),
        ],
      );
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  int _tab = 1; // default: This week
  static const _tabs = ['Last trip', 'This week', 'This month'];
  static const _ranges = ['today', 'week', 'month'];

  _EarningsData? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final j = await DriverApi.instance.earnings(range: _ranges[_tab]);
      if (!mounted) return;
      setState(() {
        _data = _EarningsData.fromJson(j);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load earnings. Try again.';
        _loading = false;
      });
    }
  }

  void _switchTab(int i) {
    setState(() => _tab = i);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Text('Your earnings', style: WBTypography.page),
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                _RangeTab(
                  label: _tabs[i],
                  active: i == _tab,
                  onTap: () => _switchTab(i),
                ),
                if (i != _tabs.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: WBSpacing.md),
          _loading
              ? Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white54),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(WBSpacing.lg),
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tabs[_tab].toUpperCase(),
                        style: WBTypography.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _data != null ? wbNaira(_data!.totalNaira) : '–',
                        style: WBTypography.hero.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: -0.9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _data != null
                            ? '${_data!.count} ${_data!.count == 1 ? 'trip' : 'trips'}'
                            : '–',
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
                          label: 'Send to my mobile money',
                          size: WBButtonSize.md,
                          trailingIcon: WBIconName.arrowRight,
                          variant: WBButtonVariant.ghost,
                          onPressed: () =>
                              _openWithdraw(context, _data?.totalNaira ?? 0),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Trips',
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Text(
                _error!,
                style: WBTypography.body
                    .copyWith(color: WBColors.fgSecondary, fontSize: 14),
              ),
            )
          else if (_loading)
            const SizedBox.shrink()
          else if (_data == null || _data!.trips.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Text(
                'No trips for this period.',
                style: WBTypography.body
                    .copyWith(color: WBColors.fgSecondary, fontSize: 14),
              ),
            )
          else
            WBCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _data!.trips.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _data!.trips[i].route,
                                  style: WBTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '#${_data!.trips[i].id} · ${_data!.trips[i].timeLabel}',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            wbNaira(_data!.trips[i].amountNaira),
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i != _data!.trips.length - 1) const WBDivider(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  const _RangeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? WBColors.surfaceDark : WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.pill),
            boxShadow: active ? null : WBShadows.card,
          ),
          child: Text(
            label,
            style: WBTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : WBColors.fgHeader,
            ),
          ),
        ),
      ),
    );
  }
}

void _openWithdraw(BuildContext context, int balance) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: WBColors.bgPrimary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
    ),
    builder: (sheetCtx) {
      return Padding(
        padding: EdgeInsets.only(
          left: WBSpacing.screenPadding,
          right: WBSpacing.screenPadding,
          top: WBSpacing.lg,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + WBSpacing.xl,
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
            Text(
              'Withdraw to wallet',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBInput(
              label: 'Amount (₦)',
              initialValue: '$balance',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: WBSpacing.md),
            const WBInput(
              label: 'Mobile money / wallet',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Send',
              fullWidth: true,
              size: WBButtonSize.lg,
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${wbNaira(balance)} sent')),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
