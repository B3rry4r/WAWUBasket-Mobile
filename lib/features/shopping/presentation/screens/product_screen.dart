import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
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
  String _protein = 'chicken';
  bool _adding = false;

  Product? _product;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final id = widget.productId;
    if (id == null || id.isEmpty) {
      setState(() => _error = 'Product not found.');
      return;
    }
    try {
      final p = await CatalogApi.instance.item(id);
      if (!mounted) return;
      setState(() => _product = p);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _addToBasket() async {
    final product = _product;
    if (product == null) return;
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
                child: _error != null
                    ? Padding(
                        padding:
                            const EdgeInsets.all(WBSpacing.screenPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: WBTypography.body.copyWith(
                                    color: WBColors.fgSecondary)),
                            const SizedBox(height: 14),
                            WBButton(
                              label: 'Try again',
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
                      onPressed: () =>
                          wbShowSnack(context, 'Saved to favorites'),
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
                      'Protein',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.sm + 4),
                    for (final option in const [
                      (id: 'chicken', label: 'Grilled chicken', sub: 'Included'),
                      (id: 'beef', label: 'Beef', sub: '+₦500'),
                      (id: 'fish', label: 'Fish', sub: '+₦800'),
                    ]) ...[
                      _OptionRow(
                        label: option.label,
                        sub: option.sub,
                        selected: option.id == _protein,
                        onTap: () => setState(() => _protein = option.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: WBSpacing.sm),
                    Text(
                      'Notes for the restaurant',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.sm + 2),
                    Container(
                      padding: const EdgeInsets.all(WBSpacing.md),
                      decoration: BoxDecoration(
                        color: WBColors.surfaceInput,
                        borderRadius: BorderRadius.circular(WBRadius.input),
                      ),
                      child: Text(
                        'Less spicy please, and no onions on the side.',
                        style: WBTypography.body.copyWith(
                          fontSize: 14,
                          color: WBColors.fgPlaceholder,
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
            child: StickyActionBar(
              child: WBButton(
                label: 'Add to basket',
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

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? WBColors.bgPrimary : WBColors.bgSoft,
          border: Border.all(
            color: selected ? WBColors.fgHeader : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(WBRadius.input),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? WBColors.surfaceDark : WBColors.bgPrimary,
                border: Border.all(
                  color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 11,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              sub,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
