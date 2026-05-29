import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/notifications_controller.dart';
import '../../features/account/application/profile_controller.dart';
import '../../features/auth/application/role_controller.dart';
import '../../core/services/guest_mode.dart';
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
    this.showChat = true,
    this.trailingExtra,
  });

  /// Whether to surface the chat button. The customer home sets this
  /// false because chat already lives in its quick-actions row; every
  /// operator home keeps it (their only entry point to chat).
  final bool showChat;

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
          child: ValueListenableBuilder(
            valueListenable: GuestModeController.instance.isGuest,
            builder: (_, isGuest, _) {
              if (isGuest) {
                return ClipOval(
                  child: Container(
                    width: 44,
                    height: 44,
                    color: WBColors.bgSoft,
                    alignment: Alignment.center,
                    child: const WBIcon(WBIconName.user, size: 20, color: WBColors.fgHeader),
                  ),
                );
              }
              return ValueListenableBuilder(
                valueListenable: ProfileController.instance.profile,
                builder: (_, profile, _) {
                  final avatarUrl = profile?.avatarUrl;
                  return ClipOval(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: avatarUrl != null
                          ? WBNetworkImage(url: avatarUrl)
                          : _AvatarInitials(name: profile?.fullName ?? ''),
                    ),
                  );
                },
              );
            },
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
            if (showChat) ...[
              WBHomeAppBarButton(
                icon: WBIconName.message,
                onTap: () => context.push(AppRoutes.chatInbox),
              ),
              const SizedBox(width: 8),
            ],
            ValueListenableBuilder<int>(
              valueListenable: NotificationsController.instance.unreadCount,
              builder: (_, count, _) => WBHomeAppBarButton(
                icon: WBIconName.bell,
                badgeCount: notificationBadge ? count : 0,
                onTap: () => context.push(AppRoutes.notifications),
              ),
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

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : parts.isNotEmpty && parts.first.isNotEmpty
            ? parts.first[0].toUpperCase()
            : '?';
    return Container(
      color: WBColors.bgSoft,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: WBTypography.body.copyWith(
          fontWeight: FontWeight.w700,
          color: WBColors.fgHeader,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// Circular icon button used in [WBHomeAppBar]. Public so screens with a
/// custom top bar (e.g. the rider map overlay) can reuse the exact chrome.
///
/// Pass [badgeCount] > 0 to show a numbered pill. Values > 9 render "9+".
class WBHomeAppBarButton extends StatelessWidget {
  const WBHomeAppBarButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
    this.badgeCount = 0,
  });

  final WBIconName icon;
  final VoidCallback onTap;
  /// Deprecated dot-only badge. Prefer [badgeCount].
  final bool badge;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount > 0 || badge;
    final label = badgeCount > 9 ? '9+' : badgeCount > 0 ? '$badgeCount' : '';
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
          if (showBadge)
            Positioned(
              right: label.isEmpty ? 10 : 4,
              top: label.isEmpty ? 10 : 4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16),
                height: label.isEmpty ? 8 : 16,
                padding: label.isEmpty
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: WBColors.surfaceDark,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                  border: Border.all(color: WBColors.bgPrimary, width: 1.5),
                ),
                alignment: Alignment.center,
                child: label.isEmpty
                    ? null
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
