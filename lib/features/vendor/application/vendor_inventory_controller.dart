import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/vendor_api.dart';

/// Categorises an inventory line. Batch-tracked kinds carry a harvest /
/// slaughter date so the UI can surface freshness.
enum InventoryKind { dryGoods, produce, livestock, packaged }

InventoryKind _kindFrom(String s) => switch (s) {
      'produce' => InventoryKind.produce,
      'livestock' => InventoryKind.livestock,
      'packaged' => InventoryKind.packaged,
      _ => InventoryKind.dryGoods,
    };

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

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        unit: (j['unit'] ?? 'kg').toString(),
        stock: (j['stock'] as num?)?.toDouble() ?? 0,
        threshold: (j['threshold'] as num?)?.toDouble() ?? 0,
        kind: _kindFrom('${j['kind'] ?? ''}'),
        batchId: j['batchId'] as String?,
        batchDate: DateTime.tryParse('${j['batchDate'] ?? ''}'),
      );
}

/// Live inventory store backed by `/v1/vendor/inventory`. Screens listen
/// to [items]; edits update optimistically and POST to the API.
class VendorInventoryController {
  VendorInventoryController._()
      : items = ValueNotifier<List<InventoryItem>>([]) {
    load();
  }
  static final VendorInventoryController instance =
      VendorInventoryController._();

  final ValueNotifier<List<InventoryItem>> items;
  final _api = VendorApi.instance;

  InventoryItem? byId(String id) {
    for (final i in items.value) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Pulls the latest inventory from the API.
  Future<void> load() async {
    try {
      final raw = await _api.listInventory();
      items.value = [
        for (final e in raw)
          InventoryItem.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh will retry.
    }
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
    _sync(id, stock, threshold, batchDate, batchId);
  }

  Future<void> _sync(
    String id,
    double? stock,
    double? threshold,
    DateTime? batchDate,
    String? batchId,
  ) async {
    final body = <String, dynamic>{
      'stock': ?stock,
      'threshold': ?threshold,
      'batchId': ?batchId,
      'batchDate': ?batchDate?.toUtc().toIso8601String(),
    };
    if (body.isEmpty) return;
    try {
      await _api.updateInventoryItem(id, body);
    } on ApiException {
      // Keep the optimistic edit; the next refresh reconciles it.
    }
  }

  void _bump() => items.value = List.of(items.value);
}
