import 'package:equatable/equatable.dart';

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

  String get unitPriceLabel => '₦${_n(unitPriceNaira)}';
  String get minOrderLabel => 'Min $minOrder ${minOrder == 1 ? 'unit' : 'units'}';

  @override
  List<Object?> get props => [id, produce, lotSize];
}

String _n(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
