import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/recipes_controller.dart';
import '../../domain/models/recipe.dart';

/// Catalogue of every cookable combo. Tap a card to fetch live pricing and
/// add to basket. Public route — no auth required.
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  void initState() {
    super.initState();
    // Idempotent — the controller skips work if already loaded.
    RecipesController.instance.load();
  }

  Future<void> _refresh() async {
    await RecipesController.instance.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WBBackChip(onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.home)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.l10n.recipesTitle,
                      style: WBTypography.page,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Text(
                  context.l10n.recipesSubtitle,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              Expanded(
                child: ValueListenableBuilder<List<Recipe>?>(
                  valueListenable: RecipesController.instance.recipes,
                  builder: (_, recipes, _) {
                    if (recipes == null) {
                      return const _RecipesShimmer();
                    }
                    if (recipes.isEmpty) {
                      return _EmptyState(
                        onRefresh: _refresh,
                        error: RecipesController.instance.error.value,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: WBColors.surfaceDark,
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.74,
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (_, i) => _RecipeCard(recipe: recipes[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final servesLabel = recipe.defaultSize?.servesLabel ?? '';
    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetail(recipe.slug)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WBNetworkImage(url: recipe.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const WBIcon(
                        WBIconName.clock,
                        size: 12,
                        color: WBColors.fgPlaceholder,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n
                            .recipeDetailCookingTime(recipe.cookingTimeMins),
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (servesLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${context.l10n.recipeDetailServes} $servesLabel',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipesShimmer extends StatelessWidget {
  const _RecipesShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: WBColors.bgSoft,
      highlightColor: WBColors.bgSecondary,
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.74,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(WBRadius.card),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh, this.error});

  final Future<void> Function() onRefresh;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: WBColors.surfaceDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: WBColors.bgSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const WBIcon(
                WBIconName.basket,
                size: 28,
                color: WBColors.fgPlaceholder,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            error != null
                ? context.l10n.recipeLoadFailed
                : context.l10n.recipeEmptyState,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.recipesSubtitle,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: WBButton(
              label: context.l10n.actionRetry,
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}
