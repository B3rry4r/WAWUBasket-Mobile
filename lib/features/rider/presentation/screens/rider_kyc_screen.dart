import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

class RiderKycScreen extends StatefulWidget {
  const RiderKycScreen({super.key});

  @override
  State<RiderKycScreen> createState() => _RiderKycScreenState();
}

class _RiderKycScreenState extends State<RiderKycScreen> {
  String _vehicle = 'motorbike';

  static const _vehicles = [
    ('bicycle', 'Bicycle'),
    ('motorbike', 'Motorbike'),
    ('car', 'Car'),
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
                          Text('Apply to ride', style: WBTypography.page),
                          Text(
                            'Quick verification, under 5 minutes.',
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
                  sub: 'Used to match you to customers.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Full name',
                  initialValue: 'Tunde Adeyemi',
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Phone number',
                  initialValue: '803 421 1820',
                  leadingIcon: WBIconName.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Home address',
                  initialValue: 'Lekki Phase 1, Lagos',
                  leadingIcon: WBIconName.pin,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Identity',
                  sub: 'NIN, passport or driver licence.',
                ),
                const SizedBox(height: 12),
                const KycUploadTile(
                  label: "Photo of ID",
                  sub: 'Clear shot of front side',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Selfie',
                  sub: 'Holding your ID',
                  icon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Vehicle',
                  sub: 'What you ride with.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in _vehicles)
                      WBTag(
                        label: v.$2,
                        active: v.$1 == _vehicle,
                        onTap: () => setState(() => _vehicle = v.$1),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                if (_vehicle != 'bicycle') ...[
                  const KycUploadTile(
                    label: 'Vehicle registration',
                    sub: 'Plate number visible',
                    icon: WBIconName.bike,
                  ),
                  const SizedBox(height: 10),
                  const KycUploadTile(
                    label: 'Driver licence',
                    sub: 'Both sides',
                    icon: WBIconName.card,
                  ),
                  const SizedBox(height: 10),
                ],
                const KycUploadTile(
                  label: 'Insurance certificate',
                  sub: 'Optional but helps approval',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout',
                  sub: 'Where we send your earnings.',
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
                      RoleController.instance.completeKyc(AppRole.rider);
                      RoleController.instance.setRole(AppRole.rider);
                      wbShowSnack(
                        context,
                        'Application approved · Time to ride',
                      );
                      context.go(AppRoutes.riderHome);
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
