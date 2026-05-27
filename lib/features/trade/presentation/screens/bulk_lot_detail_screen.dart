import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/trade_controller.dart';
import '../../domain/models/bulk_lot.dart';
import '../../domain/models/supplier.dart';
import '../../../../core/utils/wb_l10n.dart';

class BulkLotDetailScreen extends StatefulWidget {
  const BulkLotDetailScreen({super.key, required this.lotId});

  final String lotId;

  @override
  State<BulkLotDetailScreen> createState() => _BulkLotDetailScreenState();
}

class _BulkLotDetailScreenState extends State<BulkLotDetailScreen> {
  BulkLot? _lot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final ctrl = TradeController.instance;
    if (ctrl.bulkLots.value.isEmpty) await ctrl.loadBulkLots();
    if (ctrl.suppliers.value.isEmpty) await ctrl.loadSuppliers();
    if (mounted) {
      setState(() {
        _lot = ctrl.bulkLotById(widget.lotId);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lot = _lot;
    if (lot == null) {
      return Scaffold(
        backgroundColor: WBColors.bgSecondary,
        body: SafeArea(
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor:
                          AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  )
                : Text(
                    'Bulk lot not found.',
                    style: WBTypography.body
                        .copyWith(color: WBColors.fgSecondary),
                  ),
          ),
        ),
      );
    }
    final supplier = TradeController.instance.suppliers.value.firstWhere(
      (s) => s.name == lot.supplierName,
      orElse: () => Supplier(
        id: '',
        name: lot.supplierName,
        region: lot.region,
        capacity: '',
        rating: 0,
        reviews: 0,
        avatarUrl: '',
        specialties: const [],
      ),
    );

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 140),
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 11,
                    child: WBNetworkImage(url: lot.imageUrl),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        WBSpacing.screenPadding,
                        8,
                        WBSpacing.screenPadding,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WBBackChip(onPressed: () => context.pop()),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: WBColors.surfaceDark,
                              borderRadius:
                                  BorderRadius.circular(WBRadius.pill),
                            ),
                            child: Text(
                              'BULK',
                              style: WBTypography.label.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.66,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  WBSpacing.lg,
                  WBSpacing.screenPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.produce,
                      style: WBTypography.hero.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lot.lotSize} · ${lot.region}',
                      style: WBTypography.body.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    Row(
                      children: [
                        _StatTile(label: context.l10n.bulkUnitPrice, value: lot.unitPriceLabel),
                        const SizedBox(width: 10),
                        _StatTile(label: context.l10n.bulkLotSize, value: lot.lotSize),
                        const SizedBox(width: 10),
                        _StatTile(label: context.l10n.bulkMoq, value: lot.minOrderLabel),
                      ],
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      'Logistics',
                      style: WBTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    WBCard(
                      child: Column(
                        children: [
                          _LineRow(
                            label: context.l10n.bulkLeadTime,
                            value: '3–5 working days',
                          ),
                          const SizedBox(height: 12),
                          _LineRow(
                            label: context.l10n.bulkOrigin,
                            value: '${lot.region}, Nigeria',
                          ),
                          const SizedBox(height: 12),
                          _LineRow(
                            label: context.l10n.bulkShipping,
                            value: 'Nationwide · Shipbubble',
                          ),
                          const SizedBox(height: 12),
                          _LineRow(
                            label: context.l10n.bulkQuality,
                            value: 'Inspected, batch-coded',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      'Supplier',
                      style: WBTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context.push(
                        '${AppRoutes.tradeSupplier}/${supplier.id}',
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: WBCard(
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: WBNetworkImage(url: supplier.avatarUrl),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.name,
                                    style: WBTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${supplier.region} · ★ ${supplier.rating}',
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const WBIcon(
                              WBIconName.chevronRight,
                              size: 16,
                              color: WBColors.fgPlaceholder,
                            ),
                          ],
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  0,
                  WBSpacing.screenPadding,
                  20,
                ),
                child: WBButton(
                  label: context.l10n.bulkRequestQuote,
                  fullWidth: true,
                  size: WBButtonSize.lg,
                  trailingIcon: WBIconName.arrowRight,
                  onPressed: () => _openQuoteSheet(context, lot),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openQuoteSheet(BuildContext context, BulkLot lot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuoteSheet(lot: lot),
    );
  }
}

class _QuoteSheet extends StatefulWidget {
  const _QuoteSheet({required this.lot});
  final BulkLot lot;

  @override
  State<_QuoteSheet> createState() => _QuoteSheetState();
}

class _QuoteSheetState extends State<_QuoteSheet> {
  late final TextEditingController _qty =
      TextEditingController(text: widget.lot.minOrder.toString());
  final _notes = TextEditingController();
  String _need = 'within-week';

  @override
  void dispose() {
    _qty.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
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
              'Request quote',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              widget.lot.produce,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Quantity (${widget.lot.lotSize})',
              style: WBTypography.label.copyWith(
                color: WBColors.fgSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            WBInput(
              controller: _qty,
              keyboardType: TextInputType.number,
              placeholder: 'e.g. ${widget.lot.minOrder}',
            ),
            const SizedBox(height: 14),
            Text(
              'When do you need it?',
              style: WBTypography.label.copyWith(
                color: WBColors.fgSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _NeedChip(
                  label: context.l10n.bulkThisWeek,
                  active: _need == 'this-week',
                  onTap: () => setState(() => _need = 'this-week'),
                ),
                const SizedBox(width: 8),
                _NeedChip(
                  label: context.l10n.bulkWithin2Wks,
                  active: _need == 'within-week',
                  onTap: () => setState(() => _need = 'within-week'),
                ),
                const SizedBox(width: 8),
                _NeedChip(
                  label: context.l10n.bulkThisMonth,
                  active: _need == 'this-month',
                  onTap: () => setState(() => _need = 'this-month'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Notes (optional)',
              style: WBTypography.label.copyWith(
                color: WBColors.fgSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WBColors.borderFilled, width: 1),
              ),
              child: TextField(
                controller: _notes,
                maxLines: 3,
                style: WBTypography.body.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: context.l10n.bulkDeliveryHint,
                  hintStyle: WBTypography.body.copyWith(
                    color: WBColors.fgPlaceholder,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            WBButton(
              label: context.l10n.bulkSendRequest,
              fullWidth: true,
              size: WBButtonSize.lg,
              onPressed: () {
                Navigator.of(context).pop();
                wbShowSnack(
                  context,
                  'Quote request sent to ${widget.lot.supplierName}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedChip extends StatelessWidget {
  const _NeedChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? WBColors.surfaceDark : WBColors.bgSoft,
            borderRadius: BorderRadius.circular(WBRadius.pill),
          ),
          child: Text(
            label,
            style: WBTypography.caption.copyWith(
              color: active ? Colors.white : WBColors.fgHeader,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: WBShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
