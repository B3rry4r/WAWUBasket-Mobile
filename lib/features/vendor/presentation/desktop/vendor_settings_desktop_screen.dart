import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../data/vendor_api.dart';

/// Desktop-web layout for vendor store settings. Re-lays the mobile
/// [VendorSettingsScreen] into a two-column dashboard inside the persistent
/// operator sidebar chrome. Data loading, save payload, slider ranges, holiday
/// picker, status logic, actions and l10n keys mirror the mobile screen
/// exactly — only the layout changes.
class VendorSettingsDesktopScreen extends StatefulWidget {
  const VendorSettingsDesktopScreen({super.key});

  @override
  State<VendorSettingsDesktopScreen> createState() =>
      _VendorSettingsDesktopScreenState();
}

class _VendorSettingsDesktopScreenState
    extends State<VendorSettingsDesktopScreen> {
  bool _holiday = false;
  DateTimeRange? _holidayRange;
  double _prep = 25;
  double _radius = 8;
  bool _pushOrders = true;
  bool _pushLowStock = true;
  bool _emailReports = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await VendorApi.instance.settings();
      final j = (res as Map).cast<String, dynamic>();
      if (!mounted) return;
      final hs = DateTime.tryParse('${j['holidayStart'] ?? ''}');
      final he = DateTime.tryParse('${j['holidayEnd'] ?? ''}');
      setState(() {
        _holiday = j['holidayMode'] == true;
        if (hs != null && he != null) {
          _holidayRange = DateTimeRange(start: hs, end: he);
        }
        _prep = ((j['prepMins'] as num?)?.toDouble() ?? _prep)
            .clamp(5, 90)
            .toDouble();
        _radius = ((j['deliveryRadiusKm'] as num?)?.toDouble() ?? _radius)
            .clamp(1, 25)
            .toDouble();
        _pushOrders = j['notifyNewOrders'] != false;
        _pushLowStock = j['notifyLowStock'] != false;
        _emailReports = j['emailReports'] == true;
        _loading = false;
      });
    } on ApiException {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await VendorApi.instance.updateSettings({
        'holidayMode': _holiday,
        if (_holiday && _holidayRange != null)
          'holidayStart': _holidayRange!.start.toUtc().toIso8601String(),
        if (_holiday && _holidayRange != null)
          'holidayEnd': _holidayRange!.end.toUtc().toIso8601String(),
        'prepMins': _prep.toInt(),
        'deliveryRadiusKm': _radius,
        'notifyNewOrders': _pushOrders,
        'notifyLowStock': _pushLowStock,
        'emailReports': _emailReports,
      });
      if (mounted) wbShowSnack(context, context.l10n.vendorSettingsSaved);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickHolidayRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _holidayRange,
      helpText: 'Pick your holiday window',
    );
    if (picked != null) setState(() => _holidayRange = picked);
  }

  String _holidayLabel() {
    if (!_holiday) return 'Open as usual';
    final r = _holidayRange;
    if (r == null) return 'Holiday mode on';
    final s = r.start;
    final e = r.end;
    return 'Closed ${s.day}/${s.month} → ${e.day}/${e.month}';
  }

  @override
  Widget build(BuildContext context) {
    return OperatorDesktopScaffold(
      role: AppRole.vendor,
      child: _loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.xl,
                vertical: WBSpacing.xl,
              ),
              children: [
                WBMaxWidth(
                  maxWidth: WBBreakpoints.maxContent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PageHeader(saving: _saving, onSave: _save),
                      const SizedBox(height: WBSpacing.xl),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column — operations
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel(
                                  label: context.l10n.vendorSettingsStoreHours,
                                ),
                                const SizedBox(height: 10),
                                WBCard(
                                  child: Column(
                                    children: const [
                                      _HoursRow(
                                        day: 'Mon – Fri',
                                        hours: '8:00 am – 10:00 pm',
                                      ),
                                      SizedBox(height: 10),
                                      _HoursRow(
                                        day: 'Saturday',
                                        hours: '9:00 am – 11:00 pm',
                                      ),
                                      SizedBox(height: 10),
                                      _HoursRow(
                                        day: 'Sunday',
                                        hours: 'Closed',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: WBSpacing.lg),
                                _SectionLabel(label: 'Preparation time'),
                                const SizedBox(height: 10),
                                WBCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Average ${_prep.toInt()} minutes',
                                        style: WBTypography.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      _DarkSlider(
                                        value: _prep,
                                        min: 5,
                                        max: 90,
                                        divisions: 17,
                                        onChanged: (v) =>
                                            setState(() => _prep = v),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: WBSpacing.lg),
                                _SectionLabel(label: 'Delivery radius'),
                                const SizedBox(height: 10),
                                WBCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Within ${_radius.toInt()} km',
                                        style: WBTypography.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      _DarkSlider(
                                        value: _radius,
                                        min: 1,
                                        max: 25,
                                        divisions: 24,
                                        onChanged: (v) =>
                                            setState(() => _radius = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: WBSpacing.xl),
                          // Right column — notifications + holiday
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel(
                                  label: context.l10n.operatorNotifications,
                                ),
                                const SizedBox(height: 10),
                                WBCard(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      _Toggle(
                                        label: context.l10n.vendorHomeAlerts,
                                        sub: context.l10n.vendorNotifPushEmail,
                                        value: _pushOrders,
                                        onChanged: (v) =>
                                            setState(() => _pushOrders = v),
                                      ),
                                      const WBDivider(),
                                      _Toggle(
                                        label:
                                            context.l10n.vendorHomeInventory,
                                        sub: context.l10n.vendorNotifPushOnly,
                                        value: _pushLowStock,
                                        onChanged: (v) =>
                                            setState(() => _pushLowStock = v),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: WBSpacing.lg),
                                _SectionLabel(label: 'Holiday mode'),
                                const SizedBox(height: 10),
                                WBCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _holidayLabel(),
                                                  style: WBTypography.body
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "Pause new orders until you're back.",
                                                  style: WBTypography.caption
                                                      .copyWith(
                                                    color:
                                                        WBColors.fgSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch.adaptive(
                                            value: _holiday,
                                            activeThumbColor:
                                                WBColors.surfaceDark,
                                            onChanged: (v) =>
                                                setState(() => _holiday = v),
                                          ),
                                        ],
                                      ),
                                      if (_holiday) ...[
                                        const SizedBox(height: 10),
                                        WBButton(
                                          label: _holidayRange == null
                                              ? 'Pick dates'
                                              : 'Change dates',
                                          size: WBButtonSize.sm,
                                          variant: WBButtonVariant.secondary,
                                          onPressed: _pickHolidayRange,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.saving, required this.onSave});
  final bool saving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WBBackChip(onPressed: () => context.pop()),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            context.l10n.vendorSettingsTitle,
            style: WBTypography.page,
          ),
        ),
        WBButton(
          label: context.l10n.actionSave,
          size: WBButtonSize.md,
          loading: saving,
          onPressed: onSave,
        ),
      ],
    );
  }
}

class _DarkSlider extends StatelessWidget {
  const _DarkSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: WBColors.surfaceDark,
        inactiveTrackColor: WBColors.bgDivider,
        thumbColor: WBColors.surfaceDark,
        overlayColor: WBColors.surfaceDark.withValues(alpha: 0.1),
        trackHeight: 3,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
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
