import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../driver/data/driver_api.dart';
import '../data/transport_api.dart';
import '../domain/models/load_offer.dart';

/// Single source of truth for transport loads. The trader's Transport
/// screen posts + lists their own loads; the driver's board lists every
/// open load. Each screen calls the load method that suits its audience.
class TransportController {
  TransportController._()
      : loads = ValueNotifier<List<LoadOffer>>([]),
        activeTrip = ValueNotifier<LoadOffer?>(null),
        mutationError = ValueNotifier<String?>(null);
  static final TransportController instance = TransportController._();

  static const driverName = 'Aliyu Bala';

  /// Every load the system knows about, newest first.
  final ValueNotifier<List<LoadOffer>> loads;

  /// Whichever load the driver is currently moving. Null when idle.
  final ValueNotifier<LoadOffer?> activeTrip;

  /// Non-null when a bid or checkpoint call fails. Screens can listen and
  /// show a snackbar, then reset to null.
  final ValueNotifier<String?> mutationError;

  final _api = TransportApi.instance;
  final _driverApi = DriverApi.instance;

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

  /// Driver board — every open load across the network.
  Future<void> loadOpenLoads() async {
    try {
      final raw = await _driverApi.openLoads();
      loads.value = [
        for (final e in raw)
          LoadOffer.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh retries.
    }
  }

  /// Driver's currently assigned trip, if any.
  Future<void> loadActiveTrip() async {
    try {
      final j = await _driverApi.activeTrip();
      activeTrip.value = j == null ? null : LoadOffer.fromJson(j);
    } on ApiException {
      // Leave the current trip in place.
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
    _driverApi.submitBid(id, bid.priceNaira, bid.etaHours, bid.notes).catchError((Object e) {
      if (e is ApiException) mutationError.value = e.message;
    });
  }

  /// Marks the load assigned + sets active trip, and notifies the backend
  /// that the driver has accepted the assignment.
  void accept(String id) {
    final l = byId(id);
    if (l == null) return;
    l.status = LoadStatus.assigned;
    l.assignedDriver = driverName;
    activeTrip.value = l;
    _bump();
    _driverApi.acceptLoad(id).catchError((Object e) {
      if (e is ApiException) mutationError.value = e.message;
    });
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
    _driverApi.logCheckpoint(l.id).catchError((Object e) {
      if (e is ApiException) mutationError.value = e.message;
    });
  }

  /// Driver closes the trip post-delivery, freeing them up for the next
  /// load. The completed trip stays in [loads] for earnings history.
  void completeTrip() {
    final l = activeTrip.value;
    activeTrip.value = null;
    if (l != null) {
      _driverApi.completeTrip(l.id).catchError((Object e) {
        if (e is ApiException) mutationError.value = e.message;
      });
    }
  }

  void _bump() => loads.value = List.of(loads.value);
}
