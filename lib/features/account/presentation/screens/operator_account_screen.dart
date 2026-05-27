import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../application/profile_controller.dart';
import '../widgets/account_menu.dart';
import '../widgets/role_switcher_sheet.dart';

/// One Account tab, shared across every operator shell (vendor, agent,
/// rider, and later trader, driver). The visual language mirrors the
/// customer Profile screen: dark hero with avatar + name + 3 stat tiles,
/// then grouped menu sections (Account, Preferences, Switch role, Sign out).
///
/// What changes per role is just the hero name, the role badge, and the
/// three stat tiles. Everything else is identical so the user feels
/// continuity when switching between shells.
class OperatorAccountScreen extends StatefulWidget {
  const OperatorAccountScreen({super.key, required this.role});
  final AppRole role;

  @override
  State<OperatorAccountScreen> createState() => _OperatorAccountScreenState();
}

class _OperatorAccountScreenState extends State<OperatorAccountScreen> {
  @override
  void initState() {
    super.initState();
    ProfileController.instance.load();
    ProfileController.instance.loadStats();
  }

  /// Fixed (non-data-driven) fields that don't change with profile data.
  _RoleConfig get _config => switch (widget.role) {
        AppRole.vendor => const _RoleConfig(
            badge: 'Vendor · Restaurant',
            payoutLabel: 'Payouts & invoices',
            payoutSub: 'Bank account, history, commission',
            payoutRoute: AppRoutes.vendorPayouts,
            settingsLabel: 'Store settings',
            settingsSub: 'Hours, prep time, staff, holiday mode',
            settingsRoute: AppRoutes.vendorSettings,
          ),
        AppRole.agent => const _RoleConfig(
            badge: 'Trade Agent',
            payoutLabel: 'Commission & payout',
            payoutSub: 'Earnings & bank account',
            payoutRoute: AppRoutes.agentCashPayout,
            settingsLabel: 'Sync centre',
            settingsSub: 'Pending uploads & conflicts',
            settingsRoute: AppRoutes.agentSync,
          ),
        AppRole.rider => const _RoleConfig(
            badge: 'Rider',
            payoutLabel: 'Earnings',
            payoutSub: 'Trip earnings & payout history',
            payoutRoute: AppRoutes.riderEarnings,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
        AppRole.trader => const _RoleConfig(
            badge: 'Trader',
            payoutLabel: 'Escrow & settlements',
            payoutSub: 'Held funds, released funds',
            payoutRoute: AppRoutes.traderHome,
            settingsLabel: 'Transport requests',
            settingsSub: 'Loads posted for drivers',
            settingsRoute: AppRoutes.traderTransport,
          ),
        AppRole.driver => const _RoleConfig(
            badge: 'Driver',
            payoutLabel: 'Earnings',
            payoutSub: 'Trip earnings & payout history',
            payoutRoute: AppRoutes.driverEarnings,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
        AppRole.customer => const _RoleConfig(
            badge: 'Customer',
            payoutLabel: 'Wallet & payment methods',
            payoutSub: 'Cards, bank, mobile money',
            payoutRoute: AppRoutes.wallet,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
        AppRole.admin => const _RoleConfig(
            badge: 'Dev',
            payoutLabel: 'Dev Settings',
            payoutSub: 'Feature flags & platform controls',
            payoutRoute: AppRoutes.devSettings,
            settingsLabel: null,
            settingsSub: null,
            settingsRoute: null,
          ),
      };

  /// Resolve the display name from the loaded profile (role-specific business
  /// / display name where available, falling back to fullName, then a generic
  /// placeholder while loading).
  String _resolveName(UserProfile? profile) {
    if (profile == null) return '—';
    return switch (widget.role) {
      AppRole.vendor =>
        profile.vendorBusinessName?.isNotEmpty == true
            ? profile.vendorBusinessName!
            : profile.fullName.isNotEmpty
                ? profile.fullName
                : '—',
      AppRole.trader =>
        profile.traderBusinessName?.isNotEmpty == true
            ? profile.traderBusinessName!
            : profile.fullName.isNotEmpty
                ? profile.fullName
                : '—',
      AppRole.agent =>
        profile.agentDisplayName?.isNotEmpty == true
            ? profile.agentDisplayName!
            : profile.fullName.isNotEmpty
                ? profile.fullName
                : '—',
      AppRole.rider =>
        profile.riderDisplayName?.isNotEmpty == true
            ? profile.riderDisplayName!
            : profile.fullName.isNotEmpty
                ? profile.fullName
                : '—',
      AppRole.driver =>
        profile.driverDisplayName?.isNotEmpty == true
            ? profile.driverDisplayName!
            : profile.fullName.isNotEmpty
                ? profile.fullName
                : '—',
      _ => profile.fullName.isNotEmpty ? profile.fullName : '—',
    };
  }

  /// The sub-handle line beneath the name (agent region, rider vehicle type,
  /// email for vendor/trader/customer, etc.).
  String _resolveHandle(UserProfile? profile) {
    if (profile == null) return '—';
    return switch (widget.role) {
      AppRole.agent =>
        profile.agentRegionName?.isNotEmpty == true
            ? profile.agentRegionName!
            : profile.email.isNotEmpty
                ? profile.email
                : '—',
      AppRole.driver =>
        profile.driverPlateNumber?.isNotEmpty == true
            ? profile.driverPlateNumber!
            : profile.email.isNotEmpty
                ? profile.email
                : '—',
      _ =>
        profile.email.isNotEmpty
            ? profile.email
            : profile.phone.isNotEmpty
                ? profile.phone
                : '—',
    };
  }

  /// Build the three stat tiles from API stats. Falls back to '–' when stats
  /// haven't loaded yet or the field is absent for the active role.
  List<_Stat> _resolveStats(ProfileStats? s) {
    String dash = '–';
    return switch (widget.role) {
      AppRole.vendor => [
          _Stat('Orders', s?.orders != null ? '${s!.orders}' : dash),
          _Stat('Earned', s?.vendorEarnedNaira != null
              ? _nairaK(int.tryParse(s!.vendorEarnedNaira!) ?? 0)
              : dash),
          _Stat('Rating', s?.vendorRating != null
              ? '★ ${s!.vendorRating}'
              : dash),
        ],
      AppRole.agent => [
          _Stat('Today', s?.agentTodayTransactions != null
              ? '${s!.agentTodayTransactions} txns'
              : dash),
          _Stat('Commission', s?.agentTodayCommissionNaira != null
              ? _nairaK(s!.agentTodayCommissionNaira!)
              : dash),
          _Stat('To sync', s?.agentToSync != null ? '${s!.agentToSync}' : dash),
        ],
      AppRole.rider => [
          _Stat('Today', s?.riderTripsToday != null
              ? '${s!.riderTripsToday} trips'
              : dash),
          _Stat('Earned', s?.riderEarnedNaira != null
              ? _nairaK(int.tryParse(s!.riderEarnedNaira!) ?? 0)
              : dash),
          _Stat('Rating', s?.riderRating != null
              ? '★ ${s!.riderRating}'
              : dash),
        ],
      AppRole.trader => [
          _Stat('Listings', s?.traderListings != null
              ? '${s!.traderListings}'
              : dash),
          _Stat('Enquiries', s?.traderEnquiries != null
              ? '${s!.traderEnquiries}'
              : dash),
          _Stat('Earned', s?.traderEarnedNaira != null
              ? _nairaK(int.tryParse(s!.traderEarnedNaira!) ?? 0)
              : dash),
        ],
      AppRole.driver => [
          _Stat('Week', s?.driverTripsThisWeek != null
              ? '${s!.driverTripsThisWeek} trips'
              : dash),
          _Stat('Earned', s?.driverEarnedNaira != null
              ? _nairaK(int.tryParse(s!.driverEarnedNaira!) ?? 0)
              : dash),
          _Stat('Rating', s?.driverRating != null
              ? '★ ${s!.driverRating}'
              : dash),
        ],
      AppRole.customer => [
          _Stat('Orders', s?.orders != null ? '${s!.orders}' : dash),
          _Stat('Favorites', s?.favorites != null ? '${s!.favorites}' : dash),
          _Stat('Member', '—'),
        ],
      AppRole.admin => [
          _Stat('Flags', dash),
          _Stat('Users', dash),
          _Stat('Build', dash),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return ValueListenableBuilder(
      valueListenable: ProfileController.instance.profile,
      builder: (_, profile, _) => ValueListenableBuilder(
        valueListenable: ProfileController.instance.stats,
        builder: (_, stats, _) {
          final name = _resolveName(profile);
          final handle = _resolveHandle(profile);
          final statTiles = _resolveStats(stats);
          final sections = _buildSections(context, config);

          return ListView(
            padding: const EdgeInsets.only(bottom: 140),
            children: [
              _Hero(
                name: name,
                handle: handle,
                badge: config.badge,
                stat1: statTiles[0],
                stat2: statTiles[1],
                stat3: statTiles[2],
                role: widget.role,
                avatarUrl: profile?.avatarUrl,
              ),
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
        },
      ),
    );
  }

  List<AccountMenuSection> _buildSections(
    BuildContext context,
    _RoleConfig config,
  ) {
    return [
      AccountMenuSection(
        title: 'Account',
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: config.payoutLabel,
            sub: config.payoutSub,
            onTap: () => context.push(config.payoutRoute),
          ),
          AccountMenuRow(
            icon: WBIconName.user,
            label: context.l10n.operatorPersonalInfo,
            sub: context.l10n.operatorPersonalInfoSub,
            onTap: () => context.push(AppRoutes.personalInfo),
          ),
          AccountMenuRow(
            icon: WBIconName.pin,
            label: context.l10n.operatorSavedAddresses,
            sub: context.l10n.operatorSavedAddressesSub,
            onTap: () => context.push(AppRoutes.savedAddresses),
          ),
          AccountMenuRow(
            icon: WBIconName.bell,
            label: context.l10n.operatorNotifications,
            sub: context.l10n.operatorNotificationsSub,
            onTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      if (config.settingsRoute != null)
        AccountMenuSection(
          title: 'Operations',
          rows: [
            AccountMenuRow(
              icon: WBIconName.more,
              label: config.settingsLabel!,
              sub: config.settingsSub,
              onTap: () => context.push(config.settingsRoute!),
            ),
          ],
        ),
      AccountMenuSection(
        title: 'Preferences',
        rows: [
          AccountMenuRow(
            icon: WBIconName.message,
            label: context.l10n.operatorLanguage,
            sub: 'English',
            onTap: () => context.push(AppRoutes.language),
          ),
          AccountMenuRow(
            icon: WBIconName.more,
            label: context.l10n.operatorAbout,
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
            label: context.l10n.operatorSwitchRole,
            sub: _switchSub(),
            onTap: () => RoleSwitcherSheet.show(context),
          ),
          AccountMenuRow(
            icon: WBIconName.phone,
            label: context.l10n.operatorHelpSupport,
            sub: context.l10n.operatorHelpSupportSub,
            onTap: () => context.push(AppRoutes.support),
          ),
          AccountMenuRow(
            icon: WBIconName.close,
            label: context.l10n.operatorSignOut,
            danger: true,
            onTap: () => _showSignOutSheet(context),
          ),
        ],
      ),
    ];
  }

  /// e.g. "Approved: Customer · Vendor · Rider", gives a one-line picture
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

/// Format a naira integer compactly: 4800 → ₦4.8k, 120000 → ₦120k, etc.
String _nairaK(int naira) {
  if (naira >= 1000000) {
    final m = (naira / 1000000);
    return '₦${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
  }
  if (naira >= 1000) {
    final k = (naira / 1000);
    return '₦${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
  }
  return wbNaira(naira);
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.name,
    required this.handle,
    required this.badge,
    required this.stat1,
    required this.stat2,
    required this.stat3,
    required this.role,
    this.avatarUrl,
  });
  final String name;
  final String handle;
  final String badge;
  final _Stat stat1;
  final _Stat stat2;
  final _Stat stat3;
  final AppRole role;
  final String? avatarUrl;

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
                    wbShowSnack(context, context.l10n.operatorChoosePhoto),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WBColors.bgDivider,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: avatarUrl != null
                            ? WBNetworkImage(url: avatarUrl!)
                            : _InitialsAvatar(name: name),
                      ),
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
                      name,
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
                      handle,
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
                        badge,
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
                _StatTile(stat: stat1),
                _StatTile(stat: stat2),
                _StatTile(stat: stat3, last: true),
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
            context.l10n.operatorSignOutTitle,
            style: WBTypography.page,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            context.l10n.operatorSignOutBody,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.xl),
          WBButton(
            label: context.l10n.operatorSignOut,
            size: WBButtonSize.lg,
            fullWidth: true,
            onPressed: () {
              RoleController.instance.signOut();
              Navigator.of(ctx).pop();
              context.go(AppRoutes.login);
            },
          ),
          const SizedBox(height: WBSpacing.sm + 4),
          WBButton(
            label: context.l10n.actionCancel,
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

/// Fixed, non-data-driven configuration for each operator role.
class _RoleConfig {
  const _RoleConfig({
    required this.badge,
    required this.payoutLabel,
    required this.payoutSub,
    required this.payoutRoute,
    required this.settingsLabel,
    required this.settingsSub,
    required this.settingsRoute,
  });
  final String badge;
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

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});
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
          fontSize: 22,
        ),
      ),
    );
  }
}
