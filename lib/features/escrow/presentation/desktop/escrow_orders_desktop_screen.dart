import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/escrow_controller.dart';
import '../../domain/models/bulk_order.dart';

/// Desktop-web layout for the buyer's escrow-backed bulk orders list. Re-lays
/// the mobile single-column list into a centered, wider grid inside the shared
/// customer web chrome. Reuses [EscrowController] and the [BulkOrder] model
/// unchanged — this is layout only. Pushed screen: wrapped in
/// [CustomerWebScaffold].
class EscrowOrdersDesktopScreen extends StatefulWidget {
  const EscrowOrdersDesktopScreen({super.key});

  @override
  State<EscrowOrdersDesktopScreen> createState() =>
      _EscrowOrdersDesktopScreenState();
}

class _EscrowOrdersDesktopScreenState extends State<EscrowOrdersDesktopScreen> {
  @override
  void initState() {
    super.initState();
    EscrowController.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        child: ValueListenableBuilder<List<BulkOrder>>(
          valueListenable: EscrowController.instance.orders,
          builder: (_, orders, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.xl,
                WBSpacing.xl,
                WBSpacing.xl,
                40,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WBBackChip(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go(AppRoutes.home),
                        ),
                        const SizedBox(height: WBSpacing.lg),
                        Text(
                          context.l10n.escrowBulkOrdersTitle,
                          style: WBTypography.page,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Escrow-protected purchases.',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                        const SizedBox(height: WBSpacing.xl),
                        if (orders.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: WBColors.bgSoft,
                              borderRadius: BorderRadius.circular(WBRadius.card),
                            ),
                            child: Text(
                              context.l10n.escrowOrdersEmpty,
                              style: WBTypography.body.copyWith(
                                color: WBColors.fgSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const _OrdersGridDelegate(),
                            itemCount: orders.length,
                            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Two-column grid tuned for the centered 960-wide content column, sized so the
/// escrow order cards keep a comfortable row layout.
class _OrdersGridDelegate extends SliverGridDelegateWithMaxCrossAxisExtent {
  const _OrdersGridDelegate()
      : super(
          maxCrossAxisExtent: 480,
          mainAxisSpacing: WBSpacing.md,
          crossAxisSpacing: WBSpacing.md,
          mainAxisExtent: 88,
        );
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order});
  final BulkOrder order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _hovered = false;

  (String, WBStatusKind) get _pill {
    final order = widget.order;
    switch (order.status) {
      case EscrowStatus.pending:
        return ('Payment pending', WBStatusKind.info);
      case EscrowStatus.held:
        return (order.markedDeliveredBySeller
            ? 'Awaiting confirmation'
            : 'Held', WBStatusKind.info);
      case EscrowStatus.released:
        return ('Released', WBStatusKind.success);
      case EscrowStatus.refunded:
        return ('Refunded', WBStatusKind.info);
      case EscrowStatus.disputed:
        return ('Disputed', WBStatusKind.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final pill = _pill;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push('${AppRoutes.escrowStatus}/${order.id}'),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(WBRadius.card),
            boxShadow: _hovered ? WBShadows.float : WBShadows.card,
          ),
          padding: const EdgeInsets.all(WBSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: WBNetworkImage(url: order.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${order.produce} · ${order.quantityKg} kg',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        WBStatusPill(label: pill.$1, kind: pill.$2),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.sellerName} · ${wbNaira(order.totalNaira)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const WBIcon(
                WBIconName.chevronRight,
                size: 16,
                color: WBColors.fgPlaceholder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
