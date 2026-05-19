import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  static const _steps = [
    (label: 'Order confirmed', time: '12:31', done: true, active: false),
    (label: 'Preparing', time: '12:34', done: true, active: false),
    (label: 'Picked up', time: '12:48', done: true, active: false),
    (label: 'En route', time: 'Now', done: true, active: true),
    (label: 'Delivered', time: '', done: false, active: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Dark hero
            Container(
              color: WBColors.surfaceDark,
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WBCircleIconButton(
                        icon: WBIconName.chevronLeft,
                        background: Colors.white.withValues(alpha: 0.12),
                        iconColor: Colors.white,
                        shadow: const [],
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.support),
                        child: Text(
                          'Support',
                          style: WBTypography.secondary.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: WBSpacing.md),
                  Text(
                    'ARRIVING IN',
                    style: WBTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12 min',
                    style: WBTypography.hero.copyWith(
                      fontSize: 48,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tunde is bringing your basket.',
                    style: WBTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                    child: LinearProgressIndicator(
                      value: 0.68,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Map placeholder (grayscale block grid + dashed route)
            SizedBox(
              height: 200,
              child: CustomPaint(painter: _MapPainter()),
            ),
            // Rider card overlaps map by 20px
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: WBSpacing.screenPadding,
                ),
                child: Container(
                  padding: const EdgeInsets.all(WBSpacing.md + 2),
                  decoration: BoxDecoration(
                    color: WBColors.surfaceCard,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                    boxShadow: WBShadows.float,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: WBColors.bgSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(
                          WBIconName.user,
                          size: 24,
                          color: WBColors.fgPlaceholder,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tunde Adeyemi',
                              style: WBTypography.cardTitle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const WBIcon(WBIconName.star, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgHeader,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '· 1,204 deliveries',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _ContactCircle(
                        icon: WBIconName.phone,
                        onTap: () => context.push(AppRoutes.chatRider),
                      ),
                      const SizedBox(width: 10),
                      _ContactCircle(
                        icon: WBIconName.message,
                        onTap: () => context.push(AppRoutes.chatRider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Timeline
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                0,
                WBSpacing.screenPadding,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your order is on a journey',
                    style: WBTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.md),
                  for (var i = 0; i < _steps.length; i++)
                    _TimelineRow(
                      label: _steps[i].label,
                      time: _steps[i].time,
                      done: _steps[i].done,
                      active: _steps[i].active,
                      isLast: i == _steps.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCircle extends StatelessWidget {
  const _ContactCircle({required this.icon, required this.onTap});
  final WBIconName icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: WBColors.bgSoft,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: WBIcon(icon, size: 18),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.time,
    required this.done,
    required this.active,
    required this.isLast,
  });

  final String label;
  final String time;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done && !active
                          ? WBColors.surfaceDark
                          : WBColors.bgSoft,
                      border: active
                          ? Border.all(color: WBColors.surfaceDark, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: active
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: WBColors.surfaceDark,
                              shape: BoxShape.circle,
                            ),
                          )
                        : (done
                            ? const WBIcon(
                                WBIconName.check,
                                size: 12,
                                color: Colors.white,
                                strokeWidth: 2.5,
                              )
                            : null),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: done ? WBColors.surfaceDark : WBColors.bgDivider,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: done ? WBColors.fgHeader : WBColors.fgDisabled,
                    ),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
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

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEBEBEB);
    canvas.drawRect(Offset.zero & size, bg);

    final block = Paint()..color = const Color(0xFFDEDEDE);
    // Approximate the grid blocks from the JSX prototype, scaled to width
    final blocks = [
      [0.0, 0.0, 110.0, 90.0],
      [130.0, 0.0, 90.0, 90.0],
      [240.0, 0.0, 110.0, 90.0],
      [0.0, 110.0, 80.0, size.height - 110],
      [100.0, 110.0, 120.0, size.height - 110],
      [240.0, 110.0, 110.0, size.height - 110],
    ];
    final sx = size.width / 350;
    for (final b in blocks) {
      canvas.drawRect(
        Rect.fromLTWH(b[0] * sx, b[1], b[2] * sx, b[3]),
        block,
      );
    }

    // Dashed route
    final route = Path()
      ..moveTo(80 * sx, 50)
      ..lineTo(175 * sx, 50)
      ..lineTo(175 * sx, size.height - 40)
      ..lineTo(280 * sx, size.height - 40);
    final routePaint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _dashPath(canvas, route, routePaint, dashWidth: 10, dashSpace: 6);

    // Destination pin
    final dest = Paint()..color = const Color(0xFF111111);
    canvas.drawCircle(Offset(280 * sx, size.height - 40), 11, dest);
    canvas.drawCircle(
      Offset(280 * sx, size.height - 40),
      4.5,
      Paint()..color = Colors.white,
    );

    // Rider pin
    canvas.drawCircle(Offset(80 * sx, 50), 18, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(80 * sx, 50),
      18,
      Paint()
        ..color = const Color(0xFFD4D4D4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(80 * sx, 50),
      12,
      Paint()..color = const Color(0xFFBDBDBD),
    );
  }

  void _dashPath(
    Canvas canvas,
    Path source,
    Paint paint, {
    required double dashWidth,
    required double dashSpace,
  }) {
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
