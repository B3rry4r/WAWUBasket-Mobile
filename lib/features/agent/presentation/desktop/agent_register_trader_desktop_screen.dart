import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../application/agent_controller.dart';

/// Desktop-web layout for the agent "register new trader" form. Pushed
/// operator screen: wraps its body in [OperatorDesktopScaffold] so the agent
/// sidebar stays visible. Mirrors the mobile screen's controllers, validation,
/// save action, business-type selection, l10n and navigation exactly; only
/// the layout differs (a two-column form/aside split with an inline save bar).
class AgentRegisterTraderDesktopScreen extends StatefulWidget {
  const AgentRegisterTraderDesktopScreen({super.key});

  @override
  State<AgentRegisterTraderDesktopScreen> createState() =>
      _AgentRegisterTraderDesktopScreenState();
}

class _AgentRegisterTraderDesktopScreenState
    extends State<AgentRegisterTraderDesktopScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  String _typeKey = 'farmer';

  static const _types = [
    ('farmer', 'Farmer'),
    ('trader', 'Trader'),
    ('processor', 'Processor'),
    ('other', 'Other'),
  ];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.agentRegNamePhoneRequired);
      return;
    }
    AgentController.instance.addTrader(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      location: _location.text.trim(),
      type: BusinessTypeX.fromKey(_typeKey),
    );
    wbShowSnack(context, context.l10n.agentRegSavedOffline);
    context.go(AppRoutes.agentTraders);
  }

  @override
  Widget build(BuildContext context) {
    return OperatorDesktopScaffold(
      role: AppRole.agent,
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.xl,
            WBSpacing.xl,
            WBSpacing.xl,
            48,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.agentRegNewTraderTitle,
                        style: WBTypography.page,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.agentRegisterSetUp,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                WBButton(
                  label: 'Save trader',
                  size: WBButtonSize.lg,
                  onPressed: _save,
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn = constraints.maxWidth >= 880;
                final form = _DetailsCard(
                  name: _name,
                  phone: _phone,
                  location: _location,
                  typeKey: _typeKey,
                  types: _types,
                  onType: (k) => setState(() => _typeKey = k),
                );
                final aside = _CaptureCard();
                if (!twoColumn) {
                  return Column(
                    children: [
                      form,
                      const SizedBox(height: WBSpacing.lg),
                      aside,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: form),
                    const SizedBox(width: WBSpacing.lg),
                    Expanded(flex: 2, child: aside),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.name,
    required this.phone,
    required this.location,
    required this.typeKey,
    required this.types,
    required this.onType,
  });

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController location;
  final String typeKey;
  final List<(String, String)> types;
  final ValueChanged<String> onType;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WBInput(
            label: context.l10n.agentRegFullNameLabel,
            placeholder: context.l10n.agentRegFullNamePlaceholder,
            controller: name,
          ),
          const SizedBox(height: WBSpacing.md),
          WBInput(
            label: context.l10n.agentRegPhoneLabel,
            placeholder: context.l10n.agentRegPhonePlaceholder,
            controller: phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: WBSpacing.md),
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
              for (final t in types)
                WBTag(
                  label: t.$2,
                  active: t.$1 == typeKey,
                  onTap: () => onType(t.$1),
                ),
            ],
          ),
          const SizedBox(height: WBSpacing.md),
          WBInput(
            label: context.l10n.agentRegLocationLabel,
            placeholder: context.l10n.agentRegLocationPlaceholder,
            controller: location,
          ),
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.user,
                  label: context.l10n.agentRegPhotoLabel,
                  onTap: () => wbShowSnack(context, 'Camera opened'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PhotoSquare(
                  icon: WBIconName.card,
                  label: context.l10n.agentRegIdLabel,
                  onTap: () => wbShowSnack(context, 'Camera opened'),
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Row(
              children: [
                const WBIcon(WBIconName.bell, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.agentRegisterOffline,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSquare extends StatelessWidget {
  const _PhotoSquare({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Container(
          decoration: BoxDecoration(
            color: WBColors.bgSoft,
            borderRadius: BorderRadius.circular(WBRadius.card),
            border: Border.all(color: WBColors.bgDivider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: WBColors.bgPrimary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: WBIcon(icon, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgHeader,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to capture',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
