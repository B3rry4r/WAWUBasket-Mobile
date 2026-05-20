import 'corridor.dart';

/// One bulk export listing a trader posts. Customers + other traders can
/// see it on /trade; the trader manages it on their own dashboard.
class ExportListing {
  ExportListing({
    required this.id,
    required this.produce,
    required this.quantityKg,
    required this.pricePerKgNaira,
    required this.harvestDate,
    required this.originCorridor,
    required this.destinationCorridor,
    required this.farmName,
    required this.farmRegion,
    required this.imageUrl,
    this.enquiries = 0,
    this.status = ExportListingStatus.active,
  });

  final String id;
  String produce;
  int quantityKg;
  int pricePerKgNaira;
  DateTime harvestDate;
  Corridor originCorridor;
  Corridor destinationCorridor;
  String farmName;
  String farmRegion;
  String imageUrl;
  int enquiries;
  ExportListingStatus status;

  int get lotValueNaira => quantityKg * pricePerKgNaira;

  /// Builds a listing from the `/v1/trader/export-listings` (own) or
  /// `/v1/trade/export-listings` (public) payload. Public rows nest the
  /// trader's business name under `trader`.
  factory ExportListing.fromJson(Map<String, dynamic> j) {
    final trader = (j['trader'] as Map?)?.cast<String, dynamic>();
    return ExportListing(
      id: (j['id'] ?? '').toString(),
      produce: (j['produce'] ?? '').toString(),
      quantityKg: (j['quantityKg'] as num?)?.toInt() ?? 0,
      pricePerKgNaira: _exportInt(j['pricePerKgNaira']),
      harvestDate:
          DateTime.tryParse('${j['harvestDate'] ?? ''}') ?? DateTime.now(),
      originCorridor: corridorFromName(j['originCorridor']?.toString()),
      destinationCorridor:
          corridorFromName(j['destinationCorridor']?.toString()),
      farmName:
          (j['farmName'] ?? trader?['businessName'] ?? 'Trader').toString(),
      farmRegion: (j['farmRegion'] ?? trader?['farmRegion'] ?? '').toString(),
      imageUrl: (j['imageKey'] ?? j['imageUrl'] ?? '').toString(),
      enquiries: (j['enquiries'] as num?)?.toInt() ?? 0,
      status: exportStatusFromName(j['status']?.toString()),
    );
  }
}

int _exportInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

ExportListingStatus exportStatusFromName(String? s) {
  for (final v in ExportListingStatus.values) {
    if (v.name == s) return v;
  }
  return ExportListingStatus.active;
}

enum ExportListingStatus { draft, active, sold, expired }

extension ExportListingStatusX on ExportListingStatus {
  String get label => switch (this) {
        ExportListingStatus.draft => 'Draft',
        ExportListingStatus.active => 'Active',
        ExportListingStatus.sold => 'Sold',
        ExportListingStatus.expired => 'Expired',
      };
}
