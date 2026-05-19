import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _groups = [
    _Group(
      date: 'Today',
      items: [
        _Notif(
          icon: WBIconName.bike,
          title: 'Tunde is on the way',
          body: 'Your order from Mama Cass Kitchen arrives in 12 min.',
          time: '12:31',
          unread: true,
        ),
        _Notif(
          icon: WBIconName.check,
          title: 'Order confirmed',
          body: 'Mama Cass has accepted your order. Preparing now.',
          time: '12:29',
          unread: true,
        ),
        _Notif(
          icon: WBIconName.star,
          title: '20% off your next order',
          body: 'Use code WELCOME20 before Sunday.',
          time: '09:00',
          unread: false,
        ),
      ],
    ),
    _Group(
      date: 'Yesterday',
      items: [
        _Notif(
          icon: WBIconName.check,
          title: 'Delivered',
          body: 'Your order from The Daily Grain was delivered.',
          time: '18:44',
          unread: false,
        ),
        _Notif(
          icon: WBIconName.card,
          title: 'Payment confirmed',
          body: '₦7,400 deducted for order #8804.',
          time: '18:01',
          unread: false,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Text('Notifications', style: WBTypography.page),
                  ],
                ),
                GestureDetector(
                  onTap: () => wbShowSnack(context, 'All notifications marked read'),
                  child: Text(
                    'Mark all read',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            for (final group in _groups) ...[
              Text(
                group.date.toUpperCase(),
                style: WBTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WBColors.fgPlaceholder,
                  letterSpacing: 0.66,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  boxShadow: WBShadows.card,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < group.items.length; i++) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // Order-related notifications land on tracking;
                          // promotional ones surface a snackbar.
                          final n = group.items[i];
                          if (n.icon == WBIconName.bike ||
                              n.icon == WBIconName.check) {
                            context.push(AppRoutes.tracking);
                          } else {
                            wbShowSnack(context, n.title);
                          }
                        },
                        child: _NotifRow(notif: group.items[i]),
                      ),
                      if (i != group.items.length - 1) const WBDivider(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _Group {
  const _Group({required this.date, required this.items});
  final String date;
  final List<_Notif> items;
}

class _Notif {
  const _Notif({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });
  final WBIconName icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({required this.notif});
  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notif.unread ? const Color(0x04000000) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: WBColors.bgSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: WBIcon(notif.icon, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: WBTypography.body.copyWith(
                          fontSize: 14,
                          fontWeight: notif.unread
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notif.time,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.body,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (notif.unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: WBColors.statusInfo,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
