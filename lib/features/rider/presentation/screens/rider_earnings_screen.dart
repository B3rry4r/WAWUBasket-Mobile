import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/rider_api.dart';

/// Rider earnings dashboard. Today / Week / Month toggle a different
/// hero number + delivery list. Payouts are automatic.
class RiderEarningsScreen extends StatefulWidget {
  const RiderEarningsScreen({super.key});

  @override
  State<RiderEarningsScreen> createState() => _RiderEarningsScreenState();
}

/// A single delivery row fetched from the API.
class _DeliveryRow {
  const _DeliveryRow({
    required this.id,
    required this.vendorName,
    required this.amountNaira,
    required this.deliveredAt,
  });
  final String id;
  final String vendorName;
  final int amountNaira;
  final DateTime deliveredAt;

  factory _DeliveryRow.fromJson(Map<String, dynamic> j) => _DeliveryRow(
        id: '${j['id'] ?? ''}',
        vendorName: '${j['vendorName'] ?? 'Vendor'}',
        amountNaira: int.tryParse('${j['amountNaira'] ?? 0}') ?? 0,
        deliveredAt:
            DateTime.tryParse('${j['deliveredAt'] ?? ''}') ?? DateTime.now(),
      );

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(deliveredAt);
    if (diff.inDays == 0) {
      return '${deliveredAt.hour.toString().padLeft(2, '0')}:${deliveredAt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 14) return 'Last week';
    return '${diff.inDays ~/ 7} weeks ago';
  }
}

class _EarningsData {
  const _EarningsData({
    required this.totalNaira,
    required this.count,
    required this.deliveries,
  });
  final int totalNaira;
  final int count;
  final List<_DeliveryRow> deliveries;

  factory _EarningsData.fromJson(Map<String, dynamic> j) => _EarningsData(
        totalNaira: int.tryParse('${j['totalNaira'] ?? 0}') ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
        deliveries: [
          for (final d in (j['deliveries'] as List?) ?? const [])
            _DeliveryRow.fromJson((d as Map).cast<String, dynamic>()),
        ],
      );
}

class _RiderEarningsScreenState extends State<RiderEarningsScreen> {
  int _tab = 1; // default: Week
  static const _tabs = ['Today', 'Week', 'Month'];
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
      final j = await RiderApi.instance.earnings(range: _ranges[_tab]);
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
                        wbNaira(_data?.totalNaira ?? 0),
                        style: WBTypography.hero.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: -0.9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_data?.count ?? 0} ${(_data?.count ?? 0) == 1 ? 'delivery' : 'deliveries'}',
                        style: WBTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Deliveries',
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
          else if (_data == null || _data!.deliveries.isEmpty)
            const WBEmptyState(
              illustration: WBEmptyIllustration.noTrips,
              label: 'No deliveries for this period.',
            )
          else
            WBCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _data!.deliveries.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _data!.deliveries[i].vendorName,
                                  style: WBTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '#${_data!.deliveries[i].id} · ${_data!.deliveries[i].timeLabel}',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            wbNaira(_data!.deliveries[i].amountNaira),
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i != _data!.deliveries.length - 1) const WBDivider(),
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : WBColors.fgHeader,
            ),
          ),
        ),
      ),
    );
  }
}

