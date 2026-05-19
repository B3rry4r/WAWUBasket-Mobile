import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  String _tab = 'pending';
  static const _tabs = [
    ('pending', 'Pending'),
    ('preparing', 'Preparing'),
    ('ready', 'Ready'),
    ('done', 'Done'),
  ];

  static const _orders = [
    (id: 'WAWU-8821', cust: 'Adunni', items: 'Jollof × 2, Suya × 1', total: '₦9,300', mins: '4 min', stage: 'pending'),
    (id: 'WAWU-8822', cust: 'Tobi', items: 'Egusi & pounded yam', total: '₦5,200', mins: '7 min', stage: 'pending'),
    (id: 'WAWU-8820', cust: 'Kemi', items: 'Plantain & beans', total: '₦3,200', mins: '12 min', stage: 'preparing'),
    (id: 'WAWU-8819', cust: 'Daniel', items: 'Suya platter', total: '₦4,800', mins: '18 min', stage: 'preparing'),
    (id: 'WAWU-8817', cust: 'Funke', items: 'Small chops', total: '₦3,500', mins: '24 min', stage: 'ready'),
    (id: 'WAWU-8810', cust: 'Yemi', items: 'Jollof & chicken', total: '₦4,500', mins: '1 hr', stage: 'done'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = [
      for (final o in _orders)
        if (o.stage == _tab) o,
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12,
          WBSpacing.screenPadding,
          140,
        ),
        children: [
          Text('Live orders', style: WBTypography.page),
          const SizedBox(height: 4),
          Text(
            'The ones waiting for your magic.',
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => WBTag(
                label: _tabs[i].$2,
                active: _tabs[i].$1 == _tab,
                onTap: () => setState(() => _tab = _tabs[i].$1),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Text(
                'No orders right now. Time to take a breath.',
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
            )
          else
            for (final o in filtered)
              _OrderCard(
                id: o.id,
                customer: o.cust,
                items: o.items,
                total: o.total,
                mins: o.mins,
                stage: o.stage,
                onAction: (label) => wbShowSnack(context, '$label · #${o.id}'),
              ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.mins,
    required this.stage,
    required this.onAction,
  });
  final String id;
  final String customer;
  final String items;
  final String total;
  final String mins;
  final String stage;
  final ValueChanged<String> onAction;

  (String, WBStatusKind) get _status {
    switch (stage) {
      case 'pending':
        return ('Pending', WBStatusKind.warning);
      case 'preparing':
        return ('Preparing', WBStatusKind.info);
      case 'ready':
        return ('Ready', WBStatusKind.success);
      default:
        return ('Done', WBStatusKind.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WBCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#$id',
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                WBStatusPill(label: s.$1, kind: s.$2),
                const Spacer(),
                Text(
                  mins,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              customer,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(items, style: WBTypography.body.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  total,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (stage == 'pending') ...[
                  WBButton(
                    label: 'Decline',
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    onPressed: () => onAction('Declined'),
                  ),
                  const SizedBox(width: 8),
                  WBButton(
                    label: 'Accept',
                    size: WBButtonSize.sm,
                    onPressed: () => onAction('Accepted'),
                  ),
                ] else if (stage == 'preparing')
                  WBButton(
                    label: 'Mark ready',
                    size: WBButtonSize.sm,
                    onPressed: () => onAction('Marked ready'),
                  )
                else if (stage == 'ready')
                  WBButton(
                    label: 'Print ticket',
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    onPressed: () => onAction('Ticket printed'),
                  )
                else
                  WBButton(
                    label: 'Receipt',
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    onPressed: () => onAction('Receipt opened'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
