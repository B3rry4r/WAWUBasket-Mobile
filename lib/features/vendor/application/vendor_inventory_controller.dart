import 'package:flutter/foundation.dart';

/// Categorises an inventory line. Batch-tracked kinds carry a harvest /
/// slaughter date so the UI can surface freshness.
enum InventoryKind { dryGoods, produce, livestock, packaged }

class InventoryItem {
  InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.threshold,
    required this.kind,
    this.batchId,
    this.batchDate,
  });

  final String id;
  String name;
  final String unit; // e.g. "kg", "bags", "packs"
  double stock;
  double threshold;
  InventoryKind kind;
  String? batchId;
  DateTime? batchDate;

  /// True when stock is at or below the low-stock threshold.
  bool get isLow => stock <= threshold && stock > 0;

  /// True when there's literally none left.
  bool get isOut => stock <= 0;
}

class VendorInventoryController {
  VendorInventoryController._()
      : items = ValueNotifier<List<InventoryItem>>([]) {
    items.value = _seed();
  }
  static final VendorInventoryController instance =
      VendorInventoryController._();

  final ValueNotifier<List<InventoryItem>> items;

  InventoryItem? byId(String id) {
    for (final i in items.value) {
      if (i.id == id) return i;
    }
    return null;
  }

  void update({
    required String id,
    double? stock,
    double? threshold,
    DateTime? batchDate,
    String? batchId,
  }) {
    final it = byId(id);
    if (it == null) return;
    if (stock != null) it.stock = stock;
    if (threshold != null) it.threshold = threshold;
    if (batchDate != null) it.batchDate = batchDate;
    if (batchId != null) it.batchId = batchId;
    _bump();
  }

  void _bump() => items.value = List.of(items.value);

  List<InventoryItem> _seed() => [
        InventoryItem(
          id: 'inv-rice',
          name: 'Long grain rice',
          unit: 'kg',
          stock: 48,
          threshold: 10,
          kind: InventoryKind.dryGoods,
        ),
        InventoryItem(
          id: 'inv-tomato',
          name: 'Tomatoes',
          unit: 'baskets',
          stock: 6,
          threshold: 8,
          kind: InventoryKind.produce,
          batchId: 'B-2026-0518',
          batchDate: DateTime(2026, 5, 18),
        ),
        InventoryItem(
          id: 'inv-goat',
          name: 'Goat meat',
          unit: 'kg',
          stock: 0,
          threshold: 5,
          kind: InventoryKind.livestock,
          batchId: 'B-2026-0517',
          batchDate: DateTime(2026, 5, 17),
        ),
        InventoryItem(
          id: 'inv-suya',
          name: 'Suya pepper',
          unit: 'packs',
          stock: 12,
          threshold: 5,
          kind: InventoryKind.packaged,
        ),
        InventoryItem(
          id: 'inv-plantain',
          name: 'Plantain',
          unit: 'bunches',
          stock: 4,
          threshold: 6,
          kind: InventoryKind.produce,
          batchId: 'B-2026-0519',
          batchDate: DateTime(2026, 5, 19),
        ),
        InventoryItem(
          id: 'inv-onion',
          name: 'Onions',
          unit: 'bags',
          stock: 14,
          threshold: 6,
          kind: InventoryKind.produce,
          batchId: 'B-2026-0515',
          batchDate: DateTime(2026, 5, 15),
        ),
      ];
}
