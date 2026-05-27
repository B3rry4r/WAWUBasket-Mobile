import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

Widget _padded(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

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
            physics: const AlwaysScrollableScrollPhysics(),
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
                    icon: WBIconName.star,
                    label: 'Meal Kits',
                    onTap: () => context.push(AppRoutes.recipes),
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
                  _QuickAction(
                    icon: WBIconName.basket,
                    label: 'Reorder',
                    onTap: () => context.push(AppRoutes.ordersHistory),
                  ),
                ],
              )),
              const SizedBox(height: 22),
              ValueListenableBuilder<Map<String, bool>>(
                valueListenable: FeatureFlagService.instance.flags,
                builder: (_, flags, _) {
                  final orbitalUI = flags['new_categories_ui'] ?? false;
                  return ValueListenableBuilder<List<Category>?>(
                    valueListenable: CategoryController.instance.categories,
                    builder: (_, cats, _) {
                      if (orbitalUI) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _OrbitalCategorySelector(
                              cats: cats,
                              activeId: _activeCategoryId,
                              onSelect: _onCategoryTap,
                            ),
                            AnimatedSize(
                              duration: WBMotion.slow,
                              curve: WBMotion.easeSoft,
                              alignment: Alignment.topCenter,
                              child: _activeCategoryId == null
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(top: WBSpacing.md),
                                      child: CategoryBody(
                                        kind: kind,
                                        categoryId: _activeCategoryId,
                                        subcategoryId: _activeSubcategoryId,
                                      ),
                                    ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CategoryPillRow(
                            cats: cats,
                            activeCategoryId: _activeCategoryId,
                            onTap: _onCategoryTap,
                          ),
                          AnimatedSize(
                            duration: WBMotion.base,
                            curve: WBMotion.easeSoft,
                            alignment: Alignment.topCenter,
                            child: activeCategory == null
                                ? const SizedBox(width: double.infinity)
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: WBSpacing.md),
                                    child: SubcategoryChipRow(
                                      subcategories:
                                          activeCategory.subcategories,
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
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────────────────────

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

// ── Standard pill row (feature flag OFF) ─────────────────────────────────────

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
        physics: const BouncingScrollPhysics(),
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
                          ? SvgPicture.asset(
                              c.svgAsset!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            )
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

// ── Orbital category selector (feature flag ON) ───────────────────────────────
//
// A circular ring of category icons orbits a center "active" slot.
// Drag horizontally to spin the ring; it decelerates with friction and snaps
// to the nearest category. The active category is whichever item sits closest
// to the 12 o'clock position. Tapping a ring item snaps it to active position.
//
// Layout uses LayoutBuilder + Positioned (not Transform.translate) so hit
// testing and visual positions always match — essential for touch to work.

class _OrbitalCategorySelector extends StatefulWidget {
  const _OrbitalCategorySelector({
    required this.cats,
    required this.activeId,
    required this.onSelect,
  });
  final List<Category>? cats;
  final String? activeId;
  final ValueChanged<String> onSelect;

  @override
  State<_OrbitalCategorySelector> createState() =>
      _OrbitalCategorySelectorState();
}

class _OrbitalCategorySelectorState extends State<_OrbitalCategorySelector>
    with TickerProviderStateMixin {
  double _rotation = 0.0;
  double _angularVelocity = 0.0;
  Ticker? _ticker;
  int _activeIndex = 0;

  late final AnimationController _snapCtrl;
  Animation<double>? _snapAnim;

  static const _dragSensitivity = 0.0055;
  static const _friction = 0.88;
  static const _stopThreshold = 0.003;

  // Geometry — tighter orbit radius, larger readable nodes
  static const _orbitR = 90.0;
  static const _centerD = 88.0;
  static const _orbitD = 62.0;
  static const _totalH = 265.0;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _syncActiveFromParent();
  }

  @override
  void didUpdateWidget(_OrbitalCategorySelector old) {
    super.didUpdateWidget(old);
    if (old.activeId != widget.activeId) _syncActiveFromParent();
    if (old.cats != widget.cats) _syncActiveFromParent();
  }

  void _syncActiveFromParent() {
    final cats = widget.cats;
    if (cats == null || cats.isEmpty) return;
    final id = widget.activeId;
    if (id == null) {
      _activeIndex = 0;
      _rotation = 0;
      return;
    }
    final idx = cats.indexWhere((c) => c.id == id);
    if (idx >= 0 && idx != _activeIndex) {
      _activeIndex = idx;
      _rotation = -_angleForIndex(idx, cats.length);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  double _angleForIndex(int i, int n) => 2 * pi * i / n;

  int _nearestIndex(int n) {
    if (n == 0) return 0;
    final step = 2 * pi / n;
    final norm = ((-_rotation) % (2 * pi) + 2 * pi) % (2 * pi);
    return ((norm + step / 2) / step).floor() % n;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _ticker?.stop();
    _snapCtrl.stop();
    setState(() => _rotation += d.delta.dx * _dragSensitivity);
    _maybeUpdateActive();
  }

  void _onPanEnd(DragEndDetails d) {
    _angularVelocity =
        (d.velocity.pixelsPerSecond.dx * _dragSensitivity).clamp(-0.18, 0.18);
    _ticker ??= createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration _) {
    _angularVelocity *= _friction;
    setState(() => _rotation += _angularVelocity);
    _maybeUpdateActive();
    if (_angularVelocity.abs() < _stopThreshold) {
      _ticker!.stop();
      _snapToIndex(_nearestIndex(widget.cats?.length ?? 1));
    }
  }

  void _maybeUpdateActive() {
    final n = widget.cats?.length ?? 0;
    if (n == 0) return;
    final idx = _nearestIndex(n);
    if (idx != _activeIndex) {
      setState(() => _activeIndex = idx);
      HapticFeedback.selectionClick();
      widget.onSelect(widget.cats![idx].id);
    }
  }

  void _snapToIndex(int idx) {
    final n = widget.cats?.length ?? 1;
    if (n == 0) return;
    final target = -_angleForIndex(idx, n);
    final diff = (target - _rotation + pi) % (2 * pi) - pi;
    final dest = _rotation + diff;

    _snapCtrl.stop();
    _snapCtrl.reset();
    final begin = _rotation;
    _snapAnim = Tween<double>(begin: begin, end: dest).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic),
    )..addListener(() {
        if (mounted) setState(() => _rotation = _snapAnim!.value);
      });
    _snapCtrl.forward();
    setState(() => _activeIndex = idx);
    if (widget.cats?.isNotEmpty == true) {
      widget.onSelect(widget.cats![idx].id);
    }
  }

  Offset _orbitOffset(int i, int n) {
    final angle = _angleForIndex(i, n) + _rotation;
    return Offset(_orbitR * sin(angle), -_orbitR * cos(angle));
  }

  // 0 = front (12 o'clock), 1 = back (6 o'clock).
  double _depth(int i, int n) {
    final angle = (_angleForIndex(i, n) + _rotation) % (2 * pi);
    return (1.0 - cos(angle)) / 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.cats;
    if (cats == null) return _buildShimmer();

    final n = cats.length;
    final indices = List.generate(n, (i) => i)
      ..sort((a, b) => _depth(a, n).compareTo(_depth(b, n)));
    final active = n > 0 ? cats[_activeIndex] : null;

    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final cx = w / 2;
        const cy = _totalH / 2;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: SizedBox(
            width: w,
            height: _totalH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Orbit items back-to-front — Positioned so touch zones
                // match visual positions (Transform.translate breaks hit testing).
                for (final i in indices)
                  if (i != _activeIndex)
                    _buildOrbitItem(cats[i], i, n, cx, cy),
                // Active center bubble
                Positioned(
                  left: cx - _centerD / 2,
                  top: cy - _centerD / 2,
                  width: _centerD,
                  height: _centerD,
                  child: AnimatedSwitcher(
                    duration: WBMotion.base,
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                        CurvedAnimation(
                            parent: anim, curve: WBMotion.easeSoft),
                      ),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: active == null
                        ? const SizedBox.shrink()
                        : _buildCenter(active),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenter(Category cat) {
    return Container(
      key: ValueKey(cat.id),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: cat.svgAsset != null && cat.svgAsset!.isNotEmpty
                ? SvgPicture.asset(
                    cat.svgAsset!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              cat.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitItem(Category cat, int i, int n, double cx, double cy) {
    final offset = _orbitOffset(i, n);
    final depth = _depth(i, n);
    final scale = 1.0 - depth * 0.18;
    final opacity = (1.0 - depth * 0.4).clamp(0.4, 1.0);

    return Positioned(
      left: cx + offset.dx - _orbitD / 2,
      top: cy + offset.dy - _orbitD / 2,
      width: _orbitD,
      height: _orbitD,
      child: GestureDetector(
        onTap: () => _snapToIndex(i),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                shape: BoxShape.circle,
                boxShadow: WBShadows.card,
              ),
              padding: const EdgeInsets.all(13),
              child: cat.svgAsset != null && cat.svgAsset!.isNotEmpty
                  ? SvgPicture.asset(
                      cat.svgAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final cx = w / 2;
        const cy = _totalH / 2;
        return SizedBox(
          width: w,
          height: _totalH,
          child: Shimmer.fromColors(
            baseColor: WBColors.bgSoft,
            highlightColor: WBColors.bgSecondary,
            child: Stack(
              children: [
                Positioned(
                  left: cx - _centerD / 2,
                  top: cy - _centerD / 2,
                  width: _centerD,
                  height: _centerD,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                for (var i = 0; i < 6; i++)
                  Positioned(
                    left: cx + _orbitR * sin(2 * pi * i / 6) - _orbitD / 2,
                    top: cy - _orbitR * cos(2 * pi * i / 6) - _orbitD / 2,
                    width: _orbitD,
                    height: _orbitD,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
