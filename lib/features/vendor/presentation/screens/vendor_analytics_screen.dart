import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  String _range = '7d';
  static const _ranges = [('7d', 'Last 7 days'), ('30d', 'Last 30 days'), ('90d', 'Last 90 days')];

  @override
  Widget build(BuildContext context) {
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
                      Text("How you're doing", style: WBTypography.page),
                      Text(
                        "The numbers don't lie.",
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
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _ranges.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => WBTag(
                  label: _ranges[i].$2,
                  active: _ranges[i].$1 == _range,
                  onTap: () => setState(() => _range = _ranges[i].$1),
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Row(
              children: const [
                _Metric(label: 'Orders', value: '187'),
                SizedBox(width: 10),
                _Metric(label: 'Revenue', value: '₦612k'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                _Metric(label: 'Avg order', value: '₦3,274'),
                SizedBox(width: 10),
                _Metric(label: 'Rating', value: '★ 4.8'),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Sales trend',
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            WBCard(
              child: SizedBox(
                height: 140,
                child: CustomPaint(painter: _LinePainter()),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Peak hours',
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
                child: _HeatmapPainter.demoIntensities().isEmpty
                    ? const SizedBox.shrink()
                    : CustomPaint(painter: _HeatmapPainter()),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Cancellations',
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
                      children: const [
                        _LegendRow(
                          color: Color(0xFF1F1F1F),
                          label: 'Out of stock',
                          value: '42%',
                        ),
                        SizedBox(height: 8),
                        _LegendRow(
                          color: Color(0xFF6B7280),
                          label: 'Wrong address',
                          value: '23%',
                        ),
                        SizedBox(height: 8),
                        _LegendRow(
                          color: Color(0xFFA3A3A3),
                          label: 'Customer change',
                          value: '20%',
                        ),
                        SizedBox(height: 8),
                        _LegendRow(
                          color: Color(0xFFD4D4D4),
                          label: 'Other',
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
                    'Top sellers',
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: () => wbShowSnack(context, 'CSV export started'),
                  child: Row(
                    children: [
                      const WBIcon(WBIconName.more, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Export',
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
              child: Column(
                children: const [
                  _Bar(label: 'Jollof rice & chicken', value: 42, total: 50),
                  SizedBox(height: 10),
                  _Bar(label: 'Suya platter', value: 33, total: 50),
                  SizedBox(height: 10),
                  _Bar(label: 'Egusi & pounded yam', value: 24, total: 50),
                  SizedBox(height: 10),
                  _Bar(label: 'Small chops', value: 19, total: 50),
                  SizedBox(height: 10),
                  _Bar(label: 'Plantain & beans', value: 12, total: 50),
                ],
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
  static const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const _intensities = <List<double>>[
    [0.05, 0.10, 0.40, 0.85, 0.55, 0.30, 0.65, 0.45],
    [0.05, 0.12, 0.45, 0.80, 0.50, 0.28, 0.70, 0.50],
    [0.05, 0.10, 0.42, 0.78, 0.48, 0.30, 0.72, 0.52],
    [0.06, 0.11, 0.50, 0.88, 0.55, 0.32, 0.78, 0.60],
    [0.08, 0.14, 0.55, 0.95, 0.60, 0.40, 0.92, 0.85],
    [0.12, 0.18, 0.60, 0.92, 0.70, 0.55, 0.98, 0.95],
    [0.10, 0.15, 0.42, 0.70, 0.55, 0.45, 0.80, 0.65],
  ];

  static List<List<double>> demoIntensities() => _intensities;

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
        final v = _intensities[d][b];
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.4, 0.5, 0.35, 0.6, 0.55, 0.72, 0.65];
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
