import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_bottom_nav.dart' show WBNavItem;
import '../../../../core/widgets/wb_icon.dart';
import '../../../auth/application/role_controller.dart';

/// The shared desktop-web dashboard chrome for the operator roles (vendor,
/// trader, agent): a persistent left [WBSideNav] beside the page content.
/// Desktop-only — the mobile build keeps its floating bottom nav and never
/// imports this.
///
/// Both the role shells (for their tab screens) AND each pushed operator
/// screen's desktop layout wrap their body in this, so the sidebar is
/// identical and persistent everywhere — defined once, from one nav source.
///
/// The active rail item is derived from the current GoRouter location, so
/// pushed detail screens (e.g. vendor order detail) light up the tab they
/// belong under without any extra wiring.
class OperatorDesktopScaffold extends StatelessWidget {
  const OperatorDesktopScaffold({
    super.key,
    required this.role,
    required this.child,
    this.location,
  });

  final AppRole role;
  final Widget child;

  /// Current route location. When null it's read from [GoRouterState], so
  /// callers usually omit it.
  final String? location;

  List<WBNavItem> _itemsFor(BuildContext context) {
    final l = context.l10n;
    switch (role) {
      case AppRole.vendor:
        return [
          WBNavItem(id: AppRoutes.vendorHome, icon: WBIconName.home, label: l.navHome),
          WBNavItem(id: AppRoutes.vendorOrders, icon: WBIconName.basket, label: l.navOrders),
          WBNavItem(id: AppRoutes.vendorMenu, icon: WBIconName.more, label: l.navMenu),
          WBNavItem(id: AppRoutes.vendorServices, icon: WBIconName.services, label: l.navServices),
          WBNavItem(id: AppRoutes.vendorAccount, icon: WBIconName.user, label: l.navAccount),
        ];
      case AppRole.trader:
        return [
          WBNavItem(id: AppRoutes.traderHome, icon: WBIconName.home, label: l.navHome),
          WBNavItem(id: AppRoutes.traderListings, icon: WBIconName.basket, label: l.navListings),
          WBNavItem(id: AppRoutes.traderPrices, icon: WBIconName.card, label: l.navPrices),
          WBNavItem(id: AppRoutes.traderServices, icon: WBIconName.services, label: l.navServices),
          WBNavItem(id: AppRoutes.traderAccount, icon: WBIconName.user, label: l.navAccount),
        ];
      case AppRole.agent:
        return [
          WBNavItem(id: AppRoutes.agentHome, icon: WBIconName.home, label: l.navHome),
          WBNavItem(id: AppRoutes.agentRecordTxn, icon: WBIconName.basket, label: l.navRecord),
          WBNavItem(id: AppRoutes.agentCashPayout, icon: WBIconName.card, label: l.navPayout),
          WBNavItem(id: AppRoutes.agentServices, icon: WBIconName.services, label: l.navServices),
          WBNavItem(id: AppRoutes.agentAccount, icon: WBIconName.user, label: l.navAccount),
        ];
      default:
        return const [];
    }
  }

  /// Longest-prefix match — `/vendor` is a prefix of `/vendor/orders`, so the
  /// longest matching id wins; pushed routes resolve to their parent tab.
  String _activeId(List<WBNavItem> items, String loc, String fallback) {
    String? best;
    for (final item in items) {
      if (loc == item.id || loc.startsWith('${item.id}/')) {
        if (best == null || item.id.length > best.length) best = item.id;
      }
    }
    return best ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(context);
    final loc = location ?? GoRouterState.of(context).uri.toString();
    final activeId = _activeId(items, loc, items.isNotEmpty ? items.first.id : '');
    return WBDashboardShell(
      items: items,
      activeId: activeId,
      onChanged: (id) {
        if (id != activeId) context.go(id);
      },
      child: child,
    );
  }
}
