import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/application/mock_data.dart';
import '../widgets/bulk_lot_card.dart';
import '../widgets/supplier_card.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  String _tab = 'suppliers';
  String _produceFilter = 'all';

  static const _produce = [
    ('all', 'All'),
    ('rice', 'Rice'),
    ('cassava', 'Cassava'),
    ('palm-oil', 'Palm oil'),
    ('cocoa', 'Cocoa'),
    ('maize', 'Maize'),
    ('feed', 'Feed'),
    ('fertilizer', 'Fertilizer'),
    ('veg', 'Bulk veg'),
  ];

  @override
  Widget build(BuildContext context) {
    final suppliers = MockData.suppliers;
    final lots = MockData.bulkLots;
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
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.screenPadding,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: WBShadows.card,
                ),
                child: Row(
                  children: [
                    _SegmentTab(
                      label: 'Suppliers',
                      active: _tab == 'suppliers',
                      onTap: () => setState(() => _tab = 'suppliers'),
                    ),
                    _SegmentTab(
                      label: 'Bulk lots',
                      active: _tab == 'lots',
                      onTap: () => setState(() => _tab = 'lots'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.md),
            // Produce filter
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
            Expanded(
              child: _tab == 'suppliers'
                  ? ListView.separated(
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
                    )
                  : GridView.builder(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? WBColors.surfaceDark : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: WBTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : WBColors.fgSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
