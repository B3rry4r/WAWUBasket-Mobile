import 'package:flutter/foundation.dart' hide Category;

import '../../shopping/application/mock_data.dart';
import '../../shopping/data/catalog_api.dart';
import '../domain/models/category.dart';

class CategoryController {
  CategoryController._() {
    // Wire MockData.categoryById to look up from the live API list when loaded.
    MockData.liveCategories = () => categories.value;
  }

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
      // Fall back to static mock so the UI always shows something.
      categories.value = MockData.categories;
    } finally {
      _loaded = true;
    }
  }

  void reload() {
    _loaded = false;
    categories.value = null;
    load();
  }
}
