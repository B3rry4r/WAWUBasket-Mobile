import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/address_controller.dart';
import '../../../account/data/account_extras_api.dart';
import '../../application/cart_controller.dart';
import '../../data/orders_api.dart';
import '../widgets/sticky_action_bar.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _payment = 'card';
  bool _scheduled = false;
  bool _placing = false;
  bool _waitingForPayment = false;
  bool _paymentTimedOut = false;
  String? _pendingOrderId;
  _ScheduleSlot? _slot;
  String? _walletBalance;

  @override
  void initState() {
    super.initState();
    _loadWallet();
    AddressController.instance.load();
  }

  Future<void> _loadWallet() async {
    try {
      final data = await AccountExtrasApi.instance.wallet();
      if (mounted) {
        setState(() {
          _walletBalance = data['balance']?.toString() ??
              data['balanceNaira']?.toString();
        });
      }
    } catch (_) {
      // Leave as null — the UI shows "Balance ₦--" while loading or on error.
    }
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
      final order = await OrdersApi.instance.placeOrder(
        scheduledFor: _scheduledForIso(),
      );
      // The API empties the cart server-side on order creation.
      await ref.read(cartControllerProvider.notifier).load();
      if (!mounted) return;

      final orderId = order['id'] as String? ?? '';
      final checkoutUrl = order['checkoutUrl'] as String? ?? '';

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

      _waitForPayment(orderId);
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
        if (state.isNotEmpty && state != 'awaiting_payment') {
          if (mounted) {
            context.go('${AppRoutes.tracking}?orderId=$orderId');
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

  List<({String id, WBIconName icon, String label, String sub})>
      get _payOptions => [
            (
              id: 'card',
              icon: WBIconName.card,
              label: 'Debit card',
              sub: '•••• 4218'
            ),
            (
              id: 'wallet',
              icon: WBIconName.star,
              label: 'Wallet',
              sub: _walletBalance != null
                  ? 'Balance ₦$_walletBalance'
                  : 'Balance ₦--'
            ),
            (
              id: 'xfer',
              icon: WBIconName.arrowRight,
              label: 'Bank transfer',
              sub: 'Pay directly from app'
            ),
            (
              id: 'mobile',
              icon: WBIconName.phone,
              label: 'Mobile money',
              sub: 'OPay, Palmpay, others'
            ),
          ];

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
    final cart = ref.watch(cartControllerProvider);
    final lines = cart.items;
    final subtotal = lines.fold<int>(0, (s, l) => s + l.total);
    var delivery = 600;
    const serviceFee = 200;
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
                    'Waiting for payment…',
                    style: WBTypography.cardTitle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete payment in the browser. We\'ll move you to order tracking automatically.',
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
                    'Payment not confirmed',
                    style: WBTypography.cardTitle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We didn\'t receive a payment confirmation. Tap below to check again, or go back.',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  WBButton(
                    label: 'Check payment status',
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
                    label: 'Go back',
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
                    Text('Checkout', style: WBTypography.page),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                _Section(
                  label: 'Where are we sending this?',
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
                                    'No address saved — add one',
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
                              'Change',
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
                  label: 'When do you want it?',
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeOption(
                          label: 'Order now',
                          sub: 'Arrives in 25–35 min',
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
                          label: 'Schedule',
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
                  label: 'How will you pay?',
                  child: Column(
                    children: [
                      for (final o in _payOptions) ...[
                        _PaymentTile(
                          id: o.id,
                          icon: o.icon,
                          label: o.label,
                          sub: o.sub,
                          selected: o.id == _payment,
                          onTap: () => setState(() => _payment = o.id),
                        ),
                        if (o.id != _payOptions.last.id) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                _Section(
                  label: 'Your basket',
                  child: Column(
                    children: [
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
                      const _Line(label: 'Delivery', value: '₦600'),
                      const SizedBox(height: 8),
                      const _Line(label: 'Service fee', value: '₦200'),
                      const SizedBox(height: 14),
                      const WBDivider(),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
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
                label: 'Place order',
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
                onPressed: lines.isEmpty ? null : _placeOrder,
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

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.id,
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
  final String id;
  final WBIconName icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? WBColors.bgPrimary : WBColors.bgSoft,
          border: Border.all(
            color: selected ? WBColors.borderFilled : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: WBColors.bgSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? WBColors.surfaceDark : Colors.transparent,
                border: Border.all(
                  color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 10,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : null,
            ),
          ],
        ),
      ),
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
              'Schedule delivery',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a date and time slot',
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
              label: 'Confirm time slot',
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
