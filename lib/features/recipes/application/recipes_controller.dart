import 'package:flutter/foundation.dart';

import '../data/recipes_api.dart';
import '../domain/models/recipe.dart';

/// Shared catalogue store for the home carousel and the recipes list
/// screen — `null` while loading, an empty list when the API responded
/// with no results.
class RecipesController {
  RecipesController._();
  static final RecipesController instance = RecipesController._();

  final ValueNotifier<List<Recipe>?> recipes =
      ValueNotifier<List<Recipe>?>(null);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    error.value = null;
    try {
      recipes.value = await RecipesApi.instance.list();
    } catch (e) {
      // Surface the error to listeners; leave `recipes` null so screens
      // can still show shimmer/empty fallbacks without crashing.
      error.value = e.toString();
      recipes.value = const [];
    } finally {
      _loaded = true;
    }
  }

  Future<void> reload({String? cuisine, String? query}) async {
    error.value = null;
    recipes.value = null;
    try {
      recipes.value = await RecipesApi.instance.list(
        cuisine: cuisine,
        query: query,
      );
    } catch (e) {
      error.value = e.toString();
      recipes.value = const [];
    } finally {
      _loaded = true;
    }
  }
}
