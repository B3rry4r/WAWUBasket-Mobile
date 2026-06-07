import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/wawuafrica_hub.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/feature_flag_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_home_app_bar.dart';
import '../../../../core/widgets/wb_random_tagline.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../account/application/address_controller.dart';
import '../../../account/application/notifications_controller.dart';
import '../../../account/application/profile_controller.dart';
import '../../../category/domain/models/category_kind.dart';
import '../../../category/presentation/widgets/subcategory_chip_row.dart';
import '../../../recipes/application/recipes_controller.dart';
import '../../../shopping/application/cart_controller.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    NotificationsController.instance.refresh();
    ref.read(cartControllerProvider.notifier).load();
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

  Future<void> _openHub(String path) async {
    final uri = Uri.parse('$wawuAfricaHubUrl$path');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WAWUAfrica')),
      );
    }
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
                subtitle: GuestModeController.instance.isGuest.value
                    ? null
                    : defaultAddr != null
                        ? context.l10n.homeDeliveringTo(defaultAddr.line)
                        : context.l10n.homeAddAddress,
                subtitleIcon: WBIconName.pin,
                showChat: false,
                trailingExtra: WBHomeAppBarButton(
                  icon: WBIconName.basket,
                  badgeCount: ref.watch(cartControllerProvider.select(
                    (s) => s.items.fold(0, (n, l) => n + l.quantity),
                  )),
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
              _padded(_WawuServicesStrip(onOpen: _openHub)),
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

// ── WAWUAfrica services strip ────────────────────────────────────────────────
//
// The two-line WAWUAfrica brand mark stays fixed on top while the individual
// services (EasyBuy, Health Insurance, Pension, …) fade/slide through
// automatically — three visible at a time, cycling through the whole list so
// every WAWUAfrica service is surfaced from the WAWUBasket home. Tapping a row
// (or the mark) opens the hub web platform via url_launcher.

/// A single WAWUAfrica service entry surfaced by [_WawuServicesStrip].
class _WawuService {
  const _WawuService({
    required this.label,
    required this.path,
    required this.icon,
    this.soon = false,
  });

  final String label;
  final String path;
  final IconData icon;
  final bool soon;
}

const List<_WawuService> _wawuServices = [
  _WawuService(
    label: 'EasyBuy',
    path: '/services/easybuy/apply',
    icon: Icons.shopping_bag_outlined,
  ),
  _WawuService(
    label: 'Health Insurance',
    path: '/services/insurance',
    icon: Icons.health_and_safety_outlined,
    soon: true,
  ),
  _WawuService(
    label: 'Pension',
    path: '/services/pension',
    icon: Icons.savings_outlined,
    soon: true,
  ),
  _WawuService(
    label: 'Banking',
    path: '/services/banking',
    icon: Icons.account_balance_outlined,
    soon: true,
  ),
  _WawuService(
    label: 'Grants & Funding',
    path: '/services/grants',
    icon: Icons.volunteer_activism_outlined,
    soon: true,
  ),
  _WawuService(
    label: 'CAC Registration',
    path: '/services/cac-registration/apply',
    icon: Icons.assignment_outlined,
  ),
  _WawuService(
    label: 'NEPC Registration',
    path: '/services/nepc-registration/apply',
    icon: Icons.public_outlined,
  ),
  _WawuService(
    label: 'Mentorship',
    path: '/services/mentors',
    icon: Icons.diversity_3_outlined,
  ),
];

class _WawuServicesStrip extends StatefulWidget {
  final void Function(String path) onOpen;
  const _WawuServicesStrip({required this.onOpen});

  @override
  State<_WawuServicesStrip> createState() => _WawuServicesStripState();
}

class _WawuServicesStripState extends State<_WawuServicesStrip> {
  static const Duration _interval = Duration(milliseconds: 2800);
  static const int _slots = 3; // services shown (and animating) at once

  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // One fading service slot. Each of the [_slots] slots shows a different
  // service and they all advance (animate) together on every tick, cycling
  // through the whole list.
  Widget _slot(int i) {
    final service = _wawuServices[(_step * _slots + i) % _wawuServices.length];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onOpen(service.path),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.22),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _ServiceItem(
          key: ValueKey<String>('$i-${service.path}'),
          service: service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: WBColors.bgSecondary,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      // Single horizontal row: WAWUAfrica stays fixed in the first column while
      // the remaining [_slots] columns cycle through every service together.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Col 1 — fixed black two-row WAWUAfrica mark, opens the services home.
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onOpen('/services'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Image.asset(
                    'assets/brand_icons/wawuafrica_mark.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 13, thickness: 1, color: WBColors.bgDivider),
            // Cols 2..n — the cycling service slots.
            for (int i = 0; i < _slots; i++) Expanded(child: _slot(i)),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({super.key, required this.service});

  final _WawuService service;

  @override
  Widget build(BuildContext context) {
    // Compact, centred column item so each cycling service fits one grid slot.
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(service.icon, size: 24, color: WBColors.fgHeader),
        const SizedBox(height: 7),
        Text(
          service.label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: WBTypography.body.copyWith(
            color: WBColors.fgHeader,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            height: 1.15,
          ),
        ),
        if (service.soon) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
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
// Rules:
//   • Horizontal drag spins the ring with momentum (mobile + web).
//   • Spinning is visual-only — content does NOT change until a node is tapped.
//   • Tapping a node selects it: orbit snaps with a spring, content updates.
//   • All n nodes stay in the orbit at all times (no gap for the active item).
//   • Active node gets a dark ring; other nodes orbit at reduced opacity/scale.
//   • Center disc always shows the currently selected category (from parent).

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

  // Visual front-node index into _orbitCats (does NOT drive content).
  int _spinIdx = 0;

  // Suppress the didUpdateWidget snap when we ourselves just fired onSelect.
  bool _suppressSync = false;

  late final AnimationController _snapCtrl;
  Animation<double>? _snapAnim;
  CurvedAnimation? _snapCurve;

  void _onSnapTick() {
    if (mounted) setState(() => _rotation = _snapAnim?.value ?? _rotation);
  }

  // Tuned for a light, responsive spin: more rotation per pixel, a longer
  // glide, and a quick settle (previously felt heavy and appeared to "rewind"
  // to the start because the ring barely moved before snapping to nearest).
  static const _sensitivity = 0.0110;
  static const _friction = 0.945;
  static const _stopVel = 0.0022;

  // The orbit is all cats EXCEPT the currently active one.
  List<Category> get _orbitCats {
    final cats = widget.cats;
    if (cats == null) return const [];
    final selIdx = cats.indexWhere((c) => c.id == widget.activeId);
    return [
      for (var i = 0; i < cats.length; i++)
        if (i != selIdx) cats[i],
    ];
  }

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  }

  @override
  void didUpdateWidget(_OrbitalCategorySelector old) {
    super.didUpdateWidget(old);
    if (old.cats != widget.cats || old.activeId != widget.activeId) {
      if (_suppressSync) {
        _suppressSync = false;
      } else {
        final n = _orbitCats.length;
        if (n > 0 && _spinIdx >= n) _spinIdx = 0;
      }
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _snapAnim?.removeListener(_onSnapTick);
    _snapCurve?.dispose();
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
  // Use horizontal-drag (not pan) so the parent ListView keeps its vertical
  // scroll — pan competes with the scroll view on mobile and loses.

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    _ticker?.stop();
    _snapCtrl.stop();
    setState(() => _rotation += d.delta.dx * _sensitivity);
    _updateSpinIdx();
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    _vel = (d.velocity.pixelsPerSecond.dx * _sensitivity).clamp(-0.34, 0.34);
    _ticker ??= createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration _) {
    _vel *= _friction;
    setState(() => _rotation += _vel);
    _updateSpinIdx();
    if (_vel.abs() < _stopVel) {
      _ticker!.stop();
      final n = _orbitCats.length;
      if (n > 0) _snapVisual(_nearestIdx(n));
    }
  }

  void _updateSpinIdx() {
    final n = _orbitCats.length;
    if (n == 0) return;
    final idx = _nearestIdx(n);
    if (idx != _spinIdx) {
      setState(() => _spinIdx = idx);
      HapticFeedback.selectionClick();
    }
  }

  // Tap: snap + fire content change.
  void _tapNode(int idx) {
    final orbit = _orbitCats;
    if (orbit.isEmpty || idx >= orbit.length) return;
    setState(() => _spinIdx = idx);
    _animateSnap(idx, const Duration(milliseconds: 400), spring: true);
    final id = orbit[idx].id;
    if (id != widget.activeId) {
      _suppressSync = true;
      widget.onSelect(id);
    }
  }

  // Post-momentum snap: visual only, no content change.
  void _snapVisual(int idx) {
    setState(() => _spinIdx = idx);
    _animateSnap(idx, const Duration(milliseconds: 240), spring: false);
  }

  void _animateSnap(int idx, Duration duration, {required bool spring}) {
    final n = _orbitCats.length;
    if (n == 0) return;
    final target = -_angleFor(idx, n);
    final diff = (target - _rotation + pi) % (2 * pi) - pi;
    final dest = _rotation + diff;
    if ((dest - _rotation).abs() < 0.001) return;

    _snapCtrl.stop();
    _snapCtrl.duration = duration;
    _snapCtrl.reset();
    final begin = _rotation;
    final curve = spring ? Curves.easeOutBack : Curves.easeOutCubic;
    // Detach the previous tick listener and dispose the old CurvedAnimation so
    // stale ones don't pile up as listeners on _snapCtrl (one per snap).
    _snapAnim?.removeListener(_onSnapTick);
    _snapCurve?.dispose();
    _snapCurve = CurvedAnimation(parent: _snapCtrl, curve: curve);
    _snapAnim = Tween<double>(begin: begin, end: dest).animate(_snapCurve!)
      ..addListener(_onSnapTick);
    _snapCtrl.forward();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cats = widget.cats;
    if (cats == null) return _buildShimmer();

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;

      final orbitR = (w * 0.315).clamp(116.0, 152.0);
      final orbitD = (w * 0.200).clamp(72.0, 92.0);
      final centerD = (w * 0.330).clamp(122.0, 156.0);
      final totalH = 2 * orbitR + orbitD + 20.0;
      final cx = w / 2;
      final cy = orbitR + orbitD / 2 + 10.0;

      // Center disc = selected cat from parent.
      final selectedIdx = cats.indexWhere((c) => c.id == widget.activeId);
      final selectedCat = selectedIdx >= 0 ? cats[selectedIdx] : (cats.isNotEmpty ? cats[0] : null);

      // Orbit = everything except the active one.
      final orbitCats = [
        for (var i = 0; i < cats.length; i++)
          if (i != selectedIdx) cats[i],
      ];
      final n = orbitCats.length;

      final byDepth = List.generate(n, (i) => i)
        ..sort((a, b) => _depth(a, n).compareTo(_depth(b, n)));

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SizedBox(
          width: w,
          height: totalH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final i in byDepth)
                _buildNode(orbitCats[i], i, n, cx, cy,
                    orbitR: orbitR, orbitD: orbitD),
              if (selectedCat != null)
                Positioned(
                  left: cx - centerD / 2,
                  top: cy - centerD / 2,
                  width: centerD,
                  height: centerD,
                  child: AnimatedSwitcher(
                    duration: WBMotion.base,
                    child: _buildCenter(context, selectedCat, centerD),
                  ),
                ),
            ],
          ),
        ),
      );
    });
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
    final scale = (1.0 - depth * 0.12);
    final opacity = (1.0 - depth * 0.38).clamp(0.42, 1.0);

    return Positioned(
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

  Widget _buildCenter(BuildContext context, Category cat, double d) {
    return Container(
      key: ValueKey(cat.id),
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        shape: BoxShape.circle,
        boxShadow: WBShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cat.svgAsset != null && cat.svgAsset!.isNotEmpty)
            SizedBox(
              width: d * 0.32,
              height: d * 0.32,
              child: SvgPicture.asset(
                cat.svgAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: d * 0.10),
            child: Text(
              context.categoryLabel(cat.id, fallback: cat.label),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final orbitR = (w * 0.315).clamp(116.0, 152.0);
      final orbitD = (w * 0.200).clamp(72.0, 92.0);
      final centerD = (w * 0.330).clamp(122.0, 156.0);
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
            ],
          ),
        ),
      );
    });
  }
}
