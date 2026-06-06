import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/config/pricing.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/utils/wb_validators.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/address_controller.dart';
import '../../../recipes/application/recipe_cart_controller.dart';
import '../../../recipes/data/recipes_api.dart';
import '../../../recipes/domain/models/recipe_cart_item.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/cart_controller.dart';
import '../../data/orders_api.dart';
import '../../domain/models/product.dart';

enum _PayMethod { card, bankTransfer, mobileMoney }

extension _PayMethodX on _PayMethod {
  String get label => switch (this) {
        _PayMethod.card => 'Card',
        _PayMethod.bankTransfer => 'Bank Transfer',
        _PayMethod.mobileMoney => 'Mobile Money',
      };
  String get sub => switch (this) {
        _PayMethod.card => 'Visa, Mastercard, Verve',
        _PayMethod.bankTransfer => 'Direct bank transfer',
        _PayMethod.mobileMoney => 'MTN, Airtel, M-Pesa',
      };
  WBIconName get icon => switch (this) {
        _PayMethod.card => WBIconName.card,
        _PayMethod.bankTransfer => WBIconName.basket,
        _PayMethod.mobileMoney => WBIconName.phone,
      };
  String get apiValue => switch (this) {
        _PayMethod.card => 'card',
        _PayMethod.bankTransfer => 'bank_transfer',
        _PayMethod.mobileMoney => 'mobile_money',
      };
}

/// Desktop-web layout for checkout. Mirrors [CheckoutScreen]'s data loading,
/// totals math, gift-recipient validation, payment-method selection,
/// scheduling and the Flutterwave place-order / payment-polling flow, re-laid
/// out for a wide window: the delivery / recipient / timing / payment / basket
/// sections on the left and a sticky order-summary card with the primary CTA on
/// the right.
class CheckoutDesktopScreen extends ConsumerStatefulWidget {
  const CheckoutDesktopScreen({super.key});

  @override
  ConsumerState<CheckoutDesktopScreen> createState() =>
      _CheckoutDesktopScreenState();
}

class _CheckoutDesktopScreenState extends ConsumerState<CheckoutDesktopScreen> {
  bool _scheduled = false;
  bool _placing = false;
  bool _waitingForPayment = false;
  bool _paymentTimedOut = false;
  String? _pendingOrderId;
  _ScheduleSlot? _slot;
  _PayMethod _payMethod = _PayMethod.card;

