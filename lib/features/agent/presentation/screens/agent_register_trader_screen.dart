import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/agent_controller.dart';

class AgentRegisterTraderScreen extends StatefulWidget {
  const AgentRegisterTraderScreen({super.key});

  @override
  State<AgentRegisterTraderScreen> createState() =>
      _AgentRegisterTraderScreenState();
}

class _AgentRegisterTraderScreenState
    extends State<AgentRegisterTraderScreen> {
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
      wbShowSnack(context, 'Name and phone are required.');
      return;
    }
    AgentController.instance.addTrader(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      location: _location.text.trim(),
      type: BusinessTypeX.fromKey(_typeKey),
    );
    wbShowSnack(context, 'Trader saved offline · will sync next');
    context.go(AppRoutes.agentTraders);
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
                          Text('New trader', style: WBTypography.page),
                          Text(
                            context.l10n.agentRegisterSetUp,
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
                WBInput(
                  label: 'Full name',
                  placeholder: 'Full name as on ID',
                  controller: _name,
                ),
                const SizedBox(height: WBSpacing.md),
                WBInput(
                  label: 'Phone number',
                  placeholder: '812 345 6789',
                  controller: _phone,
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
                  children: [
                    for (final t in _types)
                      WBTag(
                        label: t.$2,
                        active: t.$1 == _typeKey,
                        onTap: () => setState(() => _typeKey = t.$1),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                WBInput(
                  label: 'Location',
                  placeholder: 'Market or village name',
                  controller: _location,
                ),
                const SizedBox(height: WBSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _PhotoSquare(
                        icon: WBIconName.user,
                        label: 'Trader photo',
                        onTap: () => wbShowSnack(context, 'Camera opened'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PhotoSquare(
                        icon: WBIconName.card,
                        label: 'ID document',
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
                    label: 'Save trader',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: _save,
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
