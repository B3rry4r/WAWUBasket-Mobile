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

class VendorKycScreen extends StatefulWidget {
  const VendorKycScreen({super.key});

  @override
  State<VendorKycScreen> createState() => _VendorKycScreenState();
}

class _VendorKycScreenState extends State<VendorKycScreen> {
  String _type = 'restaurant';
  bool _busy = false;
  final Map<String, String> _docs = {};

  final _businessName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _addressLine = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();

  static const _types = [
    ('restaurant', 'Restaurant'),
    ('fresh-market', 'Fresh Market'),
    ('livestock', 'Livestock'),
    ('essentials', 'Kitchen Essentials'),
    ('produce', 'Farm Produce'),
  ];

  @override
  void dispose() {
    for (final c in [
      _businessName,
      _ownerName,
      _phone,
      _email,
      _addressLine,
      _city,
      _state,
      _bankName,
      _accountNumber,
      _accountName,
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
        role: 'vendor',
        profile: {
          'businessName': _businessName.text.trim(),
          'ownerName': _ownerName.text.trim(),
          'businessType': _type,
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
          'addressLine': _addressLine.text.trim(),
          'city': _city.text.trim(),
          'state': _state.text.trim(),
          'bankName': _bankName.text.trim(),
          'accountNumber': _accountNumber.text.trim(),
          'accountName': _accountName.text.trim(),
        },
        documents: [
          for (final e in _docs.entries) {'label': e.key, 'key': e.value},
        ],
      );
      if (!mounted) return;
      RoleController.instance.markPending(AppRole.vendor);
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
                WBInput(
                  label: 'Business name',
                  controller: _businessName,
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Owner full name',
                  controller: _ownerName,
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
                WBInput(
                  label: 'Phone number',
                  controller: _phone,
                  leadingIcon: WBIconName.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Business email',
                  controller: _email,
                  leadingIcon: WBIconName.message,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Store address',
                  sub: 'Where deliveries pick up from.',
                ),
                const SizedBox(height: 12),
                WBInput(
                  label: 'Address line',
                  controller: _addressLine,
                  leadingIcon: WBIconName.pin,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                Row(
                  children: [
                    Expanded(
                      child: WBInput(
                        label: 'City',
                        controller: _city,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: WBInput(
                        label: 'State',
                        controller: _state,
                        trailing: const WBIcon(WBIconName.chevronDown, size: 14),
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
                KycUploadTile(
                  label: 'Business certificate',
                  sub: 'CAC or equivalent registration',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('vendor'),
                  onUploaded: (key) => _docs['Business certificate'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Operating permit',
                  sub: 'Trade / food / pharmacy permit',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('vendor'),
                  onUploaded: (key) => _docs['Operating permit'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: "Owner's ID",
                  sub: 'NIN, passport or driver licence',
                  icon: WBIconName.user,
                  folder: UploadFolder.kyc('vendor'),
                  onUploaded: (key) => _docs["Owner's ID"] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Store location photo',
                  sub: 'Outside shot of your shop',
                  icon: WBIconName.home,
                  folder: UploadFolder.kyc('vendor'),
                  onUploaded: (key) => _docs['Store location photo'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Utility bill',
                  sub: 'Proof of store address',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('vendor'),
                  onUploaded: (key) => _docs['Utility bill'] = key,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Payout account',
                  sub: 'Where we send your earnings.',
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
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Account name',
                  controller: _accountName,
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
