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
    this.vendorId,
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

  /// The owner's user ID — used to fetch "more from this vendor".
  final String? vendorId;

  /// Optional unit suffix for marketplace products, e.g. `'/ kg'`.
  final String? unit;

  String get formattedPrice => '₦${_n(priceNaira)}';

  /// Builds a [Product] from the API's `catalog_items` payload. `price`
  /// arrives as a BigInt-string; `images` is a URL list.
  factory Product.fromJson(Map<String, dynamic> j) {
    final images = (j['images'] as List?)?.cast<dynamic>() ?? const [];
    return Product(
      id: (j['id'] ?? '').toString(),
      name: (j['title'] ?? j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      priceNaira: int.tryParse('${j['price'] ?? 0}') ?? 0,
      vendorName: (j['vendorName'] ?? '').toString(),
      imageUrl: images.isNotEmpty ? images.first.toString() : '',
      categoryId: (j['category'] ?? 'all').toString(),
      subcategoryId: (j['subcategory'] ?? '').toString(),
      vendorId: j['ownerId']?.toString(),
      unit: j['unit'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, priceNaira, categoryId, subcategoryId];
}

class CartLine extends Equatable {
  const CartLine({
    required this.product,
    required this.quantity,
    this.note,
    this.cartItemId,
  });

  final Product product;
  final int quantity;
  final String? note;

  /// The API `cart_items.id` — needed to PATCH/DELETE the line.
  final String? cartItemId;

  int get total => product.priceNaira * quantity;
  String get totalLabel => '₦${_n(total)}';

  CartLine copyWith({
    Product? product,
    int? quantity,
    String? note,
    String? cartItemId,
  }) =>
      CartLine(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
        cartItemId: cartItemId ?? this.cartItemId,
      );

  /// Parses one entry of the API `/v1/cart` `items` array.
  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
        cartItemId: (j['id'] ?? '').toString(),
        product: Product.fromJson(
            (j['item'] as Map?)?.cast<String, dynamic>() ?? const {}),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        note: j['note'] as String?,
      );

  @override
  List<Object?> get props => [cartItemId, product, quantity, note];
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
