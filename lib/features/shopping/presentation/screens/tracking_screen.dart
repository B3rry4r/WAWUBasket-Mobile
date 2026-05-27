import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
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

  List<String> _steps(BuildContext context) => [
    context.l10n.trackingStep1,
    context.l10n.trackingStep2,
    context.l10n.trackingStep3,
    context.l10n.trackingStep4,
    context.l10n.trackingStep5,
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
    final steps = _steps(context);
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
                          context.l10n.trackingNeedHelp,
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
                        ? context.l10n.trackingDelivered
                        : order.riderName != null
                            ? '${order.riderName} is bringing your basket.'
                            : context.l10n.trackingDefaultMessage,
                    style: WBTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                    child: LinearProgressIndicator(
                      value: (activeIndex + 1) / steps.length,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (order.riderName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  WBSpacing.md,
                  WBSpacing.screenPadding,
                  0,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                WBSpacing.lg,
                WBSpacing.screenPadding,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.isRecipeParent) ...[
                    _RecipeMultiPickup(order: order),
                    const SizedBox(height: WBSpacing.lg),
                  ],
                  Text(
                    context.l10n.trackingJourney,
                    style: WBTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.md),
                  for (var i = 0; i < steps.length; i++)
                    _TimelineRow(
                      label: steps[i],
                      done: i <= activeIndex,
                      active: i == activeIndex && !order.isDelivered,
                      isLast: i == steps.length - 1,
                    ),
                  if (order.isDelivered) ...[
                    const SizedBox(height: WBSpacing.lg),
                    WBButton(
                      label: context.l10n.trackingRate,
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

/// Multi-vendor breakdown shown on the parent order of a recipe combo.
/// Lists every child order (one per vendor) with its current status badge.
class _RecipeMultiPickup extends StatelessWidget {
  const _RecipeMultiPickup({required this.order});

  final OrderModel order;

  WBStatusKind _kindFor(OrderModel child) {
    if (child.isDelivered) return WBStatusKind.success;
    if (child.isCancelled) return WBStatusKind.error;
    if (child.state == 'placed' || child.state == 'paid') {
      return WBStatusKind.info;
    }
    return WBStatusKind.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.md),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.trackingRecipeMultiPickup(order.childOrders.length),
            style: WBTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.recipeOrderChildVendors,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < order.childOrders.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: WBColors.bgSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const WBIcon(WBIconName.basket, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      order.childOrders[i].vendorName ??
                          order.childOrders[i].shortId,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  WBStatusPill(
                    label: order.childOrders[i].statusLabel,
                    kind: _kindFor(order.childOrders[i]),
                  ),
                ],
              ),
            ),
            if (i != order.childOrders.length - 1)
              const WBDivider(),
          ],
        ],
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

