import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/export_listing.dart';
import '../../application/escrow_controller.dart';

/// Desktop-web layout for the buyer bulk checkout. Two columns: the order
/// form (lot, quantity, drop-off) on the LEFT and a sticky escrow summary
/// card (amounts, fee, terms, primary CTA) on the RIGHT. Mirrors the mobile
/// [BulkCheckoutScreen] data loading, escrow placement and navigation exactly;
/// only the layout is re-flowed for a wide window. Desktop-only — the mobile
/// build never imports this.
class BulkCheckoutDesktopScreen extends StatefulWidget {
  const BulkCheckoutDesktopScreen({super.key, required this.listingId});
  final String listingId;

  @override
  State<BulkCheckoutDesktopScreen> createState() =>
      _BulkCheckoutDesktopScreenState();
}

class _BulkCheckoutDesktopScreenState extends State<BulkCheckoutDesktopScreen> {
  late int _quantityKg;
  bool _busy = false;
  final _address = TextEditingController();

  /// WAWU service fee on a bulk trade. Set as a flat 2% of subtotal so
  /// the math is visible to the buyer.
  static const _feeBps = 0.02;

  @override
  void initState() {
    super.initState();
    final l = TradeController.instance.byId(widget.listingId);
    _quantityKg = l?.quantityKg ?? 100;
    // Load public listings if none are cached yet (e.g. direct deep-link nav).
    if (l == null) {
      TradeController.instance.loadPublicListings();
    }
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _setQuantity(int v) => setState(() => _quantityKg = v);

  int _subtotal(ExportListing l) => _quantityKg * l.pricePerKgNaira;
  int _fee(ExportListing l) => (_subtotal(l) * _feeBps).round();
  int _total(ExportListing l) => _subtotal(l) + _fee(l);

  Future<void> _checkout(ExportListing l) async {
    if (_quantityKg <= 0 || _quantityKg > l.quantityKg) {
      wbShowSnack(context, 'Quantity must be between 1 and ${l.quantityKg} kg.');
      return;
    }
    if (_address.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.escrowAddDropOff);
      return;
    }
    setState(() => _busy = true);
    try {
      final order = await EscrowController.instance.place(
        listingId: l.id,
        quantityKg: _quantityKg,
        dropoffAddress: _address.text.trim(),
      );

      if (order.checkoutUrl != null) {
        final uri = Uri.parse(order.checkoutUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      if (!mounted) return;
      context.pushReplacement('${AppRoutes.escrowStatus}/${order.id}');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: TradeController.instance.listings,
      builder: (_, _, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l = TradeController.instance.byId(widget.listingId);
    if (l == null) {
      return CustomerWebScaffold(
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            WBSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WBBackChip(onPressed: () => context.pop()),
              const SizedBox(height: WBSpacing.xl),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    return CustomerWebScaffold(
      child: SingleChildScrollView(
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            WBSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WBBackChip(onPressed: () => context.pop()),
              const SizedBox(height: WBSpacing.lg),
              Text(context.l10n.checkoutTitle, style: WBTypography.page),
              const SizedBox(height: 4),
              Text(
                'Funds stay in escrow until you confirm delivery.',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _OrderForm(this, l)),
                  const SizedBox(width: WBSpacing.xl),
                  Expanded(flex: 5, child: _SummaryPanel(this, l)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// LEFT column: the editable order form — lot card, quantity stepper and
/// drop-off address.
class _OrderForm extends StatelessWidget {
  const _OrderForm(this.state, this.listing);
  final _BulkCheckoutDesktopScreenState state;
  final ExportListing listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LotCard(listing: listing),
        const SizedBox(height: WBSpacing.lg),
        const _SectionLabel('Quantity'),
        const SizedBox(height: 10),
        _QuantityStepper(
          current: state._quantityKg,
          max: listing.quantityKg,
          onChanged: state._setQuantity,
        ),
        const SizedBox(height: WBSpacing.lg),
        const _SectionLabel('Drop-off'),
        const SizedBox(height: 10),
        WBInput(
          controller: state._address,
          label: 'Address or warehouse',
          placeholder: context.l10n.escrowDropOffPlaceholder,
          leadingIcon: WBIconName.pin,
        ),
      ],
    );
  }
}

/// RIGHT column: sticky escrow summary with amounts, fee, the escrow note and
/// the primary pay-and-hold CTA.
class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel(this.state, this.listing);
  final _BulkCheckoutDesktopScreenState state;
  final ExportListing listing;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Summary'),
          const SizedBox(height: 10),
          WBCard(
            child: Column(
              children: [
                _SummaryRow(
                  label:
                      '${state._quantityKg} kg × ${wbNaira(l.pricePerKgNaira)}',
                  value: wbNaira(state._subtotal(l)),
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: 'WAWU fee · 2%',
                  value: wbNaira(state._fee(l)),
                ),
                const SizedBox(height: 10),
                const WBDivider(),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'You pay now',
                  value: wbNaira(state._total(l)),
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
                    context.l10n.bulkCheckoutEscrowNote,
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
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Pay ${wbNaira(state._total(l))} & hold in escrow',
            fullWidth: true,
            size: WBButtonSize.lg,
            trailingIcon: WBIconName.arrowRight,
            loading: state._busy,
            onPressed: state._busy ? null : () => state._checkout(l),
          ),
        ],
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
