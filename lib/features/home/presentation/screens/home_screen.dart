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

String _greeting(BuildContext context, String? firstName) {
  final h = DateTime.now().hour;
  final name = firstName != null ? ', $firstName' : '';
  final l = context.l10n;
  if (h >= 5 && h < 12) return l.homeGreetingMorning(name);
  if (h >= 12 && h < 17) return l.homeGreetingAfternoon(name);
  if (h >= 17 && h < 22) return l.homeGreetingEvening(name);
  return l.homeGreetingNight(name);
}

Widget _padded(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeCategoryId = 'restaurants';
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
          final greeting = _greeting(context, firstName);
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
                    label: context.l10n.homeQuickMealKits,
                    onTap: () => context.push(AppRoutes.recipes),
                  ),
                  _QuickAction(
                    icon: WBIconName.pin,
                    label: context.l10n.homeQuickTrack,
                    onTap: () => context.push(AppRoutes.tracking),
                  ),
                  _QuickAction(
                    icon: WBIconName.message,
                    label: context.l10n.homeQuickChat,
                    onTap: () => context.push(AppRoutes.chatInbox),
                  ),
                  _QuickAction(
                    icon: WBIconName.basket,
                    label: context.l10n.homeQuickReorder,
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
                    context.categoryLabel(c.id, fallback: c.label),
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
// Dragging the ring spins it with momentum → decelerates → snaps to nearest.
// Tapping an orbit node snaps it to the front quickly without spinning.
// Content (onSelect) only fires after a snap settles, not during drag.
// All geometry is adaptive to available screen width via LayoutBuilder.

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
  double _vel = 0.0;
  Ticker? _ticker;
  int _activeIdx = 0;

  // Prevent didUpdateWidget from resetting rotation after our own onSelect.
  bool _suppressSync = false;

  late final AnimationController _snapCtrl;
  Animation<double>? _snapAnim;

  // Physics constants
  static const _sensitivity = 0.0048;
  static const _friction = 0.910;
  static const _stopVel = 0.0022;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _syncFromParent();
  }

  @override
  void didUpdateWidget(_OrbitalCategorySelector old) {
    super.didUpdateWidget(old);
    if (old.cats != widget.cats || old.activeId != widget.activeId) {
      _syncFromParent();
    }
  }

  void _syncFromParent() {
    if (_suppressSync) {
      _suppressSync = false;
      return;
    }
    final cats = widget.cats;
    if (cats == null || cats.isEmpty) return;
    final id = widget.activeId;
    if (id == null) return;
    final idx = cats.indexWhere((c) => c.id == id);
    if (idx >= 0 && idx != _activeIdx) {
      _activeIdx = idx;
      _rotation = -_angleFor(idx, cats.length);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  double _angleFor(int i, int n) => 2 * pi * i / n;

  int _nearestIdx(int n) {
    if (n == 0) return 0;
    final step = 2 * pi / n;
    final norm = ((-_rotation) % (2 * pi) + 2 * pi) % (2 * pi);
    return ((norm + step / 2) / step).floor() % n;
  }

  double _depth(int i, int n) {
    final angle = (_angleFor(i, n) + _rotation) % (2 * pi);
    return (1.0 - cos(angle)) / 2.0;
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails d) {
    _ticker?.stop();
    _snapCtrl.stop();
    setState(() => _rotation += d.delta.dx * _sensitivity);
    _updateVisualActive();
  }

  void _onPanEnd(DragEndDetails d) {
    _vel = (d.velocity.pixelsPerSecond.dx * _sensitivity).clamp(-0.16, 0.16);
    _ticker ??= createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration _) {
    _vel *= _friction;
    setState(() => _rotation += _vel);
    _updateVisualActive();
    if (_vel.abs() < _stopVel) {
      _ticker!.stop();
      _snapAndNotify(_nearestIdx(widget.cats?.length ?? 1));
    }
  }

  // Updates the visual active indicator during drag/momentum (no content update).
  void _updateVisualActive() {
    final n = widget.cats?.length ?? 0;
    if (n == 0) return;
    final idx = _nearestIdx(n);
    if (idx != _activeIdx) {
      setState(() => _activeIdx = idx);
      HapticFeedback.selectionClick();
    }
  }

  // Tap: immediate select + fast snap animation (no physics).
  void _tapNode(int idx) {
    final cats = widget.cats;
    if (cats == null || cats.isEmpty) return;
    setState(() => _activeIdx = idx);
    _animateSnap(idx, const Duration(milliseconds: 220));
    final id = cats[idx].id;
    if (id != widget.activeId) {
      _suppressSync = true;
      widget.onSelect(id);
    }
  }

  // Post-momentum snap: animate then notify parent.
  void _snapAndNotify(int idx) {
    final cats = widget.cats;
    if (cats == null || cats.isEmpty) return;
    setState(() => _activeIdx = idx);
    _animateSnap(idx, const Duration(milliseconds: 370));
    final id = cats[idx].id;
    if (id != widget.activeId) {
      _suppressSync = true;
      widget.onSelect(id);
    }
  }

  void _animateSnap(int idx, Duration duration) {
    final n = widget.cats?.length ?? 1;
    if (n == 0) return;
    final target = -_angleFor(idx, n);
    final diff = (target - _rotation + pi) % (2 * pi) - pi;
    final dest = _rotation + diff;
    if ((dest - _rotation).abs() < 0.001) return;

    _snapCtrl.stop();
    _snapCtrl.duration = duration;
    _snapCtrl.reset();
    final begin = _rotation;
    _snapAnim = Tween<double>(begin: begin, end: dest).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic),
    )..addListener(() {
        if (mounted) setState(() => _rotation = _snapAnim!.value);
      });
    _snapCtrl.forward();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cats = widget.cats;
    if (cats == null) return _buildShimmer();

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;

      // Adaptive geometry — scales with screen width.
      final orbitR = (w * 0.315).clamp(116.0, 152.0);
      final centerD = (w * 0.330).clamp(122.0, 156.0);
      final orbitD = (w * 0.200).clamp(72.0, 92.0);
      // Height = orbit diameter + top/bottom padding so no node clips.
      final totalH = 2 * orbitR + orbitD + 20.0;
      final cx = w / 2;
      final cy = orbitR + orbitD / 2 + 10.0;

      final n = cats.length;
      final byDepth = List.generate(n, (i) => i)
        ..sort((a, b) => _depth(a, n).compareTo(_depth(b, n)));
      final active = n > 0 ? cats[_activeIdx] : null;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: SizedBox(
          width: w,
          height: totalH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final i in byDepth)
                if (i != _activeIdx)
                  _buildNode(cats[i], i, n, cx, cy,
                      orbitR: orbitR, orbitD: orbitD),
              Positioned(
                left: cx - centerD / 2,
                top: cy - centerD / 2,
                width: centerD,
                height: centerD,
                child: AnimatedSwitcher(
                  duration: WBMotion.base,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 0.84, end: 1.0).animate(
                      CurvedAnimation(parent: anim, curve: WBMotion.easeSoft),
                    ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: active == null
                      ? SizedBox(width: centerD, height: centerD)
                      : _buildCenter(context, active, centerD),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCenter(BuildContext context, Category cat, double d) {
    final iconD = d * 0.36;
    // SizedBox enforces the fixed size — AnimatedSwitcher's internal Stack
    // passes loose constraints, so without explicit size the Container
    // would shrink to its content.
    return SizedBox(
      key: ValueKey(cat.id),
      width: d,
      height: d,
      child: Container(
        decoration: BoxDecoration(
          color: WBColors.surfaceDark,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: iconD,
              height: iconD,
              child: cat.svgAsset != null && cat.svgAsset!.isNotEmpty
                  ? SvgPicture.asset(cat.svgAsset!, fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink())
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: d * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: d * 0.10),
              child: Text(
                context.categoryLabel(cat.id, fallback: cat.label),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: WBTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(
    Category cat,
    int i,
    int n,
    double cx,
    double cy, {
    required double orbitR,
    required double orbitD,
  }) {
    final angle = _angleFor(i, n) + _rotation;
    final dx = orbitR * sin(angle);
    final dy = -orbitR * cos(angle);
    final depth = _depth(i, n);
    final scale = 1.0 - depth * 0.12;
    final opacity = (1.0 - depth * 0.38).clamp(0.42, 1.0);

    return Positioned(
      // Position the circle by its centre.
      left: cx + dx - orbitD / 2,
      top: cy + dy - orbitD / 2,
      width: orbitD,
      height: orbitD,
      child: GestureDetector(
        onTap: () => _tapNode(i),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: WBColors.borderFilled, width: 1.2),
                boxShadow: WBShadows.card,
              ),
              padding: EdgeInsets.all(orbitD * 0.22),
              child: cat.svgAsset != null && cat.svgAsset!.isNotEmpty
                  ? SvgPicture.asset(cat.svgAsset!, fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink())
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final orbitR = (w * 0.315).clamp(116.0, 152.0);
      final centerD = (w * 0.330).clamp(122.0, 156.0);
      final orbitD = (w * 0.200).clamp(72.0, 92.0);
      final totalH = 2 * orbitR + orbitD + 20.0;
      final cx = w / 2;
      final cy = orbitR + orbitD / 2 + 10.0;
      return SizedBox(
        width: w,
        height: totalH,
        child: Shimmer.fromColors(
          baseColor: WBColors.bgSoft,
          highlightColor: WBColors.bgSecondary,
          child: Stack(
            children: [
              Positioned(
                left: cx - centerD / 2,
                top: cy - centerD / 2,
                width: centerD,
                height: centerD,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              for (var i = 0; i < 6; i++)
                Positioned(
                  left: cx + orbitR * sin(2 * pi * i / 6) - orbitD / 2,
                  top: cy - orbitR * cos(2 * pi * i / 6) - orbitD / 2,
                  width: orbitD,
                  height: orbitD,
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
    });
  }
}
