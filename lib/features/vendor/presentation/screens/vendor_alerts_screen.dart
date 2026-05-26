import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/vendor_api.dart';

class VendorAlertsScreen extends StatefulWidget {
  const VendorAlertsScreen({super.key});

  @override
  State<VendorAlertsScreen> createState() => _VendorAlertsScreenState();
}

class _VendorAlertsScreenState extends State<VendorAlertsScreen> {
  List<_Alert>? _alerts;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final raw = await VendorApi.instance.alerts();
      if (!mounted) return;
      setState(() => _alerts = [
            for (final e in raw)
              _Alert.fromJson((e as Map).cast<String, dynamic>()),
          ]);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  String get _subtitle {
    final n = _alerts?.length ?? 0;
    if (n == 0) return "You're all caught up.";
    return n == 1
        ? '1 thing needs your attention.'
        : '$n things need your attention.';
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _alerts;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.vendorAlertsTitle, style: WBTypography.page),
                      Text(
                        _subtitle,
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
            if (alerts == null && _error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
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
              _Hint(text: _error!)
            else if (alerts!.isEmpty)
              _Hint(text: context.l10n.vendorAlertsEmpty)
            else
              for (final a in alerts)
                _AlertRow(
                  icon: a.icon,
                  label: a.label,
                  sub: a.sub,
                  kind: a.kind,
                  cta: a.cta,
                  onTap: () => context.push(a.route),
                ),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

/// A vendor alert mapped from the `/v1/vendor/alerts` payload onto the
/// presentation fields the row needs.
class _Alert {
  const _Alert({
    required this.icon,
    required this.label,
    required this.sub,
    required this.kind,
    required this.cta,
    required this.route,
  });

  final WBIconName icon;
  final String label;
  final String sub;
  final WBStatusKind kind;
  final String cta;
  final String route;

  factory _Alert.fromJson(Map<String, dynamic> j) {
    final type = (j['type'] ?? '').toString();
    final title = (j['title'] ?? 'Alert').toString();
    final at = DateTime.tryParse('${j['at'] ?? ''}')?.toLocal();
    final sub = _ago(at);
    return switch (type) {
      'inventory.low' => _Alert(
          icon: WBIconName.basket,
          label: title,
          sub: 'Restock to keep accepting orders',
          kind: WBStatusKind.warning,
          cta: 'Restock',
          route: AppRoutes.vendorInventory,
        ),
      'order.disputed' => _Alert(
          icon: WBIconName.bell,
          label: title,
          sub: sub,
          kind: WBStatusKind.error,
          cta: 'Review',
          route: AppRoutes.vendorOrders,
        ),
      _ => _Alert(
          icon: WBIconName.bell,
          label: title,
          sub: sub,
          kind: WBStatusKind.info,
          cta: 'View',
          route: AppRoutes.vendorOrders,
        ),
    };
  }
}

String _ago(DateTime? t) {
  if (t == null) return 'Just now';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.kind,
    required this.cta,
    required this.onTap,
  });

  final WBIconName icon;
  final String label;
  final String sub;
  final WBStatusKind kind;
  final String cta;
  final VoidCallback onTap;

  Color get _accent => switch (kind) {
        WBStatusKind.error => const Color(0xFFEF4444),
        WBStatusKind.warning => const Color(0xFFB45309),
        WBStatusKind.info => WBColors.fgHeader,
        WBStatusKind.success => const Color(0xFF065F46),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WBCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 16, color: _accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
            WBButton(
              label: cta,
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
