import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shopping/application/wb_images.dart';
import '../../application/profile_controller.dart';
import '../widgets/account_menu.dart';
import '../widgets/role_switcher_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ProfileController.instance.load();
  }

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                    onTap: () =>
                        wbShowSnack(context, 'Choose a profile photo'),
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
                          child: const ClipOval(
                            child: WBNetworkImage(url: WBImages.avatar),
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
                child: const Row(
                  children: [
                    _Stat(value: '48', label: 'Orders'),
                    _Stat(value: '₦12.5k', label: 'Wallet'),
                    _Stat(value: '12', label: 'Favorites', last: true),
                  ],
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
        title: 'Account',
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: 'Wallet & payment methods',
            sub: 'Cards, bank, and mobile money',
            onTap: () => context.push(AppRoutes.wallet),
          ),
          AccountMenuRow(
            icon: WBIconName.user,
            label: 'Personal information',
            sub: 'Name, email, phone, verified ✓',
            onTap: () => context.push(AppRoutes.personalInfo),
          ),
          AccountMenuRow(
            icon: WBIconName.pin,
            label: 'Saved addresses',
            sub: 'Where you live, work, and hang out',
            onTap: () => context.push(AppRoutes.savedAddresses),
          ),
          AccountMenuRow(
            icon: WBIconName.bell,
            label: 'Notifications',
            sub: "What we tell you about",
            onTap: () => context.push(AppRoutes.notifications),
          ),
          AccountMenuRow(
            icon: WBIconName.basket,
            label: 'Bulk orders',
            sub: 'Escrow-protected purchases from /trade',
            onTap: () => context.push(AppRoutes.escrowOrders),
          ),
          AccountMenuRow(
            icon: WBIconName.star,
            label: 'WAWU+ membership',
            sub: 'Discounted delivery and more',
            onTap: () => context.push(AppRoutes.wawuPlus),
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
            icon: WBIconName.basket,
            label: 'Dietary preferences',
            sub: "Things you'd rather not eat",
            onTap: () => context.push(AppRoutes.dietary),
          ),
          AccountMenuRow(
            icon: WBIconName.star,
            label: 'Rate the app',
            onTap: () => _showRateSheet(context),
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
        title: 'Security',
        rows: [
          AccountMenuRow(
            icon: WBIconName.card,
            label: 'Password & security',
            sub: 'Change password, biometric, 2FA',
            onTap: () => context.push(AppRoutes.security),
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
            onTap: () => context.push(AppRoutes.support),
          ),
          AccountMenuRow(
            icon: WBIconName.close,
            label: 'Delete account',
            sub: "We'll be sad to see you go",
            danger: true,
            onTap: () => context.push(AppRoutes.deleteAccount),
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

  String _switchSub() {
    final switchable = RoleController.instance.switchableRoles;
    if (switchable.length <= 1) {
      return 'Apply to be a vendor, trader, agent, rider or driver';
    }
    return 'Active: ${switchable.map((r) => r.title).join(' · ')}';
  }
}

void _showRateSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: WBColors.bgPrimary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
    ),
    builder: (ctx) => const _RateSheet(),
  );
}

class _RateSheet extends StatefulWidget {
  const _RateSheet();

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + WBSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: WBSpacing.lg),
            decoration: BoxDecoration(
              color: WBColors.bgDivider,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
          ),
          Text('Rate WAWUBasket', style: WBTypography.page),
          const SizedBox(height: WBSpacing.sm),
          Text(
            'How are we doing? Your feedback shapes the app.',
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
          ),
          const SizedBox(height: WBSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: WBIcon(
                    WBIconName.star,
                    size: 36,
                    color: filled ? WBColors.fgHeader : WBColors.bgDivider,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: WBSpacing.xl),
          WBButton(
            label: _rating == 0 ? 'Tap a star to rate' : 'Submit',
            size: WBButtonSize.lg,
            fullWidth: true,
            disabled: _rating == 0,
            onPressed: _rating == 0
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thanks, you rated us $_rating stars')),
                    );
                  },
          ),
        ],
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
          Text('Sign out?', style: WBTypography.page, textAlign: TextAlign.center),
          const SizedBox(height: WBSpacing.sm),
          Text(
            "You'll need to sign in again to place new orders.",
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
