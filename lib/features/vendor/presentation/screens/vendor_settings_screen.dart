import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/vendor_api.dart';

class VendorSettingsScreen extends StatefulWidget {
  const VendorSettingsScreen({super.key});

  @override
  State<VendorSettingsScreen> createState() => _VendorSettingsScreenState();
}

class _StaffMember {
  _StaffMember({required this.name, required this.role, required this.email});
  String name;
  String role;
  String email;
}

class _VendorSettingsScreenState extends State<VendorSettingsScreen> {
  bool _holiday = false;
  DateTimeRange? _holidayRange;
  double _prep = 25;
  double _radius = 8;
  bool _pushOrders = true;
  bool _pushLowStock = true;
  bool _emailReports = true;
  bool _loading = true;
  bool _saving = false;

  final List<_StaffMember> _staff = [
    _StaffMember(name: 'Adunni Adesanya', role: 'Manager', email: 'adunni@mama-cass.ng'),
    _StaffMember(name: 'Sade Akin', role: 'Cashier', email: 'sade@mama-cass.ng'),
    _StaffMember(name: 'Femi Bello', role: 'Cook', email: 'femi@mama-cass.ng'),
  ];

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
      if (mounted) wbShowSnack(context, 'Settings saved');
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
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

  void _addStaff() {
    showModalBottomSheet<_StaffMember>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (_) => const _StaffSheet(),
    ).then((m) {
      if (m == null || !mounted) return;
      setState(() => _staff.add(m));
      wbShowSnack(context, 'Invited ${m.name} as ${m.role.toLowerCase()}');
    });
  }

  void _removeStaff(_StaffMember m) {
    setState(() => _staff.remove(m));
    wbShowSnack(context, '${m.name} removed');
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
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor:
                        AlwaysStoppedAnimation(WBColors.surfaceDark),
                  ),
                ),
              )
            : ListView(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _holidayLabel(),
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

            const SizedBox(height: WBSpacing.lg),
            Row(
              children: [
                Expanded(child: _SectionLabel(label: 'Staff accounts')),
                WBButton(
                  label: 'Invite',
                  size: WBButtonSize.sm,
                  trailingIcon: WBIconName.plus,
                  onPressed: _addStaff,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_staff.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                ),
                child: Text(
                  'No staff yet. Invite a manager, cashier or cook.',
                  style: WBTypography.body.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 14,
                  ),
                ),
              )
            else
              WBCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < _staff.length; i++) ...[
                      _StaffRow(
                        member: _staff[i],
                        onRemove: () => _removeStaff(_staff[i]),
                      ),
                      if (i != _staff.length - 1) const WBDivider(),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: 'Save changes',
              size: WBButtonSize.lg,
              fullWidth: true,
              loading: _saving,
              onPressed: _save,
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

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.member, required this.onRemove});
  final _StaffMember member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const WBIcon(WBIconName.user, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.role} · ${member.email}',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: const WBIcon(
                WBIconName.close,
                size: 14,
                color: WBColors.fgPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffSheet extends StatefulWidget {
  const _StaffSheet();

  @override
  State<_StaffSheet> createState() => _StaffSheetState();
}

class _StaffSheetState extends State<_StaffSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  String _role = 'Cashier';
  static const _roles = ['Manager', 'Cashier', 'Cook'];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _name.text.trim().isNotEmpty && _email.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + WBSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          Text(
            'Invite a staff member',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBInput(
            label: 'Full name',
            controller: _name,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: WBSpacing.md),
          WBInput(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: WBSpacing.md),
          Text(
            'ROLE',
            style: WBTypography.label.copyWith(
              fontWeight: FontWeight.w600,
              color: WBColors.fgPlaceholder,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final r in _roles)
                WBTag(
                  label: r,
                  active: r == _role,
                  onTap: () => setState(() => _role = r),
                ),
            ],
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Send invite',
            size: WBButtonSize.lg,
            fullWidth: true,
            disabled: !canSend,
            onPressed: canSend
                ? () => Navigator.of(context).pop(
                      _StaffMember(
                        name: _name.text.trim(),
                        role: _role,
                        email: _email.text.trim(),
                      ),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}
