import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/data/account_extras_api.dart';
import '../../application/cart_controller.dart';
import '../../data/catalog_api.dart';
import '../../domain/models/product.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';

/// Desktop-web layout for the product detail screen. Isolated from the mobile
/// build: re-lays the same data and logic into a two-column page (gallery left,
/// info + actions right) inside [CustomerWebScaffold]. Mirrors
/// `ProductScreen` exactly for data loading, state, and navigation.
class ProductDesktopScreen extends ConsumerStatefulWidget {
  const ProductDesktopScreen({super.key, this.productId});

  /// Id of the tapped product.
  final String? productId;

  @override
  ConsumerState<ProductDesktopScreen> createState() =>
      _ProductDesktopScreenState();
}

class _ProductDesktopScreenState extends ConsumerState<ProductDesktopScreen> {
  int _qty = 1;
  bool _adding = false;
  final _notesCtrl = TextEditingController();
  bool _isFavorited = false;
  bool _togglingFavorite = false;

  Product? _product;
  String? _error;
  List<Product> _moreLikeThis = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteState(String itemId) async {
    try {
      final data = await AccountExtrasApi.instance.favorites();
      final items = (data['items'] as List?) ?? const [];
      final favorited = items.any((v) {
        final id = v is Map ? (v['id'] ?? v['itemId']) : v;
        return id?.toString() == itemId;
      });
      if (mounted) setState(() => _isFavorited = favorited);
    } on ApiException {
      // Non-critical — leave default false.
    }
  }

  Future<void> _toggleFavorite() async {
    final id = widget.productId;
    if (id == null || _togglingFavorite) return;
    if (!GuestModeController.instance.requireAccount(context,
        // TODO(i18n): key=guestActionFavorite
        action: 'save favorites')) {
      return;
    }
    setState(() => _togglingFavorite = true);
    final wasF = _isFavorited;
    setState(() => _isFavorited = !wasF);
    try {
      await AccountExtrasApi.instance.toggleFavoriteItem(id);
      if (!mounted) return;
      wbShowSnack(context,
          _isFavorited ? 'Saved to favorites' : 'Removed from favorites');
    } on ApiException catch (e) {
      if (mounted) setState(() => _isFavorited = wasF);
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _togglingFavorite = false);
    }
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final id = widget.productId;
    if (id == null || id.isEmpty) {
      setState(() => _error = 'product_not_found');
      return;
    }
    try {
      final p = await CatalogApi.instance.item(id);
      if (!mounted) return;
      setState(() => _product = p);
      _loadFavoriteState(id);
      _loadMoreLikeThis(p);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _loadMoreLikeThis(Product p) async {
    try {
      final vendorId = p.vendorId;
      final List<Product> similar;
      if (vendorId != null && vendorId.isNotEmpty) {
        similar = await CatalogApi.instance.items(vendorId: vendorId);
      } else {
        // The API's `category` filter keys off the subcategory id (see
        // Product.fromJson taxonomy note), so filter "more like this" by it.
        similar = await CatalogApi.instance.items(category: p.subcategoryId);
      }
      if (!mounted) return;
      setState(() {
        _moreLikeThis = similar.where((x) => x.id != p.id).take(10).toList();
      });
    } catch (_) {
      // Non-critical — page works fine without this section.
    }
  }

  Future<void> _addToBasket() async {
    final product = _product;
    if (product == null) return;
    if (!GuestModeController.instance.requireAccount(context,
        action: 'add to your cart')) {
      return;
    }
    setState(() => _adding = true);
    final note = _notesCtrl.text.trim();
    await ref
        .read(cartControllerProvider.notifier)
        .add(product, qty: _qty, note: note.isEmpty ? null : note);
    if (!mounted) return;
    setState(() => _adding = false);
    final error = ref.read(cartControllerProvider).error;
    if (error != null) {
      wbShowSnack(context, error);
    } else {
      wbShowSnack(context, context.l10n.productAddedToBasket);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final errorMessage =
        _error == 'product_not_found' ? context.l10n.productNotFound : _error;

    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        child: product == null
            ? _buildLoadingOrError(errorMessage)
            : _buildContent(product),
      ),
    );
  }

