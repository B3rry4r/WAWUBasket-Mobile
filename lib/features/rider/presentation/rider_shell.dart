import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Food-courier shell. Four tabs — Map, Active, Earnings, Account. Map is
/// the rider's home and surfaces nearby delivery offers (Mapbox wired in
/// batch B).
class RiderShell extends StatelessWidget {
  const RiderShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _items = [
    WBNavItem(
      id: AppRoutes.riderHome,
      icon: WBIconName.pin,
      label: 'Map',
    ),
    WBNavItem(
      id: AppRoutes.riderDelivery,
      icon: WBIconName.bike,
      label: 'Active',
    ),
    WBNavItem(
      id: AppRoutes.riderEarnings,
      icon: WBIconName.card,
      label: 'Earnings',
    ),
    WBNavItem(
      id: AppRoutes.riderAccount,
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
    return best ?? AppRoutes.riderHome;
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
