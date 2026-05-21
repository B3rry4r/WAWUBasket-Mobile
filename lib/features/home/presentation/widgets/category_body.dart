import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../category/domain/models/category_kind.dart';
// MockData still backs the trade body (bulk lots + suppliers); wired in 7b.
import '../../../shopping/application/mock_data.dart';
import '../../../shopping/data/catalog_api.dart';
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

class _LivestockBody extends StatefulWidget {
  const _LivestockBody({required this.subcategoryId});
  final String? subcategoryId;

  @override
  State<_LivestockBody> createState() => _LivestockBodyState();
}

class _LivestockBodyState extends State<_LivestockBody> {
  List<Product>? _cuts;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LivestockBody old) {
    super.didUpdateWidget(old);
    if (old.subcategoryId != widget.subcategoryId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _cuts = null;
    });
    try {
      final cuts = await CatalogApi.instance
          .items(category: widget.subcategoryId ?? 'livestock');
      if (mounted) setState(() => _cuts = cuts);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuts = _cuts;
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
        if (_error != null)
          _padH(_RetryHint(text: _error!, onRetry: _load))
        else if (cuts == null)
          const _LoadingHint()
        else if (cuts.isEmpty)
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

/// Home default view — vendors + trending dishes pulled live from the
/// catalog API. Falls back to a retry card if the request fails.
class _AllBody extends StatefulWidget {
  const _AllBody();

  @override
  State<_AllBody> createState() => _AllBodyState();
}

class _AllBodyState extends State<_AllBody> {
  List<Vendor>? _vendors;
  List<Product>? _products;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final vendors = await CatalogApi.instance.vendors();
      final products = await CatalogApi.instance.items();
      if (!mounted) return;
      setState(() {
        _vendors = vendors;
        _products = products;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _padH(_RetryHint(text: _error!, onRetry: _load));
    }
    if (_vendors == null || _products == null) {
      return const _LoadingHint();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(_SectionHeader(
          title: 'Popular near you',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 14),
        if (_vendors!.isEmpty)
          _padH(const _EmptyHint(text: 'No vendors open near you yet.'))
        else
          _VendorCarousel(vendors: _vendors!),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Trending dishes today',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 14),
        if (_products!.isEmpty)
          _padH(const _EmptyHint(text: 'No dishes listed yet.'))
        else
          _padH(_ProductGrid(products: _products!.take(4).toList())),
      ],
    );
  }
}

class _RestaurantBody extends StatefulWidget {
  const _RestaurantBody({required this.subcategoryId});
  final String? subcategoryId;

  @override
  State<_RestaurantBody> createState() => _RestaurantBodyState();
}

class _RestaurantBodyState extends State<_RestaurantBody> {
  List<Vendor>? _vendors;
  List<Product>? _dishes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _RestaurantBody old) {
    super.didUpdateWidget(old);
    if (old.subcategoryId != widget.subcategoryId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _dishes = null;
    });
    try {
      final vendors = await CatalogApi.instance.vendors();
      final dishes =
          await CatalogApi.instance.items(category: widget.subcategoryId);
      if (!mounted) return;
      setState(() {
        _vendors = vendors;
        _dishes = dishes;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dishes = _dishes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(_SectionHeader(
          title: 'Featured restaurants',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 14),
        if (_vendors == null && _error == null)
          const _LoadingHint()
        else if ((_vendors ?? const []).isEmpty)
          _padH(const _EmptyHint(text: 'No restaurants open near you yet.'))
        else
          _VendorCarousel(vendors: _vendors!),
        const SizedBox(height: 28),
        _padH(_SectionHeader(
          title: 'Popular dishes',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/restaurants'),
        )),
        const SizedBox(height: 12),
        if (_error != null)
          _padH(_RetryHint(text: _error!, onRetry: _load))
        else if (dishes == null)
          const _LoadingHint()
        else if (dishes.isEmpty)
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
              onTap: () =>
                  context.push('${AppRoutes.product}/${dishes[i].id}'),
              onAdd: () =>
                  context.push('${AppRoutes.product}/${dishes[i].id}'),
            )),
            if (i != dishes.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MarketplaceBody extends StatefulWidget {
  const _MarketplaceBody({
    required this.categoryId,
    required this.subcategoryId,
  });
  final String categoryId;
  final String? subcategoryId;

  @override
  State<_MarketplaceBody> createState() => _MarketplaceBodyState();
}

class _MarketplaceBodyState extends State<_MarketplaceBody> {
  List<Product>? _products;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _MarketplaceBody old) {
    super.didUpdateWidget(old);
    if (old.categoryId != widget.categoryId ||
        old.subcategoryId != widget.subcategoryId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _products = null;
    });
    try {
      final products = await CatalogApi.instance
          .items(category: widget.subcategoryId ?? widget.categoryId);
      if (mounted) setState(() => _products = products);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _products;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _padH(_SectionHeader(
          title: 'Top picks',
          onSeeAll: () =>
              context.push('${AppRoutes.categoryDetail}/${widget.categoryId}'),
        )),
        const SizedBox(height: 14),
        if (_error != null)
          _padH(_RetryHint(text: _error!, onRetry: _load))
        else if (products == null)
          const _LoadingHint()
        else if (products.isEmpty)
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
        // Full-bleed bulk-lot carousel, height reserves vertical room for
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
          onTap: () => context.push('${AppRoutes.vendor}/${vendors[i].id}'),
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
        onTap: () => context.push('${AppRoutes.product}/${products[i].id}'),
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

/// Centred spinner shown while a section's API data loads.
class _LoadingHint extends StatelessWidget {
  const _LoadingHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
          ),
        ),
      ),
    );
  }
}

/// Error card with a retry action for a failed section load.
class _RetryHint extends StatelessWidget {
  const _RetryHint({required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(WBSpacing.md + 4),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: 10),
          WBButton(
            label: 'Try again',
            size: WBButtonSize.sm,
            variant: WBButtonVariant.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
