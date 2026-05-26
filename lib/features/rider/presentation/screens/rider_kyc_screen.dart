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

class RiderKycScreen extends StatefulWidget {
  const RiderKycScreen({super.key});

  @override
  State<RiderKycScreen> createState() => _RiderKycScreenState();
}

class _RiderKycScreenState extends State<RiderKycScreen> {
  String _vehicle = 'motorbike';
  bool _busy = false;
  final Map<String, String> _docs = {};

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _homeAddress = TextEditingController();
  final _payout = TextEditingController();

  static const _vehicles = [
    ('bicycle', 'Bicycle'),
    ('motorbike', 'Motorbike'),
    ('car', 'Car'),
  ];

  @override
  void dispose() {
    for (final c in [_fullName, _phone, _homeAddress, _payout]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await KycApi.instance.submit(
        role: 'rider',
        profile: {
          'fullName': _fullName.text.trim(),
          'phone': _phone.text.trim(),
          'homeAddress': _homeAddress.text.trim(),
          'vehicle': _vehicle,
          'payout': _payout.text.trim(),
        },
        documents: [
          for (final e in _docs.entries) {'label': e.key, 'key': e.value},
        ],
      );
      if (!mounted) return;
      RoleController.instance.markPending(AppRole.rider);
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
                WBInput(
                  label: 'Full name',
                  controller: _fullName,
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Phone number',
                  controller: _phone,
                  leadingIcon: WBIconName.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Home address',
                  controller: _homeAddress,
                  leadingIcon: WBIconName.pin,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Identity',
                  sub: 'NIN, passport or driver licence.',
                ),
                const SizedBox(height: 12),
                KycUploadTile(
                  label: "Photo of ID",
                  sub: 'Clear shot of front side',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('rider'),
                  onUploaded: (key) => _docs['Photo of ID'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Selfie',
                  sub: 'Holding your ID',
                  icon: WBIconName.user,
                  folder: UploadFolder.kyc('rider'),
                  onUploaded: (key) => _docs['Selfie'] = key,
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
                  KycUploadTile(
                    label: 'Vehicle registration',
                    sub: 'Plate number visible',
                    icon: WBIconName.bike,
                    folder: UploadFolder.kyc('rider'),
                    onUploaded: (key) => _docs['Vehicle registration'] = key,
                  ),
                  const SizedBox(height: 10),
                  KycUploadTile(
                    label: 'Driver licence',
                    sub: 'Both sides',
                    icon: WBIconName.card,
                    folder: UploadFolder.kyc('rider'),
                    onUploaded: (key) => _docs['Driver licence'] = key,
                  ),
                  const SizedBox(height: 10),
                ],
                KycUploadTile(
                  label: 'Insurance certificate',
                  sub: 'Optional but helps approval',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('rider'),
                  onUploaded: (key) => _docs['Insurance certificate'] = key,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout',
                  sub: 'Where we send your earnings.',
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
