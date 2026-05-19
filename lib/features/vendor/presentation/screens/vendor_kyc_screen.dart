import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

class VendorKycScreen extends StatefulWidget {
  const VendorKycScreen({super.key});

  @override
  State<VendorKycScreen> createState() => _VendorKycScreenState();
}

class _VendorKycScreenState extends State<VendorKycScreen> {
  String _type = 'restaurant';

  static const _types = [
    ('restaurant', 'Restaurant'),
    ('fresh-market', 'Fresh Market'),
    ('livestock', 'Livestock'),
    ('essentials', 'Kitchen Essentials'),
    ('produce', 'Farm Produce'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                140,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('List your business', style: WBTypography.page),
                          Text(
                            "We'll review your documents and get you live.",
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Business basics',
                  sub: 'How customers find you in the app.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Business name',
                  initialValue: 'Mama Cass Kitchen',
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Owner full name',
                  initialValue: 'Adunni Adesanya',
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                Text(
                  'BUSINESS TYPE',
                  style: WBTypography.label.copyWith(
                    color: WBColors.fgPlaceholder,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.66,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _types)
                      WBTag(
                        label: t.$2,
                        active: t.$1 == _type,
                        onTap: () => setState(() => _type = t.$1),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                const WBInput(
                  label: 'Phone number',
                  initialValue: '803 421 1820',
                  leadingIcon: WBIconName.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Business email',
                  initialValue: 'mamacass@wawu.africa',
                  leadingIcon: WBIconName.message,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Store address',
                  sub: 'Where deliveries pick up from.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Address line',
                  initialValue: '12 Adeola Odeku St, V/I',
                  leadingIcon: WBIconName.pin,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const Row(
                  children: [
                    Expanded(
                      child: WBInput(
                        label: 'City',
                        initialValue: 'Lagos',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: WBInput(
                        label: 'State',
                        initialValue: 'Lagos',
                        trailing: WBIcon(WBIconName.chevronDown, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Verification documents',
                  sub: 'All required. We never share these.',
                ),
                const SizedBox(height: 12),
                const KycUploadTile(
                  label: 'Business certificate',
                  sub: 'CAC or equivalent registration',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Operating permit',
                  sub: 'Trade / food / pharmacy permit',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: "Owner's ID",
                  sub: 'NIN, passport or driver licence',
                  icon: WBIconName.user,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Store location photo',
                  sub: 'Outside shot of your shop',
                  icon: WBIconName.home,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Utility bill',
                  sub: 'Proof of store address',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout account',
                  sub: 'Where we send your earnings.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Bank name',
                  initialValue: 'GTBank',
                  leadingIcon: WBIconName.card,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Account number',
                  initialValue: '0123456789',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Account name',
                  initialValue: 'Adunni Adesanya',
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding,
                    0,
                    WBSpacing.screenPadding,
                    20,
                  ),
                  child: WBButton(
                    label: 'Submit application',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    trailingIcon: WBIconName.arrowRight,
                    onPressed: () {
                      RoleController.instance.completeKyc(AppRole.vendor);
                      RoleController.instance.setRole(AppRole.vendor);
                      wbShowSnack(
                        context,
                        'Application approved · Welcome aboard',
                      );
                      context.go(AppRoutes.vendorHome);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
