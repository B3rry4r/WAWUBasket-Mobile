import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../category/domain/models/category_kind.dart';
import '../../../category/presentation/widgets/subcategory_chip_row.dart';
import '../../../shopping/application/mock_data.dart';
import '../../../shopping/application/wb_images.dart';
import '../widgets/category_body.dart';

/// Padding helper — wraps a non-carousel section in the standard 20 px safe
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

    return ListView(
      padding: EdgeInsets.fromLTRB(
        0,
        12 + MediaQuery.of(context).padding.top,
        0,
        _navSafePad,
      ),
      children: [
        _padded(_HeaderRow(
          onBell: () => context.push(AppRoutes.notifications),
          onBasket: () => context.push(AppRoutes.cart),
        )),
        const SizedBox(height: 22),
        _padded(RichText(
          text: TextSpan(
            style: WBTypography.hero.copyWith(
              fontSize: 32,
              height: 1.1,
              letterSpacing: -0.8,
            ),
            children: const [
              TextSpan(
                text: 'Hungry? ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: 'Order & Eat',
                style: TextStyle(
                  color: WBColors.fgPlaceholder,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 22),
        // Search bar (filter pill removed)
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
                    'Search for jollof, tomatoes, chicken, pots…',
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
        const SizedBox(height: 22),
        // Row 1 — category pills (full-bleed)
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: MockData.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = MockData.categories[i];
              final active = c.id == _activeCategoryId;
              return GestureDetector(
                onTap: () => _onCategoryTap(c.id),
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
                        child: ClipOval(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: WBNetworkImage(url: c.imageUrl),
                          ),
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
        ),
        // Row 2 — subcategory chips (animated reveal, full-bleed).
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
        // Category body — picks its own horizontal padding per section.
        CategoryBody(
          kind: kind,
          categoryId: _activeCategoryId,
          subcategoryId: _activeSubcategoryId,
        ),
        const SizedBox(height: 22),
        _padded(const _OffersBanner()),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onBell, required this.onBasket});
  final VoidCallback onBell;
  final VoidCallback onBasket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: WBNetworkImage(url: WBImages.avatar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Brooks',
                      style: WBTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        letterSpacing: -0.17,
                      ),
                    ),
                    Row(
                      children: [
                        const WBIcon(
                          WBIconName.pin,
                          size: 11,
                          color: WBColors.fgPlaceholder,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Delivering to 12 Adeola Odeku St, V/I',
                            overflow: TextOverflow.ellipsis,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgPlaceholder,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const WBIcon(
                          WBIconName.chevronDown,
                          size: 11,
                          color: WBColors.fgPlaceholder,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _HeaderIconButton(icon: WBIconName.bell, badge: true, onTap: onBell),
            const SizedBox(width: 8),
            _HeaderIconButton(icon: WBIconName.basket, onTap: onBasket),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });
  final WBIconName icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: WBColors.bgPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: WBColors.bgDivider),
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 18),
            ),
            if (badge)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: WBColors.statusError,
                    shape: BoxShape.circle,
                    border: Border.all(color: WBColors.bgPrimary, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OffersBanner extends StatelessWidget {
  const _OffersBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(WBSpacing.lg),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            bottom: -36,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WBColors.surfaceDark, width: 6),
              ),
              clipBehavior: Clip.antiAlias,
              child: const WBNetworkImage(url: WBImages.jollof),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'THIS WEEK',
                style: WBTypography.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Free delivery\non orders over ₦5,000',
                style: WBTypography.page.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.15,
                  letterSpacing: -0.48,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Until Sunday. No code needed.',
                style: WBTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Order now',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: WBColors.fgHeader,
                        fontSize: 14,
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
            ],
          ),
        ],
      ),
    );
  }
}
