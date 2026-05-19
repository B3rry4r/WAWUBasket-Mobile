import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shopping/application/wb_images.dart';
import '../widgets/account_menu.dart';
import '../widgets/role_switcher_sheet.dart';

/// One Account tab, shared across every operator shell (vendor, agent,
/// rider — and later trader, driver). The visual language mirrors the
/// customer Profile screen: dark hero with avatar + name + 3 stat tiles,
/// then grouped menu sections (Account, Preferences, Switch role, Sign out).
///
/// What changes per role is just the hero name, the role badge, and the
/// three stat tiles. Everything else is identical so the user feels
/// continuity when switching between shells.
class OperatorAccountScreen extends StatelessWidget {
  const OperatorAccountScreen({super.key, required this.role});
  final AppRole role;

  _OperatorProfile get _profile => switch (role) {
        AppRole.vendor => const _OperatorProfile(
            name: 'Mama Cass Kitchen',
            handle: 'mamacass@wawu.africa',
            badge: 'Vendor · Restaurant',
            stat1: _Stat('Orders', '14'),
            stat2: _Stat('Earned', '₦68k'),
            stat3: _Stat('Rating', '★ 4.8'),
            payoutLabel: 'Payouts & invoices',
            payoutSub: 'Bank account, history, commission',
            payoutRoute: AppRoutes.vendorPayouts,
            settingsLabel: 'Store settings',
            settingsSub: 'Hours, prep time, staff, holiday mode',
            settingsRoute: AppRoutes.vendorSettings,
          ),
        AppRole.agent => const _OperatorProfile(
            name: 'Musa Ibrahim',
            handle: 'WAWU-AG-0142 · Mile 12 Market',
            badge: 'Trade Agent',
            stat1: _Stat('Today', '12 txns'),
            stat2: _Stat('Commission', '₦4,250'),
            stat3: _Stat('To sync', '3'),
            payoutLabel: 'Commission & payout',
            payoutSub: 'Access Bank · ••• 6789',
            payoutRoute: AppRoutes.agentCashPayout,
            settingsLabel: 'Sync centre',
            settingsSub: 'Pending uploads & conflicts',
            settingsRoute: AppRoutes.agentSync,
          ),
        AppRole.rider => const _OperatorProfile(
            name: 'Tunde Adeyemi',
            handle: 'WAWU-RD-0821 · Motorbike',
            badge: 'Rider',
            stat1: _Stat('Today', '6 trips'),
            stat2: _Stat('Earned', '₦4,800'),
            stat3: _Stat('Rating', '★ 4.9'),
            payoutLabel: 'Earnings & withdraw',
            payoutSub: 'Mobile money · ••• 2114',
            payoutRoute: AppRoutes.riderEarnings,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
        // Trader & driver are returned here for completeness — their shells
        // (and therefore this screen as the Account tab body) come online
        // in batches C and E.
        AppRole.trader => const _OperatorProfile(
            name: 'Hauwa & Sons Bulk Co.',
            handle: 'TRADER-0211 · Kano corridor',
            badge: 'Trader',
            stat1: _Stat('Listings', '8'),
            stat2: _Stat('Enquiries', '23'),
            stat3: _Stat('Earned', '₦2.1M'),
            payoutLabel: 'Escrow & settlements',
            payoutSub: 'Held funds, released funds',
            payoutRoute: AppRoutes.traderHome,
            settingsLabel: 'Transport requests',
            settingsSub: 'Loads posted for drivers',
            settingsRoute: AppRoutes.traderTransport,
          ),
        AppRole.driver => const _OperatorProfile(
            name: 'Aliyu Bala',
            handle: 'DR-0044 · NRTC Kano',
            badge: 'Driver',
            stat1: _Stat('Week', '3 trips'),
            stat2: _Stat('Earned', '₦120k'),
            stat3: _Stat('Rating', '★ 4.7'),
            payoutLabel: 'Earnings & withdraw',
            payoutSub: 'Mobile money · ••• 8090',
            payoutRoute: AppRoutes.driverEarnings,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
        AppRole.customer => const _OperatorProfile(
            name: 'Brooks Adesanya',
            handle: 'brooks@wawu.africa',
            badge: 'Customer',
            stat1: _Stat('Orders', '48'),
            stat2: _Stat('Wallet', '₦12.5k'),
            stat3: _Stat('Favorites', '12'),
            payoutLabel: 'Wallet & payment methods',
            payoutSub: 'Cards, bank, mobile money',
            payoutRoute: AppRoutes.wallet,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final sections = _buildSections(context, profile);

    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: [
        _Hero(profile: profile, role: role),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            0,
          ),
          child: Column(
            children: [
              for (final s in sections) ...[
                AccountMenuSectionCard(section: s),
                const SizedBox(height: WBSpacing.sm + 2),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<AccountMenuSection> _buildSections(
    BuildContext context,
    _OperatorProfile profile,
  ) {
    return [
      AccountMenuSection(
        title: 'Account',
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: profile.payoutLabel,
            sub: profile.payoutSub,
            onTap: () => context.push(profile.payoutRoute),
          ),
          AccountMenuRow(
            icon: WBIconName.user,
            label: 'Personal information',
            sub: 'Name, email, phone — verified ✓',
            onTap: () => context.push(AppRoutes.personalInfo),
          ),
          AccountMenuRow(
            icon: WBIconName.pin,
            label: 'Saved addresses',
            sub: 'Where deliveries pick up and drop off',
            onTap: () => context.push(AppRoutes.savedAddresses),
          ),
          AccountMenuRow(
            icon: WBIconName.bell,
            label: 'Notifications',
            sub: 'New orders, payouts, alerts',
            onTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      if (profile.settingsRoute != null)
        AccountMenuSection(
          title: 'Operations',
          rows: [
            AccountMenuRow(
              icon: WBIconName.more,
              label: profile.settingsLabel!,
              sub: profile.settingsSub,
              onTap: () => context.push(profile.settingsRoute!),
            ),
          ],
        ),
      AccountMenuSection(
        title: 'Preferences',
        rows: [
          AccountMenuRow(
            icon: WBIconName.message,
            label: 'Language',
            sub: 'English',
            onTap: () => context.push(AppRoutes.language),
          ),
          AccountMenuRow(
            icon: WBIconName.more,
            label: 'About WAWUBasket',
            sub: 'v2.1.0',
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
      AccountMenuSection(
        title: '',
        rows: [
          AccountMenuRow(
            icon: WBIconName.user,
            label: 'Switch role',
            sub: _switchSub(),
            onTap: () => RoleSwitcherSheet.show(context),
          ),
          AccountMenuRow(
            icon: WBIconName.phone,
            label: 'Help & support',
            sub: 'Chat to a real human',
            onTap: () => context.push(AppRoutes.support),
          ),
          AccountMenuRow(
            icon: WBIconName.close,
            label: 'Sign out',
            danger: true,
            onTap: () => _showSignOutSheet(context),
          ),
        ],
      ),
    ];
  }

  /// e.g. "Approved: Customer · Vendor · Rider" — gives a one-line picture
  /// of what shells the user can hop into.
  String _switchSub() {
    final approved = RoleController.instance.switchableRoles
        .map((r) => r.title)
        .toList();
    if (approved.length <= 1) {
      return 'Apply to be a vendor, trader, agent, rider or driver';
    }
    return 'Active: ${approved.join(' · ')}';
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.profile, required this.role});
  final _OperatorProfile profile;
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WBColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: WBColors.bgDivider),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        16 + MediaQuery.of(context).padding.top,
        WBSpacing.screenPadding,
        28,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    wbShowSnack(context, 'Choose a profile photo'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WBColors.bgDivider,
                          width: 2.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const WBNetworkImage(url: WBImages.avatar),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: WBColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WBColors.bgPrimary,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(
                          WBIconName.plus,
                          size: 11,
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: WBColors.fgHeader,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.handle,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: WBColors.bgSoft,
                        borderRadius: BorderRadius.circular(WBRadius.pill),
                      ),
                      child: Text(
                        profile.badge,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.personalInfo),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: WBColors.bgSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const WBIcon(
                    WBIconName.more,
                    size: 16,
                    color: WBColors.fgHeader,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg - 4),
          Container(
            padding: const EdgeInsets.only(top: 18),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: WBColors.bgDivider),
              ),
            ),
            child: Row(
              children: [
                _StatTile(stat: profile.stat1),
                _StatTile(stat: profile.stat2),
                _StatTile(stat: profile.stat3, last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, this.last = false});
  final _Stat stat;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: last
            ? null
            : const BoxDecoration(
                border: Border(
                  right: BorderSide(color: WBColors.bgDivider),
                ),
              ),
        child: Column(
          children: [
            Text(
              stat.value,
              style: WBTypography.body.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              stat.label,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgPlaceholder,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSignOutSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: WBColors.bgPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(ctx).padding.bottom + WBSpacing.xl,
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
            'Sign out?',
            style: WBTypography.page,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            "You'll need to sign in again to use this dashboard.",
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.xl),
          WBButton(
            label: 'Sign out',
            size: WBButtonSize.lg,
            fullWidth: true,
            onPressed: () {
              RoleController.instance.signOut();
              Navigator.of(ctx).pop();
              context.go(AppRoutes.welcome);
            },
          ),
          const SizedBox(height: WBSpacing.sm + 4),
          WBButton(
            label: 'Cancel',
            size: WBButtonSize.lg,
            fullWidth: true,
            variant: WBButtonVariant.secondary,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    ),
  );
}

class _OperatorProfile {
  const _OperatorProfile({
    required this.name,
    required this.handle,
    required this.badge,
    required this.stat1,
    required this.stat2,
    required this.stat3,
    required this.payoutLabel,
    required this.payoutSub,
    required this.payoutRoute,
    required this.settingsLabel,
    required this.settingsSub,
    required this.settingsRoute,
  });
  final String name;
  final String handle;
  final String badge;
  final _Stat stat1;
  final _Stat stat2;
  final _Stat stat3;
  final String payoutLabel;
  final String payoutSub;
  final String payoutRoute;
  final String? settingsLabel;
  final String? settingsSub;
  final String? settingsRoute;
}

class _Stat {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
}
