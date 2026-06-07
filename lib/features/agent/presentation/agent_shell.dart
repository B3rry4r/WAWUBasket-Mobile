import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/wb_responsive_exports.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/utils/wb_l10n.dart';
import '../../../core/widgets/wb_widgets.dart';
import '../../auth/application/role_controller.dart';
import '../../shell/presentation/desktop/operator_desktop_scaffold.dart';

/// Trade-agent shell. Four tabs, Home, Record sale, Cash payout, Account.
/// Register-trader is reached as a pushed route from Home's quick action
/// row; it's a once-per-trader flow, not a daily tab.
class AgentShell extends StatelessWidget {
  const AgentShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  List<WBNavItem> _navItems(BuildContext context) {
    final l = context.l10n;
    return [
      WBNavItem(id: AppRoutes.agentHome, icon: WBIconName.home, label: l.navHome),
      WBNavItem(id: AppRoutes.agentRecordTxn, icon: WBIconName.basket, label: l.navRecord),
      WBNavItem(id: AppRoutes.agentCashPayout, icon: WBIconName.card, label: l.navPayout),
      WBNavItem(id: AppRoutes.agentServices, icon: WBIconName.services, label: l.navServices),
      WBNavItem(id: AppRoutes.agentAccount, icon: WBIconName.user, label: l.navAccount),
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
    return best ?? AppRoutes.agentHome;
  }

  @override
  Widget build(BuildContext context) {
    final items = _navItems(context);
    final activeId = _activeId(items);
    if (context.isDesktop) {
      return OperatorDesktopScaffold(
        role: AppRole.agent,
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
