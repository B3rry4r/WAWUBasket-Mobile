import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/utils/wb_l10n.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Long-haul driver's shell. Four tabs, Loads · Trip · Earnings · Account.
/// Bidding on a single load is a pushed route from the Loads board.
class DriverShell extends StatelessWidget {
  const DriverShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  List<WBNavItem> _navItems(BuildContext context) {
    final l = context.l10n;
    return [
      WBNavItem(id: AppRoutes.driverHome, icon: WBIconName.basket, label: l.navLoads),
      WBNavItem(id: AppRoutes.driverActiveTrip, icon: WBIconName.bike, label: l.navTrip),
      WBNavItem(id: AppRoutes.driverEarnings, icon: WBIconName.card, label: l.navEarnings),
      WBNavItem(id: AppRoutes.driverServices, icon: WBIconName.services, label: l.navServices),
      WBNavItem(id: AppRoutes.driverAccount, icon: WBIconName.user, label: l.navAccount),
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
    return best ?? AppRoutes.driverHome;
  }

  @override
  Widget build(BuildContext context) {
    final items = _navItems(context);
    final activeId = _activeId(items);
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
