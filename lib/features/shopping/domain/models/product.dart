import 'package:equatable/equatable.dart';

/// A purchasable item. `categoryId` + `subcategoryId` let us filter products
/// by the same taxonomy that drives the home & category screens.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceNaira,
    required this.vendorName,
    required this.imageUrl,
    required this.categoryId,
    required this.subcategoryId,
    this.unit,
  });

  final String id;
  final String name;
  final String description;
  final int priceNaira;
  final String vendorName;
  final String imageUrl;
  final String categoryId;
  final String subcategoryId;

  /// Optional unit suffix for marketplace products, e.g. `'/ kg'`.
  final String? unit;

  String get formattedPrice => '₦${_n(priceNaira)}';

  @override
  List<Object?> get props => [id, name, priceNaira, categoryId, subcategoryId];
}

class CartLine extends Equatable {
  const CartLine({
    required this.product,
    required this.quantity,
    this.note,
  });

  final Product product;
  final int quantity;
  final String? note;

  int get total => product.priceNaira * quantity;
  String get totalLabel => '₦${_n(total)}';

  CartLine copyWith({Product? product, int? quantity, String? note}) => CartLine(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
      );

  @override
  List<Object?> get props => [product, quantity, note];
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
