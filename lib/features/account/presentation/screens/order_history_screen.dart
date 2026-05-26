import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/data/orders_api.dart';
import '../../../shopping/domain/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key, this.standalone = false});

  /// When pushed (e.g. the Home "Reorder" quick action) we render a back
  /// chip; as a bottom-nav tab it stays chrome-free.
  final bool standalone;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const _tabs = ['All', 'Active', 'Past'];
  String _activeTab = 'All';

  List<OrderModel> _orders = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (GuestModeController.instance.isGuest.value) {
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await OrdersApi.instance.myOrders();
      if (!mounted) return;
      setState(() {
        _orders = raw
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  List<OrderModel> get _filtered {
    switch (_activeTab) {
      case 'Active':
        return _orders.where((o) => o.isActive).toList();
      case 'Past':
        return _orders
            .where((o) => o.isDelivered || o.isCancelled)
            .toList();
      default:
        return _orders;
    }
  }

  List<String> _tabLabels(BuildContext context) => [
        context.l10n.orderHistoryTabAll,
        context.l10n.orderHistoryTabActive,
        context.l10n.orderHistoryTabPast,
      ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GuestModeController.instance.isGuest,
      builder: (_, isGuest, _) {
        if (isGuest) return _buildGuest(context);
        return _buildSignedIn(context);
      },
    );
  }

  Widget _buildGuest(BuildContext context) {
    // TODO(i18n): key=ordersGuestTitle / ordersGuestBody
    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          80 + MediaQuery.of(context).padding.top,
          WBSpacing.screenPadding,
          120,
        ),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: const WBIcon(
                WBIconName.basket,
                size: 36,
                color: WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Your orders will live here',
              textAlign: TextAlign.center,
              style: WBTypography.hero.copyWith(fontSize: 22),
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              'Sign in to place your first order and track it from the kitchen to your door.',
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: 'Sign in',
              size: WBButtonSize.lg,
              fullWidth: true,
              trailingIcon: WBIconName.arrowRight,
              onPressed: () => context.push(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
    if (widget.standalone) {
      return Scaffold(backgroundColor: WBColors.bgPrimary, body: content);
    }
    return content;
  }

  Widget _buildSignedIn(BuildContext context) {
    final tabLabels = _tabLabels(context);
    final body = SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          120,
        ),
        children: [
          if (widget.standalone)
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(context.l10n.orderHistoryTitle, style: WBTypography.page),
                ),
              ],
            )
          else
            Text(context.l10n.orderHistoryTitle, style: WBTypography.page),
          const SizedBox(height: WBSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => WBTag(
                label: tabLabels[i],
                active: _tabs[i] == _activeTab,
                onTap: () => setState(() => _activeTab = _tabs[i]),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          if (_loading)
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
            _Hint(
              text: _error!,
              actionLabel: context.l10n.actionRetry,
              onAction: _load,
            )
          else if (_filtered.isEmpty)
            _Hint(text: context.l10n.orderHistoryEmpty)
          else
            for (final order in _filtered) ...[
              _OrderCard(order: order, onChanged: _load),
              const SizedBox(height: WBSpacing.md),
            ],
        ],
      ),
    );
    if (widget.standalone) {
      return Scaffold(backgroundColor: WBColors.bgPrimary, body: body);
    }
    return body;
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, this.actionLabel, this.onAction});
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(WBSpacing.md + 4),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            WBButton(
              label: actionLabel!,
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onChanged});
  final OrderModel order;
  final VoidCallback onChanged;

  WBStatusKind get _statusKind {
    if (order.isCancelled) return WBStatusKind.error;
    if (order.isDelivered) return WBStatusKind.success;
    return WBStatusKind.info;
  }

  Future<void> _reorder(BuildContext context) async {
    try {
      await OrdersApi.instance.reorder(order.id);
      if (!context.mounted) return;
      wbShowSnack(context, context.l10n.orderHistoryReordered);
      context.push(AppRoutes.cart);
    } on ApiException catch (e) {
      if (context.mounted) wbShowSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WBCard(
      padding: const EdgeInsets.all(WBSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shortId,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.itemsSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              WBStatusPill(label: order.statusLabel, kind: _statusKind),
            ],
          ),
          const SizedBox(height: 14),
          const WBDivider(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₦${_n(order.total)}',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _date(order.placedAt),
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.isActive)
                WBButton(
                  label: context.l10n.orderHistoryTrack,
                  size: WBButtonSize.sm,
                  onPressed: () => context.push(
                    '${AppRoutes.tracking}?orderId=${order.id}',
                  ),
                )
              else ...[
                WBButton(
                  label: context.l10n.orderHistoryReceipt,
                  size: WBButtonSize.sm,
                  variant: WBButtonVariant.secondary,
                  onPressed: () => context.push(
                    '${AppRoutes.receipt}?orderId=${order.id}',
                  ),
                ),
                if (order.isDelivered) ...[
                  const SizedBox(width: 8),
                  WBButton(
                    label: context.l10n.orderHistoryReorder,
                    size: WBButtonSize.sm,
                    onPressed: () => _reorder(context),
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _n(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _date(DateTime d) {
  final now = DateTime.now();
  final sameDay =
      d.year == now.year && d.month == now.month && d.day == now.day;
  String two(int n) => n.toString().padLeft(2, '0');
  if (sameDay) return 'Today, ${two(d.hour)}:${two(d.minute)}';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]}';
}
