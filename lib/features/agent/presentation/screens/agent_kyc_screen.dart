import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/kyc_api.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

class AgentKycScreen extends StatefulWidget {
  const AgentKycScreen({super.key});

  @override
  State<AgentKycScreen> createState() => _AgentKycScreenState();
}

class _AgentKycScreenState extends State<AgentKycScreen> {
  String _zone = 'mile-12';
  bool _busy = false;
  final Map<String, String> _docs = {};

  final _fullName = TextEditingController(text: 'Musa Ibrahim');
  final _phone = TextEditingController(text: '803 421 1820');
  final _email = TextEditingController(text: 'musa@wawu.africa');
  final _union = TextEditingController(text: 'NRTC Lagos');
  final _bankName = TextEditingController(text: 'Access Bank');
  final _accountNumber = TextEditingController(text: '0123456789');

  static const _zones = [
    ('mile-12', 'Mile 12 Market'),
    ('idumota', 'Idumota'),
    ('onitsha', 'Onitsha Main'),
    ('kano', 'Kano Central'),
    ('aba', 'Aba'),
  ];

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _phone,
      _email,
      _union,
      _bankName,
      _accountNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await KycApi.instance.submit(
        role: 'agent',
        profile: {
          'fullName': _fullName.text.trim(),
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
          'zone': _zone,
          'union': _union.text.trim(),
          'bankName': _bankName.text.trim(),
          'accountNumber': _accountNumber.text.trim(),
        },
        documents: [
          for (final e in _docs.entries) {'label': e.key, 'key': e.value},
        ],
      );
      if (!mounted) return;
      RoleController.instance.completeKyc(AppRole.agent);
      RoleController.instance.setRole(AppRole.agent);
      wbShowSnack(context, 'Application approved · Welcome agent');
      context.go(AppRoutes.agentHome);
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
                  label: 'Email',
                  controller: _email,
                  leadingIcon: WBIconName.message,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Identity',
                  sub: 'For Face ID match at every payout.',
                ),
                const SizedBox(height: 12),
                KycUploadTile(
                  label: 'Photo of ID',
                  sub: 'NIN or driver licence',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('agent'),
                  onUploaded: (key) => _docs['Photo of ID'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Face capture',
                  sub: 'Live selfie, anti-fraud',
                  icon: WBIconName.user,
                  folder: UploadFolder.kyc('agent'),
                  onUploaded: (key) => _docs['Face capture'] = key,
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
                WBInput(
                  label: 'Union or cover (optional)',
                  controller: _union,
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout',
                  sub: 'Commission settlement account.',
                ),
                const SizedBox(height: 12),
                WBInput(
                  label: 'Bank name',
                  controller: _bankName,
                  leadingIcon: WBIconName.card,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Account number',
                  controller: _accountNumber,
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
