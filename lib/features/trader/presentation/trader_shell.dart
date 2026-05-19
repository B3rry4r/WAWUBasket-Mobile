import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Trader operator shell. Four tabs — Home · Listings · Prices · Account.
/// Transport (post-a-load for drivers) is a pushed route from Home, since
/// it's an occasional action rather than a daily tab.
class TraderShell extends StatelessWidget {
  const TraderShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _items = [
    WBNavItem(
      id: AppRoutes.traderHome,
      icon: WBIconName.home,
      label: 'Home',
    ),
    WBNavItem(
      id: AppRoutes.traderListings,
      icon: WBIconName.basket,
      label: 'Listings',
    ),
    WBNavItem(
      id: AppRoutes.traderPrices,
      icon: WBIconName.card,
      label: 'Prices',
    ),
    WBNavItem(
      id: AppRoutes.traderAccount,
      icon: WBIconName.user,
      label: 'Account',
    ),
  ];

  String get _activeId {
    String? best;
    for (final item in _items) {
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
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      extendBody: true,
      body: child,
      bottomNavigationBar: WBBottomNav(
        items: _items,
        activeId: _activeId,
        onChanged: (id) {
          if (id != _activeId) context.go(id);
        },
      ),
    );
  }
}
