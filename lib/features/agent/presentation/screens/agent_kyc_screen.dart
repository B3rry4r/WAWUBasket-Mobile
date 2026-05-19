import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

class AgentKycScreen extends StatefulWidget {
  const AgentKycScreen({super.key});

  @override
  State<AgentKycScreen> createState() => _AgentKycScreenState();
}

class _AgentKycScreenState extends State<AgentKycScreen> {
  String _zone = 'mile-12';

  static const _zones = [
    ('mile-12', 'Mile 12 Market'),
    ('idumota', 'Idumota'),
    ('onitsha', 'Onitsha Main'),
    ('kano', 'Kano Central'),
    ('aba', 'Aba'),
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
                            'Apply to be an agent',
                            style: WBTypography.page,
                          ),
                          Text(
                            'Field officers help register & pay traders.',
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
                  sub: 'Used to assign you a zone.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Full name',
                  initialValue: 'Musa Ibrahim',
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
                  label: 'Email',
                  initialValue: 'musa@wawu.africa',
                  leadingIcon: WBIconName.message,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Identity',
                  sub: 'For Face ID match at every payout.',
                ),
                const SizedBox(height: 12),
                const KycUploadTile(
                  label: 'Photo of ID',
                  sub: 'NIN or driver licence',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Face capture',
                  sub: 'Live selfie, anti-fraud',
                  icon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Zone preference',
                  sub: 'Where you mostly work.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final z in _zones)
                      WBTag(
                        label: z.$2,
                        active: z.$1 == _zone,
                        onTap: () => setState(() => _zone = z.$1),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                const WBInput(
                  label: 'Union or cover (optional)',
                  initialValue: 'NRTC Lagos',
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout',
                  sub: 'Commission settlement account.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Bank name',
                  initialValue: 'Access Bank',
                  leadingIcon: WBIconName.card,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Account number',
                  initialValue: '0123456789',
                  keyboardType: TextInputType.number,
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
                      RoleController.instance.completeKyc(AppRole.agent);
                      RoleController.instance.setRole(AppRole.agent);
                      wbShowSnack(
                        context,
                        'Application approved · Welcome agent',
                      );
                      context.go(AppRoutes.agentHome);
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
