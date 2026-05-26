import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../application/escrow_controller.dart';
import '../../domain/models/bulk_order.dart';

/// Shared escrow detail screen. Renders the same order from either the
/// buyer or the seller perspective, exposing the actions appropriate to
/// the current [AppRole].
class EscrowStatusScreen extends StatelessWidget {
  const EscrowStatusScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: EscrowController.instance.orders,
          builder: (_, _, _) {
            final o = EscrowController.instance.byId(orderId);
            if (o == null) {
              return Padding(
                padding: const EdgeInsets.all(WBSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(height: WBSpacing.xl),
                    Text(context.l10n.escrowStatusNotFound, style: WBTypography.page),
                    const SizedBox(height: WBSpacing.sm),
                    Text(
                      'It may have been refunded and cleared.',
                      style: WBTypography.body.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return _Body(order: o);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.order});
  final BulkOrder order;

  bool get _isSeller => RoleController.instance.role == AppRole.trader;

  void _confirmDelivery(BuildContext context) {
    EscrowController.instance.release(order.id);
    wbShowSnack(
      context,
      'Funds released to ${order.sellerName} · ${wbNaira(order.totalNaira)}',
    );
  }

  void _markDelivered(BuildContext context) {
    EscrowController.instance.markDeliveredBySeller(order.id);
    wbShowSnack(
      context,
      'Buyer notified, waiting on their confirmation to release funds.',
    );
  }

  @override
  Widget build(BuildContext context) {
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
            WBBackChip(onPressed: () => context.canPop()
                ? context.pop()
                : context.go(_isSeller ? AppRoutes.traderHome : AppRoutes.home)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${order.id}', style: WBTypography.page),
                  Text(
                    _isSeller ? 'Incoming order' : 'Your bulk order',
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
        _StatusHero(order: order),
        const SizedBox(height: WBSpacing.lg),
        _Timeline(order: order),
        const SizedBox(height: WBSpacing.lg),
        _LotCard(order: order),
        const SizedBox(height: WBSpacing.lg),
        _PartyCard(
          tag: _isSeller ? 'BUYER' : 'SELLER',
          title: _isSeller ? order.buyerName : order.sellerName,
          sub: _isSeller ? order.buyerPhone : order.sellerRegion,
          callable: true,
          icon: WBIconName.user,
        ),
        const SizedBox(height: WBSpacing.md),
        WBCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: WBIcon(WBIconName.pin, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DROP-OFF',
                      style: WBTypography.label.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.dropoffAddress,
                      style: WBTypography.body.copyWith(
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        Text(
          'Totals',
          style: WBTypography.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 10),
        WBCard(
          child: Column(
            children: [
              _TotalRow(
                label: '${order.quantityKg} kg × ${wbNaira(order.pricePerKgNaira)}',
                value: wbNaira(order.subtotalNaira),
              ),
              const SizedBox(height: 6),
              _TotalRow(label: 'WAWU fee', value: wbNaira(order.feeNaira)),
              const SizedBox(height: 6),
              _TotalRow(
                label: 'Paid via ${order.method.label}',
                value: _formatTime(order.placedAt),
              ),
              const SizedBox(height: 10),
              const WBDivider(),
              const SizedBox(height: 10),
              _TotalRow(
                label: 'Total held in escrow',
                value: wbNaira(order.totalNaira),
                emphasised: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        if (order.status == EscrowStatus.disputed && order.disputeReason != null)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: WBSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0x14F59E0B),
              borderRadius: BorderRadius.circular(WBRadius.card),
              border: Border.all(color: const Color(0x33F59E0B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISPUTE OPEN',
                  style: WBTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.disputeReason!,
                  style: WBTypography.body.copyWith(fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.escrowStatusReviewNote,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
        if (order.status == EscrowStatus.held) ...[
          if (_isSeller) ...[
            WBButton(
              label: order.markedDeliveredBySeller
                  ? 'Buyer notified · waiting on release'
                  : 'Mark delivered',
              fullWidth: true,
              size: WBButtonSize.lg,
              trailingIcon: order.markedDeliveredBySeller
                  ? null
                  : WBIconName.arrowRight,
              disabled: order.markedDeliveredBySeller,
              onPressed: order.markedDeliveredBySeller
                  ? null
                  : () => _markDelivered(context),
            ),
            const SizedBox(height: 10),
            WBButton(
              label: 'Report issue',
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () =>
                  context.push('${AppRoutes.escrowDispute}/${order.id}'),
            ),
          ] else ...[
            WBButton(
              label: 'Confirm delivery & release funds',
              fullWidth: true,
              size: WBButtonSize.lg,
              trailingIcon: WBIconName.check,
              onPressed: () => _confirmDelivery(context),
            ),
            const SizedBox(height: 10),
            WBButton(
              label: 'Open dispute',
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () =>
                  context.push('${AppRoutes.escrowDispute}/${order.id}'),
            ),
          ],
        ] else if (order.status == EscrowStatus.released) ...[
          WBButton(
            label: context.l10n.actionDone,
            fullWidth: true,
            size: WBButtonSize.lg,
            onPressed: () => context.go(
              _isSeller ? AppRoutes.traderHome : AppRoutes.home,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime d) {
    final now = DateTime.now();
    final h = now.difference(d).inHours;
    if (h < 1) return 'Just now';
    if (h < 24) return '${h}h ago';
    return '${now.difference(d).inDays}d ago';
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.order});
  final BulkOrder order;

  Color get _accent => switch (order.status) {
        EscrowStatus.held => const Color(0xFF10B981),
        EscrowStatus.released => const Color(0xFF10B981),
        EscrowStatus.refunded => const Color(0xFF6B7280),
        EscrowStatus.disputed => const Color(0xFFF59E0B),
      };

  WBIconName get _icon => switch (order.status) {
        EscrowStatus.held => WBIconName.card,
        EscrowStatus.released => WBIconName.check,
        EscrowStatus.refunded => WBIconName.arrowLeft,
        EscrowStatus.disputed => WBIconName.bell,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.lg),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: WBIcon(_icon, size: 22, color: _accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.label,
                  style: WBTypography.hero.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wbNaira(order.totalNaira),
                  style: WBTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});
  final BulkOrder order;

  @override
  Widget build(BuildContext context) {
    // Always 4 conceptual steps so the line length doesn't jump when the
    // status changes. Refund / dispute light up step 3 instead of 4.
    final isReleased = order.status == EscrowStatus.released;
    final isRefunded = order.status == EscrowStatus.refunded;
    final isDisputed = order.status == EscrowStatus.disputed;
    final steps = <_Step>[
      _Step(label: 'Paid', done: true),
      _Step(label: 'Held in escrow', done: true),
      _Step(
        label: order.markedDeliveredBySeller || isReleased
            ? 'Out for delivery'
            : 'Awaiting delivery',
        done: order.markedDeliveredBySeller || isReleased,
      ),
      _Step(
        label: isReleased
            ? 'Released'
            : isRefunded
                ? 'Refunded'
                : isDisputed
                    ? 'In review'
                    : 'Confirm receipt',
        done: isReleased || isRefunded,
        warning: isDisputed,
      ),
    ];

    return WBCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left rail: 20px wide column holding the dot and the
                  // vertical connector that runs to the next dot. Sharing
                  // a single column guarantees pixel-perfect alignment
                  // between the dot's centre and the line.
                  SizedBox(
                    width: 20,
                    child: Column(
                      children: [
                        _StepDot(
                          done: steps[i].done,
                          warning: steps[i].warning,
                        ),
                        if (i != steps.length - 1)
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 2,
                                color: steps[i + 1].done
                                    ? WBColors.surfaceDark
                                    : WBColors.bgDivider,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 1,
                        bottom: i == steps.length - 1 ? 0 : 14,
                      ),
                      child: Text(
                        steps[i].label,
                        style: WBTypography.body.copyWith(
                          fontWeight: steps[i].done || steps[i].warning
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                          color: steps[i].done || steps[i].warning
                              ? WBColors.fgHeader
                              : WBColors.fgPlaceholder,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Step {
  const _Step({required this.label, required this.done, this.warning = false});
  final String label;
  final bool done;
  final bool warning;
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.done, required this.warning});
  final bool done;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    Color fill;
    if (warning) {
      fill = const Color(0xFFF59E0B);
    } else if (done) {
      fill = WBColors.surfaceDark;
    } else {
      fill = WBColors.bgSoft;
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: done || warning
          ? const WBIcon(
              WBIconName.check,
              size: 10,
              color: Colors.white,
              strokeWidth: 2.5,
            )
          : null,
    );
  }
}

class _LotCard extends StatelessWidget {
  const _LotCard({required this.order});
  final BulkOrder order;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: WBNetworkImage(url: order.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.produce,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.quantityKg} kg · ${wbNaira(order.pricePerKgNaira)}/kg',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.tag,
    required this.title,
    required this.sub,
    required this.callable,
    required this.icon,
  });
  final String tag;
  final String title;
  final String sub;
  final bool callable;
  final WBIconName icon;

  @override
  Widget build(BuildContext context) {
    return WBCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: Text(
              tag,
              style: WBTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.66,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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
          if (callable)
            WBButton(
              label: 'Call',
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              trailingIcon: WBIconName.phone,
              onPressed: () => wbShowSnack(context, 'Calling $title…'),
            ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });
  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: WBTypography.body.copyWith(
            fontSize: emphasised ? 15 : 14,
            color: emphasised ? WBColors.fgHeader : WBColors.fgSecondary,
            fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: WBTypography.body.copyWith(
            fontSize: emphasised ? 17 : 14,
            fontWeight: emphasised ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
