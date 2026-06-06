import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../widgets/kyc_widgets.dart';

/// Desktop-web layout for [RoleSelectScreen]. Same controllers, routes and
/// rider/driver web-gate logic as mobile — re-laid-out as a brand split panel
/// with the role list rendered as a 2-column grid on the right.
class RoleSelectDesktopScreen extends StatefulWidget {
  const RoleSelectDesktopScreen({super.key});

  @override
  State<RoleSelectDesktopScreen> createState() =>
      _RoleSelectDesktopScreenState();
}

class _RoleSelectDesktopScreenState extends State<RoleSelectDesktopScreen> {
  AppRole _selected = AppRole.customer;

  static const _roles = [
    _Role(AppRole.customer, WBIconName.basket,
        'Order food, groceries and household goods.'),
    _Role(AppRole.vendor, WBIconName.home,
        'Sell from your kitchen, store or stall.'),
    _Role(AppRole.trader, WBIconName.basket,
        'List bulk lots and reach buyers across corridors.'),
    _Role(AppRole.rider, WBIconName.bike,
        'Deliver baskets across your city.'),
    _Role(AppRole.driver, WBIconName.bike,
        'Move long-haul corridor loads.'),
    _Role(AppRole.agent, WBIconName.card,
        'Register traders. Log sales. Pay them out.'),
  ];

  String get _selectedTitle => _selected.title;

  String get _ctaLabel {
    if (_selected == AppRole.customer) return 'Continue as Customer';
    final status = RoleController.instance.statusOf(_selected);
    return switch (status) {
      RoleStatus.approved => 'Continue as $_selectedTitle',
      RoleStatus.pending => 'Awaiting review',
      RoleStatus.suspended => '$_selectedTitle suspended',
      RoleStatus.unregistered => 'Apply to be a $_selectedTitle',
    };
  }

  bool get _ctaDisabled =>
      _selected != AppRole.customer &&
      (RoleController.instance.statusOf(_selected) == RoleStatus.pending ||
          RoleController.instance.statusOf(_selected) == RoleStatus.suspended);

  Future<void> _commit() async {
    if (_selected == AppRole.customer) {
      RoleController.instance.setRole(AppRole.customer);
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboardingDone') ?? false;
      if (!mounted) return;
      context.go(onboardingDone ? AppRoutes.home : AppRoutes.onboarding);
      return;
    }
    // Rider and Driver are mobile-only — block them on Flutter web with
    // a "get the app" gate.
    if (kIsWeb &&
        (_selected == AppRole.rider || _selected == AppRole.driver)) {
      context.push(
        _selected == AppRole.rider
            ? AppRoutes.webUnavailableRider
            : AppRoutes.webUnavailableDriver,
      );
      return;
    }
    final status = RoleController.instance.statusOf(_selected);
    switch (status) {
      case RoleStatus.approved:
        RoleController.instance.setRole(_selected);
        context.go(_selected.homeRoute);
      case RoleStatus.pending:
        wbShowSnack(
          context,
          'Your $_selectedTitle application is under review.',
        );
      case RoleStatus.suspended:
        wbShowSnack(
          context,
          'Your $_selectedTitle role is suspended. Contact support to reinstate it.',
        );
      case RoleStatus.unregistered:
        final kyc = _selected.kycRoute;
        if (kyc != null) {
          // Refresh when KYC returns so the new "In review" status shows.
          context.push(kyc).then((_) {
            if (mounted) setState(() {});
          });
        }
    }
  }

