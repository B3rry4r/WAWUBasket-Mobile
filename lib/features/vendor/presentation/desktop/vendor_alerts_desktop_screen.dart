import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../data/vendor_api.dart';

/// Desktop-web layout for the vendor alerts screen. Pushed operator screen:
/// wraps its body in [OperatorDesktopScaffold] so the vendor sidebar stays
/// visible. Mirrors the mobile data loading, status mapping, formatting,
/// empty/error handling and navigation exactly; only the layout differs.
class VendorAlertsDesktopScreen extends StatefulWidget {
  const VendorAlertsDesktopScreen({super.key});

  @override
  State<VendorAlertsDesktopScreen> createState() =>
      _VendorAlertsDesktopScreenState();
}

class _VendorAlertsDesktopScreenState extends State<VendorAlertsDesktopScreen> {
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
    return OperatorDesktopScaffold(
      role: AppRole.vendor,
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
                        context.l10n.vendorAlertsTitle,
                        style: WBTypography.page,
                      ),
                      const SizedBox(height: 2),
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
            const SizedBox(height: WBSpacing.xl),
            if (alerts == null && _error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  ),
                ),
              )
            else if (_error != null)
              _Hint(text: _error!)
            else if (alerts!.isEmpty)
              _Hint(text: context.l10n.vendorAlertsEmpty)
            else
              _AlertGrid(alerts: alerts),
          ],
        ),
      ),
    );
  }
}

class _AlertGrid extends StatelessWidget {
  const _AlertGrid({required this.alerts});

  final List<_Alert> alerts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 880 ? 2 : 1;
        const gap = WBSpacing.md;
        final tileWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final a in alerts)
              SizedBox(
                width: tileWidth,
                child: _AlertRow(
                  icon: a.icon,
                  label: a.label,
                  sub: a.sub,
                  kind: a.kind,
                  cta: a.cta,
                  onTap: () => context.push(a.route),
                ),
              ),
          ],
        );
      },
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
    return WBCard(
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
          const SizedBox(width: 12),
          WBButton(
            label: cta,
            size: WBButtonSize.sm,
            variant: WBButtonVariant.secondary,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
