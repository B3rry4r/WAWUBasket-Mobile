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
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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

// ── Orbital category selector (feature flag ON) ───────────────────────────────
//
// A circular ring of category icons orbits a center "active" slot.
// Drag horizontally to spin the ring; it decelerates with friction and snaps
// to the nearest category. The active category is whichever item sits closest
// to the 12 o'clock position. Tapping a ring item snaps it to active position.

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
  // Ring rotation in radians. 0 = first category at 12 o'clock.
  double _rotation = 0.0;
  double _angularVelocity = 0.0;
  Ticker? _ticker;
  int _activeIndex = 0;

  // Snapping spring animation
  late final AnimationController _snapCtrl;
  Animation<double>? _snapAnim;

  // Drag → rotation scale. Controls how fast the ring spins relative to drag.
  static const _dragSensitivity = 0.0055; // rad / screen-pixel
  // Friction coefficient applied every frame during fling (0=instant stop, 1=no friction).
  static const _friction = 0.88;
  // Below this angular speed (rad/frame), friction loop ends and we snap.
  static const _stopThreshold = 0.003;

  // Geometry
  static const _orbitR = 108.0;  // center → orbit-item center
  static const _centerD = 82.0;  // active bubble diameter
  static const _orbitD = 52.0;   // orbit item diameter
  static const _totalH = 290.0;  // fixed widget height

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

  // Which index is currently closest to 12 o'clock (angle 0 after rotation).
  int _nearestIndex(int n) {
    if (n == 0) return 0;
    final step = 2 * pi / n;
    final norm = ((-_rotation) % (2 * pi) + 2 * pi) % (2 * pi);
    return ((norm + step / 2) / step).floor() % n;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _ticker?.stop();
    _snapCtrl.stop();
    setState(() {
      _rotation += d.delta.dx * _dragSensitivity;
    });
    _maybeUpdateActive();
  }

  void _onPanEnd(DragEndDetails d) {
    final vx = d.velocity.pixelsPerSecond.dx;
    _angularVelocity = vx * _dragSensitivity;
    // Cap max fling speed so the ring never whips uncontrollably.
    _angularVelocity = _angularVelocity.clamp(-0.18, 0.18);
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
    // Find shortest arc to target (handles wrap-around).
    var diff = (target - _rotation + pi) % (2 * pi) - pi;
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
    if (widget.cats != null && widget.cats!.isNotEmpty) {
      widget.onSelect(widget.cats![idx].id);
    }
  }

  // Returns the x,y offset from the selector center for orbit item i.
  Offset _orbitOffset(int i, int n) {
    final angle = _angleForIndex(i, n) + _rotation;
    return Offset(_orbitR * sin(angle), -_orbitR * cos(angle));
  }

  // Depth factor 0..1: 0 = front (top of ring), 1 = back (bottom of ring).
  double _depth(int i, int n) {
    final angle = (_angleForIndex(i, n) + _rotation) % (2 * pi);
    // cos(angle): 1 at top (front), -1 at bottom (back)
    final cosA = cos(angle);
    return (1.0 - cosA) / 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.cats;
    if (cats == null) return _buildShimmer();

    final n = cats.length;
    // Sort orbit items by depth so back items are drawn first (behind center).
    final indices = List.generate(n, (i) => i)
      ..sort((a, b) => _depth(a, n).compareTo(_depth(b, n)));

    final active = n > 0 ? cats[_activeIndex] : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        height: _totalH,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Faint orbit track
            Positioned.fill(
              child: CustomPaint(painter: _OrbitTrackPainter(radius: _orbitR)),
            ),
            // Orbit items (back-to-front)
            for (final i in indices)
              if (i != _activeIndex)
                _buildOrbitItem(cats[i], i, n),
            // Active center bubble
            AnimatedSwitcher(
              duration: WBMotion.base,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: WBMotion.easeSoft),
                ),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: active == null
                  ? const SizedBox.shrink()
                  : _buildCenter(active),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenter(Category cat) {
    return Container(
      key: ValueKey(cat.id),
      width: _centerD,
      height: _centerD,
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
          if (cat.svgAsset != null && cat.svgAsset!.isNotEmpty)
            SizedBox(
              width: 28,
              height: 28,
              child: SvgPicture.asset(
                cat.svgAsset!,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Colors.white, BlendMode.srcIn),
              ),
            )
          else
            const SizedBox(width: 28, height: 28),
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

  Widget _buildOrbitItem(Category cat, int i, int n) {
    final offset = _orbitOffset(i, n);
    final depth = _depth(i, n);
    // Items at the back are smaller and more transparent — creates depth illusion.
    final scale = 1.0 - depth * 0.2;
    final opacity = 1.0 - depth * 0.45;

    return Transform.translate(
      offset: offset,
      child: GestureDetector(
        onTap: () => _snapToIndex(i),
        child: Opacity(
          opacity: opacity.clamp(0.35, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: _orbitD,
              height: _orbitD,
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                shape: BoxShape.circle,
                boxShadow: WBShadows.card,
              ),
              padding: const EdgeInsets.all(11),
              child: cat.svgAsset != null && cat.svgAsset!.isNotEmpty
                  ? SvgPicture.asset(
                      cat.svgAsset!,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        WBColors.fgSecondary, BlendMode.srcIn),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: _totalH,
      child: Shimmer.fromColors(
        baseColor: WBColors.bgSoft,
        highlightColor: WBColors.bgSecondary,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center
            Container(
              width: _centerD,
              height: _centerD,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            // A few orbit placeholders
            for (var i = 0; i < 6; i++)
              Transform.translate(
                offset: Offset(
                  _orbitR * sin(2 * pi * i / 6),
                  -_orbitR * cos(2 * pi * i / 6),
                ),
                child: Container(
                  width: _orbitD,
                  height: _orbitD,
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
  }
}

// Paints the subtle circular orbit track behind the items.
class _OrbitTrackPainter extends CustomPainter {
  const _OrbitTrackPainter({required this.radius});
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_OrbitTrackPainter old) => old.radius != radius;
}
