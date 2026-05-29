import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../home/presentation/widgets/ds_vendor_card.dart';
import '../../../shopping/application/mock_data.dart';
import '../../../shopping/data/catalog_api.dart';
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
  bool _premium = false;

  // Category presentation (label, image, subcategory chips) is static app
  // content; the products + vendors below it load live from the catalog.
  List<Product> _products = const [];
  List<Vendor> _vendors = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? subcategoryId}) async {
    setState(() {
      _loading = true;
      _error = null;
      _products = const [];
      _vendors = const [];
    });
    try {
      final category = MockData.categoryById(widget.categoryId);
      final effectiveCategory = subcategoryId ?? widget.categoryId;
      final isRestaurant = category?.kind == CategoryKind.restaurant;

      if (isRestaurant) {
        final vendors = await CatalogApi.instance.vendors(
          category: subcategoryId,
        );
        if (!mounted) return;
        setState(() {
          _vendors = vendors;
          _loading = false;
        });
      } else {
        final products = await CatalogApi.instance.items(
          category: effectiveCategory,
        );
        if (!mounted) return;
        setState(() {
          _products = products;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = MockData.categoryById(widget.categoryId)!;
    final products = _products;
    final vendors = _vendors;

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
              child: SubcategoryChipRow(
                subcategories: category.subcategories,
                activeId: _activeSubcategory,
                onTap: (id) {
                  setState(() => _activeSubcategory = id);
                  _load(subcategoryId: id);
                },
                visible: true,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: WBSpacing.lg)),
            SliverToBoxAdapter(
              child: _ContextBand(
                categoryId: widget.categoryId,
                premium: _premium,
                onQualityChanged: (v) => setState(() => _premium = v),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation(WBColors.surfaceDark),
                      ),
                    ),
                  ),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WBSpacing.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _emptyHint(_error!),
                      const SizedBox(height: 10),
                      WBButton(
                        label: context.l10n.actionRetry,
                        size: WBButtonSize.sm,
                        variant: WBButtonVariant.secondary,
                        onPressed: _load,
                      ),
                    ],
                  ),
                ),
              )
            else if (category.kind == CategoryKind.restaurant)
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
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: WBEmptyState(
            illustration: WBEmptyIllustration.noProducts,
            label: 'No vendors match this filter yet.',
          ),
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
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: WBEmptyState(
            illustration: WBEmptyIllustration.noProducts,
            label: 'No products match this filter yet.',
          ),
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

/// Category-specific band shown above the product grid. Produce gets a
/// quality toggle + recipe bundle + farmer spotlight; livestock gets the
/// live-butchery WhatsApp banner; essentials gets a smart-reorder nudge.
class _ContextBand extends StatelessWidget {
  const _ContextBand({
    required this.categoryId,
    required this.premium,
    required this.onQualityChanged,
  });
  final String categoryId;
  final bool premium;
  final ValueChanged<bool> onQualityChanged;

  bool get _isProduce =>
      categoryId == 'fresh-market' || categoryId == 'farm-produce';
  bool get _isLivestock => categoryId == 'livestock';
  bool get _isEssentials =>
      categoryId == 'kitchen-essentials' || categoryId == 'groceries';

  @override
  Widget build(BuildContext context) {
    if (_isProduce) return _produce(context);
    if (_isLivestock) return _livestock(context);
    if (_isEssentials) return _essentials(context);
    return const SizedBox.shrink();
  }

  Widget _wrap(Widget child) => Padding(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          0,
          WBSpacing.screenPadding,
          WBSpacing.lg,
        ),
        child: child,
      );

  Widget _produce(BuildContext context) {
    return _wrap(Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: WBColors.bgSecondary,
            borderRadius: BorderRadius.circular(WBRadius.pill),
          ),
          child: Row(
            children: [
              _QualityTab(
                label: context.l10n.catStandardLabel,
                sub: context.l10n.catStandardSub,
                active: !premium,
                onTap: () => onQualityChanged(false),
              ),
              _QualityTab(
                label: context.l10n.catPremiumLabel,
                sub: context.l10n.catPremiumSub,
                active: premium,
                onTap: () => onQualityChanged(true),
              ),
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                icon: WBIconName.basket,
                title: context.l10n.catJollofBundleTitle,
                sub: context.l10n.catJollofBundleSub,
                onTap: () => wbShowSnack(context, context.l10n.catBundleAdded),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniCard(
                icon: WBIconName.user,
                title: context.l10n.catFarmerTitle,
                sub: context.l10n.catFarmerSub,
                onTap: () =>
                    wbShowSnack(context, context.l10n.catFarmerSoon),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _livestock(BuildContext context) {
    return _wrap(GestureDetector(
      onTap: () => wbShowSnack(context, 'Connecting you to Butcher John…'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(WBSpacing.md),
        decoration: BoxDecoration(
          color: WBColors.surfaceDark,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const WBIcon(
                WBIconName.phone,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Watch your meat being cut',
                    style: WBTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Butcher John · 4.9★ · 5 min wait · WhatsApp call',
                    style: WBTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const WBIcon(
              WBIconName.arrowRight,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _essentials(BuildContext context) {
    return _wrap(Container(
      padding: const EdgeInsets.all(WBSpacing.md),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        children: [
          const WBIcon(WBIconName.clock, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You bought some of these 2 months ago. Need a refill?',
              style: WBTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          WBButton(
            label: context.l10n.catReorderLabel,
            size: WBButtonSize.sm,
            onPressed: () => wbShowSnack(context, context.l10n.catLastBasketReordered),
          ),
        ],
      ),
    ));
  }
}

class _QualityTab extends StatelessWidget {
  const _QualityTab({
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? WBColors.surfaceDark : Colors.transparent,
            borderRadius: BorderRadius.circular(WBRadius.pill),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : WBColors.fgHeader,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: WBTypography.caption.copyWith(
                  fontSize: 11,
                  color: active
                      ? Colors.white.withValues(alpha: 0.6)
                      : WBColors.fgPlaceholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });
  final WBIconName icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WBIcon(icon, size: 18),
            const SizedBox(height: 10),
            Text(
              title,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

