import 'package:equatable/equatable.dart';

import 'recipe_ingredient.dart';
import 'recipe_size.dart';

/// A cookable dish the customer can drop into their basket as a combo.
/// `sizes` + `ingredients` are populated on the detail endpoint and empty
/// on the list endpoint — the UI degrades gracefully when they're missing.
class Recipe extends Equatable {
  const Recipe({
    required this.id,
    required this.slug,
    required this.name,
    required this.cuisine,
    required this.imageUrl,
    required this.cookingTimeMins,
    this.description,
    this.sizes = const [],
    this.ingredients = const [],
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final String cuisine;
  final String imageUrl;
  final int cookingTimeMins;
  final List<RecipeSize> sizes;
  final List<RecipeIngredient> ingredients;

  /// The size flagged as default by the backend — falls back to the first
  /// available size, or `null` if the recipe has no sizes loaded.
  RecipeSize? get defaultSize {
    if (sizes.isEmpty) return null;
    for (final s in sizes) {
      if (s.isDefault) return s;
    }
    return sizes.first;
  }

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
        id: (j['id'] ?? '').toString(),
        slug: (j['slug'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        description: j['description'] as String?,
        cuisine: (j['cuisine'] ?? '').toString(),
        imageUrl: (j['imageUrl'] ?? '').toString(),
        cookingTimeMins: (j['cookingTimeMins'] as num?)?.toInt() ?? 0,
        sizes: ((j['sizes'] as List?) ?? const [])
            .map((e) => RecipeSize.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        ingredients: ((j['ingredients'] as List?) ?? const [])
            .map((e) =>
                RecipeIngredient.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  List<Object?> get props => [id, slug, name, cuisine, cookingTimeMins];
}
