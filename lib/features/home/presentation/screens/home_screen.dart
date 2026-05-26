import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/feature_flag_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_home_app_bar.dart';
import '../../../../core/widgets/wb_random_tagline.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/address_controller.dart';
import '../../../account/application/profile_controller.dart';
import '../../../category/domain/models/category_kind.dart';
import '../../../category/presentation/widgets/subcategory_chip_row.dart';
import '../../../recipes/application/recipes_controller.dart';
import '../../../recipes/domain/models/recipe.dart';
import '../../../shopping/application/mock_data.dart';
import '../../application/category_controller.dart';
import '../../domain/models/category.dart';
import '../widgets/category_body.dart';

String _greeting(String? firstName) {
  final h = DateTime.now().hour;
  final name = firstName != null ? ', $firstName' : '';
  if (h >= 5 && h < 12) return 'Good morning$name. What\'s cooking?';
  if (h >= 12 && h < 17) return 'Hey$name. Lunch break?';
  if (h >= 17 && h < 22) return 'Evening$name. Dinner plans?';
  return 'Late night craving$name? We see you.';
}

/// Padding helper, wraps a non-carousel section in the standard 20 px safe
/// area so carousels can stay full-bleed.
Widget _padded(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

/// Home tab. Outer ListView has zero horizontal padding so horizontal
/// carousels can scroll edge-to-edge; static sections opt-in to the 20 px
/// padding via [_padded].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeCategoryId;
  String? _activeSubcategoryId;

  static const _navSafePad = 140.0;

  @override
  void initState() {
    super.initState();
    ProfileController.instance.load();
    AddressController.instance.load();
    CategoryController.instance.load();
    RecipesController.instance.load();
  }

  void _onCategoryTap(String id) {
    setState(() {
      if (_activeCategoryId == id) {
        _activeCategoryId = null;
        _activeSubcategoryId = null;
      } else {
        _activeCategoryId = id;
        _activeSubcategoryId = null;
      }
    });
  }

  void _onSubcategoryTap(String? id) {
    setState(() => _activeSubcategoryId = id);
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = _activeCategoryId == null
        ? null
        : MockData.categoryById(_activeCategoryId!);
    final kind = activeCategory?.kind ?? CategoryKind.all;

    return ValueListenableBuilder<UserProfile?>(
      valueListenable: ProfileController.instance.profile,
      builder: (_, profile, _) => ValueListenableBuilder<List<Address>>(
        valueListenable: AddressController.instance.addresses,
        builder: (_, addresses, _) {
          final firstName = profile?.fullName.isNotEmpty == true
              ? profile!.fullName.split(' ').first
              : null;
          final greeting = _greeting(firstName);
          final defaultAddr =
              addresses.where((a) => a.isDefault).firstOrNull;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              0,
              12 + MediaQuery.of(context).padding.top,
              0,
              _navSafePad,
            ),
            children: [
              _padded(WBHomeAppBar(
                title: greeting,
                subtitle: defaultAddr != null
                    ? context.l10n.homeDeliveringTo(defaultAddr.line)
                    : context.l10n.homeAddAddress,
                subtitleIcon: WBIconName.pin,
                showChat: false,
                trailingExtra: WBHomeAppBarButton(
                  icon: WBIconName.basket,
                  onTap: () => context.push(AppRoutes.cart),
                ),
              )),
              const SizedBox(height: 22),
              _padded(const WBRandomTagline(pairs: WBTaglines.customer)),
              const SizedBox(height: 22),
              // Search bar
              _padded(GestureDetector(
                onTap: () => context.push(AppRoutes.search),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: WBColors.bgSecondary,
                    borderRadius: BorderRadius.circular(WBRadius.input),
                  ),
                  child: Row(
                    children: [
                      const WBIcon(WBIconName.search, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.homeSearchPlaceholder,
                          overflow: TextOverflow.ellipsis,
                          style: WBTypography.body.copyWith(
                            color: WBColors.fgPlaceholder,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 20),
              _padded(Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAction(
                    icon: WBIconName.basket,
                    label: 'Reorder',
                    onTap: () => context.push(AppRoutes.ordersHistory),
                  ),
                  _QuickAction(
                    icon: WBIconName.pin,
                    label: 'Track',
                    onTap: () => context.push(AppRoutes.tracking),
                  ),
                  _QuickAction(
                    icon: WBIconName.message,
                    label: 'Chat',
                    onTap: () => context.push(AppRoutes.chatInbox),
                  ),
                ],
              )),
              const SizedBox(height: 18),
              _padded(GestureDetector(
                onTap: () => context.push(AppRoutes.trade),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                          WBIconName.basket,
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
                              context.l10n.homeBulkMarketsTitle,
                              style: WBTypography.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.homeBulkMarketsSubtitle,
                              style: WBTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const WBIcon(
                        WBIconName.arrowRight,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 22),
              ValueListenableBuilder<Map<String, bool>>(
                valueListenable: FeatureFlagService.instance.flags,
                builder: (_, flags, _) {
                  final newUI = flags['new_categories_ui'] ?? true;
                  return ValueListenableBuilder<List<Category>?>(
                    valueListenable: CategoryController.instance.categories,
                    builder: (_, cats, _) => newUI
                        ? _CategoryPillRow(
                            cats: cats,
                            activeCategoryId: _activeCategoryId,
                            onTap: _onCategoryTap,
                          )
                        : _CategoryGrid(
                            cats: cats,
                            activeCategoryId: _activeCategoryId,
                            onTap: _onCategoryTap,
                          ),
                  );
                },
              ),
              // Subcategory chips (animated reveal, full-bleed)
              AnimatedSize(
                duration: WBMotion.base,
                curve: WBMotion.easeSoft,
                alignment: Alignment.topCenter,
                child: activeCategory == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: WBSpacing.md),
                        child: SubcategoryChipRow(
                          subcategories: activeCategory.subcategories,
                          activeId: _activeSubcategoryId,
                          onTap: _onSubcategoryTap,
                          visible: true,
                          horizontalPadding: 20,
                        ),
                      ),
              ),
              const SizedBox(height: 22),
              CategoryBody(
                kind: kind,
                categoryId: _activeCategoryId,
                subcategoryId: _activeSubcategoryId,
              ),
              const SizedBox(height: 22),
              _padded(_CookTonightHeader()),
              const SizedBox(height: 12),
              const _CookTonightCarousel(),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 20),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CookTonightHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.homeCookTonight,
            style: WBTypography.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.recipes),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                context.l10n.homeCookTonightSeeAll,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const WBIcon(WBIconName.arrowRight, size: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _CookTonightCarousel extends StatelessWidget {
  const _CookTonightCarousel();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Recipe>?>(
      valueListenable: RecipesController.instance.recipes,
      builder: (_, recipes, _) {
        if (recipes == null) {
          return SizedBox(
            height: 220,
            child: Shimmer.fromColors(
              baseColor: WBColors.bgSoft,
              highlightColor: WBColors.bgSecondary,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                  ),
                ),
              ),
            ),
          );
        }
        if (recipes.isEmpty) return const SizedBox.shrink();
        final shown = recipes.take(5).toList();
        return SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _HomeRecipeCard(recipe: shown[i]),
          ),
        );
      },
    );
  }
}

