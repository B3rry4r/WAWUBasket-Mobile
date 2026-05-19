import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';
import '../../../trade/domain/models/corridor.dart';

class TraderKycScreen extends StatefulWidget {
  const TraderKycScreen({super.key});

  @override
  State<TraderKycScreen> createState() => _TraderKycScreenState();
}

class _TraderKycScreenState extends State<TraderKycScreen> {
  final Set<Corridor> _corridors = {Corridor.nigeria, Corridor.benin};

  void _toggle(Corridor c) {
    setState(() {
      if (_corridors.contains(c)) {
        _corridors.remove(c);
      } else {
        _corridors.add(c);
      }
    });
  }

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
                            'Apply to list bulk goods',
                            style: WBTypography.page,
                          ),
                          Text(
                            'Get verified, then post your first export listing.',
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
                  label: 'About your trade',
                  sub: 'How buyers find you.',
                ),
                const SizedBox(height: 12),
                const WBInput(
                  label: 'Business / farm name',
                  initialValue: 'Hauwa & Sons Bulk Co.',
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Region',
                  initialValue: 'Kano',
                  leadingIcon: WBIconName.pin,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Primary contact',
                  initialValue: 'Hauwa Sani',
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                const WBInput(
                  label: 'Phone',
                  initialValue: '803 421 1820',
                  keyboardType: TextInputType.phone,
                  leadingIcon: WBIconName.phone,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Corridors you serve',
                  sub: 'Pick every market you currently sell into.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in Corridor.values)
                      WBTag(
                        label: c.label,
                        active: _corridors.contains(c),
                        onTap: () => _toggle(c),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Verification documents',
                  sub: 'Required before your first listing goes live.',
                ),
                const SizedBox(height: 12),
                const KycUploadTile(
                  label: 'Business registration',
                  sub: 'CAC / co-op certificate',
                  icon: WBIconName.card,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Owner ID',
                  sub: 'NIN, passport or driver licence',
                  icon: WBIconName.user,
                ),
                const SizedBox(height: 10),
                const KycUploadTile(
                  label: 'Farm / warehouse photo',
                  sub: 'Outside shot, geo-tagged if possible',
                  icon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Settlement',
                  sub: 'Where we release escrow once a sale clears.',
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
                      RoleController.instance.completeKyc(AppRole.trader);
                      RoleController.instance.setRole(AppRole.trader);
                      wbShowSnack(
                        context,
                        'Application approved · Welcome trader',
                      );
                      context.go(AppRoutes.traderHome);
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
