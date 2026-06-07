import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/wb_responsive_exports.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/utils/wb_l10n.dart';
import '../../../core/widgets/wb_widgets.dart';
import '../../auth/application/role_controller.dart';
import '../../shell/presentation/desktop/operator_desktop_scaffold.dart';

/// Vendor's persistent shell. Four tabs, Home, Orders, Menu, Account —
/// match the customer flow's tab count so the navbar stays comfortable.
/// Earnings, Inventory, Reviews and Settings live as pushed routes reached
/// from Home's quick actions and the Account tab.
class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  List<WBNavItem> _navItems(BuildContext context) {
    final l = context.l10n;
    return [
      WBNavItem(id: AppRoutes.vendorHome, icon: WBIconName.home, label: l.navHome),
      WBNavItem(id: AppRoutes.vendorOrders, icon: WBIconName.basket, label: l.navOrders),
      WBNavItem(id: AppRoutes.vendorMenu, icon: WBIconName.more, label: l.navMenu),
      WBNavItem(id: AppRoutes.vendorServices, icon: WBIconName.services, label: l.navServices),
      WBNavItem(id: AppRoutes.vendorAccount, icon: WBIconName.user, label: l.navAccount),
    ];
  }

  String _activeId(List<WBNavItem> items) {
    // Longest-prefix match, `/vendor` is a prefix of `/vendor/orders` etc.
    // so we have to pick the longest matching item id, not the first.
    String? best;
    for (final item in items) {
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
    final items = _navItems(context);
    final activeId = _activeId(items);
    if (context.isDesktop) {
      return OperatorDesktopScaffold(
        role: AppRole.vendor,
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
