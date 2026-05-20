import '../../../core/network/api_client.dart';
import '../domain/models/product.dart';

/// Wraps the `/v1/cart` endpoints. All calls require a session.
class CartApi {
  CartApi._();
  static final CartApi instance = CartApi._();

  final _api = ApiClient.instance;

  /// The current user's cart, newest single-vendor basket.
  Future<List<CartLine>> getCart() async {
    final res = await _api.get('/cart') as Map<String, dynamic>;
    final items = (res['items'] as List?) ?? const [];
    return items
        .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Adds a catalog item (or bumps its quantity).
  Future<void> addItem(String itemId, int quantity, {String? note}) =>
      _api.post('/cart/items', body: {
        'itemId': itemId,
        'quantity': quantity,
        if (note != null && note.isNotEmpty) 'note': note,
      });

  /// Sets a line's quantity; quantity 0 removes it.
  Future<void> updateItem(String cartItemId, int quantity) =>
      _api.patch('/cart/items/$cartItemId', body: {'quantity': quantity});

  Future<void> removeItem(String cartItemId) =>
      _api.delete('/cart/items/$cartItemId');

  Future<void> clear() => _api.delete('/cart');
}
