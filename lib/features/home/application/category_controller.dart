import 'package:flutter/foundation.dart' hide Category;

import '../../shopping/data/catalog_api.dart';
import '../domain/models/category.dart';

class CategoryController {
  CategoryController._();

  static final CategoryController instance = CategoryController._();

  final categories = ValueNotifier<List<Category>?>(null);
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await CatalogApi.instance.categories();
      final parsed = raw
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      categories.value = parsed;
    } catch (_) {
      // No hardcoded fallback — surface an empty list so the UI shows its
      // empty state instead of mock content. Allow a retry on the next load.
      categories.value = const [];
      _loaded = false;
      return;
    }
    _loaded = true;
  }

  void reload() {
    _loaded = false;
    categories.value = null;
    load();
  }

  /// Resolve a category from the live API list. Returns null when categories
  /// haven't loaded yet or the id isn't found, so callers show a
  /// loading/empty state — there is no hardcoded fallback.
  Category? categoryById(String id) {
    final live = categories.value;
    if (live == null) return null;
    for (final c in live) {
      if (c.id == id) return c;
    }
    return null;
  }
}
