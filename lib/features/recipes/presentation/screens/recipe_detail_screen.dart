import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/recipe_cart_controller.dart';
import '../../data/recipes_api.dart';
import '../../domain/models/recipe.dart';
import '../../domain/models/recipe_match.dart';
import '../../domain/models/recipe_size.dart';

/// Detail view for a single recipe combo. Loads the canonical recipe, then
/// auto-fetches a price quote for the default size. Changing size kicks off
/// another match call so the sticky CTA always reflects the live total.
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  String? _recipeError;
  RecipeMatch? _match;
  String? _matchError;
  bool _matching = false;
  bool _submitting = false;
  bool _ingredientsExpanded = false;
  RecipeSize? _selectedSize;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _recipeError = null;
    });
    try {
      final recipe = await RecipesApi.instance.detail(widget.slug);
      if (!mounted) return;
      final defaultSize = recipe.defaultSize;
      setState(() {
        _recipe = recipe;
        _selectedSize = defaultSize;
      });
      if (defaultSize != null) {
        _runMatch(recipe.id, defaultSize.id);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _recipeError = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _recipeError = context.l10n.recipeDetailNotFound);
      }
    }
  }

  Future<void> _runMatch(String recipeId, String sizeId) async {
    setState(() {
      _matching = true;
      _matchError = null;
    });
    try {
      final match = await RecipesApi.instance.match(
        recipeId: recipeId,
        sizeId: sizeId,
      );
      if (!mounted) return;
      setState(() {
        _match = match;
        _matching = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _matching = false;
        _matchError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _matching = false;
        _matchError = context.l10n.recipeMatchFailed;
      });
    }
  }

  void _onSizePicked(RecipeSize size) {
    if (_recipe == null) return;
    if (size.id == _selectedSize?.id) return;
    setState(() => _selectedSize = size);
    _runMatch(_recipe!.id, size.id);
  }

  Future<void> _addToBasket() async {
    final recipe = _recipe;
    final size = _selectedSize;
    final match = _match;
    if (recipe == null || size == null || match == null) return;
    if (!match.fullyAvailable) return;
    setState(() => _submitting = true);
    try {
      await RecipeCartController.instance.add(
        recipeId: recipe.id,
        sizeId: size.id,
      );
      if (!mounted) return;
      wbShowSnack(context, context.l10n.recipeAddedToBasket);
      context.go(AppRoutes.cart);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (_) {
      if (mounted) wbShowSnack(context, context.l10n.recipeAddFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    if (_recipeError != null) {
      return _stateScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _recipeError!,
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: 14),
            WBButton(
              label: context.l10n.actionRetry,
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: _loadRecipe,
            ),
          ],
        ),
      );
    }
    final recipe = _recipe;
    if (recipe == null) {
      return _stateScaffold(
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
          ),
        ),
      );
    }

    final match = _match;
    final priceNaira = match != null ? match.totalNaira : 0;
    final fullyAvailable = match?.fullyAvailable ?? false;
    final canSubmit =
        match != null && fullyAvailable && !_matching && !_submitting;

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 160 + MediaQuery.of(context).padding.bottom),
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: WBNetworkImage(url: recipe.imageUrl),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        WBSpacing.screenPadding,
                        12,
                        WBSpacing.screenPadding,
                        0,
                      ),
                      child: WBBackChip(
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.recipes),
                      ),
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
                    Text(recipe.name, style: WBTypography.page),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        WBTag(
                          label: context.l10n
                              .recipeDetailCookingTime(recipe.cookingTimeMins),
                        ),
                        if (recipe.cuisine.isNotEmpty)
                          WBTag(label: recipe.cuisine),
                      ],
                    ),
                    if (recipe.description != null &&
                        recipe.description!.isNotEmpty) ...[
                      const SizedBox(height: WBSpacing.lg),
                      Text(
                        context.l10n.recipeDetailDescription,
                        style: WBTypography.label.copyWith(
                          color: WBColors.fgPlaceholder,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.66,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description!,
                        style: WBTypography.body.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      context.l10n.recipeDetailServes.toUpperCase(),
                      style: WBTypography.label.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.66,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final size in recipe.sizes)
                          WBTag(
                            label: _sizeLabel(context, size.label),
                            active: size.id == _selectedSize?.id,
                            onTap: () => _onSizePicked(size),
                          ),
                      ],
                    ),
                    if (_selectedSize != null &&
                        _selectedSize!.servesLabel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _selectedSize!.servesLabel,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: WBSpacing.lg),
                    if (match != null && !match.fullyAvailable)
                      _UnavailableCard(unavailable: match.unavailable),
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      context.l10n.recipeDetailIngredients,
                      style: WBTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _IngredientsList(
                      match: match,
                      matching: _matching,
                      matchError: _matchError,
                      expanded: _ingredientsExpanded,
                      onToggle: () => setState(
                        () => _ingredientsExpanded = !_ingredientsExpanded,
                      ),
                      onRetry: _selectedSize == null
                          ? null
                          : () => _runMatch(recipe.id, _selectedSize!.id),
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
            child: _StickyBuyBar(
              priceNaira: priceNaira,
              matching: _matching,
              submitting: _submitting,
              enabled: canSubmit,
              onPressed: canSubmit ? _addToBasket : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateScaffold({required Widget child}) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(WBSpacing.screenPadding),
              child: WBBackChip(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.recipes),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(WBSpacing.screenPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.unavailable});

  final List<UnavailableIngredient> unavailable;

  @override
  Widget build(BuildContext context) {
    final names = unavailable.map((u) => u.name).join(', ');
    return Container(
      padding: const EdgeInsets.all(WBSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0x24F59E0B),
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WBIcon(
            WBIconName.bell,
            size: 18,
            color: WBColors.statusWarningFg,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.recipeUnavailableTitle,
                  style: WBTypography.body.copyWith(
                    color: WBColors.statusWarningFg,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.recipeUnavailableBody(names),
                  style: WBTypography.caption.copyWith(
                    color: WBColors.statusWarningFg,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  const _IngredientsList({
    required this.match,
    required this.matching,
    required this.matchError,
    required this.expanded,
    required this.onToggle,
    required this.onRetry,
  });

  final RecipeMatch? match;
  final bool matching;
  final String? matchError;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (match == null && matching) {
      return Container(
        padding: const EdgeInsets.all(WBSpacing.lg),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
          ),
        ),
      );
    }
    if (match == null) {
      return Container(
        padding: const EdgeInsets.all(WBSpacing.lg),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Column(
          children: [
            Text(
              matchError ?? context.l10n.recipeMatchFailed,
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              WBButton(
                label: context.l10n.actionRetry,
                size: WBButtonSize.sm,
                variant: WBButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      );
    }

    final visible =
        expanded ? match!.ingredients : match!.ingredients.take(3).toList();
    final canExpand = match!.ingredients.length > 3;

    return Container(
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visible[i].name,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_qty(visible[i].qty)} ${visible[i].unit} · ${visible[i].sellerName}',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    wbNaira(visible[i].lineTotalNaira),
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (i != visible.length - 1) const WBDivider(indent: 16, endIndent: 16),
          ],
          if (canExpand) ...[
            const WBDivider(indent: 16, endIndent: 16),
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      expanded
                          ? context.l10n.recipeIngredientsCollapse
                          : context.l10n.recipeIngredientsSeeAll,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    WBIcon(
                      expanded
                          ? WBIconName.chevronLeft
                          : WBIconName.chevronRight,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _qty(double q) {
    if (q == q.roundToDouble()) return q.toInt().toString();
    return q.toStringAsFixed(1);
  }
}

class _StickyBuyBar extends StatelessWidget {
  const _StickyBuyBar({
    required this.priceNaira,
    required this.matching,
    required this.submitting,
    required this.enabled,
    required this.onPressed,
  });

  final int priceNaira;
  final bool matching;
  final bool submitting;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final priceString = wbThousands(priceNaira);
    return Container(
      padding: EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        14,
        WBSpacing.screenPadding,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: WBColors.bgPrimary,
        boxShadow: WBShadows.float,
      ),
      child: WBButton(
        label: context.l10n.recipeAddToBasket(priceString),
        fullWidth: true,
        size: WBButtonSize.lg,
        loading: submitting,
        disabled: !enabled,
        trailing: matching
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : null,
        onPressed: onPressed,
      ),
    );
  }
}
