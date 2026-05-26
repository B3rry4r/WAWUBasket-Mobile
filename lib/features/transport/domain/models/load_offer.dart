import '../../../trade/domain/models/corridor.dart';

/// State a transport load moves through. Mirrors build-guide #87–98.
enum LoadStatus {
  open, // accepting bids
  assigned, // driver picked, trip not yet started
  inTransit, // checkpoints in progress
  delivered, // last checkpoint logged
  cancelled,
}

extension LoadStatusX on LoadStatus {
  String get label => switch (this) {
        LoadStatus.open => 'Open',
        LoadStatus.assigned => 'Assigned',
        LoadStatus.inTransit => 'In transit',
        LoadStatus.delivered => 'Delivered',
        LoadStatus.cancelled => 'Cancelled',
      };
}

/// One checkpoint logged on the way from origin to destination.
class Checkpoint {
  const Checkpoint({required this.name, required this.reachedAt});
  final String name;
  final DateTime reachedAt;
}

/// One transport load a trader has posted for drivers to bid on.
class LoadOffer {
  LoadOffer({
    required this.id,
    required this.origin,
    required this.destination,
    required this.originLabel,
    required this.destinationLabel,
    required this.weightKg,
    required this.offerNaira,
    required this.traderName,
    required this.distanceKm,
    required this.checkpointNames,
    required this.postedAt,
    this.status = LoadStatus.open,
    this.bids = const [],
    this.assignedDriver,
    this.reachedCheckpoints = const [],
  });

  final String id;
  final Corridor origin;
  final Corridor destination;

  /// Friendlier than the raw corridor for the route subtitle (e.g.
  /// "Kano → Cotonou" instead of "Nigeria → Benin").
  final String originLabel;
  final String destinationLabel;
  final int weightKg;
  final int offerNaira;
  final String traderName;
  final double distanceKm;
  final List<String> checkpointNames;
  final DateTime postedAt;

  LoadStatus status;
  List<LoadBid> bids;
  String? assignedDriver;
  List<Checkpoint> reachedCheckpoints;

  String get routeLabel => '$originLabel → $destinationLabel';

  /// True when the current driver has logged the last checkpoint.
  bool get atFinalCheckpoint =>
      reachedCheckpoints.length >= checkpointNames.length;

  /// Builds a load from the `/v1/trader/loads` payload.
  factory LoadOffer.fromJson(Map<String, dynamic> j) {
    return LoadOffer(
      id: (j['id'] ?? '').toString(),
      origin: corridorFromName(j['originCountry']?.toString()),
      destination: corridorFromName(j['destCountry']?.toString()),
      originLabel: (j['originLabel'] ?? '').toString(),
      destinationLabel: (j['destLabel'] ?? '').toString(),
      weightKg: (j['weightKg'] as num?)?.toInt() ?? 0,
      offerNaira: _loadInt(j['offerNaira']),
      traderName: (j['traderName'] ?? '').toString(),
      distanceKm: (j['distanceKm'] as num?)?.toDouble() ?? 0,
      checkpointNames: [
        for (final c in (j['checkpoints'] as List? ?? const [])) c.toString(),
      ],
      postedAt:
          DateTime.tryParse('${j['postedAt'] ?? ''}') ?? DateTime.now(),
      status: _loadStatusFromName(j['status']?.toString()),
      bids: [
        for (final b in (j['bids'] as List? ?? const []))
          LoadBid.fromJson((b as Map).cast<String, dynamic>()),
      ],
      reachedCheckpoints: [
        for (final c in (j['checkpointLogs'] as List? ?? const []))
          Checkpoint(
            name: (c['checkpoint'] ?? '').toString(),
            reachedAt: DateTime.tryParse('${c['reachedAt'] ?? ''}') ??
                DateTime.now(),
          ),
      ],
    );
  }
}

int _loadInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

LoadStatus _loadStatusFromName(String? s) => switch (s) {
      'assigned' => LoadStatus.assigned,
      'in_transit' => LoadStatus.inTransit,
      'delivered' => LoadStatus.delivered,
      'cancelled' => LoadStatus.cancelled,
      _ => LoadStatus.open,
    };

/// One driver's bid on an open load.
class LoadBid {
  const LoadBid({
    required this.driverName,
    required this.priceNaira,
    required this.etaHours,
    this.notes = '',
  });
  final String driverName;
  final int priceNaira;
  final int etaHours;
  final String notes;

  factory LoadBid.fromJson(Map<String, dynamic> j) => LoadBid(
        driverName: (j['driverName'] ?? '').toString(),
        priceNaira: _loadInt(j['priceNaira']),
        etaHours: (j['etaHours'] as num?)?.toInt() ?? 0,
        notes: (j['notes'] ?? '').toString(),
      );
}
