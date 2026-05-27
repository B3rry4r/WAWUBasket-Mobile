import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/utils/wb_l10n.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Food-courier shell. Four tabs, Map, Active, Earnings, Account. Map is
/// the rider's home and surfaces nearby delivery offers (Mapbox wired in
/// batch B).
class RiderShell extends StatelessWidget {
  const RiderShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  List<WBNavItem> _navItems(BuildContext context) {
    final l = context.l10n;
    return [
      WBNavItem(id: AppRoutes.riderHome, icon: WBIconName.pin, label: l.navMap),
      WBNavItem(id: AppRoutes.riderDelivery, icon: WBIconName.bike, label: l.navActive),
      WBNavItem(id: AppRoutes.riderEarnings, icon: WBIconName.card, label: l.navEarnings),
      WBNavItem(id: AppRoutes.riderAccount, icon: WBIconName.user, label: l.navAccount),
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
    return best ?? AppRoutes.riderHome;
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
