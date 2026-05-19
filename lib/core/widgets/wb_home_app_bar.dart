import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/role_controller.dart';
import '../../features/shopping/application/wb_images.dart';
import '../router/app_routes.dart';
import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';
import 'wb_network_image.dart';

/// The universal home top bar. Appears at the top of every role's home so
/// the navigation affordances are identical app-wide:
///   • avatar  → the current role's Account / Profile tab
///   • chat    → the chat inbox (anyone the user can message)
///   • bell    → notifications
///
/// `title` / `subtitle` are role-specific (e.g. "Hi, Brooks" + address, or
/// "Mama Cass Kitchen" + "Open"). `trailingExtra` lets the customer slot a
/// cart button in without every other role inheriting commerce chrome.
class WBHomeAppBar extends StatelessWidget {
  const WBHomeAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleIcon,
    this.notificationBadge = true,
    this.trailingExtra,
  });

  final String title;
  final String? subtitle;
  final WBIconName? subtitleIcon;
  final bool notificationBadge;
  final Widget? trailingExtra;

  void _openAccount(BuildContext context) {
    final route = RoleController.instance.role.accountRoute;
    if (route != null) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _openAccount(context),
          behavior: HitTestBehavior.opaque,
          child: ClipOval(
            child: SizedBox(
              width: 44,
              height: 44,
              child: WBNetworkImage(url: WBImages.avatar),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: WBTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: -0.17,
                ),
              ),
              if (subtitle != null)
                Row(
                  children: [
                    if (subtitleIcon != null) ...[
                      WBIcon(
                        subtitleIcon!,
                        size: 11,
                        color: WBColors.fgPlaceholder,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgPlaceholder,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Row(
          children: [
            WBHomeAppBarButton(
              icon: WBIconName.message,
              onTap: () => context.push(AppRoutes.chatInbox),
            ),
            const SizedBox(width: 8),
            WBHomeAppBarButton(
              icon: WBIconName.bell,
              badge: notificationBadge,
              onTap: () => context.push(AppRoutes.notifications),
            ),
            if (trailingExtra != null) ...[
              const SizedBox(width: 8),
              trailingExtra!,
            ],
          ],
        ),
      ],
    );
  }
}

/// Circular icon button used in [WBHomeAppBar]. Public so screens with a
/// custom top bar (e.g. the rider map overlay) can reuse the exact chrome.
class WBHomeAppBarButton extends StatelessWidget {
  const WBHomeAppBarButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final WBIconName icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: WBColors.surfaceCard,
              borderRadius: BorderRadius.circular(WBRadius.pill),
              border: Border.all(color: WBColors.bgDivider),
            ),
            alignment: Alignment.center,
            child: WBIcon(icon, size: 18, color: WBColors.fgHeader),
          ),
          if (badge)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: WBColors.statusError,
                  shape: BoxShape.circle,
                  border: Border.all(color: WBColors.bgPrimary, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
