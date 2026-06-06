import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import '../widgets/wb_bottom_nav.dart' show WBNavItem;
import '../widgets/wb_icon.dart';
import '../widgets/wb_logo.dart';
import 'wb_breakpoints.dart';

/// The desktop operator dashboard side rail. It's the wide-screen counterpart
/// to [WBBottomNav] and consumes the exact same [WBNavItem] list each role's
/// shell already defines, so the two navigations can never drift apart.
///
/// Dark surface to match the app's nav vocabulary; the active item inflates
/// into a white pill with dark text (the bottom-nav's active treatment,
/// turned horizontal). [header] and [footer] are optional slots — roles use
/// them for a brand lock-up and an account/sign-out affordance.
class WBSideNav extends StatelessWidget {
  const WBSideNav({
    super.key,
    required this.items,
    required this.activeId,
    required this.onChanged,
    this.header,
    this.footer,
  });

  final List<WBNavItem> items;
  final String activeId;
  final ValueChanged<String> onChanged;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: WBBreakpoints.sideNavWidth,
      color: WBColors.surfaceDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: header ??
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: WBWMark(size: 26, color: Colors.white),
                  ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final item in items)
                    _SideNavSlot(
                      item: item,
                      active: item.id == activeId,
                      onTap: () => onChanged(item.id),
                    ),
                ],
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class _SideNavSlot extends StatefulWidget {
  const _SideNavSlot({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final WBNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SideNavSlot> createState() => _SideNavSlotState();
}

class _SideNavSlotState extends State<_SideNavSlot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final Color bg = active
        ? Colors.white
        : _hovered
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent;
    final Color fg =
        active ? WBColors.fgHeader : Colors.white.withValues(alpha: 0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: WBMotion.base,
            curve: WBMotion.easeSoft,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(WBRadius.button),
            ),
            child: Row(
              children: [
                WBIcon(widget.item.icon, size: 20, color: fg),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.body.copyWith(
                      color: fg,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
