import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/recipes_api.dart';
import '../domain/models/recipe_cart_item.dart';

/// Live store for the signed-in user's recipe combos. The cart, checkout
/// and order screens listen to [items] so every screen sees the same
/// basket without re-fetching.
class RecipeCartController {
  RecipeCartController._();
  static final RecipeCartController instance = RecipeCartController._();

  final ValueNotifier<List<RecipeCartItem>> items =
      ValueNotifier<List<RecipeCartItem>>(const []);
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /// Sum of every combo's total, in WHOLE NAIRA.
  int get totalNaira =>
      items.value.fold<int>(0, (s, i) => s + i.totalPriceNaira);

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      items.value = await RecipesApi.instance.cartItems();
    } on ApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<RecipeCartItem?> add({
    required String recipeId,
    required String sizeId,
    double? lat,
    double? lng,
  }) async {
    try {
      final added = await RecipesApi.instance.addToCart(
        recipeId: recipeId,
        sizeId: sizeId,
        lat: lat,
        lng: lng,
      );
      // Refresh from server so we stay the single source of truth.
      await load();
      return added;
    } on ApiException catch (e) {
      error.value = e.message;
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await RecipesApi.instance.removeFromCart(id);
      // Optimistic update — drop the row before the next refresh so the
      // cart never shows a removed combo for a beat.
      items.value = items.value.where((i) => i.id != id).toList();
      await load();
    } on ApiException catch (e) {
      error.value = e.message;
      await load();
    }
  }

  /// Drops local state without calling the API — used after a successful
  /// checkout where the server has already emptied the recipe cart.
  void clearLocal() {
    items.value = const [];
  }
}
