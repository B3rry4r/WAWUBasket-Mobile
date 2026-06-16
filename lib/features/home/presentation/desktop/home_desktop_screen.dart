import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_random_tagline.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/address_controller.dart';
import '../../../account/application/notifications_controller.dart';
import '../../../account/application/profile_controller.dart';
import '../../../category/domain/models/category_kind.dart';
import '../../../category/presentation/widgets/subcategory_chip_row.dart';
import '../../../recipes/application/recipes_controller.dart';
import '../../../shopping/application/cart_controller.dart';
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

/// Desktop-web layout for the customer Home **tab**. Body content only — the
/// persistent top bar is supplied by the customer shell's
/// [CustomerWebScaffold], so this widget never adds its own chrome.
///
/// Re-lays-out the mobile [HomeScreen] for a wide window: the vertical
/// category-pill + body stack becomes a left category rail beside a centered
/// content column (subcategory chips + the shared [CategoryBody]). All data
/// loading, state, and navigation mirror the mobile screen exactly — this is a
/// re-layout, not a re-implementation.
class HomeDesktopScreen extends ConsumerStatefulWidget {
  const HomeDesktopScreen({super.key});

  @override
  ConsumerState<HomeDesktopScreen> createState() => _HomeDesktopScreenState();
}

class _HomeDesktopScreenState extends ConsumerState<HomeDesktopScreen> {
  String? _activeCategoryId = 'restaurants';
  String? _activeSubcategoryId;

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

  @override
  Widget build(BuildContext context) {
    final activeCategory = _activeCategoryId == null
        ? null
        : CategoryController.instance.categoryById(_activeCategoryId!);
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
          final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull;
          final subtitle = GuestModeController.instance.isGuest.value
              ? null
              : defaultAddr != null
                  ? context.l10n.homeDeliveringTo(defaultAddr.line)
                  : context.l10n.homeAddAddress;

          return SingleChildScrollView(
            child: WBMaxWidth(
              maxWidth: WBBreakpoints.maxContent,
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.lg,
                WBSpacing.xl,
                WBSpacing.lg,
                WBSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(greeting: greeting, subtitle: subtitle),
                  const SizedBox(height: WBSpacing.lg),
                  const WBRandomTagline(pairs: WBTaglines.customer),
                  const SizedBox(height: WBSpacing.lg),
                  _QuickActionRow(),
                  const SizedBox(height: WBSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 260,
                        child: ValueListenableBuilder<List<Category>?>(
                          valueListenable:
                              CategoryController.instance.categories,
                          builder: (_, cats, _) => _CategoryRail(
                            cats: cats,
                            activeCategoryId: _activeCategoryId,
                            onTap: _onCategoryTap,
                          ),
                        ),
                      ),
                      const SizedBox(width: WBSpacing.xl),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSize(
                              duration: WBMotion.base,
                              curve: WBMotion.easeSoft,
                              alignment: Alignment.topCenter,
                              child: activeCategory == null
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: WBSpacing.md),
                                      child: SubcategoryChipRow(
                                        subcategories:
                                            activeCategory.subcategories,
                                        activeId: _activeSubcategoryId,
                                        onTap: _onSubcategoryTap,
                                        visible: true,
                                        horizontalPadding: 0,
                                      ),
                                    ),
                            ),
                            CategoryBody(
                              kind: kind,
                              categoryId: _activeCategoryId,
                              subcategoryId: _activeSubcategoryId,
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.greeting, this.subtitle});
  final String greeting;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: WBTypography.page.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: WBSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WBIcon(
                WBIconName.pin,
                size: 16,
                color: WBColors.fgSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                subtitle!,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      spacing: WBSpacing.md,
      runSpacing: WBSpacing.md,
      children: [
        _QuickAction(
          icon: WBIconName.star,
          label: l.homeQuickMealKits,
          onTap: () => context.push(AppRoutes.recipes),
        ),
        _QuickAction(
          icon: WBIconName.pin,
          label: l.homeQuickTrack,
          onTap: () => context.push(AppRoutes.tracking),
        ),
        _QuickAction(
          icon: WBIconName.message,
          label: l.homeQuickChat,
          onTap: () => context.push(AppRoutes.chatInbox),
        ),
        _QuickAction(
          icon: WBIconName.basket,
          label: l.homeQuickReorder,
          onTap: () => context.push(AppRoutes.ordersHistory),
        ),
      ],
    );
  }
}

class _QuickAction extends StatefulWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _hovered ? WBColors.bgSecondary : WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: WBShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: WBColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: WBIcon(widget.icon, size: 18),
              ),
              const SizedBox(width: WBSpacing.sm),
              Text(
                widget.label,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category rail ─────────────────────────────────────────────────────────────

/// Vertical equivalent of the mobile horizontal category pill row. Reuses the
/// same category list, labels (via [WBL10n.categoryLabel]) and SVG icons, and
/// drives the same `onTap` selection toggle.
class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
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
      return Shimmer.fromColors(
        baseColor: WBColors.bgSoft,
        highlightColor: WBColors.bgSecondary,
        child: Column(
          children: [
            for (var i = 0; i < 7; i++)
              Container(
                height: 52,
                margin: const EdgeInsets.only(bottom: WBSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in cats!) ...[
          _CategoryRailTile(
            category: c,
            active: c.id == activeCategoryId,
            onTap: () => onTap(c.id),
          ),
          const SizedBox(height: WBSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryRailTile extends StatefulWidget {
  const _CategoryRailTile({
    required this.category,
    required this.active,
    required this.onTap,
  });
  final Category category;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_CategoryRailTile> createState() => _CategoryRailTileState();
}

class _CategoryRailTileState extends State<_CategoryRailTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final c = widget.category;
    final bg = active
        ? WBColors.surfaceDark
        : _hovered
            ? WBColors.bgSecondary
            : WBColors.surfaceTag;
    final fg = active ? Colors.white : WBColors.fgHeader;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(WBRadius.card),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.12)
                      : WBColors.bgPrimary,
                  shape: BoxShape.circle,
                ),
                child: (c.svgAsset != null && c.svgAsset!.isNotEmpty)
                    ? SvgPicture.asset(
                        c.svgAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: WBSpacing.sm + 2),
              Expanded(
                child: Text(
                  context.categoryLabel(c.id, fallback: c.label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WBTypography.body.copyWith(
                    color: fg,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
