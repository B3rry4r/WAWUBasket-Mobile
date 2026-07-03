import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_home_app_bar.dart';
import '../../../../core/widgets/wb_icon.dart';
import '../../../account/application/notifications_controller.dart';
import '../../../account/application/profile_controller.dart';
import '../../../shopping/application/cart_controller.dart';

/// The shared desktop-web chrome for every customer-facing surface: a
/// persistent top bar (logo · search · nav links · cart · notifications ·
/// account) above the page [child]. Desktop-only — the mobile build keeps its
/// floating bottom nav and never imports this.
///
/// Used by [CustomerShell] for the four tab screens *and* by each pushed
/// browse screen's desktop layout, so the header is identical everywhere and
/// defined in exactly one place.
class CustomerWebScaffold extends ConsumerWidget {
  const CustomerWebScaffold({
    super.key,
    required this.child,
    this.activeNavId,
    this.showSearch = true,
  });

  final Widget child;

  /// Route id of the active top-level destination (e.g. [AppRoutes.home]) so
  /// the matching nav link renders active. Null on pushed screens that aren't
  /// one of the four tabs.
  final String? activeNavId;

  final bool showSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cartCount = ref.watch(
      cartControllerProvider.select(
        (s) => s.items.fold(0, (n, l) => n + l.quantity),
      ),
    );

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: Column(
        children: [
          WBWebTopBar(
            onLogoTap: () => context.go(AppRoutes.home),
            search: showSearch ? const _DesktopSearchBar() : null,
            actions: [
              _NavLink(
                label: l.navHome,
                routeId: AppRoutes.home,
                active: activeNavId == AppRoutes.home,
              ),
              _NavLink(
                label: l.navServices,
                routeId: AppRoutes.services,
                active: activeNavId == AppRoutes.services,
              ),
              _NavLink(
                label: l.navFavorites,
                routeId: AppRoutes.favorites,
                active: activeNavId == AppRoutes.favorites,
              ),
              _NavLink(
                label: l.navOrders,
                routeId: AppRoutes.orders,
                active: activeNavId == AppRoutes.orders,
              ),
              const SizedBox(width: WBSpacing.xs),
              WBHomeAppBarButton(
                icon: WBIconName.basket,
                badgeCount: cartCount,
                onTap: () {
                  if (GuestModeController.instance
                      .requireAccount(context, action: 'view your basket')) {
                    context.push(AppRoutes.cart);
                  }
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: NotificationsController.instance.unreadCount,
                builder: (_, count, _) => WBHomeAppBarButton(
                  icon: WBIconName.bell,
                  badgeCount: count,
                  onTap: () => context.push(AppRoutes.notifications),
                ),
              ),
              _AccountAvatar(active: activeNavId == AppRoutes.profile),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// A top-bar text destination. Active state shows a filled-weight label with a
/// short underline; hover lifts the color.
class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.routeId,
    required this.active,
  });
  final String label;
  final String routeId;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final color = active || _hovered ? WBColors.fgHeader : WBColors.fgSecondary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(widget.routeId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: WBTypography.body.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: WBMotion.base,
                curve: WBMotion.easeSoft,
                height: 2,
                width: active ? 18 : 0,
                decoration: BoxDecoration(
                  color: WBColors.fgHeader,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact search affordance in the top bar. Tapping routes to the full search
/// screen (same destination the mobile home search bar uses).
class _DesktopSearchBar extends StatelessWidget {
  const _DesktopSearchBar();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(AppRoutes.search),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: WBSpacing.md),
            decoration: BoxDecoration(
              color: WBColors.surfaceInput,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: Row(
              children: [
                const WBIcon(
                  WBIconName.search,
                  size: 18,
                  color: WBColors.fgPlaceholder,
                ),
                const SizedBox(width: WBSpacing.sm),
                Text(
                  context.l10n.homeSearchPlaceholder,
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgPlaceholder,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(AppRoutes.profile),
        child: Padding(
          padding: const EdgeInsets.only(left: WBSpacing.xs),
          child: ValueListenableBuilder(
            valueListenable: ProfileController.instance.profile,
            builder: (_, profile, _) {
              final initials = _initialsOf(profile?.fullName ?? '');
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: WBColors.fgHeader, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: WBColors.fgHeader,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
