import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/agent_api.dart';

/// Business classification for traders an agent registers in the field.
enum BusinessType { farmer, trader, processor, other }

extension BusinessTypeX on BusinessType {
  String get label => switch (this) {
        BusinessType.farmer => 'Farmer',
        BusinessType.trader => 'Trader',
        BusinessType.processor => 'Processor',
        BusinessType.other => 'Other',
      };

  static BusinessType fromKey(String key) => switch (key) {
        'farmer' => BusinessType.farmer,
        'trader' => BusinessType.trader,
        'processor' => BusinessType.processor,
        _ => BusinessType.other,
      };
}

class Trader {
  Trader({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.type,
    required this.registeredAt,
    this.synced = true,
  });

  final String id;
  final String name;
  final String phone;
  final String location;
  final BusinessType type;
  final DateTime registeredAt;
  bool synced;

  factory Trader.fromJson(Map<String, dynamic> j) => Trader(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        location: (j['location'] ?? '').toString(),
        type: BusinessTypeX.fromKey('${j['businessType'] ?? 'other'}'),
        registeredAt:
            DateTime.tryParse('${j['registeredAt'] ?? ''}') ?? DateTime.now(),
        synced: true,
      );
}

class AgentTransaction {
  AgentTransaction({
    required this.id,
    required this.traderId,
    required this.traderName,
    required this.product,
    required this.quantityKg,
    required this.pricePerKgNaira,
    required this.recordedAt,
    this.synced = true,
  });

  final String id;
  final String traderId;
  final String traderName;
  final String product;
  final int quantityKg;
  final int pricePerKgNaira;
  final DateTime recordedAt;
  bool synced;

  int get totalNaira => quantityKg * pricePerKgNaira;

  /// Agent commission. Fixed 0.5% per the build guide.
  int get commissionNaira => (totalNaira * 0.005).round();

  factory AgentTransaction.fromJson(Map<String, dynamic> j) =>
      AgentTransaction(
        id: (j['id'] ?? '').toString(),
        traderId: (j['traderId'] ?? '').toString(),
        traderName: (j['traderName'] ?? '').toString(),
        product: (j['product'] ?? '').toString(),
        quantityKg: (j['quantityKg'] as num?)?.toInt() ?? 0,
        pricePerKgNaira: (j['pricePerKgNaira'] as num?)?.toInt() ?? 0,
        recordedAt:
            DateTime.tryParse('${j['recordedAt'] ?? ''}') ?? DateTime.now(),
        synced: true,
      );
}

class AgentPayout {
  AgentPayout({
    required this.id,
    required this.traderId,
    required this.traderName,
    required this.amountNaira,
    required this.recordedAt,
    this.signatureBytes,
    this.synced = true,
  });

  final String id;
  final String traderId;
  final String traderName;
  final int amountNaira;
  final DateTime recordedAt;

  /// Raw bytes of a serialized signature stroke list. Optional, only
  /// captured when the agent uses the signature pad.
  final List<List<Offset>>? signatureBytes;
  bool synced;
}

/// A simulated sync conflict, two versions of the same transaction
/// (offline edit vs server snapshot) that the agent has to pick between
/// before sync can complete.
class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.traderName,
    required this.product,
    required this.localQty,
    required this.localPrice,
    required this.serverQty,
    required this.serverPrice,
  });

  final String id;
  final String traderName;
  final String product;
  final int localQty;
  final int localPrice;
  final int serverQty;
  final int serverPrice;
}

/// State for the trade-agent module. Traders + transactions load from the
/// `/v1/agent` API; field records POST through and fall back to an
/// unsynced local row when the call fails (offline-first).
class AgentController {
  AgentController._()
      : traders = ValueNotifier<List<Trader>>([]),
        transactions = ValueNotifier<List<AgentTransaction>>([]),
        payouts = ValueNotifier<List<AgentPayout>>([]),
        conflicts = ValueNotifier<List<SyncConflict>>([]);
  static final AgentController instance = AgentController._();

  final ValueNotifier<List<Trader>> traders;
  final ValueNotifier<List<AgentTransaction>> transactions;
  final ValueNotifier<List<AgentPayout>> payouts;
  final ValueNotifier<List<SyncConflict>> conflicts;
  final _api = AgentApi.instance;

  /// Total items waiting on sync, drives the badge on the home hero
  /// and the sync screen's pending counts.
  int get pendingSyncCount {
    var n = 0;
    for (final t in traders.value) {
      if (!t.synced) n++;
    }
    for (final t in transactions.value) {
      if (!t.synced) n++;
    }
    for (final p in payouts.value) {
      if (!p.synced) n++;
    }
    return n;
  }

  /// Commission earned today across every transaction recorded today.
  int get commissionToday {
    final dayStart = DateTime.now().subtract(const Duration(hours: 24));
    var total = 0;
    for (final t in transactions.value) {
      if (t.recordedAt.isAfter(dayStart)) total += t.commissionNaira;
    }
    return total;
  }

  int get transactionsToday {
    final dayStart = DateTime.now().subtract(const Duration(hours: 24));
    var n = 0;
    for (final t in transactions.value) {
      if (t.recordedAt.isAfter(dayStart)) n++;
    }
    return n;
  }