  Future<void> _skip() async {
    RoleController.instance.setRole(AppRole.customer);
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboardingDone') ?? false;
    if (!mounted) return;
    context.go(onboardingDone ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showBrand = constraints.maxWidth >= 1100;
            return Row(
              children: [
                if (showBrand) const Expanded(child: _BrandPanel()),
                Expanded(
                  flex: showBrand ? 0 : 1,
                  child: SizedBox(
                    width: showBrand ? 640 : null,
                    child: _FormPanel(
                      roles: _roles,
                      selected: _selected,
                      onSelect: (role) => setState(() => _selected = role),
                      ctaLabel: _ctaLabel,
                      ctaDisabled: _ctaDisabled,
                      onCommit: _commit,
                      onSkip: _skip,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WBColors.surfaceDark,
      padding: const EdgeInsets.all(WBSpacing.xl),
      alignment: Alignment.center,
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxReading,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WBWMark(size: 40, color: Colors.white),
            const SizedBox(height: WBSpacing.lg),
            Text(
              context.l10n.roleSelectTitle,
              style: WBTypography.hero.copyWith(
                color: Colors.white,
                fontSize: 34,
                height: 1.15,
              ),
            ),
            const SizedBox(height: WBSpacing.sm + 2),
            Text(
              context.l10n.roleSelectSubtitle,
              style: WBTypography.body.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.roles,
    required this.selected,
    required this.onSelect,
    required this.ctaLabel,
    required this.ctaDisabled,
    required this.onCommit,
    required this.onSkip,
  });

  final List<_Role> roles;
  final AppRole selected;
  final ValueChanged<AppRole> onSelect;
  final String ctaLabel;
  final bool ctaDisabled;
  final Future<void> Function() onCommit;
  final Future<void> Function() onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WBSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: WBSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const WBBackChip(),
                // Skip is only useful for brand-new users exploring the
                // onboarding. Returning users already have a role.
                if (!RoleController.instance.hasEverSignedIn)
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      context.l10n.onboardingSkip,
                      style: WBTypography.secondary.copyWith(
                        color: WBColors.fgSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.roleSelectTitle,
                    style:
                        WBTypography.hero.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: WBSpacing.sm + 2),
                  Text(
                    context.l10n.roleSelectSubtitle,
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: roles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 108,
                    ),
                    itemBuilder: (context, i) {
                      final role = roles[i];
                      return _RoleCard(
                        role: role,
                        selected: role.id == selected,
                        onTap: () => onSelect(role.id),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: WBSpacing.lg),
            child: WBButton(
              label: ctaLabel,
              size: WBButtonSize.lg,
              fullWidth: true,
              trailingIcon: WBIconName.arrowRight,
              disabled: ctaDisabled,
              onPressed: ctaDisabled ? null : onCommit,
            ),
          ),
        ],
      ),
    );
  }
}

class _Role {
  const _Role(this.id, this.icon, this.description);
  final AppRole id;
  final WBIconName icon;
  final String description;

  String get title => id.title;
}

class _StatusFor extends StatelessWidget {
  const _StatusFor({required this.role, required this.onDark});
  final AppRole role;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final status = RoleController.instance.statusOf(role);
    if (onDark) {
      // On the dark selected card we draw a lighter pill so it stays
      // legible without introducing a new colour.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        child: Text(
          status.label,
          style: WBTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.2,
          ),
        ),
      );
    }
    return KycStatusChip(
      label: status.label,
      tone: switch (status) {
        RoleStatus.unregistered => KycStatusTone.unregistered,
        RoleStatus.pending => KycStatusTone.pending,
        RoleStatus.approved => KycStatusTone.approved,
        RoleStatus.suspended => KycStatusTone.suspended,
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final _Role role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(WBSpacing.md),
        decoration: BoxDecoration(
          color: selected ? WBColors.surfaceDark : WBColors.bgPrimary,
          border: Border.all(
            color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.12)
                        : WBColors.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: WBIcon(
                    role.icon,
                    size: 20,
                    color: selected ? Colors.white : WBColors.fgHeader,
                  ),
                ),
                const Spacer(),
                if (role.id != AppRole.customer)
                  _StatusFor(role: role.id, onDark: selected)
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: selected ? Colors.white : WBColors.bgDivider,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: selected
                        ? const WBIcon(
                            WBIconName.check,
                            size: 12,
                            color: WBColors.surfaceDark,
                            strokeWidth: 2.5,
                          )
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              role.title,
              style: WBTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                role.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: WBTypography.caption.copyWith(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.65)
                      : WBColors.fgSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
