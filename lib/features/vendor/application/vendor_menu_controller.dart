import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/wb_format.dart';
import '../data/vendor_api.dart';

/// One configurable modifier on a menu item (size, spice, extras). Cleanly
/// separated from the item itself so the menu-edit screen can add/remove
/// rows without touching the rest of the item shape.
class ModifierOption {
  const ModifierOption({required this.label, this.priceDeltaNaira = 0});
  final String label;
  final int priceDeltaNaira;
}

class ModifierGroup {
  const ModifierGroup({
    required this.name,
    required this.options,
    this.required = false,
  });
  final String name;
  final List<ModifierOption> options;
  final bool required;
}

/// Money fields cross the wire as BigInt strings; coerce to a plain int.
int _money(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

List<ModifierGroup> _parseGroups(dynamic raw) {
  if (raw is! List) return const [];
  return [
    for (final g in raw)
      if (g is Map)
        ModifierGroup(
          name: (g['name'] ?? '').toString(),
          required: g['required'] == true,
          options: [
            for (final o in (g['options'] as List? ?? const []))
              if (o is Map)
                ModifierOption(
                  label: (o['label'] ?? '').toString(),
                  priceDeltaNaira: _money(o['priceDeltaNaira'] ?? o['price']),
                ),
          ],
        ),
  ];
}

/// The vendor-side projection of a menu item. Distinct from the
/// customer-side `Product` so we can carry availability, prep time and
/// modifier groups without polluting that model.
class VendorMenuItem {
  VendorMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.priceNaira,
    required this.category,
    required this.imageUrl,
    this.available = true,
    this.prepMins = 15,
    this.modifierGroups = const [],
  });

  final String id;
  String name;
  String description;
  int priceNaira;
  String category;
  String imageUrl;
  bool available;
  int prepMins;
  List<ModifierGroup> modifierGroups;

  String get formattedPrice => wbNaira(priceNaira);

  factory VendorMenuItem.fromJson(Map<String, dynamic> j) {
    final images = (j['images'] as List?) ?? const [];
    return VendorMenuItem(
      id: (j['id'] ?? '').toString(),
      name: (j['title'] ?? j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      priceNaira: _money(j['price']),
      category: (j['category'] ?? 'Mains').toString(),
      imageUrl: images.isNotEmpty ? images.first.toString() : '',
      available: '${j['status'] ?? 'active'}' == 'active',
      prepMins: (j['prepMins'] as num?)?.toInt() ?? 15,
      modifierGroups: _parseGroups(j['modifierGroups']),
    );
  }
}

/// Live menu store backed by `/v1/vendor/products`. Screens subscribe to
/// [items]; edits update optimistically and POST/PATCH to the API.
class VendorMenuController {
  VendorMenuController._() : items = ValueNotifier<List<VendorMenuItem>>([]) {
    load();
  }
  static final VendorMenuController instance = VendorMenuController._();

  /// Fixed category set the menu screen uses for its tab strip. Mirrors
  /// the customer-facing food categories so a vendor's tabs match what
  /// the customer sees on the restaurant detail screen.
  static const categories = ['Popular', 'Mains', 'Sides', 'Drinks'];

  final ValueNotifier<List<VendorMenuItem>> items;
  final _api = VendorApi.instance;

  /// True for an item that exists only in this session's optimistic state
  /// (its create call may still be in flight or have failed).
  bool _isLocal(String id) => id.startsWith('m-') || id.contains('-copy-');

  VendorMenuItem? byId(String id) {
    for (final it in items.value) {
      if (it.id == id) return it;
    }
    return null;
  }

  List<VendorMenuItem> byCategory(String c) {
    if (c == 'All') return List.unmodifiable(items.value);
    return [
      for (final it in items.value)
        if (it.category == c) it,
    ];
  }

  /// Pulls the vendor's products from the API.
  Future<void> load() async {
    try {
      final raw = await _api.listProducts();
      items.value = [
        for (final e in raw)
          VendorMenuItem.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh will retry.
    }
  }

  void toggleAvailable(String id) {
    final it = byId(id);
    if (it == null) return;
    it.available = !it.available;
    _bump();
  }

  /// Clone an item with " (copy)" appended to its name. Returns the new id
  /// so the caller can scroll to or open it.
  String clone(String id) {
    final src = byId(id);
    if (src == null) return id;
    final newId = '${src.id}-copy-${DateTime.now().millisecondsSinceEpoch}';
    final item = VendorMenuItem(
      id: newId,
      name: '${src.name} (copy)',
      description: src.description,
      priceNaira: src.priceNaira,
      category: src.category,
      imageUrl: src.imageUrl,
      available: src.available,
      prepMins: src.prepMins,
      modifierGroups: src.modifierGroups,
    );
    items.value = [...items.value, item];
    _create(item);
    return newId;
  }

  void delete(String id) {
    items.value = [
      for (final it in items.value)
        if (it.id != id) it,
    ];
    if (!_isLocal(id)) {
      _api.deleteProduct(id).catchError((_) {});
    }
  }

  /// Save edits to an existing item. Caller can pass any non-null field;
  /// the rest stay the same.
  void update({
    required String id,
    String? name,
    String? description,
    int? priceNaira,
    String? category,
    int? prepMins,
    bool? available,
    List<ModifierGroup>? modifierGroups,
  }) {
    final it = byId(id);
    if (it == null) return;
    if (name != null) it.name = name;
    if (description != null) it.description = description;
    if (priceNaira != null) it.priceNaira = priceNaira;
    if (category != null) it.category = category;
    if (prepMins != null) it.prepMins = prepMins;
    if (available != null) it.available = available;
    if (modifierGroups != null) it.modifierGroups = modifierGroups;
    _bump();
    if (!_isLocal(id)) {
      _api.updateProduct(id, {
        'title': ?name,
        'description': ?description,
        'price': ?priceNaira,
        'category': ?category,
        'prepMins': ?prepMins,
      }).catchError((_) {});
    }
  }

  /// Insert a new item authored from the menu-edit form. Returns the new id.
  String add({
    required String name,
    required String description,
    required int priceNaira,
    required String category,
    int prepMins = 15,
    bool available = true,
    String imageUrl =
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80&auto=format&fit=crop',
    List<ModifierGroup> modifierGroups = const [],
  }) {
    final newId = 'm-${DateTime.now().millisecondsSinceEpoch}';
    final item = VendorMenuItem(
      id: newId,
      name: name,
      description: description,
      priceNaira: priceNaira,
      category: category,
      imageUrl: imageUrl,
      available: available,
      prepMins: prepMins,
      modifierGroups: modifierGroups,
    );
    items.value = [...items.value, item];
    _create(item);
    return newId;
  }

  /// Pushes a freshly-added item to the API. The optimistic row keeps its
  /// local id for the session; the next [load] reconciles to the real one.
  Future<void> _create(VendorMenuItem item) async {
    try {
      await _api.createProduct({
        'title': item.name,
        'description': item.description,
        'price': item.priceNaira,
        'category': item.category,
        'prepMins': item.prepMins,
        'images': [if (item.imageUrl.isNotEmpty) item.imageUrl],
      });
    } on ApiException {
      // Keep the optimistic row; the vendor can retry the save.
    }
  }

  void _bump() => items.value = List.of(items.value);
}