  Trader? traderById(String id) {
    for (final t in traders.value) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Filter traders by free-text query against name + phone. Empty
  /// query returns the full list.
  List<Trader> searchTraders(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(traders.value);
    final q = query.trim().toLowerCase();
    return [
      for (final t in traders.value)
        if (t.name.toLowerCase().contains(q) || t.phone.contains(q)) t,
    ];
  }

  /// Pulls the agent's linked traders from the API.
  Future<void> loadTraders() async {
    try {
      final raw = await _api.linkedTraders();
      traders.value = [
        for (final e in raw)
          Trader.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh retries.
    }
  }

  /// Pulls the last month of recorded transactions from the API.
  Future<void> loadTransactions() async {
    try {
      final res = await _api.earnings(range: 'month');
      final items = (res['transactions'] as List?) ?? const [];
      transactions.value = [
        for (final e in items)
          AgentTransaction.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place.
    }
  }

  String addTrader({
    required String name,
    required String phone,
    required String location,
    required BusinessType type,
  }) {
    final id = 'T-${DateTime.now().millisecondsSinceEpoch}';
    traders.value = [
      Trader(
        id: id,
        name: name,
        phone: phone,
        location: location,
        type: type,
        registeredAt: DateTime.now(),
        synced: false,
      ),
      ...traders.value,
    ];
    _syncTrader(name, phone, location, type);
    return id;
  }

  Future<void> _syncTrader(
    String name,
    String phone,
    String location,
    BusinessType type,
  ) async {
    try {
      await _api.registerTrader({
        'name': name,
        'phone': phone,
        'location': location,
        'businessType': type.name,
      });
      await loadTraders();
    } on ApiException {
      // Keep the unsynced local row; the sync screen will retry.
    }
  }

  String addTransaction({
    required String traderId,
    required String traderName,
    required String product,
    required int quantityKg,
    required int pricePerKgNaira,
  }) {
    final id = 'TX-${DateTime.now().millisecondsSinceEpoch}';
    transactions.value = [
      AgentTransaction(
        id: id,
        traderId: traderId,
        traderName: traderName,
        product: product,
        quantityKg: quantityKg,
        pricePerKgNaira: pricePerKgNaira,
        recordedAt: DateTime.now(),
        synced: false,
      ),
      ...transactions.value,
    ];
    _syncTransaction(id, traderId, product, quantityKg, pricePerKgNaira);
    return id;
  }

  Future<void> _syncTransaction(
    String localId,
    String traderId,
    String product,
    int quantityKg,
    int pricePerKgNaira,
  ) async {
    try {
      await _api.recordTransaction({
        'traderId': traderId,
        'product': product,
        'quantityKg': quantityKg,
        'pricePerKgNaira': pricePerKgNaira,
      });
      _markSynced(transactionId: localId);
    } on ApiException {
      // Keep the unsynced local row.
    }
  }

  String addPayout({
    required String traderId,
    required String traderName,
    required int amountNaira,
    List<List<Offset>>? signatureBytes,
  }) {
    final id = 'P-${DateTime.now().millisecondsSinceEpoch}';
    payouts.value = [
      AgentPayout(
        id: id,
        traderId: traderId,
        traderName: traderName,
        amountNaira: amountNaira,
        recordedAt: DateTime.now(),
        signatureBytes: signatureBytes,
        synced: false,
      ),
      ...payouts.value,
    ];
    _syncPayout(id, traderId, amountNaira);
    return id;
  }

  Future<void> _syncPayout(
    String localId,
    String traderId,
    int amountNaira,
  ) async {
    try {
      await _api.recordPayout({
        'traderId': traderId,
        'amountNaira': amountNaira,
      });
      _markSynced(payoutId: localId);
    } on ApiException {
      // Keep the unsynced local row.
    }
  }

  void _markSynced({String? transactionId, String? payoutId}) {
    if (transactionId != null) {
      for (final t in transactions.value) {
        if (t.id == transactionId) t.synced = true;
      }
    }
    if (payoutId != null) {
      for (final p in payouts.value) {
        if (p.id == payoutId) p.synced = true;
      }
    }
    _bump();
  }

  /// Retries any unsynced field records against the API.
  Future<void> runSync() async {
    for (final t in List.of(traders.value)) {
      if (!t.synced) {
        await _syncTrader(t.name, t.phone, t.location, t.type);
      }
    }
    for (final t in transactions.value) {
      if (!t.synced) {
        await _syncTransaction(
            t.id, t.traderId, t.product, t.quantityKg, t.pricePerKgNaira);
      }
    }
    for (final p in payouts.value) {
      if (!p.synced) {
        await _syncPayout(p.id, p.traderId, p.amountNaira);
      }
    }
    _bump();
  }

  void resolveConflict(String id, {required bool keepLocal}) {
    final c = conflicts.value.where((c) => c.id == id).firstOrNull;
    if (c == null) return;
    if (!keepLocal) {
      for (final t in transactions.value) {
        if (t.id == id) {
          transactions.value = [
            for (final tx in transactions.value)
              if (tx.id == id)
                AgentTransaction(
                  id: tx.id,
                  traderId: tx.traderId,
                  traderName: tx.traderName,
                  product: tx.product,
                  quantityKg: c.serverQty,
                  pricePerKgNaira: c.serverPrice,
                  recordedAt: tx.recordedAt,
                  synced: true,
                )
              else
                tx,
          ];
          break;
        }
      }
    }
    conflicts.value = [
      for (final cur in conflicts.value)
        if (cur.id != id) cur,
    ];
  }

  void _bump() {
    traders.value = List.of(traders.value);
    transactions.value = List.of(transactions.value);
    payouts.value = List.of(payouts.value);
  }
}
