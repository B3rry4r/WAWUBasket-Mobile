import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/trade_controller.dart';
import '../widgets/bulk_lot_card.dart';
import '../widgets/corridor_prices_table.dart';
import '../widgets/export_listing_card.dart';
import '../widgets/supplier_card.dart';

/// Desktop-web layout for the customer bulk-trade browse. Re-lays the four
/// mobile tabs (Suppliers, Lots, Listings, Corridor prices) into a wide,
/// capped content column with multi-column card grids. Mirrors the mobile
/// [TradeScreen] data loading, state, empty handling, and navigation exactly;
/// only the arrangement differs. Renders only at desktop width — the mobile
/// build never imports this.
class TradeDesktopScreen extends StatefulWidget {
  const TradeDesktopScreen({super.key});

  @override
  State<TradeDesktopScreen> createState() => _TradeDesktopScreenState();
}

enum _Tab { suppliers, lots, listings, prices }

class _TradeDesktopScreenState extends State<TradeDesktopScreen> {
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
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.lg,
          vertical: WBSpacing.xl,
        ),
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: WBBackChip(onPressed: () => context.pop()),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text('Farm Produce', style: WBTypography.hero),
              const SizedBox(height: 4),
              Text(
                'Bulk · Wholesale · Direct from farm',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _TabBar(
                      current: _tab,
                      onChanged: (t) => setState(() => _tab = t),
                    ),
                  ),
                ],
              ),
              if (_showProduceFilter) ...[
                const SizedBox(height: WBSpacing.lg),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _produce)
                      WBTag(
                        label: p.$2,
                        active: p.$1 == _produceFilter,
                        onTap: () => setState(() => _produceFilter = p.$1),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: WBSpacing.xl),
              _tabBody(),
            ],
          ),
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
            return _CardGrid(
              minTileWidth: 380,
              childAspectRatio: 2.4,
              count: suppliers.length,
              builder: (i) => SupplierCard(
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
            return _CardGrid(
              minTileWidth: 280,
              childAspectRatio: 0.62,
              count: lots.length,
              builder: (i) => BulkLotCard(
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
              return const WBEmptyState(
                illustration: WBEmptyIllustration.noActiveListing,
                label: 'No active export listings right now.',
                sub: 'Check back in a bit.',
              );
            }
            return _CardGrid(
              minTileWidth: 460,
              childAspectRatio: 3.0,
              count: listings.length,
              builder: (i) => ExportListingCard(
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
          builder: (_, rows, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

/// Responsive multi-column card grid: fits as many columns as the content
/// width allows given [minTileWidth], then lays the cards out with the mobile
/// card widgets unchanged.
class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.count,
    required this.builder,
    required this.minTileWidth,
    required this.childAspectRatio,
  });

  final int count;
  final Widget Function(int index) builder;
  final double minTileWidth;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minTileWidth).floor().clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (_, i) => builder(i),
        );
      },
    );
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
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
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
    return Container(
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
    );
  }
}
