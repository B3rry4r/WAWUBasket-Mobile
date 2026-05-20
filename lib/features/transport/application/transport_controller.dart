import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../trade/domain/models/corridor.dart';
import '../data/transport_api.dart';
import '../domain/models/load_offer.dart';

/// Single source of truth for transport loads. Trader's Transport screen
/// posts to it; driver's load board reads from it; the same in-memory
/// list backs both so a fresh post shows up on the driver's home
/// instantly.
class TransportController {
  TransportController._()
      : loads = ValueNotifier<List<LoadOffer>>([]),
        activeTrip = ValueNotifier<LoadOffer?>(null) {
    loads.value = _seed();
  }
  static final TransportController instance = TransportController._();

  static const driverName = 'Aliyu Bala';

  /// Every load the system knows about, newest first.
  final ValueNotifier<List<LoadOffer>> loads;

  /// Whichever load the driver is currently moving. Null when idle.
  final ValueNotifier<LoadOffer?> activeTrip;

  final _api = TransportApi.instance;

  LoadOffer? byId(String id) {
    for (final l in loads.value) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Loads the signed-in trader's own posted loads from the API.
  Future<void> loadMyLoads() async {
    try {
      final raw = await _api.myLoads();
      loads.value = [
        for (final e in raw)
          LoadOffer.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh retries.
    }
  }

  /// Trader posts a new load.
  String post(LoadOffer offer) {
    loads.value = [offer, ...loads.value];
    _create(offer);
    return offer.id;
  }

  Future<void> _create(LoadOffer o) async {
    try {
      await _api.postLoad({
        'originCountry': o.origin.name,
        'originLabel': o.originLabel,
        'destCountry': o.destination.name,
        'destLabel': o.destinationLabel,
        'weightKg': o.weightKg,
        'offerNaira': o.offerNaira,
        'distanceKm': o.distanceKm,
        'checkpoints': o.checkpointNames,
      });
    } on ApiException {
      // Keep the optimistic row; the trader can retry the post.
    }
  }

  /// Driver submits a bid. Stays open until the trader assigns.
  void bid(String id, LoadBid bid) {
    final l = byId(id);
    if (l == null) return;
    l.bids = [...l.bids, bid];
    _bump();
  }

  /// Driver "auto-wins" the bid in the prototype (no trader-side accept
  /// flow yet). Marks the load assigned + sets active trip.
  void accept(String id) {
    final l = byId(id);
    if (l == null) return;
    l.status = LoadStatus.assigned;
    l.assignedDriver = driverName;
    activeTrip.value = l;
    _bump();
  }

  /// Log the next checkpoint on the active trip. Auto-advances status
  /// to in-transit on the first checkpoint and to delivered when the
  /// last one logs.
  void logCheckpoint() {
    final l = activeTrip.value;
    if (l == null) return;
    final remaining =
        l.checkpointNames.length - l.reachedCheckpoints.length;
    if (remaining <= 0) return;
    final next = l.checkpointNames[l.reachedCheckpoints.length];
    l.reachedCheckpoints = [
      ...l.reachedCheckpoints,
      Checkpoint(name: next, reachedAt: DateTime.now()),
    ];
    if (l.reachedCheckpoints.length == 1) {
      l.status = LoadStatus.inTransit;
    }
    if (l.atFinalCheckpoint) {
      l.status = LoadStatus.delivered;
    }
    activeTrip.value = l;
    _bump();
  }

  /// Driver closes the trip post-delivery, freeing them up for the next
  /// load. The completed trip stays in [loads] for earnings history.
  void completeTrip() {
    activeTrip.value = null;
  }

  void _bump() => loads.value = List.of(loads.value);

  List<LoadOffer> _seed() => [
        LoadOffer(
          id: 'LOAD-0042',
          origin: Corridor.nigeria,
          destination: Corridor.benin,
          originLabel: 'Kano',
          destinationLabel: 'Cotonou',
          weightKg: 8000,
          offerNaira: 620000,
          traderName: 'Hauwa & Sons Bulk Co.',
          distanceKm: 1280,
          checkpointNames: const [
            'Kaduna depot',
            'Ilorin yard',
            'Seme border',
            'Cotonou warehouse',
          ],
          postedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        LoadOffer(
          id: 'LOAD-0039',
          origin: Corridor.nigeria,
          destination: Corridor.togo,
          originLabel: 'Ondo',
          destinationLabel: 'Lomé',
          weightKg: 2500,
          offerNaira: 280000,
          traderName: 'Ondo Cocoa Co-op',
          distanceKm: 540,
          checkpointNames: const [
            'Lagos depot',
            'Hilla-Condji border',
            'Lomé warehouse',
          ],
          postedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        LoadOffer(
          id: 'LOAD-0035',
          origin: Corridor.nigeria,
          destination: Corridor.niger,
          originLabel: 'Lagos',
          destinationLabel: 'Niamey',
          weightKg: 12000,
          offerNaira: 1100000,
          traderName: 'Sahel Grain Union',
          distanceKm: 1620,
          checkpointNames: const [
            'Ibadan depot',
            'Kaduna depot',
            'Illela border',
            'Niamey warehouse',
          ],
          postedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        LoadOffer(
          id: 'LOAD-0029',
          origin: Corridor.nigeria,
          destination: Corridor.cameroon,
          originLabel: 'Calabar',
          destinationLabel: 'Douala',
          weightKg: 4500,
          offerNaira: 540000,
          traderName: 'Delta Mills',
          distanceKm: 760,
          checkpointNames: const [
            'Mfum border',
            'Mamfe yard',
            'Douala warehouse',
          ],
          postedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];
}
