import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/wb_responsive_exports.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/utils/wb_l10n.dart';
import '../../../core/widgets/wb_widgets.dart';
import '../../auth/application/role_controller.dart';
import '../../shell/presentation/desktop/operator_desktop_scaffold.dart';

/// Trader operator shell. Four tabs, Home · Listings · Prices · Account.
/// Transport (post-a-load for drivers) is a pushed route from Home, since
/// it's an occasional action rather than a daily tab.
class TraderShell extends StatelessWidget {
  const TraderShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  List<WBNavItem> _navItems(BuildContext context) {
    final l = context.l10n;
    return [
      WBNavItem(id: AppRoutes.traderHome, icon: WBIconName.home, label: l.navHome),
      WBNavItem(id: AppRoutes.traderListings, icon: WBIconName.basket, label: l.navListings),
      WBNavItem(id: AppRoutes.traderPrices, icon: WBIconName.card, label: l.navPrices),
      WBNavItem(id: AppRoutes.traderServices, icon: WBIconName.services, label: l.navServices),
      WBNavItem(id: AppRoutes.traderAccount, icon: WBIconName.user, label: l.navAccount),
    ];
  }

  String _activeId(List<WBNavItem> items) {
    String? best;
    for (final item in items) {
      if (location == item.id || location.startsWith('${item.id}/')) {
        if (best == null || item.id.length > best.length) {
          best = item.id;
        }
      }
    }
    return best ?? AppRoutes.traderHome;
  }

  @override
  Widget build(BuildContext context) {
    final items = _navItems(context);
    final activeId = _activeId(items);
    if (context.isDesktop) {
      return OperatorDesktopScaffold(
        role: AppRole.trader,
        location: location,
        child: child,
      );
    }
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      extendBody: true,
      body: child,
      bottomNavigationBar: WBBottomNav(
        items: items,
        activeId: activeId,
        onChanged: (id) {
          if (id != activeId) context.go(id);
        },
      ),
    );
  }
}
