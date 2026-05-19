import 'corridor.dart';

/// One commodity's last-known price across the corridors we cover.
/// Values are in NGN per kg so the table reads cleanly without per-row
/// currency conversion (FX layer lives in a later batch).
class CorridorPrice {
  const CorridorPrice({
    required this.produce,
    required this.unit,
    required this.prices,
    required this.trend,
  });

  final String produce;
  final String unit; // e.g. "kg", "bag", "crate"
  final Map<Corridor, int> prices;

  /// 7-day % change vs last week. Positive = price rose.
  final double trend;
}
