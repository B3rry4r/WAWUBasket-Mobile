import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

class DriverKycScreen extends StatefulWidget {
  const DriverKycScreen({super.key});

  @override
  State<DriverKycScreen> createState() => _DriverKycScreenState();
}

class _DriverKycScreenState extends State<DriverKycScreen> {
  String _vehicleType = 'truck';

  static const _vehicleTypes = [
    ('truck', 'Long-haul truck'),
    ('container', 'Container'),
    ('flatbed', 'Flatbed'),
    ('reefer', 'Reefer / cold chain'),
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
                          Text(
                            'Apply with your union',
                            style: WBTypography.page,
                          ),
                          Text(
                            "We verify with your transport union before you bid.",
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
                  label: 'About you',
                  sub: "Drivers' licence name, please.",
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Full name',
                  initialValue: 'Aliyu Bala',
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Phone',
                  initialValue: '803 421 1820',
                  leadingIcon: WBIconName.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Transport union',
                  initialValue: 'NRTC Kano',
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Vehicle',
                  sub: "What you'll move loads with.",
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in _vehicleTypes)
                      WBTag(
                        label: v.$2,
                        active: v.$1 == _vehicleType,
                        onTap: () => setState(() => _vehicleType = v.$1),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                const WBInput(
                  label: 'Plate number',
                  initialValue: 'KN-541-XA',
                  leadingIcon: WBIconName.bike,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Capacity (kg)',
                  initialValue: '15,000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Documents',
                  sub: 'All required before your first trip.',
                ),
                const SizedBox(height: 12),
                const KycUploadTile(
                  label: 'Driver licence',
                  sub: 'Front + back',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Vehicle registration',
                  sub: 'Plate number visible',
                  icon: WBIconName.bike,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Insurance certificate',
                  sub: 'Cargo + liability',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Union endorsement',
                  sub: 'Signed letter from your union office',
                  icon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout',
                  sub: 'Where we settle each completed trip.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Mobile money / bank',
                  initialValue: '+234 805 0214 311',
                  leadingIcon: WBIconName.card,
                  keyboardType: TextInputType.phone,
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
                      RoleController.instance.completeKyc(AppRole.driver);
                      RoleController.instance.setRole(AppRole.driver);
                      wbShowSnack(
                        context,
                        'Application approved · Time to roll',
                      );
                      context.go(AppRoutes.driverHome);
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
