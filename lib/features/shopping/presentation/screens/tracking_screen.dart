import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/orders_api.dart';
import '../../domain/models/order.dart';

/// Live order tracking. [orderId] is passed from checkout / order history.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  OrderModel? _order;
  String? _error;

  static const _steps = [
    'Order confirmed',
    'Preparing',
    'Picked up',
    'En route',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      setState(() => _error = 'No order to track.');
      return;
    }
    try {
      final res = await OrdersApi.instance.orderDetail(id);
      if (!mounted) return;
      setState(() => _order = OrderModel.fromJson(res));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  int _activeStep(String state) {
    switch (state) {
      case 'placed':
      case 'paid':
      case 'accepted_by_vendor':
        return 0;
      case 'preparing':
      case 'ready':
        return 1;
      case 'rider_assigned':
      case 'picked_up':
        return 2;
      case 'in_transit':
        return 3;
      case 'delivered':
      case 'confirmed':
      case 'settled':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _stateScaffold(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                textAlign: TextAlign.center,
                style:
                    WBTypography.body.copyWith(color: WBColors.fgSecondary)),
            const SizedBox(height: 14),
            WBButton(
              label: 'Try again',
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: _load,
            ),
          ],
        ),
      );
    }
    if (_order == null) {
      return _stateScaffold(
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      );
    }

    final order = _order!;
    final activeIndex = _activeStep(order.state);

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.home),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.support),
                        child: Text(
                          'Need help?',
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
                    'ORDER ${order.shortId}',
                    style: WBTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.statusLabel,
                    style: WBTypography.hero.copyWith(
                      fontSize: 32,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.isDelivered
                        ? 'Delivered. Enjoy your basket!'
                        : order.riderName != null
                            ? '${order.riderName} is bringing your basket.'
                            : "We'll update you as your order moves.",
                    style: WBTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                    child: LinearProgressIndicator(
                      value: (activeIndex + 1) / _steps.length,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 200, child: CustomPaint(painter: _MapPainter())),
            if (order.riderName != null)
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
                          child: const WBIcon(WBIconName.user,
                              size: 24, color: WBColors.fgPlaceholder),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            order.riderName!,
                            style: WBTypography.cardTitle
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _ContactCircle(
                          icon: WBIconName.message,
                          onTap: () => context.push(
                            Uri(
                              path: AppRoutes.chatRider,
                              queryParameters: {
                                'orderId': order.id,
                                'title': order.riderName!,
                              },
                            ).toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                order.riderName != null ? 0 : 20,
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
                      label: _steps[i],
                      done: i <= activeIndex,
                      active: i == activeIndex && !order.isDelivered,
                      isLast: i == _steps.length - 1,
                    ),
                  if (order.isDelivered) ...[
                    const SizedBox(height: WBSpacing.lg),
                    WBButton(
                      label: 'Rate your order',
                      fullWidth: true,
                      size: WBButtonSize.md,
                      trailingIcon: WBIconName.star,
                      onPressed: () => context.push(
                        '${AppRoutes.deliveryComplete}?orderId=${order.id}',
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

  Widget _stateScaffold(Widget child) {
    return Scaffold(
      backgroundColor: WBColors.surfaceDark,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(WBSpacing.screenPadding),
              child: WBCircleIconButton(
                icon: WBIconName.chevronLeft,
                background: Colors.white.withValues(alpha: 0.12),
                iconColor: Colors.white,
                shadow: const [],
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(WBSpacing.screenPadding),
                child: child,
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
    required this.done,
    required this.active,
    required this.isLast,
  });

  final String label;
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
                          ? Border.all(
                              color: WBColors.surfaceDark, width: 2)
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
                        color: done
                            ? WBColors.surfaceDark
                            : WBColors.bgDivider,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: done ? WBColors.fgHeader : WBColors.fgDisabled,
                ),
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
    final sx = size.width / 350;
    for (final b in [
      [0.0, 0.0, 110.0, 90.0],
      [130.0, 0.0, 90.0, 90.0],
      [240.0, 0.0, 110.0, 90.0],
      [0.0, 110.0, 80.0, size.height - 110],
      [100.0, 110.0, 120.0, size.height - 110],
      [240.0, 110.0, 110.0, size.height - 110],
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(b[0] * sx, b[1], b[2] * sx, b[3]),
        block,
      );
    }
    final dest = Paint()..color = const Color(0xFF111111);
    canvas.drawCircle(Offset(280 * sx, size.height - 40), 11, dest);
    canvas.drawCircle(Offset(280 * sx, size.height - 40), 4.5,
        Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(80 * sx, 50), 12, Paint()..color = const Color(0xFFBDBDBD));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
