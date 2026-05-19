import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/rider_controller.dart';

/// Post-delivery screen — confirms earnings, surfaces the customer rating
/// + optional tip, then clears the active delivery and routes back to
/// the rider's map.
class RiderDeliveryCompleteScreen extends StatefulWidget {
  const RiderDeliveryCompleteScreen({super.key});

  @override
  State<RiderDeliveryCompleteScreen> createState() =>
      _RiderDeliveryCompleteScreenState();
}

class _RiderDeliveryCompleteScreenState
    extends State<RiderDeliveryCompleteScreen> {
  int? _tip;
  int _stars = 5;

  void _finish() {
    final earnings = (RiderController.instance.active.value?.offer.feeNaira ?? 0) +
        (_tip ?? 0);
    RiderController.instance.clearActive();
    wbShowSnack(context, 'Delivery wrapped · ${wbNaira(earnings)} earned');
    context.go(AppRoutes.riderHome);
  }

  @override
  Widget build(BuildContext context) {
    final offer = RiderController.instance.active.value?.offer;
    final base = offer?.feeNaira ?? 0;
    final total = base + (_tip ?? 0);

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                160,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: _finish),
                    const SizedBox(width: 14),
                    Text('Delivery complete', style: WBTypography.page),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(WBSpacing.lg),
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EARNED',
                        style: WBTypography.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wbNaira(total),
                        style: WBTypography.hero.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tip == null
                            ? 'Base fare ${wbNaira(base)}'
                            : 'Base ${wbNaira(base)} · tip ${wbNaira(_tip!)}',
                        style: WBTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'Rate the customer',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Helps us match polite customers to friendly riders.',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < 5; i++)
                        GestureDetector(
                          onTap: () => setState(() => _stars = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: WBIcon(
                              WBIconName.star,
                              size: 36,
                              color: i < _stars
                                  ? WBColors.fgHeader
                                  : WBColors.bgDivider,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'Add a tip',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sent straight to your wallet on top of the base fare.',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final amt in const [0, 200, 500, 1000])
                      _TipChip(
                        amount: amt,
                        selected: _tip == (amt == 0 ? null : amt),
                        onTap: () =>
                            setState(() => _tip = amt == 0 ? null : amt),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding,
                    0,
                    WBSpacing.screenPadding,
                    18,
                  ),
                  child: WBButton(
                    label: 'Back to map',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    trailingIcon: WBIconName.arrowRight,
                    onPressed: _finish,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });
  final int amount;
  final bool selected;
  final VoidCallback onTap;

  String get _label => amount == 0 ? 'None' : wbNaira(amount);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: WBMotion.base,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? WBColors.surfaceDark : WBColors.surfaceCard,
              borderRadius: BorderRadius.circular(WBRadius.card),
              border: Border.all(
                color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _label,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selected ? Colors.white : WBColors.fgHeader,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