  Widget _buildLoadingOrError(String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(WBSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WBBackChip(onPressed: () => context.pop()),
          Expanded(
            child: Center(
              child: errorMessage != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: WBTypography.body
                              .copyWith(color: WBColors.fgSecondary),
                        ),
                        const SizedBox(height: 14),
                        WBButton(
                          label: context.l10n.actionRetry,
                          size: WBButtonSize.sm,
                          variant: WBButtonVariant.secondary,
                          onPressed: _load,
                        ),
                      ],
                    )
                  : const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor:
                            AlwaysStoppedAnimation(WBColors.surfaceDark),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Product product) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.lg,
        WBSpacing.screenPadding,
        WBSpacing.xxl,
      ),
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(height: WBSpacing.lg),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildGallery(product)),
              const SizedBox(width: WBSpacing.xl),
              Expanded(flex: 4, child: _buildInfoColumn(product)),
            ],
          ),
        ),
        if (_moreLikeThis.isNotEmpty) ...[
          const SizedBox(height: WBSpacing.xxl),
          Text(
            'More from this vendor',
            style: WBTypography.cardTitle.copyWith(fontSize: 19),
          ),
          const SizedBox(height: WBSpacing.md),
          _buildMoreGrid(),
        ],
      ],
    );
  }

  Widget _buildGallery(Product product) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(WBRadius.card),
          child: AspectRatio(
            aspectRatio: 1,
            child: WBNetworkImage(url: product.imageUrl),
          ),
        ),
        Positioned(
          top: WBSpacing.md,
          right: WBSpacing.md,
          child: WBCircleIconButton(
            icon: WBIconName.heart,
            iconColor:
                _isFavorited ? WBColors.statusError : WBColors.fgHeader,
            onPressed: _toggleFavorite,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(Product product) {
    final total = product.priceNaira * _qty;
    final cartCount = ref.watch(cartControllerProvider.select(
      (s) => s.items.fold(0, (n, l) => n + l.quantity),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: WBTypography.page),
        const SizedBox(height: 6),
        Text(product.vendorName, style: WBTypography.secondary),
        const SizedBox(height: WBSpacing.md),
        Text(
          product.formattedPrice,
          style: WBTypography.page.copyWith(fontSize: 28),
        ),
        const SizedBox(height: WBSpacing.lg),
        Text(
          product.description,
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quantity',
              style: WBTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),
            WBQtyStepper(
              value: _qty,
              onChanged: (v) => setState(() => _qty = v),
            ),
          ],
        ),
        const SizedBox(height: WBSpacing.lg),
        Text(
          'Special instructions (optional)',
          style: WBTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: WBSpacing.sm + 2),
        WBInput(
          controller: _notesCtrl,
          label: context.l10n.productAddNote,
          placeholder: context.l10n.productNotePlaceholder,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: WBSpacing.xl),
        Row(
          children: [
            Expanded(
              child: WBButton(
                label: context.l10n.productAddButton,
                fullWidth: true,
                size: WBButtonSize.lg,
                loading: _adding,
                trailing: Text(
                  '₦${_format(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: _addToBasket,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (GuestModeController.instance
                    .requireAccount(context, action: 'view your basket')) {
                  context.push(AppRoutes.cart);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: WBColors.surfaceCard,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                      border: Border.all(color: WBColors.bgDivider),
                      boxShadow: WBShadows.card,
                    ),
                    alignment: Alignment.center,
                    child: const WBIcon(WBIconName.basket, size: 22),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: WBColors.surfaceDark,
                          borderRadius: BorderRadius.circular(WBRadius.pill),
                          border: Border.all(
                              color: WBColors.bgPrimary, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cartCount > 9 ? '9+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreGrid() {
    return Wrap(
      spacing: WBSpacing.md,
      runSpacing: WBSpacing.lg,
      children: [
        for (final p in _moreLikeThis)
          SizedBox(
            width: 200,
            child: GestureDetector(
              onTap: () => context.push('${AppRoutes.product}/${p.id}'),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(WBRadius.card),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: WBNetworkImage(url: p.imageUrl),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.formattedPrice,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _format(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
