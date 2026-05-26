import 'package:equatable/equatable.dart';

import 'recipe.dart';
import 'recipe_match.dart';
import 'recipe_size.dart';

/// One recipe combo sitting in the user's basket. Surfaces enough joined
/// data (recipe + size + matched sellers) that the cart screen can render
/// without re-fetching anything.
class RecipeCartItem extends Equatable {
  const RecipeCartItem({
    required this.id,
    required this.recipeId,
    required this.recipeSizeId,
    required this.recipe,
    required this.size,
    required this.matchedSellers,
    required this.totalPriceKobo,
    required this.createdAt,
  });

  final String id;
  final String recipeId;
  final String recipeSizeId;
  final Recipe recipe;
  final RecipeSize size;
  final List<MatchedIngredient> matchedSellers;
  final int totalPriceKobo;
  final DateTime createdAt;

  /// Count of distinct vendors the combo sources from — used for the
  /// "X ingredients from Y vendors" subtitle on the cart row.
  int get vendorCount =>
      matchedSellers.map((s) => s.sellerId).toSet().length;

  int get ingredientCount => matchedSellers.length;

  factory RecipeCartItem.fromJson(Map<String, dynamic> j) {
    final recipeJson =
        (j['recipe'] as Map?)?.cast<String, dynamic>() ?? const {};
    final sizeJson =
        (j['size'] as Map?)?.cast<String, dynamic>() ?? const {};
    return RecipeCartItem(
      id: (j['id'] ?? '').toString(),
      recipeId: (j['recipeId'] ?? '').toString(),
      recipeSizeId: (j['recipeSizeId'] ?? '').toString(),
      recipe: Recipe.fromJson(recipeJson),
      size: RecipeSize.fromJson(sizeJson),
      matchedSellers: ((j['matchedSellers'] as List?) ?? const [])
          .map((e) =>
              MatchedIngredient.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      totalPriceKobo: (j['totalPriceKobo'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse('${j['createdAt'] ?? ''}') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, recipeId, recipeSizeId, totalPriceKobo];
}
