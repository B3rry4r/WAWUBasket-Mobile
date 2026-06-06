import '../../../core/network/api_client.dart';
import '../../../core/network/api_parse.dart';
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
    );
    return safeMapList(safeMap(res, context: 'recipes')['recipes'],
            context: 'recipes')
        .map(Recipe.fromJson)
        .toList();
  }

  /// Single recipe with `sizes` and `ingredients` populated.
  Future<Recipe> detail(String slug) async {
    final res = await _api.get('/recipes/$slug');
    return Recipe.fromJson(safeMap(res, context: 'recipe'));
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
    final res = await _api.post('/recipes/$recipeId/match', body: body);
    return RecipeMatch.fromJson(safeMap(res, context: 'recipeMatch'));
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
    final res = safeMap(await _api.post('/recipes/cart', body: body),
        context: 'addToCart');
    final item = res['recipeCartItem'] != null
        ? safeMap(res['recipeCartItem'], context: 'recipeCartItem')
        : res;
    return RecipeCartItem.fromJson(item);
  }

  /// All recipe combos in the signed-in user's basket.
  Future<List<RecipeCartItem>> cartItems() async {
    final res = await _api.get('/recipes/cart');
    return safeMapList(safeMap(res, context: 'recipeCart')['items'],
            context: 'recipeCartItems')
        .map(RecipeCartItem.fromJson)
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
    String? platform,
  }) async {
    final body = <String, dynamic>{'addressId': addressId};
    if (platform != null) body['platform'] = platform;
    final res = await _api.post('/recipes/cart/checkout', body: body);
    final map = safeMap(res, context: 'recipeCheckout');
    // The endpoint shape is `{ order: {...} }`; surface a flat map that
    // mirrors the regular orders endpoint for caller convenience.
    return map['order'] != null
        ? safeMap(map['order'], context: 'recipeCheckoutOrder')
        : map;
  }
}
