import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/cart_api.dart';
import '../domain/models/product.dart';

/// Snapshot of the cart the screens render.
class CartState {
  const CartState({
    this.items = const [],
    this.loading = true,
    this.error,
  });

  final List<CartLine> items;
  final bool loading;
  final String? error;

  CartState copyWith({
    List<CartLine>? items,
    bool? loading,
    String? error,
  }) =>
      CartState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        error: error,
      );
}

/// API-backed cart. Every mutation hits `/v1/cart` then refreshes from the
/// server so the basket stays the single source of truth.
class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState()) {
    load();
  }

  final _api = CartApi.instance;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _api.getCart();
      state = CartState(items: items, loading: false);
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  Future<void> add(Product product, {int qty = 1, String? note}) async {
    try {
      await _api.addItem(product.id, qty, note: note);
      await load();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> setQuantity(String productId, int qty) async {
    final line = state.items
        .where((l) => l.product.id == productId)
        .cast<CartLine?>()
        .firstWhere((_) => true, orElse: () => null);
    if (line?.cartItemId == null) return;
    try {
      await _api.updateItem(line!.cartItemId!, qty);
      await load();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> remove(String productId) async {
    final line = state.items
        .where((l) => l.product.id == productId)
        .cast<CartLine?>()
        .firstWhere((_) => true, orElse: () => null);
    if (line?.cartItemId == null) return;
    try {
      await _api.removeItem(line!.cartItemId!);
      await load();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  int get subtotal => state.items.fold(0, (s, l) => s + l.total);
  int get itemCount => state.items.fold(0, (s, l) => s + l.quantity);
}

final cartControllerProvider =
    StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);
