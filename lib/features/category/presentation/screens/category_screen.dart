import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../home/presentation/widgets/ds_vendor_card.dart';
import '../../../shopping/application/mock_data.dart';
import '../../../shopping/domain/models/product.dart';
import '../../domain/models/category_kind.dart';
import '../widgets/subcategory_chip_row.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _activeSubcategory;

  @override
  Widget build(BuildContext context) {
    final category = MockData.categoryById(widget.categoryId);
    final products = MockData.productsForCategory(
      widget.categoryId,
      subcategoryId: _activeSubcategory,
    );
    final vendors = MockData.vendorsForCategory(widget.categoryId);

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  12,
                  WBSpacing.screenPadding,
                  WBSpacing.md,
                ),
                child: Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.label, style: WBTypography.page),
                          Text(
                            category.tagline,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.search),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: WBColors.bgPrimary,
                          shape: BoxShape.circle,
                          boxShadow: WBShadows.card,
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(WBIconName.search, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: WBSpacing.screenPadding,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  child: AspectRatio(
                    aspectRatio: 2.2,
                    child: WBNetworkImage(url: category.imageUrl),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: WBSpacing.md)),
            SliverToBoxAdapter(
              child: SubcategoryChipRow(
                subcategories: category.subcategories,
                activeId: _activeSubcategory,
                onTap: (id) => setState(() => _activeSubcategory = id),
                visible: true,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: WBSpacing.lg)),
            if (category.kind == CategoryKind.restaurant)
              _vendorList(context, vendors)
            else
              _productGrid(context, products),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _vendorList(BuildContext context, List<Vendor> vendors) {
    if (vendors.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: _emptyHint('No vendors match this filter yet.'),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: WBSpacing.screenPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: WBSpacing.md),
            child: DSVendorCard(
              vendor: vendors[i],
              onTap: () =>
                  context.push('${AppRoutes.vendor}/${vendors[i].id}'),
            ),
          ),
          childCount: vendors.length,
        ),
      ),
    );
  }

  Widget _productGrid(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: _emptyHint('No products match this filter yet.'),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: WBSpacing.screenPadding,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.64,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final p = products[i];
            final isLivestock = p.categoryId == 'livestock';
            return WBProductCard(
              imageUrl: p.imageUrl,
              name: p.name,
              vendorName: p.vendorName,
              priceLabel: p.formattedPrice,
              unit: p.unit,
              tag: isLivestock ? 'Halal' : null,
              variant: WBProductCardVariant.grid,
              onTap: () => isLivestock
                  ? context.push('${AppRoutes.meatCut}/${p.id}')
                  : context.push('${AppRoutes.product}/${p.id}'),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _emptyHint(String text) {
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
