import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/location_data.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/kyc_api.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';
import '../../../trade/domain/models/corridor.dart';

class TraderKycScreen extends StatefulWidget {
  const TraderKycScreen({super.key});

  @override
  State<TraderKycScreen> createState() => _TraderKycScreenState();
}

class _TraderKycScreenState extends State<TraderKycScreen> {
  final Set<Corridor> _corridors = {Corridor.nigeria, Corridor.benin};
  bool _busy = false;
  final Map<String, String> _docs = {};
  String? _selectedCountry;
  String? _selectedState;

  final _businessName = TextEditingController();
  final _stateText = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _businessName,
      _stateText,
      _contact,
      _phone,
      _bankName,
      _accountNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFromList(
    BuildContext context,
    List<String> items,
    ValueChanged<String> onPicked,
  ) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(items[i], style: WBTypography.body),
                  onTap: () => Navigator.of(context).pop(items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickCountry(BuildContext context) =>
      _pickFromList(context, kCountries, (v) {
        setState(() {
          _selectedCountry = v;
          _selectedState = null;
          _stateText.clear();
        });
      });

  Future<void> _pickState(BuildContext context) {
    final states = kCountryStates[_selectedCountry];
    if (states != null) {
      return _pickFromList(
          context, states, (v) => setState(() => _selectedState = v));
    }
    return Future.value();
  }

  void _toggle(Corridor c) {
    setState(() {
      if (_corridors.contains(c)) {
        _corridors.remove(c);
      } else {
        _corridors.add(c);
      }
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await KycApi.instance.submit(
        role: 'trader',
        profile: {
          'businessName': _businessName.text.trim(),
          'country': _selectedCountry ?? '',
          'region': _selectedState ?? _stateText.text.trim(),
          'contact': _contact.text.trim(),
          'phone': _phone.text.trim(),
          'corridors': [for (final c in _corridors) c.name],
          'bankName': _bankName.text.trim(),
          'accountNumber': _accountNumber.text.trim(),
        },
        documents: [
          for (final e in _docs.entries) {'label': e.key, 'key': e.value},
        ],
      );
      if (!mounted) return;
      RoleController.instance.markPending(AppRole.trader);
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
                WBInput(
                  label: 'Business / farm name',
                  controller: _businessName,
                  leadingIcon: WBIconName.home,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                _PickerField(
                  value: _selectedCountry,
                  placeholder: 'Country',
                  onTap: () => _pickCountry(context),
                ),
                const SizedBox(height: WBSpacing.md - 2),
                kCountryStates.containsKey(_selectedCountry)
                    ? _PickerField(
                        value: _selectedState,
                        placeholder: 'State / Region',
                        onTap: () => _pickState(context),
                      )
                    : WBInput(
                        label: 'State / Region',
                        controller: _stateText,
                        leadingIcon: WBIconName.pin,
                      ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Primary contact',
                  controller: _contact,
                  leadingIcon: WBIconName.user,
                ),
                const SizedBox(height: WBSpacing.md - 2),
                WBInput(
                  label: 'Phone',
                  controller: _phone,
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
                KycUploadTile(
                  label: 'Business registration',
                  sub: 'CAC / co-op certificate',
                  icon: WBIconName.card,
                  folder: UploadFolder.kyc('trader'),
                  onUploaded: (key) => _docs['Business registration'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Owner ID',
                  sub: 'NIN, passport or driver licence',
                  icon: WBIconName.user,
                  folder: UploadFolder.kyc('trader'),
                  onUploaded: (key) => _docs['Owner ID'] = key,
                ),
                const SizedBox(height: 10),
                KycUploadTile(
                  label: 'Farm / warehouse photo',
                  sub: 'Outside shot, geo-tagged if possible',
                  icon: WBIconName.home,
                  folder: UploadFolder.kyc('trader'),
                  onUploaded: (key) => _docs['Farm / warehouse photo'] = key,
                ),
                const SizedBox(height: WBSpacing.lg),
                const KycSectionLabel(
                  label: 'Settlement',
                  sub: 'Where we release escrow once a sale clears.',
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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.placeholder,
    required this.onTap,
    this.value,
  });

  final String placeholder;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: WBColors.surfaceInput,
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: WBTypography.body.copyWith(
                  color:
                      value != null ? WBColors.fgHeader : WBColors.fgPlaceholder,
                  fontSize: 15,
                ),
              ),
            ),
            const WBIcon(WBIconName.chevronDown,
                size: 14, color: WBColors.fgPlaceholder),
          ],
        ),
      ),
    );
  }
}
