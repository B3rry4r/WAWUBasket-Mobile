import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/vendor_api.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

int _int(dynamic v) =>
    v is num ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0;

String _compactNaira(int v) {
  if (v >= 1000000) {
    final m = v / 1000000;
    return '₦${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}m';
  }
  if (v >= 1000) return '₦${(v / 1000).round()}k';
  return '₦$v';
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  String _range = '7d';
  List<(String, String)> _ranges(BuildContext context) => [
        ('7d', context.l10n.vendorAnalyticsLast7),
        ('30d', context.l10n.vendorAnalyticsLast30),
        ('90d', context.l10n.vendorAnalyticsLast90),
      ];

  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = false; });
    try {
      final d = await VendorApi.instance.analytics(range: _range);
      if (mounted) setState(() { _data = d; _loading = false; });
    } on ApiException {
      if (mounted) setState(() { _loading = false; _error = true; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  /// Daily revenue normalised to 0–1 for the trend line.
  List<double> get _trendPoints {
    final trend = (_data?['revenueTrend'] as List?) ?? const [];
    final revs = [
      for (final t in trend) _int((t as Map)['revenue']).toDouble(),
    ];
    if (revs.isEmpty) return List.filled(7, 0.1);
    final max = revs.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return [for (final _ in revs) 0.08];
    return [for (final r in revs) (r / max).clamp(0.05, 1.0)];
  }

  /// Best-selling items for the range, highest first.
  List<({String label, int count})> get _topSellers {
    final raw = (_data?['topSellers'] as List?) ?? const [];
    return [
      for (final t in raw)
        (
          label: ((t as Map)['label'] ?? '').toString(),
          count: (t['count'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// 7×8 peak-hours grid normalised to 0–1 for the heatmap.
  List<List<double>> get _heatmap {
    final raw = (_data?['peakHours'] as List?) ?? const [];
    final grid = [
      for (final row in raw)
        [for (final c in (row as List)) (c as num).toDouble()],
    ];
    if (grid.isEmpty) return const [];
    var max = 0.0;
    for (final row in grid) {
      for (final c in row) {
        if (c > max) max = c;
      }
    }
    if (max <= 0) return grid;
    return [
      for (final row in grid) [for (final c in row) c / max],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final d = _data ?? const <String, dynamic>{};
    final orders = _int(d['orders']).toString();
    final revenue = _compactNaira(_int(d['revenue']));
    final avgOrder = wbNaira(_int(d['avgOrderValue']));
    final rating = '★ ${d['rating'] ?? '0.0'}';

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor:
                        AlwaysStoppedAnimation(WBColors.surfaceDark),
                  ),
                ),
              )
            : _error && _data == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(WBSpacing.screenPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load analytics.',
                        style: WBTypography.body.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                      const SizedBox(height: WBSpacing.md),
                      WBButton(
                        label: context.l10n.actionRetry,
                        size: WBButtonSize.sm,
                        variant: WBButtonVariant.secondary,
                        onPressed: _load,
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
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
                      Text(context.l10n.vendorAnalyticsTitle, style: WBTypography.page),
                      Text(
                        context.l10n.vendorAnalyticsSubtitle,
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
            Builder(
              builder: (ctx) {
                final ranges = _ranges(ctx);
                return SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ranges.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => WBTag(
                      label: ranges[i].$2,
                      active: ranges[i].$1 == _range,
                      onTap: () {
                        setState(() => _range = ranges[i].$1);
                        _load();
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: WBSpacing.lg),
            Row(
              children: [
                _Metric(label: context.l10n.vendorAnalyticsOrders, value: orders),
                const SizedBox(width: 10),
                _Metric(label: context.l10n.vendorAnalyticsRevenue, value: revenue),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Metric(label: context.l10n.vendorAnalyticsAvgOrder, value: avgOrder),
                const SizedBox(width: 10),
                _Metric(label: context.l10n.vendorAnalyticsRating, value: rating),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              context.l10n.vendorAnalyticsSalesTrend,
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            WBCard(
              child: SizedBox(
                height: 140,
                child: CustomPaint(painter: _LinePainter(_trendPoints)),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.vendorAnalyticsPeakHours,
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  'Mon → Sun · 12 am → 11 pm',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            WBCard(
              child: SizedBox(
                height: 180,
                child: _heatmap.isEmpty
                    ? const SizedBox.shrink()
                    : CustomPaint(painter: _HeatmapPainter(_heatmap)),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              context.l10n.vendorAnalyticsCancellations,
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            WBCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(painter: _DonutPainter()),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendRow(
                          color: const Color(0xFF1F1F1F),
                          label: context.l10n.vendorAnalyticsOutOfStock,
                          value: '42%',
                        ),
                        const SizedBox(height: 8),
                        _LegendRow(
                          color: const Color(0xFF6B7280),
                          label: context.l10n.vendorAnalyticsWrongAddress,
                          value: '23%',
                        ),
                        const SizedBox(height: 8),
                        _LegendRow(
                          color: const Color(0xFFA3A3A3),
                          label: context.l10n.vendorAnalyticsCustomerChange,
                          value: '20%',
                        ),
                        const SizedBox(height: 8),
                        _LegendRow(
                          color: const Color(0xFFD4D4D4),
                          label: context.l10n.vendorAnalyticsOther,
                          value: '15%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.vendorAnalyticsTopSellers,
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: () => wbShowSnack(context, context.l10n.vendorAnalyticsCsvStarted),
                  child: Row(
                    children: [
                      const WBIcon(WBIconName.more, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.vendorAnalyticsExport,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            WBCard(
              child: Builder(
                builder: (_) {
                  final sellers = _topSellers;
                  if (sellers.isEmpty) {
                    return Text(
                      context.l10n.vendorAnalyticsNoSales,
                      style: WBTypography.caption
                          .copyWith(color: WBColors.fgSecondary),
                    );
                  }
                  final top = sellers.first.count;
                  return Column(
                    children: [
                      for (var i = 0; i < sellers.length; i++) ...[
                        _Bar(
                          label: sellers[i].label,
                          value: sellers[i].count,
                          total: top == 0 ? 1 : top,
                        ),
                        if (i != sellers.length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.total,
  });
  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgHeader,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(WBRadius.pill),
            child: LinearProgressIndicator(
              value: value / total,
              minHeight: 8,
              backgroundColor: WBColors.bgSoft,
              valueColor: const AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value.toString(),
          style: WBTypography.caption.copyWith(
            color: WBColors.fgHeader,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgHeader,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: WBTypography.caption.copyWith(
            color: WBColors.fgHeader,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// 7 days × 8 buckets-of-3-hours heatmap. The grid is fixed so the bar
/// widths stay legible on small screens; bucketing 24h into 8 reads more
/// like "morning/midday/dinner" than 24 thin columns.
class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter(this.intensities);

  static const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// 7 rows × 8 buckets, each value normalised to 0–1.
  final List<List<double>> intensities;

  @override
  void paint(Canvas canvas, Size size) {
    final labelStyle = TextPainter(
      textDirection: TextDirection.ltr,
    );
    const leftPad = 18.0;
    const bottomPad = 18.0;
    final cellW = (size.width - leftPad) / 8;
    final cellH = (size.height - bottomPad) / 7;
    final paint = Paint();
    for (var d = 0; d < 7; d++) {
      for (var b = 0; b < 8; b++) {
        final v = d < intensities.length && b < intensities[d].length
            ? intensities[d][b]
            : 0.0;
        paint.color = WBColors.surfaceDark.withValues(alpha: 0.08 + v * 0.92);
        final rect = Rect.fromLTWH(
          leftPad + b * cellW + 1,
          d * cellH + 1,
          cellW - 2,
          cellH - 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
      }
      labelStyle
        ..text = TextSpan(
          text: days[d],
          style: const TextStyle(
            fontSize: 10,
            color: WBColors.fgPlaceholder,
            fontWeight: FontWeight.w600,
          ),
        )
        ..layout();
      labelStyle.paint(
        canvas,
        Offset(0, d * cellH + (cellH - labelStyle.height) / 2),
      );
    }
    // Bottom hour buckets
    const buckets = ['12a', '3', '6', '9', '12p', '3', '6', '9p'];
    for (var b = 0; b < buckets.length; b++) {
      labelStyle
        ..text = TextSpan(
          text: buckets[b],
          style: const TextStyle(
            fontSize: 10,
            color: WBColors.fgPlaceholder,
            fontWeight: FontWeight.w500,
          ),
        )
        ..layout();
      labelStyle.paint(
        canvas,
        Offset(
          leftPad + b * cellW + (cellW - labelStyle.width) / 2,
          size.height - bottomPad + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) =>
      oldDelegate.intensities != intensities;
}

class _DonutPainter extends CustomPainter {
  static const _slices = [
    (0.42, Color(0xFF1F1F1F)),
    (0.23, Color(0xFF6B7280)),
    (0.20, Color(0xFFA3A3A3)),
    (0.15, Color(0xFFD4D4D4)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    const start = -3.14159 / 2;
    var sweepStart = start;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;
    for (final s in _slices) {
      paint.color = s.$2;
      final sweep = 6.28318 * s.$1;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        sweepStart + 0.02,
        sweep - 0.04,
        false,
        paint,
      );
      sweepStart += sweep;
    }
    final tp = TextPainter(
      text: const TextSpan(
        text: '3.4%',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: WBColors.fgHeader,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2 - 6),
    );
    final tp2 = TextPainter(
      text: const TextSpan(
        text: 'cancel rate',
        style: TextStyle(
          fontSize: 10,
          color: WBColors.fgPlaceholder,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(
      canvas,
      Offset(center.dx - tp2.width / 2, center.dy + tp.height / 2 - 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.points);

  /// Daily revenue normalised to 0–1, oldest first.
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height - (points[i] * size.height) - 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = WBColors.surfaceDark
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Last point dot
    canvas.drawCircle(
      Offset(size.width, size.height - (points.last * size.height) - 8),
      4,
      Paint()..color = WBColors.surfaceDark,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.points != points;
}
