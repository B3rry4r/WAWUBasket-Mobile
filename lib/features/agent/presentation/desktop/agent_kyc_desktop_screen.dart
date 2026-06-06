import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../auth/data/kyc_api.dart';
import '../../../auth/presentation/widgets/kyc_widgets.dart';

/// Desktop-web layout for [AgentKycScreen]. Pre-auth: the user is not in the
/// operator shell, so this renders a centered form column with the brand
/// wordmark and a back chip — no sidebar. Behaviour (controllers, document
/// map, zones, submit) is mirrored exactly from the mobile screen; only the
/// layout is re-arranged. Shown ONLY at desktop width and isolated from the
/// mobile build.
class AgentKycDesktopScreen extends StatefulWidget {
  const AgentKycDesktopScreen({super.key});

  @override
  State<AgentKycDesktopScreen> createState() => _AgentKycDesktopScreenState();
}

class _AgentKycDesktopScreenState extends State<AgentKycDesktopScreen> {
  String _zone = 'mile-12';
  bool _busy = false;
  final Map<String, String> _docs = {};

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _union = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();

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
      RoleController.instance.markPending(AppRole.agent);
      wbShowSnack(context, context.l10n.kycSubmitted);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.roleSelect);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        wbShowError(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: WBSpacing.xl,
              vertical: WBSpacing.xl,
            ),
            child: WBMaxWidth(
              maxWidth: 520,
              alignment: Alignment.center,
              child: _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WBWMark(size: 32),
        const SizedBox(height: WBSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WBBackChip(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apply to be an agent', style: WBTypography.page),
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
          sub: 'For identity match at every payout.',
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
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: 'Submit application',
          fullWidth: true,
          size: WBButtonSize.lg,
          trailingIcon: WBIconName.arrowRight,
          loading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
