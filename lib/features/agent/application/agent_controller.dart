import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

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

/// In-memory state for the trade-agent module. Drives the home stats,
/// trader directory, transactions list, payouts list, and the sync
/// status indicator.
class AgentController {
  AgentController._()
      : traders = ValueNotifier<List<Trader>>([]),
        transactions = ValueNotifier<List<AgentTransaction>>([]),
        payouts = ValueNotifier<List<AgentPayout>>([]),
        conflicts = ValueNotifier<List<SyncConflict>>([]) {
    traders.value = _seedTraders();
    transactions.value = _seedTransactions();
    payouts.value = _seedPayouts();
  }
  static final AgentController instance = AgentController._();

  final ValueNotifier<List<Trader>> traders;
  final ValueNotifier<List<AgentTransaction>> transactions;
  final ValueNotifier<List<AgentPayout>> payouts;
  final ValueNotifier<List<SyncConflict>> conflicts;

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
    return id;
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
    return id;
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
    return id;
  }

  /// Pretend-sync. Flips everything to `synced=true`, then seeds one
  /// conflict if there were two or more pending items (so the conflict
  /// resolver has something to do).
  void runSync() {
    final pending = pendingSyncCount;
    for (final t in traders.value) {
      t.synced = true;
    }
    for (final t in transactions.value) {
      t.synced = true;
    }
    for (final p in payouts.value) {
      p.synced = true;
    }
    if (pending >= 2 && transactions.value.isNotEmpty) {
      final first = transactions.value.first;
      conflicts.value = [
        SyncConflict(
          id: first.id,
          traderName: first.traderName,
          product: first.product,
          localQty: first.quantityKg,
          localPrice: first.pricePerKgNaira,
          serverQty: first.quantityKg,
          // Pretend the server has a higher price recorded.
          serverPrice: first.pricePerKgNaira + 20,
        ),
      ];
    }
    _bump();
  }

  void resolveConflict(String id, {required bool keepLocal}) {
    final c = conflicts.value.where((c) => c.id == id).firstOrNull;
    if (c == null) return;
    if (!keepLocal) {
      // Apply server price to the local transaction.
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

  // ─── Seeds ─────────────────────────────────────────────────────

  List<Trader> _seedTraders() => [
        Trader(
          id: 'T-101',
          name: 'Adamu Bello',
          phone: '+234 803 421 1820',
          location: 'Mile 12 Market',
          type: BusinessType.farmer,
          registeredAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        Trader(
          id: 'T-102',
          name: 'Hauwa Sani',
          phone: '+234 802 988 0421',
          location: 'Kano Central',
          type: BusinessType.trader,
          registeredAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Trader(
          id: 'T-103',
          name: 'Sani Audu',
          phone: '+234 805 117 7032',
          location: 'Idumota',
          type: BusinessType.processor,
          registeredAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Trader(
          id: 'T-104',
          name: 'Aisha Garba',
          phone: '+234 808 110 4200',
          location: 'Aba',
          type: BusinessType.trader,
          registeredAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  List<AgentTransaction> _seedTransactions() => [
        AgentTransaction(
          id: 'TX-101',
          traderId: 'T-101',
          traderName: 'Adamu Bello',
          product: 'Tomatoes',
          quantityKg: 50,
          pricePerKgNaira: 360,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        AgentTransaction(
          id: 'TX-100',
          traderId: 'T-102',
          traderName: 'Hauwa Sani',
          product: 'Maize',
          quantityKg: 100,
          pricePerKgNaira: 550,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 34)),
        ),
        AgentTransaction(
          id: 'TX-099',
          traderId: 'T-103',
          traderName: 'Sani Audu',
          product: 'Onions',
          quantityKg: 25,
          pricePerKgNaira: 900,
          recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AgentTransaction(
          id: 'TX-098',
          traderId: 'T-104',
          traderName: 'Aisha Garba',
          product: 'Cassava',
          quantityKg: 80,
          pricePerKgNaira: 280,
          recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  List<AgentPayout> _seedPayouts() => [
        AgentPayout(
          id: 'P-101',
          traderId: 'T-101',
          traderName: 'Adamu Bello',
          amountNaira: 18000,
          recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
}
