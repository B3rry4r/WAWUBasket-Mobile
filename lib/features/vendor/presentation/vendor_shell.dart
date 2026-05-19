import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Vendor's persistent shell. Four tabs — Home, Orders, Menu, Account —
/// match the customer flow's tab count so the navbar stays comfortable.
/// Earnings, Inventory, Reviews and Settings live as pushed routes reached
/// from Home's quick actions and the Account tab.
class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _items = [
    WBNavItem(
      id: AppRoutes.vendorHome,
      icon: WBIconName.home,
      label: 'Home',
    ),
    WBNavItem(
      id: AppRoutes.vendorOrders,
      icon: WBIconName.basket,
      label: 'Orders',
    ),
    WBNavItem(
      id: AppRoutes.vendorMenu,
      icon: WBIconName.more,
      label: 'Menu',
    ),
    WBNavItem(
      id: AppRoutes.vendorAccount,
      icon: WBIconName.user,
      label: 'Account',
    ),
  ];

  String get _activeId {
    // Longest-prefix match — `/vendor` is a prefix of `/vendor/orders` etc.
    // so we have to pick the longest matching item id, not the first.
    String? best;
    for (final item in _items) {
      if (location == item.id || location.startsWith('${item.id}/')) {
        if (best == null || item.id.length > best.length) {
          best = item.id;
        }
      }
    }
    return best ?? AppRoutes.vendorHome;
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
