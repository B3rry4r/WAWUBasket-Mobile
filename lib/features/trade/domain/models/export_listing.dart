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
