import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';

class VendorSettingsScreen extends StatefulWidget {
  const VendorSettingsScreen({super.key});

  @override
  State<VendorSettingsScreen> createState() => _VendorSettingsScreenState();
}

class _VendorSettingsScreenState extends State<VendorSettingsScreen> {
  bool _holiday = false;
  double _prep = 25;
  double _radius = 8;
  bool _pushOrders = true;
  bool _pushLowStock = true;
  bool _emailReports = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Text('Store settings', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel(label: 'Store hours'),
            const SizedBox(height: 10),
            WBCard(
              child: Column(
                children: [
                  _HoursRow(day: 'Mon – Fri', hours: '8:00 am – 10:00 pm'),
                  const SizedBox(height: 10),
                  _HoursRow(day: 'Saturday', hours: '9:00 am – 11:00 pm'),
                  const SizedBox(height: 10),
                  _HoursRow(day: 'Sunday', hours: 'Closed'),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel(label: 'Preparation time'),
            const SizedBox(height: 10),
            WBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average ${_prep.toInt()} minutes',
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: WBColors.surfaceDark,
                      inactiveTrackColor: WBColors.bgDivider,
                      thumbColor: WBColors.surfaceDark,
                      overlayColor:
                          WBColors.surfaceDark.withValues(alpha: 0.1),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _prep,
                      min: 5,
                      max: 90,
                      divisions: 17,
                      onChanged: (v) => setState(() => _prep = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel(label: 'Delivery radius'),
            const SizedBox(height: 10),
            WBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Within ${_radius.toInt()} km',
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: WBColors.surfaceDark,
                      inactiveTrackColor: WBColors.bgDivider,
                      thumbColor: WBColors.surfaceDark,
                      overlayColor:
                          WBColors.surfaceDark.withValues(alpha: 0.1),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _radius,
                      min: 1,
                      max: 25,
                      divisions: 24,
                      onChanged: (v) => setState(() => _radius = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel(label: 'Notifications'),
            const SizedBox(height: 10),
            WBCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Toggle(
                    label: 'New order alerts',
                    sub: 'Push + email',
                    value: _pushOrders,
                    onChanged: (v) => setState(() => _pushOrders = v),
                  ),
                  const WBDivider(),
                  _Toggle(
                    label: 'Low stock alerts',
                    sub: 'Push only',
                    value: _pushLowStock,
                    onChanged: (v) => setState(() => _pushLowStock = v),
                  ),
                  const WBDivider(),
                  _Toggle(
                    label: 'Weekly reports',
                    sub: 'Email',
                    value: _emailReports,
                    onChanged: (v) => setState(() => _emailReports = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel(label: 'Holiday mode'),
            const SizedBox(height: 10),
            WBCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _holiday ? 'On vacation' : 'Open as usual',
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Pause new orders until you're back.",
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _holiday,
                    activeThumbColor: WBColors.surfaceDark,
                    onChanged: (v) => setState(() => _holiday = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel(label: 'Account'),
            const SizedBox(height: 10),
            WBCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Tap(
                    icon: WBIconName.user,
                    label: 'Switch role',
                    sub: 'Customer · Rider · Trade Agent',
                    onTap: () => context.push(AppRoutes.roleSelect),
                  ),
                  const WBDivider(),
                  _Tap(
                    icon: WBIconName.close,
                    label: 'Sign out',
                    sub: 'End your vendor session',
                    danger: true,
                    onTap: () {
                      RoleController.instance.signOut();
                      context.go(AppRoutes.welcome);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Save changes',
              size: WBButtonSize.lg,
              fullWidth: true,
              onPressed: () => wbShowSnack(context, 'Settings saved'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: WBTypography.label.copyWith(
        color: WBColors.fgPlaceholder,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.66,
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.hours});
  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: WBTypography.body.copyWith(fontSize: 14)),
        Text(
          hours,
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: hours == 'Closed' ? WBColors.fgSecondary : WBColors.fgHeader,
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: WBColors.surfaceDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Tap extends StatelessWidget {
  const _Tap({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.danger = false,
  });
  final WBIconName icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: danger
                    ? const Color(0x14EF4444)
                    : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                icon,
                size: 16,
                color: danger ? WBColors.statusError : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color:
                          danger ? WBColors.statusError : WBColors.fgHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const WBIcon(
              WBIconName.chevronRight,
              size: 16,
              color: WBColors.fgPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}