class _HomeRecipeCard extends StatelessWidget {
  const _HomeRecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetail(recipe.slug)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 240,
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
                  const SizedBox(height: 8),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── New UI: scrollable pill row ───────────────────────────────────────────────

class _CategoryPillRow extends StatelessWidget {
  const _CategoryPillRow({
    required this.cats,
    required this.activeCategoryId,
    required this.onTap,
  });
  final List<Category>? cats;
  final String? activeCategoryId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (cats == null) {
      return SizedBox(
        height: 44,
        child: Shimmer.fromColors(
          baseColor: WBColors.bgSoft,
          highlightColor: WBColors.bgSecondary,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, _) => Container(
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cats!.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = cats![i];
          final active = c.id == activeCategoryId;
          return GestureDetector(
            onTap: () => onTap(c.id),
            child: AnimatedContainer(
              duration: WBMotion.base,
              curve: WBMotion.easeSoft,
              padding: const EdgeInsets.only(left: 6, right: 16),
              decoration: BoxDecoration(
                color: active ? WBColors.surfaceDark : WBColors.surfaceTag,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withValues(alpha: 0.12)
                            : WBColors.bgPrimary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: (c.svgAsset != null && c.svgAsset!.isNotEmpty)
                          ? SvgPicture.asset(c.svgAsset!, fit: BoxFit.contain)
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    c.label,
                    style: WBTypography.caption.copyWith(
                      color: active ? Colors.white : WBColors.fgHeader,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Old UI: 3-column icon grid ────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.cats,
    required this.activeCategoryId,
    required this.onTap,
  });
  final List<Category>? cats;
  final String? activeCategoryId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (cats == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Shimmer.fromColors(
          baseColor: WBColors.bgSoft,
          highlightColor: WBColors.bgSecondary,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 9,
            itemBuilder: (_, _) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: cats!.length,
        itemBuilder: (_, i) {
          final c = cats![i];
          final active = c.id == activeCategoryId;
          return GestureDetector(
            onTap: () => onTap(c.id),
            child: AnimatedContainer(
              duration: WBMotion.base,
              curve: WBMotion.easeSoft,
              decoration: BoxDecoration(
                color: active ? WBColors.surfaceDark : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (c.svgAsset != null && c.svgAsset!.isNotEmpty)
                    SvgPicture.asset(
                      c.svgAsset!,
                      width: 28,
                      height: 28,
                      colorFilter: active
                          ? const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn)
                          : null,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    c.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.caption.copyWith(
                      color: active ? Colors.white : WBColors.fgHeader,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
