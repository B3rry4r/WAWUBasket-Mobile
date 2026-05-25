import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/export_listing.dart';
import '../../application/escrow_controller.dart';
import '../../domain/models/bulk_order.dart';
import '../widgets/flutterwave_payment_sheet.dart';

/// Buyer checkout for one [ExportListing]. Picks a quantity, drop-off
/// address, then hands off to [FlutterwavePaymentSheet]. On success,
/// stages the order in [EscrowController] and routes to the status
/// screen.
class BulkCheckoutScreen extends StatefulWidget {
  const BulkCheckoutScreen({super.key, required this.listingId});
  final String listingId;

  @override
  State<BulkCheckoutScreen> createState() => _BulkCheckoutScreenState();
}

class _BulkCheckoutScreenState extends State<BulkCheckoutScreen> {
  late int _quantityKg;
  final _address = TextEditingController(
    text: 'Tin Can Port · Warehouse 7, Apapa',
  );

  /// WAWU service fee on a bulk trade. Set as a flat 2% of subtotal so
  /// the math is visible to the buyer.
  static const _feeBps = 0.02;

  @override
  void initState() {
    super.initState();
    final l = TradeController.instance.byId(widget.listingId);
    _quantityKg = l?.quantityKg ?? 100;
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  int _subtotal(ExportListing l) => _quantityKg * l.pricePerKgNaira;
  int _fee(ExportListing l) => (_subtotal(l) * _feeBps).round();
  int _total(ExportListing l) => _subtotal(l) + _fee(l);

  Future<void> _checkout(ExportListing l) async {
    if (_quantityKg <= 0 || _quantityKg > l.quantityKg) {
      wbShowSnack(context, 'Quantity must be between 1 and ${l.quantityKg} kg.');
      return;
    }
    if (_address.text.trim().isEmpty) {
      wbShowSnack(context, 'Add a drop-off address.');
      return;
    }
    final method = await FlutterwavePaymentSheet.show(
      context,
      amountNaira: _total(l),
      purpose: '$_quantityKg kg ${l.produce}',
      recipientName: l.farmName,
    );
    if (!mounted || method == null) return;

    final orderId = EscrowController.instance.place(
      BulkOrder(
        id: 'ESC-${DateTime.now().millisecondsSinceEpoch}',
        listingId: l.id,
        produce: l.produce,
        quantityKg: _quantityKg,
        pricePerKgNaira: l.pricePerKgNaira,
        feeNaira: _fee(l),
        imageUrl: l.imageUrl,
        buyerName: ProfileController.instance.profile.value?.fullName ?? '',
        buyerPhone: ProfileController.instance.profile.value?.phone ?? '',
        dropoffAddress: _address.text.trim(),
        sellerName: l.farmName,
        sellerRegion: l.farmRegion,
        method: method,
        status: EscrowStatus.held,
        placedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    context.pushReplacement('${AppRoutes.escrowStatus}/$orderId');
  }

  @override
  Widget build(BuildContext context) {
    final l = TradeController.instance.byId(widget.listingId);
    if (l == null) {
      return Scaffold(
        backgroundColor: WBColors.bgSecondary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(WBSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(height: WBSpacing.xl),
                Text("Listing not found", style: WBTypography.page),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                160,
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
                          Text('Checkout', style: WBTypography.page),
                          Text(
                            'Funds stay in escrow until you confirm delivery.',
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
                _LotCard(listing: l),
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Quantity'),
                const SizedBox(height: 10),
                _QuantityStepper(
                  current: _quantityKg,
                  max: l.quantityKg,
                  onChanged: (v) => setState(() => _quantityKg = v),
                ),
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Drop-off'),
                const SizedBox(height: 10),
                WBInput(
                  controller: _address,
                  label: 'Address or warehouse',
                  placeholder: 'Where should the lot land?',
                  leadingIcon: WBIconName.pin,
                ),
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Summary'),
                const SizedBox(height: 10),
                WBCard(
                  child: Column(
                    children: [
                      _SummaryRow(
                        label:
                            '$_quantityKg kg × ${wbNaira(l.pricePerKgNaira)}',
                        value: wbNaira(_subtotal(l)),
                      ),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: 'WAWU fee · 2%',
                        value: wbNaira(_fee(l)),
                      ),
                      const SizedBox(height: 10),
                      const WBDivider(),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'You pay now',
                        value: wbNaira(_total(l)),
                        emphasised: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x1410B981),
                    borderRadius: BorderRadius.circular(WBRadius.card),
                    border: Border.all(color: const Color(0x3310B981)),
                  ),
                  child: Row(
                    children: [
                      const WBIcon(WBIconName.check, size: 14),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "We hold your funds until you confirm delivery. Dispute anytime if something's off.",
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding,
                    12,
                    WBSpacing.screenPadding,
                    18,
                  ),
                  decoration: BoxDecoration(
                    color: WBColors.bgPrimary,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 18,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: WBButton(
                    label: 'Pay ${wbNaira(_total(l))} & hold in escrow',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    trailingIcon: WBIconName.arrowRight,
                    onPressed: () => _checkout(l),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  const _LotCard({required this.listing});
  final ExportListing listing;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: WBNetworkImage(url: listing.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.produce,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${listing.farmName} · ${listing.farmRegion}',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${wbNaira(listing.pricePerKgNaira)}/kg · max ${listing.quantityKg} kg',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: WBTypography.cardTitle.copyWith(fontSize: 16),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.current,
    required this.max,
    required this.onChanged,
  });
  final int current;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$current kg',
                  style: WBTypography.hero.copyWith(fontSize: 26),
                ),
                Text(
                  'Available · ${wbThousands(max)} kg',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: WBIconName.minus,
            enabled: current > 1,
            onTap: () => onChanged((current - 100).clamp(1, max)),
          ),
          const SizedBox(width: 8),
          _StepButton(
            icon: WBIconName.plus,
            enabled: current < max,
            onTap: () => onChanged((current + 100).clamp(1, max)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final WBIconName icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? WBColors.surfaceDark : WBColors.bgSoft,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: WBIcon(
          icon,
          size: 14,
          color: enabled ? Colors.white : WBColors.fgPlaceholder,
          strokeWidth: 2.4,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });
  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: WBTypography.body.copyWith(
            fontSize: emphasised ? 15 : 14,
            color: emphasised ? WBColors.fgHeader : WBColors.fgSecondary,
            fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontSize: emphasised ? 17 : 14,
            fontWeight: emphasised ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
