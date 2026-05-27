import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/address_controller.dart';
import '../../../recipes/application/recipe_cart_controller.dart';
import '../../../recipes/data/recipes_api.dart';
import '../../../recipes/domain/models/recipe_cart_item.dart';
import '../../application/cart_controller.dart';
import '../../data/orders_api.dart';
import '../widgets/sticky_action_bar.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _scheduled = false;
  bool _placing = false;
  bool _waitingForPayment = false;
  bool _paymentTimedOut = false;
  String? _pendingOrderId;
  _ScheduleSlot? _slot;

  @override
  void initState() {
    super.initState();
    AddressController.instance.load();
    RecipeCartController.instance.load();
  }

  /// Converts the picked slot into an ISO datetime for the API.
  String? _scheduledForIso() {
    if (!_scheduled || _slot == null) return null;
    final dayOffset = int.tryParse(_slot!.dateKey.substring(1)) ?? 0;
    final slotIndex = int.tryParse(_slot!.timeKey.substring(1)) ?? 1;
    final base = DateTime.now().add(Duration(days: dayOffset));
    return DateTime(base.year, base.month, base.day, 10 + slotIndex)
        .toIso8601String();
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    try {
      final hasRecipes =
          RecipeCartController.instance.items.value.isNotEmpty;
      final hasProducts =
          ref.read(cartControllerProvider).items.isNotEmpty;

      String orderId = '';
      String checkoutUrl = '';

      if (hasRecipes) {
        // Resolve the default address — required by the recipe checkout
        // endpoint. We piggy-back on AddressController which is already
        // loaded by initState.
        final addr = AddressController.instance.addresses.value
            .where((a) => a.isDefault)
            .firstOrNull;
        if (addr == null) {
          if (mounted) {
            wbShowSnack(context, context.l10n.checkoutNoAddress);
            setState(() => _placing = false);
          }
          return;
        }
        final res = await RecipesApi.instance.checkout(
          addressId: addr.id,
        );
        orderId = res['id'] as String? ?? '';
        checkoutUrl = res['checkoutUrl'] as String? ?? '';
        // Server already emptied the recipe cart.
        RecipeCartController.instance.clearLocal();
      }

      if (hasProducts) {
        // Resolve default address for product delivery.
        final productAddr = AddressController.instance.addresses.value
            .where((a) => a.isDefault)
            .firstOrNull;
        if (productAddr == null && !hasRecipes) {
          if (mounted) {
            wbShowSnack(context, context.l10n.checkoutNoAddress);
            setState(() => _placing = false);
          }
          return;
        }
        final order = await OrdersApi.instance.placeOrder(
          addressId: productAddr?.id,
          scheduledFor: _scheduledForIso(),
        );
        await ref.read(cartControllerProvider.notifier).load();
        // The product order takes precedence as the order we follow on the
        // tracking screen (riders/timelines/etc are wired to it).
        orderId = order['id'] as String? ?? orderId;
        final url = order['checkoutUrl'] as String? ?? '';
        if (url.isNotEmpty) checkoutUrl = url;
      }

      if (!mounted) return;

      if (checkoutUrl.isNotEmpty) {
        // Open the Flutterwave hosted checkout page in the device browser.
        await launchUrl(
          Uri.parse(checkoutUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      if (!mounted) return;
      setState(() {
        _placing = false;
        _waitingForPayment = true;
        _paymentTimedOut = false;
        _pendingOrderId = orderId;
      });

      if (orderId.isNotEmpty) {
        _waitForPayment(orderId);
      }
      return; // skip the finally setState below — state already set
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted && _placing) setState(() => _placing = false);
    }
  }

  /// Polls GET /orders/{orderId} every 3 seconds (max 10 minutes / 200 tries).
  /// Navigates to tracking once the order leaves the `awaiting_payment` state.
  Future<void> _waitForPayment(String orderId) async {
    for (var i = 0; i < 200; i++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      try {
        final order = await OrdersApi.instance.orderDetail(orderId);
        final state = order['state'] as String? ?? '';
        if (state.isNotEmpty && state != 'placed') {
          if (mounted) {
            context.go('${AppRoutes.orderConfirmation}?orderId=$orderId');
          }
          return;
        }
      } catch (_) {
        // Network blip — keep polling.
      }
    }
    // 10-minute timeout reached.
    if (mounted) setState(() => _paymentTimedOut = true);
  }

  String get _scheduleSubtitle {
    if (_slot == null) return 'Pick a time slot';
    return '${_slot!.dateLabel} · ${_slot!.timeLabel}';
  }

  Future<void> _openScheduleSheet() async {
    final picked = await showModalBottomSheet<_ScheduleSlot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleSheet(initial: _slot),
    );
    if (picked != null) {
      setState(() {
        _slot = picked;
        _scheduled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RecipeCartItem>>(
      valueListenable: RecipeCartController.instance.items,
      builder: (context, recipeItems, _) =>
          _buildBody(context, recipeItems),
    );
  }

  Widget _buildBody(BuildContext context, List<RecipeCartItem> recipeItems) {
    final cart = ref.watch(cartControllerProvider);
    final lines = cart.items;
    final productSubtotal = lines.fold<int>(0, (s, l) => s + l.total);
    final recipeSubtotal = recipeItems.fold<int>(
      0,
      (s, i) => s + (i.totalPriceKobo ~/ 100),
    );
    final subtotal = productSubtotal + recipeSubtotal;
    var delivery = 600;
    // Mirror server-side fee logic: 1.5% service fee, min ₦50, max ₦5000.
    final serviceFee = (subtotal * 150 / 10000).ceil().clamp(50, 5000);
    final total = subtotal + delivery + serviceFee;

    // Show waiting-for-payment screen while polling.
    if (_waitingForPayment) {
      return Scaffold(
        backgroundColor: WBColors.bgSecondary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(WBSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_paymentTimedOut) ...[
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: WBColors.surfaceDark,
                      backgroundColor: WBColors.bgSoft,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  Text(
                    context.l10n.checkoutWaiting,
                    style: WBTypography.cardTitle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.checkoutWaitingBody,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const WBIcon(WBIconName.bell, size: 40),
                  const SizedBox(height: WBSpacing.lg),
                  Text(
                    context.l10n.checkoutTimeout,
                    style: WBTypography.cardTitle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.checkoutTimeoutBody,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  WBButton(
                    label: context.l10n.checkoutCheckStatus,
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: () {
                      if (_pendingOrderId != null) {
                        setState(() => _paymentTimedOut = false);
                        _waitForPayment(_pendingOrderId!);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  WBButton(
                    label: context.l10n.checkoutGoBack,
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: () => setState(() {
                      _waitingForPayment = false;
                      _paymentTimedOut = false;
                      _pendingOrderId = null;
                    }),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                140,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Text(context.l10n.checkoutTitle, style: WBTypography.page),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                _Section(
                  label: context.l10n.checkoutDeliverySection,
                  child: ValueListenableBuilder<List<Address>>(
                    valueListenable: AddressController.instance.addresses,
                    builder: (_, addresses, _) {
                      final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: WBColors.bgSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const WBIcon(WBIconName.pin, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: defaultAddr == null
                                ? Text(
                                    context.l10n.checkoutNoAddress,
                                    style: WBTypography.body.copyWith(
                                      color: WBColors.fgSecondary,
                                      fontSize: 14,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        defaultAddr.line,
                                        style: WBTypography.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (defaultAddr.detail.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          defaultAddr.detail,
                                          style: WBTypography.caption.copyWith(
                                            color: WBColors.fgSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.savedAddresses),
                            child: Text(
                              context.l10n.checkoutChangeAddress,
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgHeader,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                _Section(
                  label: context.l10n.checkoutTimingSection,
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeOption(
                          label: context.l10n.checkoutNow,
                          sub: context.l10n.checkoutNowSubtitle,
                          active: !_scheduled,
                          onTap: () => setState(() {
                            _scheduled = false;
                            _slot = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TimeOption(
                          label: context.l10n.checkoutSchedule,
                          sub: _scheduleSubtitle,
                          active: _scheduled,
                          onTap: _openScheduleSheet,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                _Section(
                  label: context.l10n.checkoutPaymentSection,
                  child: Text(
                    "You will be redirected to Flutterwave to complete your payment securely.",
                    style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
                  ),
                ),
                _Section(
                  label: context.l10n.checkoutBasketSection,
                  child: Column(
                    children: [
                      if (recipeItems.isNotEmpty) ...[
                        _RecipeSubsection(items: recipeItems),
                        const SizedBox(height: 10),
                        if (lines.isNotEmpty) ...[
                          const WBDivider(),
                          const SizedBox(height: 12),
                        ],
                      ],
                      for (final l in lines) ...[
                        _Line(
                          label: '${l.product.name} × ${l.quantity}',
                          value: l.totalLabel,
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 4),
                      const WBDivider(),
                      const SizedBox(height: 14),
                      _Line(label: 'Delivery', value: '₦${_n(delivery)}'),
                      const SizedBox(height: 8),
                      _Line(label: 'Service fee', value: '₦${_n(serviceFee)}'),
                      const SizedBox(height: 14),
                      const WBDivider(),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.cartTotal,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₦${_n(total)}',
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                      ),
                      children: const [
                        TextSpan(text: 'By placing this order you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: WBColors.fgHeader,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionBar(
              child: WBButton(
                label: context.l10n.checkoutPlaceOrder,
                fullWidth: true,
                size: WBButtonSize.lg,
                loading: _placing,
                trailing: Text(
                  '₦${_n(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: (lines.isEmpty && recipeItems.isEmpty)
                    ? null
                    : _placeOrder,
              ),
            ),
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

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.md + 2),
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
              fontWeight: FontWeight.w600,
              color: WBColors.fgPlaceholder,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.label,
    required this.sub,
    required this.active,
    required this.onTap,
  });
  final String label;
  final String sub;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? WBColors.surfaceDark : WBColors.bgSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: WBTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              style: WBTypography.caption.copyWith(
                color: active
                    ? Colors.white.withValues(alpha: 0.65)
                    : WBColors.fgSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeSubsection extends StatelessWidget {
  const _RecipeSubsection({required this.items});

  final List<RecipeCartItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.recipeCartSection.toUpperCase(),
          style: WBTypography.label.copyWith(
            fontWeight: FontWeight.w600,
            color: WBColors.fgPlaceholder,
            letterSpacing: 0.66,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        for (final i in items) ...[
          _Line(
            label: i.recipe.name,
            value: '₦${_n(i.totalPriceKobo ~/ 100)}',
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WBTypography.secondary),
        Text(
          value,
          style: WBTypography.secondary.copyWith(
            color: WBColors.fgHeader,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ScheduleSlot {
  const _ScheduleSlot({
    required this.dateKey,
    required this.dateLabel,
    required this.timeKey,
    required this.timeLabel,
  });
  final String dateKey;
  final String dateLabel;
  final String timeKey;
  final String timeLabel;
}

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({this.initial});
  final _ScheduleSlot? initial;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  late String _dateKey = widget.initial?.dateKey ?? _dates.first.$1;
  String? _timeKey;

  @override
  void initState() {
    super.initState();
    _timeKey = widget.initial?.timeKey;
  }

  static final List<(String, String)> _dates = _buildDates();

  static List<(String, String)> _buildDates() {
    final now = DateTime.now();
    String fmt(DateTime d, int offset) {
      if (offset == 0) return 'Today';
      if (offset == 1) return 'Tomorrow';
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${d.day} ${months[d.month - 1]}';
    }

    return [
      for (var i = 0; i < 5; i++)
        ('d$i', fmt(now.add(Duration(days: i)), i)),
    ];
  }

  static const _slots = [
    ('s1', '11 am – 12 pm'),
    ('s2', '12 – 1 pm'),
    ('s3', '1 – 2 pm'),
    ('s4', '2 – 3 pm'),
    ('s5', '3 – 4 pm'),
    ('s6', '4 – 5 pm'),
    ('s7', '5 – 6 pm'),
    ('s8', '6 – 7 pm'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: WBColors.bgDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'When do you want it?',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a time that works for you.',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'DATE',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final d = _dates[i];
                  return WBTag(
                    label: d.$2,
                    active: d.$1 == _dateKey,
                    onTap: () => setState(() => _dateKey = d.$1),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'TIME SLOT',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final s in _slots)
                  WBTag(
                    label: s.$2,
                    active: s.$1 == _timeKey,
                    onTap: () => setState(() => _timeKey = s.$1),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            WBButton(
              label: context.l10n.checkoutScheduleConfirm,
              fullWidth: true,
              size: WBButtonSize.lg,
              onPressed: _timeKey == null
                  ? null
                  : () {
                      final date = _dates.firstWhere(
                        (d) => d.$1 == _dateKey,
                      );
                      final slot = _slots.firstWhere(
                        (s) => s.$1 == _timeKey,
                      );
                      Navigator.of(context).pop(
                        _ScheduleSlot(
                          dateKey: date.$1,
                          dateLabel: date.$2,
                          timeKey: slot.$1,
                          timeLabel: slot.$2,
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
