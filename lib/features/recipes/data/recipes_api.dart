import '../../../core/network/api_client.dart';
import '../domain/models/recipe.dart';
import '../domain/models/recipe_cart_item.dart';
import '../domain/models/recipe_match.dart';

/// Wraps the `/v1/recipes` endpoints. Browsing is public; everything that
/// touches the cart requires a signed-in session.
class RecipesApi {
  RecipesApi._();
  static final RecipesApi instance = RecipesApi._();

  final _api = ApiClient.instance;

  /// Public catalogue. `cuisine` + `query` filter server-side.
  Future<List<Recipe>> list({String? cuisine, String? query}) async {
    final params = <String, dynamic>{};
    if (cuisine != null && cuisine.isNotEmpty) params['cuisine'] = cuisine;
    if (query != null && query.isNotEmpty) params['q'] = query;
    final res = await _api.get(
      '/recipes',
      query: params.isEmpty ? null : params,
    ) as Map<String, dynamic>;
    final raw = (res['recipes'] as List?) ?? const [];
    return raw
        .map((e) => Recipe.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Single recipe with `sizes` and `ingredients` populated.
  Future<Recipe> detail(String slug) async {
    final res = await _api.get('/recipes/$slug') as Map<String, dynamic>;
    return Recipe.fromJson(res);
  }

  /// Quotes a recipe at a given size. `lat`/`lng` let the engine prefer
  /// nearby sellers; when missing it falls back to city-level matching.
  Future<RecipeMatch> match({
    required String recipeId,
    required String sizeId,
    double? lat,
    double? lng,
  }) async {
    final body = <String, dynamic>{'sizeId': sizeId};
    if (lat != null) body['lat'] = lat;
    if (lng != null) body['lng'] = lng;
    final res =
        await _api.post('/recipes/$recipeId/match', body: body)
            as Map<String, dynamic>;
    return RecipeMatch.fromJson(res);
  }

  /// Adds a recipe combo to the signed-in user's basket. The server
  /// re-runs matching at insert time to lock in the price.
  Future<RecipeCartItem> addToCart({
    required String recipeId,
    required String sizeId,
    double? lat,
    double? lng,
  }) async {
    final body = <String, dynamic>{
      'recipeId': recipeId,
      'sizeId': sizeId,
    };
    if (lat != null) body['lat'] = lat;
    if (lng != null) body['lng'] = lng;
    final res = await _api.post('/recipes/cart', body: body)
        as Map<String, dynamic>;
    final item =
        (res['recipeCartItem'] as Map?)?.cast<String, dynamic>() ?? res;
    return RecipeCartItem.fromJson(item);
  }

  /// All recipe combos in the signed-in user's basket.
  Future<List<RecipeCartItem>> cartItems() async {
    final res = await _api.get('/recipes/cart') as Map<String, dynamic>;
    final raw = (res['items'] as List?) ?? const [];
    return raw
        .map((e) => RecipeCartItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> removeFromCart(String id) =>
      _api.delete('/recipes/cart/$id');

  /// Places a parent order over every recipe combo currently in the
  /// basket. Returns the raw response (parent `order` + optional
  /// `checkoutUrl`) so the checkout screen can reuse the existing
  /// payment polling pipeline.
  Future<Map<String, dynamic>> checkout({
    required String addressId,
  }) async {
    final res = await _api.post(
      '/recipes/cart/checkout',
      body: {'addressId': addressId},
    );
    final map = (res as Map).cast<String, dynamic>();
    // The endpoint shape is `{ order: {...} }`; surface a flat map that
    // mirrors the regular orders endpoint for caller convenience.
    final order = (map['order'] as Map?)?.cast<String, dynamic>();
    return order ?? map;
  }
}
