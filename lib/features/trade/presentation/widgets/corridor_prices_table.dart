import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/corridor.dart';
import '../../domain/models/corridor_price.dart';

/// Read-only corridor-prices table. Shared by the customer-side `/trade`
/// browse and the trader-side market-reference screen. Renders a sticky
/// commodity column on the left and one column per corridor on the right.
class CorridorPricesTable extends StatelessWidget {
  const CorridorPricesTable({super.key, required this.rows});
  final List<CorridorPrice> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          for (var i = 0; i < rows.length; i++) ...[
            _Row(row: rows[i]),
            if (i != rows.length - 1) const WBDivider(),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: const BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.card)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 96,
            child: Text(
              'COMMODITY',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.66,
                color: WBColors.fgPlaceholder,
              ),
            ),
          ),
          for (final c in Corridor.values)
            Expanded(
              child: Text(
                c.short,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.66,
                  color: WBColors.fgPlaceholder,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});
  final CorridorPrice row;

  @override
  Widget build(BuildContext context) {
    final trendUp = row.trend >= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.produce,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    WBIcon(
                      trendUp ? WBIconName.arrowRight : WBIconName.arrowLeft,
                      size: 9,
                      color: trendUp
                          ? const Color(0xFF047857)
                          : const Color(0xFFB91C1C),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${(row.trend * 100).abs().toStringAsFixed(1)}%',
                      style: WBTypography.caption.copyWith(
                        fontSize: 10,
                        color: trendUp
                            ? const Color(0xFF047857)
                            : const Color(0xFFB91C1C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/${row.unit}',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgPlaceholder,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          for (final c in Corridor.values)
            Expanded(
              child: Text(
                wbThousands(row.prices[c] ?? 0),
                textAlign: TextAlign.right,
                style: WBTypography.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
