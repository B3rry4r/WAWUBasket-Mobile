import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/notifications_controller.dart';
import '../../data/account_extras_api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

WBIconName _iconFrom(String s) => switch (s) {
      'bike' => WBIconName.bike,
      'check' => WBIconName.check,
      'star' => WBIconName.star,
      'card' => WBIconName.card,
      _ => WBIconName.bell,
    };

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_Notif>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!GuestModeController.instance.isGuest.value) _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final res = await AccountExtrasApi.instance.notifications();
      final raw = (res['items'] as List?) ?? const [];
      if (!mounted) return;
      final items = [
        for (final e in raw)
          _Notif.fromJson((e as Map).cast<String, dynamic>()),
      ];
      setState(() => _items = items);
      // Sync the badge with the real unread count.
      NotificationsController.instance.unreadCount.value =
          items.where((n) => n.unread).length;
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _markAll() async {
    final items = _items;
    if (items == null) return;
    setState(() => _items = [for (final n in items) n.copyRead()]);
    NotificationsController.instance.markAllRead();
    try {
      await AccountExtrasApi.instance.markAllNotificationsRead();
      if (mounted) wbShowSnack(context, context.l10n.notificationsAllRead);
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    }
  }

  void _open(_Notif n) {
    if (n.unread) {
      setState(() => _items = [
            for (final cur in _items ?? const <_Notif>[])
              cur.id == n.id ? cur.copyRead() : cur,
          ]);
      NotificationsController.instance.decrement();
      AccountExtrasApi.instance.markNotificationRead(n.id).catchError((_) {});
    }
    if (n.icon == WBIconName.bike || n.icon == WBIconName.check) {
      final path = n.orderId != null
          ? '${AppRoutes.tracking}?orderId=${n.orderId}'
          : AppRoutes.tracking;
      context.push(path);
    } else {
      wbShowSnack(context, n.title);
    }
  }

  /// Groups notifications under Today / Yesterday / date headers.
  List<({String label, List<_Notif> items})> get _grouped {
    final items = _items ?? const <_Notif>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final order = <String>[];
    final map = <String, List<_Notif>>{};
    for (final n in items) {
      final d = DateTime(n.at.year, n.at.month, n.at.day);
      final diff = today.difference(d).inDays;
      final label = diff <= 0
          ? 'Today'
          : diff == 1
              ? 'Yesterday'
              : '${n.at.day} ${_months[n.at.month - 1]}';
      if (!map.containsKey(label)) {
        order.add(label);
        map[label] = [];
      }
      map[label]!.add(n);
    }
    return [for (final l in order) (label: l, items: map[l]!)];
  }

  Widget _buildGuest(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            80 + MediaQuery.of(context).padding.top,
            WBSpacing.screenPadding,
            120,
          ),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: const WBIcon(WBIconName.bell, size: 36, color: WBColors.fgHeader),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                'Stay in the loop',
                textAlign: TextAlign.center,
                style: WBTypography.hero.copyWith(fontSize: 22),
              ),
              const SizedBox(height: WBSpacing.sm),
              Text(
                'Sign in to receive order updates, delivery alerts and promotions.',
                textAlign: TextAlign.center,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: 'Sign in',
                size: WBButtonSize.lg,
                fullWidth: true,
                trailingIcon: WBIconName.arrowRight,
                onPressed: () => context.push(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GuestModeController.instance.isGuest,
      builder: (_, isGuest, _) {
        if (isGuest) return _buildGuest(context);
        return _buildSignedIn(context);
      },
    );
  }

  Widget _buildSignedIn(BuildContext context) {
    final items = _items;
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
                    Text(context.l10n.notificationsTitle, style: WBTypography.page),
                  ],
                ),
                GestureDetector(
                  onTap: _markAll,
                  child: Text(
                    context.l10n.notificationsMarkAllRead,
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
            if (items == null && _error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 56),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor:
                          AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  ),
                ),
              )
            else if (_error != null)
              _hint(_error!)
            else if (items!.isEmpty)
              _hint(context.l10n.notificationsEmpty)
            else
              for (final group in _grouped) ...[
                Text(
                  group.label.toUpperCase(),
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
                          onTap: () => _open(group.items[i]),
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

  Widget _hint(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(WBSpacing.md + 4),
        decoration: BoxDecoration(
          color: WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Text(
          text,
          style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
        ),
      );
}

class _Notif {
  const _Notif({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.at,
    required this.unread,
    this.orderId,
  });

  final String id;
  final WBIconName icon;
  final String title;
  final String body;
  final DateTime at;
  final bool unread;
  final String? orderId;

  String get time =>
      '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

  _Notif copyRead() => _Notif(
        id: id,
        icon: icon,
        title: title,
        body: body,
        at: at,
        unread: false,
        orderId: orderId,
      );

  factory _Notif.fromJson(Map<String, dynamic> j) => _Notif(
        id: (j['id'] ?? '').toString(),
        icon: _iconFrom('${j['icon'] ?? 'bell'}'),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
        at: DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
            DateTime.now(),
        unread: j['read'] != true,
        orderId: j['orderId']?.toString(),
      );
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
