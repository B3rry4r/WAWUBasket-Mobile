import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
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
            Text(
              'Top sellers',
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
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
