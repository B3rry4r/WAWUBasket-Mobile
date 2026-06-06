import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import '../widgets/wb_logo.dart';
import 'wb_breakpoints.dart';

/// The persistent customer-facing header for the desktop web layout (the
/// "top bar + search" navigation pattern). It is the desktop replacement for
/// the floating bottom nav — the mobile build never renders it.
///
/// Generic by design: the customer shell supplies the concrete [search] field
/// and the [actions] (cart, notifications, account). Content is capped at
/// [WBBreakpoints.maxContent] so the bar lines up with the page column beneath.
class WBWebTopBar extends StatelessWidget implements PreferredSizeWidget {
  const WBWebTopBar({
    super.key,
    this.onLogoTap,
    this.search,
    this.actions = const [],
    this.height = 72,
  });

  final VoidCallback? onLogoTap;
  final Widget? search;
  final List<Widget> actions;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: WBColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: WBColors.bgDivider),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: WBBreakpoints.maxContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: WBSpacing.lg),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onLogoTap,
                    child: const WBWMark(size: 28),
                  ),
                ),
                const SizedBox(width: WBSpacing.xl),
                if (search != null)
                  Expanded(child: Center(child: search!))
                else
                  const Spacer(),
                const SizedBox(width: WBSpacing.xl),
                for (final action in actions) ...[
                  action,
                  const SizedBox(width: WBSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
