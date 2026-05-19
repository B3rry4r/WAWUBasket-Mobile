import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Long-haul driver's shell. Four tabs — Loads · Trip · Earnings · Account.
/// Bidding on a single load is a pushed route from the Loads board.
class DriverShell extends StatelessWidget {
  const DriverShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _items = [
    WBNavItem(
      id: AppRoutes.driverHome,
      icon: WBIconName.basket,
      label: 'Loads',
    ),
    WBNavItem(
      id: AppRoutes.driverActiveTrip,
      icon: WBIconName.bike,
      label: 'Trip',
    ),
    WBNavItem(
      id: AppRoutes.driverEarnings,
      icon: WBIconName.card,
      label: 'Earnings',
    ),
    WBNavItem(
      id: AppRoutes.driverAccount,
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
    return best ?? AppRoutes.driverHome;
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
