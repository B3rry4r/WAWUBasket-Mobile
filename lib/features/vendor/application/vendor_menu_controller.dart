import 'package:flutter/foundation.dart';

import '../../../core/utils/wb_format.dart';

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
}

/// In-memory store for the vendor's menu. Screens subscribe to [items];
/// edit / clone / toggle calls mutate the list and notify listeners.
class VendorMenuController {
  VendorMenuController._() : items = ValueNotifier<List<VendorMenuItem>>([]) {
    items.value = _seed();
  }
  static final VendorMenuController instance = VendorMenuController._();

  /// Fixed category set the menu screen uses for its tab strip. Mirrors
  /// the customer-facing food categories so a vendor's tabs match what
  /// the customer sees on the restaurant detail screen.
  static const categories = ['Popular', 'Mains', 'Sides', 'Drinks'];

  final ValueNotifier<List<VendorMenuItem>> items;

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
    items.value = [
      ...items.value,
      VendorMenuItem(
        id: newId,
        name: '${src.name} (copy)',
        description: src.description,
        priceNaira: src.priceNaira,
        category: src.category,
        imageUrl: src.imageUrl,
        available: src.available,
        prepMins: src.prepMins,
        modifierGroups: src.modifierGroups,
      ),
    ];
    return newId;
  }

  void delete(String id) {
    items.value = [
      for (final it in items.value)
        if (it.id != id) it,
    ];
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
    items.value = [
      ...items.value,
      VendorMenuItem(
        id: newId,
        name: name,
        description: description,
        priceNaira: priceNaira,
        category: category,
        imageUrl: imageUrl,
        available: available,
        prepMins: prepMins,
        modifierGroups: modifierGroups,
      ),
    ];
    return newId;
  }

  void _bump() => items.value = List.of(items.value);

  List<VendorMenuItem> _seed() => [
        VendorMenuItem(
          id: 'm1',
          name: 'Jollof rice & grilled chicken',
          description:
              'Smoky party-style jollof, charcoal-grilled chicken, fried plantain.',
          priceNaira: 4500,
          category: 'Popular',
          imageUrl:
              'https://images.unsplash.com/photo-1604908554049-3a3d3f9d3128?w=600&q=80&auto=format&fit=crop',
          prepMins: 25,
          modifierGroups: const [
            ModifierGroup(
              name: 'Spice level',
              required: true,
              options: [
                ModifierOption(label: 'Mild'),
                ModifierOption(label: 'Medium'),
                ModifierOption(label: 'Hot'),
                ModifierOption(label: 'Extra hot'),
              ],
            ),
            ModifierGroup(
              name: 'Add-ons',
              options: [
                ModifierOption(label: 'Add plantain', priceDeltaNaira: 500),
                ModifierOption(label: 'Add egg', priceDeltaNaira: 400),
                ModifierOption(label: 'Extra chicken', priceDeltaNaira: 1500),
              ],
            ),
          ],
        ),
        VendorMenuItem(
          id: 'm2',
          name: 'Egusi & pounded yam',
          description:
              'Hand-pounded yam, rich egusi, assorted meats and stockfish.',
          priceNaira: 5200,
          category: 'Mains',
          imageUrl:
              'https://images.unsplash.com/photo-1568827999250-3f6afff96e66?w=600&q=80&auto=format&fit=crop',
          prepMins: 35,
          modifierGroups: const [
            ModifierGroup(
              name: 'Protein',
              required: true,
              options: [
                ModifierOption(label: 'Mixed meat'),
                ModifierOption(label: 'Beef only'),
                ModifierOption(label: 'Goat meat', priceDeltaNaira: 700),
              ],
            ),
          ],
        ),
        VendorMenuItem(
          id: 'm3',
          name: 'Suya platter',
          description: 'Char-grilled spiced beef, onions, fresh tomato salad.',
          priceNaira: 4800,
          category: 'Popular',
          imageUrl:
              'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?w=600&q=80&auto=format&fit=crop',
          prepMins: 20,
        ),
        VendorMenuItem(
          id: 'm4',
          name: 'Plantain & beans',
          description: 'Soft beans porridge served with ripe fried plantain.',
          priceNaira: 3200,
          category: 'Mains',
          imageUrl:
              'https://images.unsplash.com/photo-1611764596828-eda4d10ec4f6?w=600&q=80&auto=format&fit=crop',
          prepMins: 25,
          available: false,
        ),
        VendorMenuItem(
          id: 'm5',
          name: 'Small chops platter',
          description: 'Puff puff, samosa, spring roll, peppered gizzard.',
          priceNaira: 3500,
          category: 'Sides',
          imageUrl:
              'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600&q=80&auto=format&fit=crop',
          prepMins: 15,
        ),
        VendorMenuItem(
          id: 'm6',
          name: 'Zobo (chilled)',
          description: 'Hibiscus drink, ginger, pineapple, a squeeze of lime.',
          priceNaira: 1200,
          category: 'Drinks',
          imageUrl:
              'https://images.unsplash.com/photo-1567448400815-59d5b8b6a36e?w=600&q=80&auto=format&fit=crop',
          prepMins: 5,
        ),
      ];
}

