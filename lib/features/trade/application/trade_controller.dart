import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/trade_api.dart';
import '../domain/models/bulk_lot.dart';
import '../domain/models/corridor.dart';
import '../domain/models/corridor_price.dart';
import '../domain/models/export_listing.dart';
import '../domain/models/supplier.dart';

int _money(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

/// Single source of truth for trader-posted export listings + market
/// corridor prices. Both the customer-side `/trade` browse and the
/// trader-side dashboard subscribe to it; each calls the load method
/// that suits its audience.
class TradeController {
  TradeController._()
      : listings = ValueNotifier<List<ExportListing>>([]),
        prices = ValueNotifier<List<CorridorPrice>>([]),
        suppliers = ValueNotifier<List<Supplier>>([]),
        bulkLots = ValueNotifier<List<BulkLot>>([]),
        mutationError = ValueNotifier<String?>(null);
  static final TradeController instance = TradeController._();

  final ValueNotifier<List<ExportListing>> listings;
  final ValueNotifier<List<CorridorPrice>> prices;
  final ValueNotifier<List<Supplier>> suppliers;
  final ValueNotifier<List<BulkLot>> bulkLots;

  /// Non-null when an update or remove call fails. Screens can listen and
  /// show a snackbar, then reset to null.
  final ValueNotifier<String?> mutationError;

  final _api = TradeApi.instance;

  /// True for a listing that exists only in this session's optimistic
  /// state — its create call may still be in flight.
  bool _isLocal(String id) => id.startsWith('EXP-');

  ExportListing? byId(String id) {
    for (final l in listings.value) {
      if (l.id == id) return l;
    }
    return null;
  }

  Supplier? supplierById(String id) {
    for (final s in suppliers.value) {
      if (s.id == id) return s;
    }
    return null;
  }

  BulkLot? bulkLotById(String id) {
    for (final l in bulkLots.value) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Public supplier directory for the customer trade browse.
  Future<void> loadSuppliers() async {
    try {
      final raw = await _api.suppliers();
      suppliers.value = [
        for (final e in raw)
          Supplier.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place.
    }
  }

  /// Public wholesale-lot board for the customer trade browse.
  Future<void> loadBulkLots() async {
    try {
      final raw = await _api.bulkLots();
      bulkLots.value = [
        for (final e in raw)
          BulkLot.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place.
    }
  }

  /// Trader dashboard — the signed-in trader's own listings.
  Future<void> loadMyListings() async {
    try {
      final raw = await _api.myExportListings();
      listings.value = [
        for (final e in raw)
          ExportListing.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh retries.
    }
  }

  /// Customer `/trade` browse — every active public listing.
  Future<void> loadPublicListings() async {
    try {
      final raw = await _api.publicExportListings();
      listings.value = [
        for (final e in raw)
          ExportListing.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place.
    }
  }

  /// Market corridor prices — shown to traders and customers alike.
  Future<void> loadPrices() async {
    try {
      final raw = await _api.corridorPrices();
      prices.value = _mapPrices(raw);
    } on ApiException {
      // Leave the current prices in place.
    }
  }

  String add(ExportListing l) {
    listings.value = [l, ...listings.value];
    _create(l);
    return l.id;
  }

  void update(ExportListing l) {
    listings.value = [for (final cur in listings.value) if (cur.id == l.id) l else cur];
    if (!_isLocal(l.id)) {
      _api.updateExportListing(l.id, {
        'produce': l.produce,
        'quantityKg': l.quantityKg,
        'pricePerKgNaira': l.pricePerKgNaira,
        'harvestDate': l.harvestDate.toUtc().toIso8601String(),
        'originCorridor': l.originCorridor.name,
        'destinationCorridor': l.destinationCorridor.name,
        'farmName': l.farmName,
        'farmRegion': l.farmRegion,
        'status': l.status.name,
      }).catchError((Object e) {
        if (e is ApiException) mutationError.value = e.message;
      });
    }
  }

  void remove(String id) {
    final removed = byId(id);
    listings.value = [for (final l in listings.value) if (l.id != id) l];
    if (!_isLocal(id)) {
      _api.deleteExportListing(id).catchError((Object e) {
        if (e is ApiException) mutationError.value = e.message;
        if (removed != null) listings.value = [removed, ...listings.value];
      });
    }
  }

  /// Bumps the enquiry tally when a buyer taps the enquiry CTA. Local
  /// only — there is no enquiry endpoint yet.
  void recordEnquiry(String id) {
    final l = byId(id);
    if (l == null) return;
    l.enquiries += 1;
    listings.value = List.of(listings.value);
  }

  Future<void> _create(ExportListing l) async {
    try {
      await _api.createExportListing({
        'produce': l.produce,
        'quantityKg': l.quantityKg,
        'pricePerKgNaira': l.pricePerKgNaira,
        'harvestDate': l.harvestDate.toUtc().toIso8601String(),
        'originCorridor': l.originCorridor.name,
        'destinationCorridor': l.destinationCorridor.name,
        'farmName': l.farmName,
        'farmRegion': l.farmRegion,
        if (l.imageUrl.isNotEmpty) 'imageKey': l.imageUrl,
        if (l.category != null) 'category': l.category,
      });
      // Replace the optimistic EXP-<timestamp> row with the real server record.
      await loadMyListings();
    } on ApiException {
      // Keep the optimistic row; the trader can retry the save.
    }
  }

  /// Reshapes the API's per-(produce, origin) price rows into one
  /// [CorridorPrice] per produce, merging every destination price seen.
  List<CorridorPrice> _mapPrices(List<dynamic> raw) {
    final order = <String>[];
    final merged = <String, Map<Corridor, int>>{};
    final meta = <String, ({String unit, double trend})>{};
    for (final r in raw) {
      final m = (r as Map).cast<String, dynamic>();
      final produce = (m['produce'] ?? '').toString();
      if (produce.isEmpty) continue;
      if (!merged.containsKey(produce)) {
        order.add(produce);
        merged[produce] = {};
        final tp = (m['trendPct'] as num?)?.toDouble() ?? 0;
        meta[produce] = (
          unit: (m['unit'] ?? 'kg').toString(),
          trend: tp.abs() > 1.5 ? tp / 100 : tp,
        );
      }
      final pm = (m['prices'] as Map?)?.cast<String, dynamic>() ?? const {};
      for (final e in pm.entries) {
        merged[produce]![corridorFromName(e.key)] = _money(e.value);
      }
    }
    return [
      for (final p in order)
        CorridorPrice(
          produce: p,
          unit: meta[p]!.unit,
          trend: meta[p]!.trend,
          prices: merged[p]!,
        ),
    ];
  }
}
