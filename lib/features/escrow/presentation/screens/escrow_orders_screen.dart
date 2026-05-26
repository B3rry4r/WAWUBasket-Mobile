import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/escrow_controller.dart';
import '../../domain/models/bulk_order.dart';

/// Buyer-side list of every escrow-backed bulk order they've placed.
/// Tap into an order to confirm delivery, release funds, or open a
/// dispute via [EscrowStatusScreen].
class EscrowOrdersScreen extends StatefulWidget {
  const EscrowOrdersScreen({super.key});

  @override
  State<EscrowOrdersScreen> createState() => _EscrowOrdersScreenState();
}

class _EscrowOrdersScreenState extends State<EscrowOrdersScreen> {
  @override
  void initState() {
    super.initState();
    EscrowController.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: EscrowController.instance.orders,
          builder: (_, orders, _) {
            return ListView(
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
                          Text('Bulk orders', style: WBTypography.page),
                          Text(
                            'Escrow-protected purchases.',
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
                  for (final o in orders)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OrderRow(order: o),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final BulkOrder order;

  (String, WBStatusKind) get _pill {
    switch (order.status) {
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
    final pill = _pill;
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.escrowStatus}/${order.id}'),
      behavior: HitTestBehavior.opaque,
      child: WBCard(
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
    );
  }
}
