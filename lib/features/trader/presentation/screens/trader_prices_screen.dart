import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/presentation/widgets/corridor_prices_table.dart';

/// Read-only corridor price reference for the trader. Same table the
/// customer sees in `/trade`; identical surface keeps the visual
/// continuity Excel asked for.
class TraderPricesScreen extends StatefulWidget {
  const TraderPricesScreen({super.key});

  @override
  State<TraderPricesScreen> createState() => _TraderPricesScreenState();
}

class _TraderPricesScreenState extends State<TraderPricesScreen> {
  @override
  void initState() {
    super.initState();
    TradeController.instance.loadPrices();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: TradeController.instance.prices,
        builder: (_, rows, _) => ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            140,
          ),
          children: [
            Text('Market prices', style: WBTypography.page),
            const SizedBox(height: 4),
            Text(
              'Last-known corridor prices. Use them to set yours fairly.',
              style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            CorridorPricesTable(rows: rows),
            const SizedBox(height: 12),
            Text(
              'Prices in ₦ per unit. Updated daily from corridor trades.',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgPlaceholder,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