  bool _forSomeoneElse = false;
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    AddressController.instance.load();
    RecipeCartController.instance.load();
  }

  @override
  void dispose() {
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    super.dispose();
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
    // Validate gift-recipient details up front so we never send blank/invalid
    // recipient data to the API for a "sending to someone else" order.
    if (_forSomeoneElse) {
      if (_recipientNameCtrl.text.trim().isEmpty) {
        wbShowSnack(context, 'Enter the recipient\'s name.');
        return;
      }
      if (!WbValidators.isValidPhone(_recipientPhoneCtrl.text)) {
        wbShowSnack(context, 'Enter a valid recipient phone number.');
        return;
      }
    }
    setState(() => _placing = true);
    try {
      final hasRecipes = RecipeCartController.instance.items.value.isNotEmpty;
      final hasProducts = ref.read(cartControllerProvider).items.isNotEmpty;

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
          paymentMethod: _payMethod.apiValue,
          recipientName: _forSomeoneElse ? _recipientNameCtrl.text.trim() : null,
          recipientPhone:
              _forSomeoneElse ? _recipientPhoneCtrl.text.trim() : null,
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
      if (mounted) wbShowError(context, e.message);
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
      builder: (context, recipeItems, _) => _buildBody(context, recipeItems),
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
    final delivery = WbPricing.deliveryFeeNaira;
    final serviceFee = WbPricing.serviceFee(subtotal);
    final total = subtotal + delivery + serviceFee;

    // Show waiting-for-payment screen while polling.
    if (_waitingForPayment) {
      return CustomerWebScaffold(
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxReading,
          padding: const EdgeInsets.all(WBSpacing.screenPadding),
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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

    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.lg),
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          padding:
              const EdgeInsets.symmetric(horizontal: WBSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Text(context.l10n.checkoutTitle, style: WBTypography.page),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT — the checkout sections.
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Section(
                          label: context.l10n.checkoutDeliverySection,
                          child: ValueListenableBuilder<List<Address>>(
                            valueListenable:
                                AddressController.instance.addresses,
                            builder: (_, addresses, _) {
                              final defaultAddr = addresses
                                  .where((a) => a.isDefault)
                                  .firstOrNull;
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
                                    child:
                                        const WBIcon(WBIconName.pin, size: 18),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                defaultAddr.line,
                                                style:
                                                    WBTypography.body.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              if (defaultAddr
                                                  .detail.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  defaultAddr.detail,
                                                  style: WBTypography.caption
                                                      .copyWith(
                                                    color: WBColors.fgSecondary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context
                                        .push(AppRoutes.savedAddresses),
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
                          label: 'RECIPIENT',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _RecipientToggle(
                                    label: 'For me',
                                    active: !_forSomeoneElse,
                                    onTap: () => setState(
                                        () => _forSomeoneElse = false),
                                  ),
                                  const SizedBox(width: 10),
                                  _RecipientToggle(
                                    label: 'For someone else',
                                    active: _forSomeoneElse,
                                    onTap: () => setState(
                                        () => _forSomeoneElse = true),
                                  ),
                                ],
                              ),
                              if (_forSomeoneElse) ...[
                                const SizedBox(height: WBSpacing.md),
                                WBInput(
                                  label: 'Recipient name',
                                  placeholder:
                                      'Who are you sending this to?',
                                  controller: _recipientNameCtrl,
                                ),
                                const SizedBox(height: WBSpacing.sm),
                                WBInput(
                                  label: 'Recipient phone',
                                  placeholder: '+234 800 000 0000',
                                  controller: _recipientPhoneCtrl,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: WBSpacing.sm),
                                Row(
                                  children: [
                                    const WBIcon(WBIconName.pin,
                                        size: 13,
                                        color: WBColors.fgPlaceholder),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Update the delivery address above to their location.',
                                        style: WBTypography.caption.copyWith(
                                          color: WBColors.fgPlaceholder,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
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
                          child: Column(
                            children: [
                              for (final method in _PayMethod.values) ...[
                                _PayMethodRow(
                                  method: method,
                                  selected: _payMethod == method,
                                  onTap: () =>
                                      setState(() => _payMethod = method),
                                ),
                                if (method != _PayMethod.values.last)
                                  const SizedBox(height: 8),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const WBIcon(WBIconName.close, size: 12),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Secured by Flutterwave. Apple Pay & Google Pay available on checkout.',
                                      style: WBTypography.caption.copyWith(
                                        color: WBColors.fgPlaceholder,
                                        fontSize: 11,
                                      ),
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
                                TextSpan(
                                    text:
                                        'By placing this order you agree to our '),
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
                  const SizedBox(width: WBSpacing.lg),
                  // RIGHT — sticky order summary + primary CTA.
                  SizedBox(
                    width: 380,
                    child: _OrderSummary(
                      recipeItems: recipeItems,
                      lines: lines,
                      delivery: delivery,
                      serviceFee: serviceFee,
                      total: total,
                      placing: _placing,
                      onPlaceOrder: (lines.isEmpty && recipeItems.isEmpty)
                          ? null
                          : _placeOrder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Right-hand sticky order summary card: the recipe + product line items, the
/// delivery / service-fee breakdown, the total and the primary place-order CTA.
/// Reuses the exact mobile totals math passed in from the parent.
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.recipeItems,
    required this.lines,
    required this.delivery,
    required this.serviceFee,
    required this.total,
    required this.placing,
    required this.onPlaceOrder,
  });

  final List<RecipeCartItem> recipeItems;
  final List<CartLine> lines;
  final int delivery;
  final int serviceFee;
  final int total;
  final bool placing;
  final VoidCallback? onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return _Section(
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
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: context.l10n.checkoutPlaceOrder,
            fullWidth: true,
            size: WBButtonSize.lg,
            loading: placing,
            trailing: Text(
              '₦${_n(total)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: onPlaceOrder,
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
        Expanded(child: Text(label, style: WBTypography.secondary)),
        const SizedBox(width: 8),
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

class _PayMethodRow extends StatelessWidget {
  const _PayMethodRow({
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final _PayMethod method;
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
          color: selected ? WBColors.surfaceDark : WBColors.bgSoft,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? null
              : Border.all(color: WBColors.bgDivider, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.15)
                    : WBColors.bgPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                method.icon,
                size: 17,
                color: selected ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : WBColors.fgHeader,
                    ),
                  ),
                  Text(
                    method.sub,
                    style: WBTypography.caption.copyWith(
                      fontSize: 12,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.6)
                          : WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const WBIcon(
                  WBIconName.star,
                  size: 9,
                  color: WBColors.surfaceDark,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipientToggle extends StatelessWidget {
  const _RecipientToggle({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? WBColors.surfaceDark : WBColors.bgSecondary,
          borderRadius: BorderRadius.circular(WBRadius.pill),
          border: active ? null : Border.all(color: WBColors.bgDivider),
        ),
        child: Text(
          label,
          style: WBTypography.caption.copyWith(
            color: active ? Colors.white : WBColors.fgSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
