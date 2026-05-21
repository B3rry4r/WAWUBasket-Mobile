import 'package:equatable/equatable.dart';

import '../../../../core/utils/wb_format.dart';

class BulkLot extends Equatable {
  const BulkLot({
    required this.id,
    required this.produce,
    required this.lotSize,
    required this.unitPriceNaira,
    required this.minOrder,
    required this.supplierName,
    required this.region,
    required this.imageUrl,
  });

  final String id;
  final String produce;

  /// e.g. `"50 kg bag"`.
  final String lotSize;

  /// Wholesale price per lot.
  final int unitPriceNaira;

  /// Minimum order in lot units, e.g. `5` (= "Min 5 bags").
  final int minOrder;
  final String supplierName;
  final String region;
  final String imageUrl;

  String get unitPriceLabel => wbNaira(unitPriceNaira);
  String get minOrderLabel => 'Min $minOrder ${minOrder == 1 ? 'unit' : 'units'}';

  factory BulkLot.fromJson(Map<String, dynamic> j) {
    final images = (j['images'] as List?) ?? const [];
    final price = j['price'];
    return BulkLot(
      id: (j['id'] ?? '').toString(),
      produce: (j['title'] ?? j['produce'] ?? '').toString(),
      lotSize: (j['unit'] ?? j['lotSize'] ?? '').toString(),
      unitPriceNaira:
          price is num ? price.toInt() : int.tryParse('${price ?? 0}') ?? 0,
      minOrder: (j['moq'] as num?)?.toInt() ?? 1,
      supplierName: (j['supplierName'] ?? 'Supplier').toString(),
      region: (j['region'] ?? '').toString(),
      imageUrl: images.isNotEmpty ? images.first.toString() : '',
    );
  }

  @override
  List<Object?> get props => [id, produce, lotSize];
}
