import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/recipes_controller.dart';
import '../../domain/models/recipe.dart';

/// Desktop-web layout for the recipes catalogue. Re-lays the mobile vertical
/// grid into a wide, centered multi-column grid inside the shared customer
/// web chrome. Reuses [RecipesController] and the [Recipe] model unchanged —
/// this is layout only. Pushed screen: wrapped in [CustomerWebScaffold].
class RecipesDesktopScreen extends StatefulWidget {
  const RecipesDesktopScreen({super.key});

  @override
  State<RecipesDesktopScreen> createState() => _RecipesDesktopScreenState();
}

class _RecipesDesktopScreenState extends State<RecipesDesktopScreen> {
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
    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.xl,
            WBSpacing.xl,
            WBSpacing.xl,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WBBackChip(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.recipesTitle,
                style: WBTypography.page,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.recipesSubtitle,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
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
                        gridDelegate: const _RecipesGridDelegate(),
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

/// Fixed 4-column grid tuned for desktop width, matching the mobile card
/// aspect ratio so the same [_RecipeCard] reads correctly.
class _RecipesGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const _RecipesGridDelegate()
      : super(
          crossAxisCount: 4,
          mainAxisSpacing: WBSpacing.lg,
          crossAxisSpacing: WBSpacing.lg,
          childAspectRatio: 0.78,
        );
}

class _RecipeCard extends StatefulWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final servesLabel = recipe.defaultSize?.servesLabel ?? '';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.recipeDetail(recipe.slug)),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: _hovered ? WBShadows.float : WBShadows.card,
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
        gridDelegate: const _RecipesGridDelegate(),
        itemCount: 8,
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
