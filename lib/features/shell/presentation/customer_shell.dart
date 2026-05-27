import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/utils/wb_l10n.dart';
import '../../../core/widgets/wb_widgets.dart';

/// The persistent shell wrapping the 4 customer tabs. The floating dark-pill
/// nav sits above the content so cards can scroll under it.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  List<WBNavItem> _navItems(BuildContext context) {
    final l = context.l10n;
    return [
      WBNavItem(id: AppRoutes.home, icon: WBIconName.home, label: l.navHome),
      WBNavItem(id: AppRoutes.favorites, icon: WBIconName.heart, label: l.navFavorites),
      WBNavItem(id: AppRoutes.orders, icon: WBIconName.basket, label: l.navOrders),
      WBNavItem(id: AppRoutes.profile, icon: WBIconName.user, label: l.navProfile),
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
    return best ?? AppRoutes.home;
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
