import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/role_controller.dart';
import '../widgets/kyc_widgets.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
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
      RoleStatus.unregistered => 'Apply to be a $_selectedTitle',
    };
  }

  bool get _ctaDisabled =>
      _selected != AppRole.customer &&
      RoleController.instance.statusOf(_selected) == RoleStatus.pending;

  void _commit() {
    if (_selected == AppRole.customer) {
      RoleController.instance.setRole(AppRole.customer);
      context.go(AppRoutes.onboarding);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const WBBackChip(),
                  TextButton(
                    onPressed: () {
                      RoleController.instance.setRole(AppRole.customer);
                      context.go(AppRoutes.onboarding);
                    },
                    child: Text(
                      'Skip',
                      style: WBTypography.secondary.copyWith(
                        color: WBColors.fgSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  WBSpacing.lg,
                  WBSpacing.screenPadding,
                  WBSpacing.lg,
                ),
                children: [
                  Text(
                    'How will you use\nWAWUBasket?',
                    style: WBTypography.hero
                        .copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: WBSpacing.sm + 2),
                  Text(
                    "Pick what you'll do most. You can switch roles anytime from your profile.",
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  for (final role in _roles) ...[
                    _RoleCard(
                      role: role,
                      selected: role.id == _selected,
                      onTap: () => setState(() => _selected = role.id),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                0,
                WBSpacing.screenPadding,
                WBSpacing.lg,
              ),
              child: WBButton(
                label: _ctaLabel,
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                disabled: _ctaDisabled,
                onPressed: _ctaDisabled ? null : _commit,
              ),
            ),
          ],
        ),
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
        child: Row(
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
                            color:
                                selected ? Colors.white : WBColors.fgHeader,
                          ),
                        ),
                      ),
                      if (role.id != AppRole.customer)
                        _StatusFor(role: role.id, onDark: selected),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.description,
                    style: WBTypography.caption.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.65)
                          : WBColors.fgSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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
      ),
    );
  }
}
