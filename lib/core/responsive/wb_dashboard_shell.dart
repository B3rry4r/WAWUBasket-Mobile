import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import '../widgets/wb_bottom_nav.dart';
import 'wb_responsive.dart';
import 'wb_side_nav.dart';

/// The adaptive shell every *operator* role (vendor, trader, agent) renders.
///
///   • Mobile / tablet  → the existing floating [WBBottomNav] over the content
///     (pixel-identical to today — the role shells keep their current look).
///   • Desktop (web ≥1024) → a persistent [WBSideNav] rail beside the content.
///
/// Roles pass the same [items] / [activeId] / [onChanged] they already build
/// for the bottom nav, so adopting this is a one-line swap in each shell with
/// zero change to the mobile experience. Because the branch keys off
/// [WBResponsive.isDesktop], it rebuilds live as the window is resized.
class WBDashboardShell extends StatelessWidget {
  const WBDashboardShell({
    super.key,
    required this.items,
    required this.activeId,
    required this.onChanged,
    required this.child,
    this.sideNavHeader,
    this.sideNavFooter,
  });

  final List<WBNavItem> items;
  final String activeId;
  final ValueChanged<String> onChanged;
  final Widget child;
  final Widget? sideNavHeader;
  final Widget? sideNavFooter;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: WBColors.bgSecondary,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WBSideNav(
              items: items,
              activeId: activeId,
              onChanged: onChanged,
              header: sideNavHeader,
              footer: sideNavFooter,
            ),
            Expanded(
              child: ColoredBox(
                color: WBColors.bgPrimary,
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / tablet — unchanged floating bottom nav.
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      extendBody: true,
      body: child,
      bottomNavigationBar: WBBottomNav(
        items: items,
        activeId: activeId,
        onChanged: onChanged,
      ),
    );
  }
}
