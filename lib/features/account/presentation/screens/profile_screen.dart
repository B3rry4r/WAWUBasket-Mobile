import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/biometric_service.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../application/profile_controller.dart';
import '../../data/profile_api.dart';
import '../widgets/account_menu.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../widgets/role_switcher_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;
  bool _biometric = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    if (!GuestModeController.instance.isGuest.value) {
      ProfileController.instance.load();
      ProfileController.instance.loadStats();
    }
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final available = await BiometricService.instance.isAvailable();
    final enabled = await BiometricService.instance.isEnabled();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometric = enabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final ok = await BiometricService.instance.authenticate(
        reason: 'Enable biometric unlock for WAWUBasket',
      );
      if (!ok) return;
    }
    await BiometricService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _biometric = value);
  }

  Future<void> _uploadAvatar() async {
    if (_uploadingAvatar) return;
    setState(() => _uploadingAvatar = true);
    try {
      final result = await UploadService.instance.pickAndUpload(
        folder: UploadFolder.avatars,
      );
      if (result == null) return;
      await ProfileApi.instance.updateAvatar(result.key);
      await ProfileController.instance.load();
    } catch (_) {
      if (mounted) wbShowSnack(context, 'Could not update photo. Try again.');
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GuestModeController.instance.isGuest,
      builder: (_, isGuest, _) {
        if (isGuest) return _buildGuest(context);
        return _buildSignedIn(context);
      },
    );
  }

  Widget _buildGuest(BuildContext context) {
    // TODO(i18n): key=profileGuestTitle / profileGuestBody / profileGuestCta
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        80,
        WBSpacing.screenPadding,
        180,
      ),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: const WBIcon(
              WBIconName.user,
              size: 36,
              color: WBColors.fgHeader,
            ),
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        Text(
          "You're browsing as a guest",
          textAlign: TextAlign.center,
          style: WBTypography.hero.copyWith(fontSize: 24),
        ),
        const SizedBox(height: WBSpacing.sm),
        Text(
          'Sign in to manage your profile, orders, wallet and favorites.',
          textAlign: TextAlign.center,
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: 'Sign in',
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          onPressed: () => context.push(AppRoutes.login),
        ),
        const SizedBox(height: WBSpacing.sm + 4),
        WBButton(
          label: 'Create an account',
          size: WBButtonSize.lg,
          fullWidth: true,
          variant: WBButtonVariant.secondary,
          onPressed: () => context.push(AppRoutes.signup),
        ),
      ],
    );
  }

  Widget _buildSignedIn(BuildContext context) {
    final sections = _buildSections(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: WBColors.bgPrimary,
            border: Border(bottom: BorderSide(color: WBColors.bgDivider)),
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
                  ValueListenableBuilder<UserProfile?>(
                    valueListenable: ProfileController.instance.profile,
                    builder: (_, profile, _) {
                      final url = profile?.avatarUrl;
                      final initials = _initials(profile?.fullName);
                      return GestureDetector(
                        onTap: _uploadAvatar,
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
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: url != null && url.isNotEmpty
                                    ? WBNetworkImage(url: url)
                                    : Container(
                                        color: WBColors.surfaceDark,
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: WBTypography.hero.copyWith(
                                            fontSize: 22,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
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
                                child: _uploadingAvatar
                                    ? const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      )
                                    : const WBIcon(
                                        WBIconName.plus,
                                        size: 11,
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: ProfileController.instance.profile,
                      builder: (_, profile, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.fullName.isNotEmpty == true
                                ? profile!.fullName
                                : 'WAWUBasket user',
                            style: WBTypography.cardTitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: WBColors.fgHeader,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile?.email.isNotEmpty == true
                                ? profile!.email
                                : (profile?.phone ?? ''),
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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
                child: ValueListenableBuilder(
                  valueListenable: ProfileController.instance.stats,
                  builder: (_, stats, _) => Row(
                    children: [
                      _Stat(
                        value: stats?.orders != null ? '${stats!.orders}' : '–',
                        label: 'Orders',
                      ),
                      _Stat(
                        value: stats?.orders != null ? '${stats!.orders}' : '–',
                        label: 'Bulk',
                      ),
                      _Stat(
                        value: stats?.favorites != null ? '${stats!.favorites}' : '–',
                        label: 'Favorites',
                        last: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            180,
          ),
          child: Column(
            children: [
              for (final section in sections) ...[
                AccountMenuSectionCard(section: section),
                const SizedBox(height: WBSpacing.sm + 2),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<AccountMenuSection> _buildSections(BuildContext context) {
    return [
      AccountMenuSection(
        title: context.l10n.navAccount,
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: context.l10n.profileWalletMenu,
            sub: context.l10n.profileWalletSub,
            onTap: () => context.push(AppRoutes.wallet),
          ),
          AccountMenuRow(
            icon: WBIconName.user,
            label: context.l10n.profilePersonalInfo,
            sub: context.l10n.profilePersonalInfoSub,
            onTap: () => context.push(AppRoutes.personalInfo),
          ),
          AccountMenuRow(
            icon: WBIconName.pin,
            label: context.l10n.profileSavedAddresses,
            sub: context.l10n.profileSavedAddressesSub,
            onTap: () => context.push(AppRoutes.savedAddresses),
          ),
          AccountMenuRow(
            icon: WBIconName.bell,
            label: context.l10n.profileNotifications,
            sub: context.l10n.profileNotificationsSub,
            onTap: () => context.push(AppRoutes.notifications),
          ),
          AccountMenuRow(
            icon: WBIconName.star,
            label: context.l10n.profileWawuPlus,
            sub: context.l10n.profileWawuPlusSub,
            onTap: () => context.push(AppRoutes.wawuPlus),
          ),
        ],
      ),
      AccountMenuSection(
        title: 'Preferences',
        rows: [
          AccountMenuRow(
            icon: WBIconName.message,
            label: context.l10n.profileLanguage,
            sub: 'English · Français · Hausa · Yorùbá · Igbo',
            onTap: () => context.push(AppRoutes.language),
          ),
          AccountMenuRow(
            icon: WBIconName.basket,
            label: context.l10n.profileDietary,
            sub: context.l10n.profileDietarySub,
            onTap: () => context.push(AppRoutes.dietary),
          ),
          AccountMenuRow(
            icon: WBIconName.more,
            label: context.l10n.profileAbout,
            sub: 'v2.1.0',
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
      AccountMenuSection(
        title: context.l10n.securityTitle,
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: context.l10n.profileChangePassword,
            sub: context.l10n.profileChangePasswordSub,
            onTap: () => context.push(AppRoutes.security),
          ),
          if (_biometricAvailable)
            AccountMenuRow(
              icon: WBIconName.user,
              label: context.l10n.profileBiometricLogin,
              sub: context.l10n.profileBiometricLoginSub,
              onTap: () => _toggleBiometric(!_biometric),
              trailing: Switch.adaptive(
                value: _biometric,
                activeThumbColor: WBColors.surfaceDark,
                onChanged: _toggleBiometric,
              ),
            ),
        ],
      ),
      AccountMenuSection(
        title: context.l10n.supportTitle,
        rows: [
          AccountMenuRow(
            icon: WBIconName.message,
            label: context.l10n.profileHelpCenter,
            sub: context.l10n.profileHelpCenterSub,
            onTap: () => context.push(AppRoutes.support),
          ),
          AccountMenuRow(
            icon: WBIconName.phone,
            label: context.l10n.profileChatWithUs,
            sub: context.l10n.profileChatWithUsSub,
            onTap: () => context.push(AppRoutes.support),
          ),
          AccountMenuRow(
            icon: WBIconName.more,
            label: context.l10n.profileReportProblem,
            sub: context.l10n.profileReportProblemSub,
            onTap: () => context.push(AppRoutes.support),
          ),
        ],
      ),
      AccountMenuSection(
        title: 'Legal',
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: context.l10n.profileTerms,
            sub: context.l10n.profileTermsSub,
            onTap: () => context.push(AppRoutes.about),
          ),
          AccountMenuRow(
            icon: WBIconName.user,
            label: context.l10n.profilePrivacy,
            sub: context.l10n.profilePrivacySub,
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
      AccountMenuSection(
        title: '',
        rows: [
          AccountMenuRow(
            icon: WBIconName.user,
            label: context.l10n.profileSwitchRole,
            sub: _switchSub(),
            onTap: () => RoleSwitcherSheet.show(context),
          ),
          if (RoleController.instance.statusOf(AppRole.admin) == RoleStatus.approved)
            AccountMenuRow(
              icon: WBIconName.filter,
              label: 'Dev Settings',
              sub: 'Feature flags & platform controls',
              onTap: () => context.push(AppRoutes.devSettings),
            ),
          AccountMenuRow(
            icon: WBIconName.close,
            label: context.l10n.profileDeleteAccount,
            sub: context.l10n.profileDeleteAccountSub,
            danger: true,
            onTap: () => context.push(AppRoutes.deleteAccount),
          ),
          AccountMenuRow(
            icon: WBIconName.close,
            label: context.l10n.profileSignOut,
            danger: true,
            onTap: () => _showSignOutSheet(context),
          ),
        ],
      ),
    ];
  }

  String _switchSub() {
    final switchable = RoleController.instance.switchableRoles;
    if (switchable.length <= 1) {
      return 'Apply to be a vendor, trader, agent, rider or driver';
    }
    return 'Active: ${switchable.map((r) => r.title).join(' · ')}';
  }

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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
          Text(context.l10n.profileSignOutTitle, style: WBTypography.page, textAlign: TextAlign.center),
          const SizedBox(height: WBSpacing.sm),
          Text(
            context.l10n.profileSignOutBody,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.xl),
          WBButton(
            label: context.l10n.profileSignOut,
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.last = false,
  });
  final String value;
  final String label;
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
              value,
              style: WBTypography.body.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
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
