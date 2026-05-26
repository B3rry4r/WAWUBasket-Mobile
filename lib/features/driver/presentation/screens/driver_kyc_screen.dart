import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/kyc_api.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

class DriverKycScreen extends StatefulWidget {
  const DriverKycScreen({super.key});

  @override
  State<DriverKycScreen> createState() => _DriverKycScreenState();
}

class _DriverKycScreenState extends State<DriverKycScreen> {
  String _vehicleType = 'truck';
  bool _busy = false;
  final Map<String, String> _docs = {};

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _union = TextEditingController();
  final _plate = TextEditingController();
  final _capacity = TextEditingController();
  final _payout = TextEditingController();

  static const _vehicleTypes = [
    ('truck', 'Long-haul truck'),
    ('container', 'Container'),
    ('flatbed', 'Flatbed'),
    ('reefer', 'Reefer / cold chain'),
  ];

  @override
  void dispose() {
    for (final c in [_fullName, _phone, _union, _plate, _capacity, _payout]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await KycApi.instance.submit(
        role: 'driver',
        profile: {
          'fullName': _fullName.text.trim(),
          'phone': _phone.text.trim(),
          'union': _union.text.trim(),
          'vehicleType': _vehicleType,
          'plate': _plate.text.trim(),
          'capacityKg': _capacity.text.trim(),
          'payout': _payout.text.trim(),
        },
        documents: [
          for (final e in _docs.entries) {'label': e.key, 'key': e.value},
        ],
      );
      if (!mounted) return;
      RoleController.instance.markPending(AppRole.driver);
      wbShowSnack(context, context.l10n.kycSubmitted);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.roleSelect);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        wbShowSnack(context, e.message);
      }
    }
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
                WBInput(
                  label: 'Full name',
                  controller: _fullName,
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Phone',
                  controller: _phone,
                  leadingIcon: WBIconName.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Transport union',
                  controller: _union,
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
                WBInput(
                  label: 'Plate number',
                  controller: _plate,
                  leadingIcon: WBIconName.bike,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Capacity (kg)',
                  controller: _capacity,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Documents',
                  sub: 'All required before your first trip.',
                ),
                const SizedBox(height: 12),
                KycUploadTile(
                  label: 'Driver licence',
                  sub: 'Front + back',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['Driver licence'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Vehicle registration',
                  sub: 'Plate number visible',
                  icon: WBIconName.bike,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['Vehicle registration'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Insurance certificate',
                  sub: 'Cargo + liability',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['Insurance certificate'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Union endorsement',
                  sub: 'Signed letter from your union office',
                  icon: WBIconName.home,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['Union endorsement'] = key,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Cross-border papers',
                  sub: 'Required if you run loads across ECOWAS borders.',
                ),
                const SizedBox(height: 12),
                KycUploadTile(
                  label: 'ECOWAS Trade Liberalisation Scheme certificate',
                  sub: 'ETLS approval issued by your country trade ministry',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) =>
                      _docs['ECOWAS Trade Liberalisation Scheme certificate'] =
                          key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'AfCFTA registration',
                  sub: 'African Continental Free Trade Area papers',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['AfCFTA registration'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Customs clearance licence',
                  sub: 'Or partnership with a licensed customs agent',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['Customs clearance licence'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'International passport',
                  sub: 'Bio data page',
                  icon: WBIconName.user,
                  folder: UploadFolder.kyc('driver'),
                  onUploaded: (key) => _docs['International passport'] = key,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout',
                  sub: 'Where we settle each completed trip.',
                ),
                const SizedBox(height: 12),
                WBInput(
                  label: 'Mobile money / bank',
                  controller: _payout,
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
                    loading: _busy,
                    onPressed: _submit,
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
