import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../category/domain/models/category_kind.dart';
import '../../../shopping/application/mock_data.dart';
import '../../../shopping/domain/models/product.dart';
import '../../../trade/presentation/widgets/bulk_lot_card.dart';
import '../../../trade/presentation/widgets/supplier_card.dart';
import '../../domain/models/vendor.dart';
import 'ds_vendor_card.dart';

const _hPad = 20.0;

Widget _padH(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: _hPad), child: child);

/// Switches the Home body by active category. Static sections are padded
/// to the 20 px safe area; horizontal carousels are full-bleed and apply
/// their own padding internally.
class CategoryBody extends StatelessWidget {
  const CategoryBody({
    super.key,
    required this.kind,
    required this.categoryId,
    required this.subcategoryId,
  });

  final CategoryKind kind;
  final String? categoryId;
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case CategoryKind.all:
        return const _AllBody();
      case CategoryKind.restaurant:
        return _RestaurantBody(subcategoryId: subcategoryId);
      case CategoryKind.marketplace:
        return _MarketplaceBody(
          categoryId: categoryId!,
          subcategoryId: subcategoryId,
        );
      case CategoryKind.trade:
        return const _TradeBody();
      case CategoryKind.livestock:
        return _LivestockBody(subcategoryId: subcategoryId);
    }
  }
}

class _LivestockBody extends StatelessWidget {
  const _LivestockBody({required this.subcategoryId});
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final cuts = MockData.productsForCategory(
      'livestock',
      subcategoryId: subcategoryId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(Container(
          padding: const EdgeInsets.all(WBSpacing.lg),
          decoration: BoxDecoration(
            color: WBColors.surfaceDark,
            borderRadius: BorderRadius.circular(WBRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHOP FRESH',
                style: WBTypography.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cut exactly\nhow you want.',
                style: WBTypography.page.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Halal certified · Cold chain · Inspected daily',
                style: WBTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Choose your cut',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/livestock'),
        )),
        const SizedBox(height: 14),
        if (cuts.isEmpty)
          _padH(const _EmptyHint(text: 'No cuts match this filter yet.'))
        else
          _padH(GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: cuts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (_, i) => WBProductCard(
              imageUrl: cuts[i].imageUrl,
              name: cuts[i].name,
              vendorName: cuts[i].vendorName,
              priceLabel: cuts[i].formattedPrice,
              unit: cuts[i].unit,
              tag: 'Halal',
              variant: WBProductCardVariant.grid,
              onTap: () =>
                  context.push('${AppRoutes.meatCut}/${cuts[i].id}'),
            ),
          )),
      ],
    );
  }
}

class _AllBody extends StatelessWidget {
  const _AllBody();

  @override
  Widget build(BuildContext context) {
    final products = MockData.menu.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(_SectionHeader(
          title: 'Popular near you',
          onSeeAll: () => context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 14),
        _VendorCarousel(vendors: MockData.vendors),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Trending dishes today',
          onSeeAll: () => context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 14),
        _padH(_ProductGrid(products: products)),
      ],
    );
  }
}

class _RestaurantBody extends StatelessWidget {
  const _RestaurantBody({required this.subcategoryId});
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final dishes = MockData.productsForCategory(
      'restaurants',
      subcategoryId: subcategoryId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(_SectionHeader(
          title: 'Featured restaurants',
          onSeeAll: () => context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 14),
        _VendorCarousel(vendors: MockData.vendors),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Popular dishes',
          onSeeAll: () => context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 12),
        if (dishes.isEmpty)
          _padH(const _EmptyHint(text: 'No dishes match this filter yet.'))
        else
          for (var i = 0; i < dishes.length; i++) ...[
            _padH(WBProductCard(
              imageUrl: dishes[i].imageUrl,
              name: dishes[i].name,
              vendorName: dishes[i].vendorName,
              priceLabel: dishes[i].formattedPrice,
              description: dishes[i].description,
              variant: WBProductCardVariant.row,
              onTap: () => context.push(AppRoutes.product),
              onAdd: () => context.push(AppRoutes.product),
            )),
            if (i != dishes.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MarketplaceBody extends StatelessWidget {
  const _MarketplaceBody({
    required this.categoryId,
    required this.subcategoryId,
  });
  final String categoryId;
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final products = MockData.productsForCategory(
      categoryId,
      subcategoryId: subcategoryId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(_SectionHeader(
          title: 'Top picks',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/$categoryId'),
        )),
        const SizedBox(height: 14),
        if (products.isEmpty)
          _padH(const _EmptyHint(text: 'No products match this filter yet.'))
        else
          _padH(_ProductGrid(products: products)),
      ],
    );
  }
}

class _TradeBody extends StatelessWidget {
  const _TradeBody();

  @override
  Widget build(BuildContext context) {
    final lots = MockData.bulkLots;
    final suppliers = MockData.suppliers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(Container(
          padding: const EdgeInsets.all(WBSpacing.lg),
          decoration: BoxDecoration(
            color: WBColors.surfaceDark,
            borderRadius: BorderRadius.circular(WBRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BULK · WHOLESALE',
                style: WBTypography.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Connect to suppliers\n& request quotes',
                style: WBTypography.page.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Source directly from verified farms across Nigeria.',
                style: WBTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.push(AppRoutes.trade),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View suppliers',
                        style: WBTypography.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const WBIcon(
                        WBIconName.arrowRight,
                        size: 14,
                        strokeWidth: 1.6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Top bulk lots',
          onSeeAll: () => context.push(AppRoutes.trade),
        )),
        const SizedBox(height: 14),
        // Full-bleed bulk-lot carousel — height reserves vertical room for
        // the card content plus its soft shadow bleed so nothing clips.
        SizedBox(
          height: 360,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_hPad, 6, _hPad, 18),
            itemCount: lots.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => SizedBox(
              width: 220,
              child: BulkLotCard(
                lot: lots[i],
                onTap: () =>
                    context.push('${AppRoutes.tradeLot}/${lots[i].id}'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Featured suppliers',
          onSeeAll: () => context.push(AppRoutes.trade),
        )),
        const SizedBox(height: 14),
        for (var i = 0; i < 3 && i < suppliers.length; i++) ...[
          _padH(SupplierCard(
            supplier: suppliers[i],
            onTap: () => context.push(
              '${AppRoutes.tradeSupplier}/${suppliers[i].id}',
            ),
          )),
          if (i < 2 && i + 1 < suppliers.length) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: WBTypography.cardTitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.18,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                'See all',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const WBIcon(
                WBIconName.arrowRight,
                size: 13,
                color: WBColors.fgSecondary,
                strokeWidth: 1.6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VendorCarousel extends StatelessWidget {
  const _VendorCarousel({required this.vendors});
  final List<Vendor> vendors;

  @override
  Widget build(BuildContext context) {
    // Carousel reserves vertical space for the card content + the soft
    // shadow that bleeds below it (so cards never look clipped at the
    // bottom).
    return SizedBox(
      height: 372,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(_hPad, 6, _hPad, 18),
        itemCount: vendors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => DSVendorCard(
          vendor: vendors[i],
          onTap: () => context.push(AppRoutes.vendor),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (_, i) => WBProductCard(
        imageUrl: products[i].imageUrl,
        name: products[i].name,
        vendorName: products[i].vendorName,
        priceLabel: products[i].formattedPrice,
        unit: products[i].unit,
        variant: WBProductCardVariant.grid,
        onTap: () => context.push(AppRoutes.product),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(WBSpacing.md + 4),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Text(
        text,
        style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
      ),
    );
  }
}
