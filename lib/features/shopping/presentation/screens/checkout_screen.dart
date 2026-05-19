import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../widgets/sticky_action_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _payment = 'card';
  bool _scheduled = false;
  _ScheduleSlot? _slot;

  static const _payOptions = [
    (id: 'card', icon: WBIconName.card, label: 'Debit card', sub: '•••• 4218'),
    (id: 'wallet', icon: WBIconName.star, label: 'Wallet', sub: 'Balance ₦12,500'),
    (id: 'xfer', icon: WBIconName.arrowRight, label: 'Bank transfer', sub: 'Pay directly from app'),
    (id: 'mobile', icon: WBIconName.phone, label: 'Mobile money', sub: 'OPay, Palmpay, others'),
  ];

  String get _scheduleSubtitle {
    if (_slot == null) return 'Pick a time slot';
    return '${_slot!.dateLabel} · ${_slot!.timeLabel}';
  }

  Future<void> _openScheduleSheet() async {
    final picked = await showModalBottomSheet<_ScheduleSlot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleSheet(initial: _slot),
    );
    if (picked != null) {
      setState(() {
        _slot = picked;
        _scheduled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
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
                    Text('Checkout', style: WBTypography.page),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                _Section(
                  label: 'Where are we sending this?',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: WBColors.bgSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const WBIcon(WBIconName.pin, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2118 Thornridge Cir',
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Surulere, Lagos · Apt 4B',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.savedAddresses),
                        child: Text(
                          'Change',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                _Section(
                  label: 'When do you want it?',
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeOption(
                          label: 'Order now',
                          sub: 'Arrives in 25–35 min',
                          active: !_scheduled,
                          onTap: () => setState(() {
                            _scheduled = false;
                            _slot = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TimeOption(
                          label: 'Schedule',
                          sub: _scheduleSubtitle,
                          active: _scheduled,
                          onTap: _openScheduleSheet,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                _Section(
                  label: 'How will you pay?',
                  child: Column(
                    children: [
                      for (final o in _payOptions) ...[
                        _PaymentTile(
                          id: o.id,
                          icon: o.icon,
                          label: o.label,
                          sub: o.sub,
                          selected: o.id == _payment,
                          onTap: () => setState(() => _payment = o.id),
                        ),
                        if (o.id != _payOptions.last.id) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                _Section(
                  label: 'Your basket',
                  child: Column(
                    children: [
                      const _Line(label: 'Jollof rice × 2', value: '₦9,000'),
                      const SizedBox(height: 10),
                      const _Line(label: 'Suya platter × 1', value: '₦4,800'),
                      const SizedBox(height: 14),
                      const WBDivider(),
                      const SizedBox(height: 14),
                      const _Line(label: 'Delivery', value: '₦600'),
                      const SizedBox(height: 8),
                      const _Line(label: 'Service fee', value: '₦200'),
                      const SizedBox(height: 14),
                      const WBDivider(),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₦14,600',
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                      ),
                      children: const [
                        TextSpan(text: 'By placing this order you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: WBColors.fgHeader,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionBar(
              child: WBButton(
                label: 'Place order',
                fullWidth: true,
                size: WBButtonSize.lg,
                trailing: const Text(
                  '₦14,600',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => context.go(AppRoutes.tracking),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.md + 2),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: WBTypography.label.copyWith(
              fontWeight: FontWeight.w600,
              color: WBColors.fgPlaceholder,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.label,
    required this.sub,
    required this.active,
    required this.onTap,
  });
  final String label;
  final String sub;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? WBColors.surfaceDark : WBColors.bgSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: WBTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              style: WBTypography.caption.copyWith(
                color: active
                    ? Colors.white.withValues(alpha: 0.65)
                    : WBColors.fgSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.id,
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
  final String id;
  final WBIconName icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? WBColors.bgPrimary : WBColors.bgSoft,
          border: Border.all(
            color: selected ? WBColors.borderFilled : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: WBColors.bgSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sub,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? WBColors.surfaceDark : Colors.transparent,
                border: Border.all(
                  color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 10,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WBTypography.secondary),
        Text(
          value,
          style: WBTypography.secondary.copyWith(
            color: WBColors.fgHeader,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ScheduleSlot {
  const _ScheduleSlot({
    required this.dateKey,
    required this.dateLabel,
    required this.timeKey,
    required this.timeLabel,
  });
  final String dateKey;
  final String dateLabel;
  final String timeKey;
  final String timeLabel;
}

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({this.initial});
  final _ScheduleSlot? initial;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  late String _dateKey = widget.initial?.dateKey ?? _dates.first.$1;
  String? _timeKey;

  @override
  void initState() {
    super.initState();
    _timeKey = widget.initial?.timeKey;
  }

  static final List<(String, String)> _dates = _buildDates();

  static List<(String, String)> _buildDates() {
    final now = DateTime.now();
    String fmt(DateTime d, int offset) {
      if (offset == 0) return 'Today';
      if (offset == 1) return 'Tomorrow';
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${d.day} ${months[d.month - 1]}';
    }

    return [
      for (var i = 0; i < 5; i++)
        ('d$i', fmt(now.add(Duration(days: i)), i)),
    ];
  }

  static const _slots = [
    ('s1', '11 am – 12 pm'),
    ('s2', '12 – 1 pm'),
    ('s3', '1 – 2 pm'),
    ('s4', '2 – 3 pm'),
    ('s5', '3 – 4 pm'),
    ('s6', '4 – 5 pm'),
    ('s7', '5 – 6 pm'),
    ('s8', '6 – 7 pm'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: WBColors.bgDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Schedule delivery',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a date and time slot',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'DATE',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final d = _dates[i];
                  return WBTag(
                    label: d.$2,
                    active: d.$1 == _dateKey,
                    onTap: () => setState(() => _dateKey = d.$1),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'TIME SLOT',
              style: WBTypography.label.copyWith(
                color: WBColors.fgPlaceholder,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final s in _slots)
                  WBTag(
                    label: s.$2,
                    active: s.$1 == _timeKey,
                    onTap: () => setState(() => _timeKey = s.$1),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            WBButton(
              label: 'Confirm time slot',
              fullWidth: true,
              size: WBButtonSize.lg,
              onPressed: _timeKey == null
                  ? null
                  : () {
                      final date = _dates.firstWhere(
                        (d) => d.$1 == _dateKey,
                      );
                      final slot = _slots.firstWhere(
                        (s) => s.$1 == _timeKey,
                      );
                      Navigator.of(context).pop(
                        _ScheduleSlot(
                          dateKey: date.$1,
                          dateLabel: date.$2,
                          timeKey: slot.$1,
                          timeLabel: slot.$2,
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
