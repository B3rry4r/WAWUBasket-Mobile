import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/product.dart';
import 'mock_data.dart';

/// Minimal in-memory cart for the prototype. Lines come pre-seeded from the
/// design's mock data so the screens render with real content.
class CartController extends StateNotifier<List<CartLine>> {
  CartController() : super(List.of(MockData.cart));

  void add(Product product, {int qty = 1, String? note}) {
    final idx = state.indexWhere((l) => l.product.id == product.id);
    if (idx == -1) {
      state = [...state, CartLine(product: product, quantity: qty, note: note)];
    } else {
      final updated = [...state];
      updated[idx] = updated[idx].copyWith(
        quantity: updated[idx].quantity + qty,
        note: note ?? updated[idx].note,
      );
      state = updated;
    }
  }

  void setQuantity(String productId, int qty) {
    final updated = <CartLine>[];
    for (final l in state) {
      if (l.product.id == productId) {
        if (qty > 0) updated.add(l.copyWith(quantity: qty));
      } else {
        updated.add(l);
      }
    }
    state = updated;
  }

  void remove(String productId) {
    state = state.where((l) => l.product.id != productId).toList();
  }

  int get subtotal => state.fold(0, (s, l) => s + l.total);
  int get itemCount => state.fold(0, (s, l) => s + l.quantity);
}

final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartLine>>(
  (ref) => CartController(),
);
