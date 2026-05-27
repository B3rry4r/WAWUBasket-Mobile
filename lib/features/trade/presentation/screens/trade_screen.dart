import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/trade_controller.dart';
import '../widgets/bulk_lot_card.dart';
import '../widgets/corridor_prices_table.dart';
import '../widgets/export_listing_card.dart';
import '../widgets/supplier_card.dart';
import '../../../../core/utils/wb_l10n.dart';

/// Customer-side bulk-trade browse. Four tabs: Suppliers, Bulk lots,
/// Export listings, Corridor prices. The tab pills sit in a segmented
/// control so the active tab feels distinct; the produce filter row
/// shows only on tabs where it's meaningful.
class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

enum _Tab { suppliers, lots, listings, prices }

class _TradeScreenState extends State<TradeScreen> {
  _Tab _tab = _Tab.suppliers;
  String _produceFilter = 'all';

  static const _produce = [
    ('all', 'All'),
    ('rice', 'Rice'),
    ('cassava', 'Cassava'),
    ('palm-oil', 'Palm oil'),
    ('cocoa', 'Cocoa'),
    ('maize', 'Maize'),
    ('tomato', 'Tomato'),
    ('onions', 'Onions'),
  ];

  bool get _showProduceFilter => _tab == _Tab.suppliers || _tab == _Tab.lots;

  @override
  void initState() {
    super.initState();
    TradeController.instance.loadPublicListings();
    TradeController.instance.loadPrices();
    TradeController.instance.loadSuppliers();
    TradeController.instance.loadBulkLots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                0,
              ),
              child: Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farm Produce', style: WBTypography.page),
                        Text(
                          'Bulk · Wholesale · Direct from farm',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.screenPadding,
              ),
              child: _TabBar(
                current: _tab,
                onChanged: (t) => setState(() => _tab = t),
              ),
            ),
            const SizedBox(height: WBSpacing.md),
            if (_showProduceFilter) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: WBSpacing.screenPadding,
                  ),
                  itemCount: _produce.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final p = _produce[i];
                    return WBTag(
                      label: p.$2,
                      active: p.$1 == _produceFilter,
                      onTap: () => setState(() => _produceFilter = p.$1),
                    );
                  },
                ),
              ),
              const SizedBox(height: WBSpacing.md),
            ],
            Expanded(child: _tabBody()),
          ],
        ),
      ),
    );
  }

  Widget _tabBody() {
    switch (_tab) {
      case _Tab.suppliers:
        return ValueListenableBuilder(
          valueListenable: TradeController.instance.suppliers,
          builder: (_, suppliers, _) {
            if (suppliers.isEmpty) {
              return _Empty(label: context.l10n.tradeSuppliersEmpty);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                4,
                WBSpacing.screenPadding,
                40,
              ),
              itemCount: suppliers.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: WBSpacing.md),
              itemBuilder: (_, i) => SupplierCard(
                supplier: suppliers[i],
                onTap: () => context.push(
                  '${AppRoutes.tradeSupplier}/${suppliers[i].id}',
                ),
              ),
            );
          },
        );
      case _Tab.lots:
        return ValueListenableBuilder(
          valueListenable: TradeController.instance.bulkLots,
          builder: (_, lots, _) {
            if (lots.isEmpty) {
              return _Empty(label: context.l10n.tradeBulkEmpty);
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                4,
                WBSpacing.screenPadding,
                40,
              ),
              itemCount: lots.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (_, i) => BulkLotCard(
                lot: lots[i],
                onTap: () => context.push(
                  '${AppRoutes.tradeLot}/${lots[i].id}',
                ),
              ),
            );
          },
        );
      case _Tab.listings:
        return ValueListenableBuilder(
          valueListenable: TradeController.instance.listings,
          builder: (_, listings, _) {
            if (listings.isEmpty) {
              return _Empty(
                label:
                    'No active export listings right now. Check back in a bit.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                4,
                WBSpacing.screenPadding,
                40,
              ),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => ExportListingCard(
                listing: listings[i],
                onTap: () => context.push(
                  '${AppRoutes.tradeListing}/${listings[i].id}',
                ),
              ),
            );
          },
        );
      case _Tab.prices:
        return ValueListenableBuilder(
          valueListenable: TradeController.instance.prices,
          builder: (_, rows, _) => ListView(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              4,
              WBSpacing.screenPadding,
              40,
            ),
            children: [
              CorridorPricesTable(rows: rows),
              const SizedBox(height: 12),
              Text(
                'Prices in ₦ per unit. Updated daily from corridor trades.',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.onChanged});
  final _Tab current;
  final ValueChanged<_Tab> onChanged;

  static const _spec = [
    (_Tab.suppliers, 'Suppliers'),
    (_Tab.lots, 'Lots'),
    (_Tab.listings, 'Listings'),
    (_Tab.prices, 'Prices'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.pill),
        boxShadow: WBShadows.card,
      ),
      child: Row(
        children: [
          for (final s in _spec)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(s.$1),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: WBMotion.base,
                  curve: WBMotion.easeSoft,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.$1 == current
                        ? WBColors.surfaceDark
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Text(
                    s.$2,
                    style: WBTypography.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: s.$1 == current
                          ? Colors.white
                          : WBColors.fgSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        4,
        WBSpacing.screenPadding,
        40,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Text(
          label,
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
