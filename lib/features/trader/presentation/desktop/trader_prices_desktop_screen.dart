import 'package:flutter/material.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/presentation/widgets/corridor_prices_table.dart';

/// Desktop-web layout for the trader market-prices reference.
///
/// TAB screen: the trader role shell supplies the sidebar and chrome, so this
/// renders body content only. Re-lays the mobile single-column list into a
/// capped dashboard surface — a page header up top, then the same read-only
/// [CorridorPricesTable] the mobile screen (and the customer `/trade` browse)
/// show. Reuses [TradeController.loadPrices], its `prices` notifier, the same
/// table widget and the exact mobile copy; this is layout only.
class TraderPricesDesktopScreen extends StatefulWidget {
  const TraderPricesDesktopScreen({super.key});

  @override
  State<TraderPricesDesktopScreen> createState() =>
      _TraderPricesDesktopScreenState();
}

class _TraderPricesDesktopScreenState extends State<TraderPricesDesktopScreen> {
  @override
  void initState() {
    super.initState();
    TradeController.instance.loadPrices();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: TradeController.instance.prices,
      builder: (_, rows, _) => WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xxl,
        ),
        child: ListView(
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
            const SizedBox(height: WBSpacing.xl),
            // The table has a fixed-layout structure; cap it to a comfortable
            // reading width so it stays legible on wide monitors instead of
            // stretching corridor columns edge to edge.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: CorridorPricesTable(rows: rows),
            ),
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
