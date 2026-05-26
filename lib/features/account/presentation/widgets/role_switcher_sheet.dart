import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/auth_api.dart';

/// In-place role switcher. Lists every role the user could be in with its
/// current KYC status, then routes accordingly when one is tapped:
/// approved → switch shell, unregistered → start KYC, pending → snack.
///
/// Trader and driver rows render with a "Coming soon" pill (and no tap
/// action) until batches C and E wire their shells.
class RoleSwitcherSheet extends StatelessWidget {
  const RoleSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WBRadius.sheet),
        ),
      ),
      builder: (_) => const RoleSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = RoleController.instance.role;
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + WBSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          Text(
            'Switch role',
            style: WBTypography.page,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            "Approved roles let you jump in. Tap an unverified one to start verification.",
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          for (final r in AppRole.values.where((r) =>
              r != AppRole.admin ||
              RoleController.instance.statusOf(AppRole.admin) ==
                  RoleStatus.approved)) ...[
            _RoleRow(
              role: r,
              isActive: r == active,
              onTap: () => _handleTap(context, r),
            ),
            if (r != AppRole.values.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, AppRole role) {
    final ctrl = RoleController.instance;
    if (role == ctrl.role) {
      Navigator.of(context).pop();
      return;
    }

    if (role == AppRole.customer) {
      _switchTo(context, AppRole.customer);
      return;
    }

    // Rider and Driver shells need native GPS / push and are mobile-only.
    // From the Flutter web build we redirect to a "get the app" screen
    // instead of dropping the user into a broken shell.
    if (kIsWeb && (role == AppRole.rider || role == AppRole.driver)) {
      Navigator.of(context).pop();
      context.push(
        role == AppRole.rider
            ? AppRoutes.webUnavailableRider
            : AppRoutes.webUnavailableDriver,
      );
      return;
    }

    final status = ctrl.statusOf(role);
    switch (status) {
      case RoleStatus.approved:
        _switchTo(context, role);
      case RoleStatus.pending:
        wbShowSnack(
          context,
          'Your ${role.title} application is under review.',
        );
      case RoleStatus.unregistered:
        final kyc = role.kycRoute;
        Navigator.of(context).pop();
        if (kyc != null) context.push(kyc);
    }
  }

  /// Mints a fresh token carrying the new `activeRole`, then routes into
  /// that role's shell. A failed switch leaves the user where they were.
  Future<void> _switchTo(BuildContext context, AppRole role) async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    try {
      await AuthApi.instance.switchRole(role.name);
    } on ApiException catch (e) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    RoleController.instance.setRole(role);
    router.go(role.homeRoute);
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.role,
    required this.isActive,
    required this.onTap,
  });
  final AppRole role;
  final bool isActive;
  final VoidCallback onTap;

  WBIconName get _icon => switch (role) {
        AppRole.customer => WBIconName.basket,
        AppRole.vendor => WBIconName.home,
        AppRole.trader => WBIconName.basket,
        AppRole.agent => WBIconName.card,
        AppRole.rider => WBIconName.bike,
        AppRole.driver => WBIconName.bike,
        AppRole.admin => WBIconName.filter,
      };

  ({String label, _PillTone tone}) _pill(AppRole r) {
    if (r == AppRole.customer) {
      return (label: 'Always on', tone: _PillTone.success);
    }
    final status = RoleController.instance.statusOf(r);
    return switch (status) {
      RoleStatus.approved => (label: 'Approved', tone: _PillTone.success),
      RoleStatus.pending => (label: 'In review', tone: _PillTone.warning),
      RoleStatus.unregistered => (
          label: 'Get verified',
          tone: _PillTone.muted,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final pill = _pill(role);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(WBSpacing.md - 2),
        decoration: BoxDecoration(
          color: isActive ? WBColors.surfaceDark : WBColors.bgPrimary,
          border: Border.all(
            color: isActive ? WBColors.surfaceDark : WBColors.bgDivider,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.12)
                    : WBColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                _icon,
                size: 18,
                color: isActive ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: WBSpacing.md - 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          role.title,
                          style: WBTypography.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : WBColors.fgHeader,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius:
                                BorderRadius.circular(WBRadius.pill),
                          ),
                          child: Text(
                            'Active',
                            style: WBTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 0.4,
                            ),
                          ),
                        )
                      else
                        _Pill(label: pill.label, tone: pill.tone),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.tagline,
                    style: WBTypography.caption.copyWith(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.65)
                          : WBColors.fgSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PillTone { success, warning, muted }

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone});
  final String label;
  final _PillTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _PillTone.success => (const Color(0x1410B981), const Color(0xFF047857)),
      _PillTone.warning => (const Color(0x14F59E0B), const Color(0xFFB45309)),
      _PillTone.muted => (WBColors.bgSoft, WBColors.fgSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Text(
        label,
        style: WBTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
