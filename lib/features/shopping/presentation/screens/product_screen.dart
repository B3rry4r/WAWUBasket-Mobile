import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
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
import '../widgets/sticky_action_bar.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, this.productId});

  /// Id of the tapped product.
  final String? productId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  int _qty = 1;
  bool _adding = false;
  final _notesCtrl = TextEditingController();
  bool _isFavorited = false;
  bool _togglingFavorite = false;

  Product? _product;
  String? _error;

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
      wbShowSnack(context, _isFavorited ? 'Saved to favorites' : 'Removed from favorites');
    } on ApiException catch (e) {
      if (mounted) setState(() => _isFavorited = wasF);
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _togglingFavorite = false);
    }
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final id = widget.productId;
    if (id == null || id.isEmpty) {
      // Cannot use context here (called from initState); set literal for now,
      // will be rendered in build where context.l10n is available.
      setState(() => _error = 'product_not_found');
      return;
    }
    try {
      final p = await CatalogApi.instance.item(id);
      if (!mounted) return;
      setState(() => _product = p);
      _loadFavoriteState(id);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _addToBasket() async {
    final product = _product;
    if (product == null) return;
    if (!GuestModeController.instance.requireAccount(context,
        // TODO(i18n): key=guestActionAddToCart
        action: 'add to your cart')) {
      return;
    }
    setState(() => _adding = true);
    await ref
        .read(cartControllerProvider.notifier)
        .add(product, qty: _qty);
    if (!mounted) return;
    setState(() => _adding = false);
    final error = ref.read(cartControllerProvider).error;
    if (error != null) {
      wbShowSnack(context, error);
    } else {
      context.push(AppRoutes.cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final errorMessage = _error == 'product_not_found'
        ? context.l10n.productNotFound
        : _error;
    if (product == null) {
      return Scaffold(
        backgroundColor: WBColors.bgPrimary,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(WBSpacing.screenPadding),
                child: WBBackChip(onPressed: () => context.pop()),
              ),
              Center(
                child: errorMessage != null
                    ? Padding(
                        padding:
                            const EdgeInsets.all(WBSpacing.screenPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(errorMessage,
                                textAlign: TextAlign.center,
                                style: WBTypography.body.copyWith(
                                    color: WBColors.fgSecondary)),
                            const SizedBox(height: 14),
                            WBButton(
                              label: context.l10n.actionRetry,
                              size: WBButtonSize.sm,
                              variant: WBButtonVariant.secondary,
                              onPressed: _load,
                            ),
                          ],
                        ),
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
            ],
          ),
        ),
      );
    }

    final total = product.priceNaira * _qty;
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 140),
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 380,
                    width: double.infinity,
                    child: WBNetworkImage(url: product.imageUrl),
                  ),
                  Positioned(
                    top: 56,
                    left: WBSpacing.screenPadding,
                    child: WBBackChip(onPressed: () => context.pop()),
                  ),
                  Positioned(
                    top: 56,
                    right: WBSpacing.screenPadding,
                    child: WBCircleIconButton(
                      icon: WBIconName.heart,
                      iconColor: _isFavorited
                          ? WBColors.statusError
                          : WBColors.fgHeader,
                      onPressed: _toggleFavorite,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: WBTypography.page,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.vendorName,
                                style: WBTypography.secondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          product.formattedPrice,
                          style: WBTypography.page.copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: WBSpacing.md),
                    Text(
                      product.description,
                      style: WBTypography.body.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        WBQtyStepper(
                          value: _qty,
                          onChanged: (v) => setState(() => _qty = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      'Notes for the restaurant',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.sm + 2),
                    WBInput(
                      controller: _notesCtrl,
                      label: 'Special instructions',
                      placeholder: 'Less spicy, no onions…',
                      keyboardType: TextInputType.text,
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
            child: StickyActionBar(
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
          ),
        ],
      ),
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
