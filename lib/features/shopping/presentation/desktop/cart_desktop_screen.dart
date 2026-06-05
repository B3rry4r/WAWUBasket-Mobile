import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../recipes/application/recipe_cart_controller.dart';
import '../../../recipes/domain/models/recipe_cart_item.dart';
import '../../../recipes/domain/models/recipe_size.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/cart_controller.dart';
import '../../domain/models/product.dart';

/// Desktop-web layout for the customer basket. Isolated from the mobile build:
/// re-lays the exact same data, controllers and totals math used by
/// `CartScreen` into a two-column page (item list left, sticky order summary
/// right) inside [CustomerWebScaffold]. Mirrors `CartScreen` precisely for
/// data loading, guest handling, state, error/empty handling and navigation.
class CartDesktopScreen extends ConsumerStatefulWidget {
  const CartDesktopScreen({super.key});

  @override
  ConsumerState<CartDesktopScreen> createState() => _CartDesktopScreenState();
}

class _CartDesktopScreenState extends ConsumerState<CartDesktopScreen> {
  final Set<String> _expandedRecipeIds = {};

  @override
  void initState() {
    super.initState();
    if (GuestModeController.instance.isGuest.value) return;
    RecipeCartController.instance.load();
    // Reload cart on every open so stale state from a prior session is cleared.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(cartControllerProvider.notifier).load();
    });
  }

  String _sizeLabel(BuildContext context, RecipeSizeLabel l) {
    switch (l) {
      case RecipeSizeLabel.small:
        return context.l10n.recipeSizeSmall;
      case RecipeSizeLabel.medium:
        return context.l10n.recipeSizeMedium;
      case RecipeSizeLabel.family:
        return context.l10n.recipeSizeFamily;
      case RecipeSizeLabel.party:
        return context.l10n.recipeSizeParty;
    }
  }

  Future<void> _confirmRemoveRecipe(RecipeCartItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.recipeRemoveTitle),
        content: Text(context.l10n.recipeRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.actionRemove),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await RecipeCartController.instance.remove(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: ValueListenableBuilder(
        valueListenable: GuestModeController.instance.isGuest,
        builder: (_, isGuest, _) {
          if (isGuest) return _buildGuest(context);
          return _buildSignedIn(context);
        },
      ),
    );
  }

  Widget _buildGuest(BuildContext context) {
    return WBMaxWidth(
      maxWidth: WBBreakpoints.maxReading,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.xxl,
          WBSpacing.screenPadding,
          WBSpacing.xxl,
        ),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: const WBIcon(WBIconName.basket,
                  size: 36, color: WBColors.fgHeader),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Your basket is waiting',
              textAlign: TextAlign.center,
              style: WBTypography.hero.copyWith(fontSize: 22),
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              'Sign in to add items, place orders and track deliveries.',
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: 'Sign in',
              size: WBButtonSize.lg,
              fullWidth: true,
              trailingIcon: WBIconName.arrowRight,
              onPressed: () => context.push(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedIn(BuildContext context) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);
    final productLines = state.items;
    final productSubtotal = controller.subtotal;

    return ValueListenableBuilder<List<RecipeCartItem>>(
      valueListenable: RecipeCartController.instance.items,
      builder: (_, recipeItems, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: RecipeCartController.instance.loading,
          builder: (_, recipeLoading, _) {
            final recipeSubtotalNaira =
                recipeItems.fold<int>(0, (s, i) => s + (i.totalPriceKobo ~/ 100));
            final subtotal = productSubtotal + recipeSubtotalNaira;
            final serviceFee = WbPricing.serviceFee(subtotal);
            const delivery = WbPricing.deliveryFeeNaira;
            final total = subtotal + delivery + serviceFee;
            final loading = state.loading || recipeLoading;
            final cartIsEmpty = productLines.isEmpty && recipeItems.isEmpty;

            // Transient states — both carts are still loading / hard error / empty.
            if ((loading && cartIsEmpty) || state.error != null || cartIsEmpty) {
              return WBMaxWidth(
                maxWidth: WBBreakpoints.maxContent,
                child: _emptyOrLoading(
                  context,
                  loading: loading,
                  error: state.error,
                  onRetry: controller.load,
                ),
              );
            }

            final vendorName = productLines.isNotEmpty
                ? (productLines.first.product.vendorName.isEmpty
                    ? 'Your vendor'
                    : productLines.first.product.vendorName)
                : '';

            return WBMaxWidth(
              maxWidth: WBBreakpoints.maxContent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  WBSpacing.lg,
                  WBSpacing.screenPadding,
                  WBSpacing.xxl,
                ),
                children: [
                  Row(
                    children: [
                      WBBackChip(onPressed: () => context.pop()),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          context.l10n.cartTitle,
                          style: WBTypography.page,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildItems(
                            context,
                            controller: controller,
                            productLines: productLines,
                            recipeItems: recipeItems,
                            vendorName: vendorName,
                          ),
                        ),
                        const SizedBox(width: WBSpacing.xl),
                        Expanded(
                          flex: 1,
                          child: _buildSummaryColumn(
                            context,
                            subtotal: subtotal,
                            delivery: delivery,
                            serviceFee: serviceFee,
                            total: total,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItems(
    BuildContext context, {
    required CartController controller,
    required List<CartLine> productLines,
    required List<RecipeCartItem> recipeItems,
    required String vendorName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recipeItems.isNotEmpty) ...[
          _SectionLabel(label: context.l10n.recipeCartSection),
          const SizedBox(height: 10),
          WBCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < recipeItems.length; i++) ...[
                  _RecipeCartRow(
                    item: recipeItems[i],
                    sizeLabel: _sizeLabel(
                      context,
                      recipeItems[i].size.label,
                    ),
                    expanded:
                        _expandedRecipeIds.contains(recipeItems[i].id),
                    onToggle: () => setState(() {
                      final id = recipeItems[i].id;
                      if (_expandedRecipeIds.contains(id)) {
                        _expandedRecipeIds.remove(id);
                      } else {
                        _expandedRecipeIds.add(id);
                      }
                    }),
                    onRemove: () => _confirmRemoveRecipe(recipeItems[i]),
                  ),
                  if (i != recipeItems.length - 1) const WBDivider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.md),
        ],
        if (productLines.isNotEmpty) ...[
          WBCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(WBSpacing.md - 2),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WBColors.bgSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Heading(
                          title: vendorName,
                          subtitle: context.l10n.cartEta,
                        ),
                      ),
                    ],
                  ),
                ),
                const WBDivider(),
                for (var i = 0; i < productLines.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.all(WBSpacing.md - 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: WBNetworkImage(
                              url: productLines[i].product.imageUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productLines[i].product.name,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              if (productLines[i].note != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  productLines[i].note!,
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                productLines[i].totalLabel,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        WBQtyStepper(
                          value: productLines[i].quantity,
                          onChanged: (q) => controller.setQuantity(
                            productLines[i].product.id,
                            q,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != productLines.length - 1) const WBDivider(),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryColumn(
    BuildContext context, {
    required int subtotal,
    required int delivery,
    required int serviceFee,
    required int total,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: WBCard(
        child: Column(
          children: [
            _SummaryRow(
              label: context.l10n.cartSubtotal,
              value: wbNaira(subtotal),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: context.l10n.cartDeliveryFee,
              value: wbNaira(delivery),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: context.l10n.cartServiceFee,
              value: wbNaira(serviceFee),
            ),
            const SizedBox(height: 14),
            const WBDivider(),
            const SizedBox(height: 14),
            _SummaryRow(
              label: context.l10n.cartTotal,
              value: wbNaira(total),
              emphasised: true,
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: context.l10n.cartCheckout,
              fullWidth: true,
              size: WBButtonSize.lg,
              trailing: Text(
                wbNaira(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => context.push(AppRoutes.checkout),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyOrLoading(
    BuildContext context, {
    required bool loading,
    required String? error,
    required Future<void> Function() onRetry,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            0,
          ),
          child: Row(
            children: [
              WBBackChip(onPressed: () => context.pop()),
              const SizedBox(width: 14),
              Text(context.l10n.cartTitle, style: WBTypography.page),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(WBSpacing.screenPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (error != null) ...[
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: WBTypography.body
                                .copyWith(color: WBColors.fgSecondary),
                          ),
                          const SizedBox(height: 14),
                          WBButton(
                            label: context.l10n.actionRetry,
                            size: WBButtonSize.sm,
                            variant: WBButtonVariant.secondary,
                            onPressed: onRetry,
                          ),
                        ] else ...[
                          Text(
                            context.l10n.cartEmpty,
                            textAlign: TextAlign.center,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.cartEmptySubtitle,
                            textAlign: TextAlign.center,
                            style: WBTypography.body
                                .copyWith(color: WBColors.fgSecondary),
                          ),
                          const SizedBox(height: 18),
                          WBButton(
                            label: context.l10n.cartStartShopping,
                            size: WBButtonSize.sm,
                            trailingIcon: WBIconName.arrowRight,
                            onPressed: () => context.go(AppRoutes.home),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: WBTypography.label.copyWith(
        fontWeight: FontWeight.w600,
        color: WBColors.fgPlaceholder,
        letterSpacing: 0.66,
      ),
    );
  }
}

class _RecipeCartRow extends StatelessWidget {
  const _RecipeCartRow({
    required this.item,
    required this.sizeLabel,
    required this.expanded,
    required this.onToggle,
    required this.onRemove,
  });

  final RecipeCartItem item;
  final String sizeLabel;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final priceNaira = item.totalPriceKobo ~/ 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(WBSpacing.md - 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: WBNetworkImage(url: item.recipe.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.recipe.name} · $sizeLabel',
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.recipeCartFromVendors(
                          item.ingredientCount,
                          item.vendorCount,
                        ),
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      wbNaira(priceNaira),
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onRemove,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: WBColors.bgSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(
                          WBIconName.close,
                          size: 14,
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WBDivider(),
                      const SizedBox(height: 10),
                      for (final s in item.matchedSellers) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_qty(s.qty)} ${s.unit} · ${s.name}',
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                wbNaira(s.lineTotalKobo ~/ 100),
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgHeader,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _qty(double q) {
    if (q == q.roundToDouble()) return q.toInt().toString();
    return q.toStringAsFixed(1);
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 1),
        Text(subtitle, style: WBTypography.caption),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });
  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final style = emphasised
        ? WBTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          )
        : WBTypography.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: WBColors.fgHeader)),
      ],
    );
  }
}
