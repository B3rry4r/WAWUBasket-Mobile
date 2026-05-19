import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/wb_theme_exports.dart';
import '../../../core/widgets/wb_widgets.dart';

/// Trade-agent shell. Four tabs — Home, Record sale, Cash payout, Account.
/// Register-trader is reached as a pushed route from Home's quick action
/// row; it's a once-per-trader flow, not a daily tab.
class AgentShell extends StatelessWidget {
  const AgentShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _items = [
    WBNavItem(
      id: AppRoutes.agentHome,
      icon: WBIconName.home,
      label: 'Home',
    ),
    WBNavItem(
      id: AppRoutes.agentRecordTxn,
      icon: WBIconName.basket,
      label: 'Record',
    ),
    WBNavItem(
      id: AppRoutes.agentCashPayout,
      icon: WBIconName.card,
      label: 'Payout',
    ),
    WBNavItem(
      id: AppRoutes.agentAccount,
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
    return best ?? AppRoutes.agentHome;
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
