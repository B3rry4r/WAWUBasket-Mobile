import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension WBL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Returns the localized label for a top-level category by its ID,
  /// falling back to [fallback] (the English label from the data model).
  String categoryLabel(String id, {String fallback = ''}) {
    final s = l10n;
    return switch (id) {
      'restaurants' => s.catRestaurants,
      'fresh-market' => s.catFreshMarket,
      'livestock' => s.catLivestock,
      'kitchen-essentials' => s.catKitchenEssentials,
      'groceries' => s.catGroceries,
      'farm-produce' => s.catFarmProduce,
      'drinks' => s.catDrinks,
      'snacks' => s.catSnacks,
      'pharmacy' => s.catPharmacy,
      _ => fallback.isNotEmpty ? fallback : id,
    };
  }

  /// Returns the localized tagline for a category by its ID.
  String categoryTagline(String id, {String fallback = ''}) {
    final s = l10n;
    return switch (id) {
      'restaurants' => s.catTagRestaurants,
      'fresh-market' => s.catTagFreshMarket,
      'livestock' => s.catTagLivestock,
      'kitchen-essentials' => s.catTagKitchenEssentials,
      'groceries' => s.catTagGroceries,
      'farm-produce' => s.catTagFarmProduce,
      'drinks' => s.catTagDrinks,
      'snacks' => s.catTagSnacks,
      'pharmacy' => s.catTagPharmacy,
      _ => fallback.isNotEmpty ? fallback : id,
    };
  }

  /// Returns the localized label for a subcategory by its ID.
  String subcategoryLabel(String id, {String fallback = ''}) {
    final s = l10n;
    return switch (id) {
      'all' => s.subcatAll,
      'fast-food' => s.subcatFastFood,
      'local-cuisine' => s.subcatLocalCuisine,
      'fine-dining' => s.subcatFineDining,
      'grills-bbq' => s.subcatGrillsBbq,
      'seafood' => s.subcatSeafood,
      'breakfast-brunch' => s.subcatBreakfastBrunch,
      'cafes' => s.subcatCafes,
      'shawarma' => s.subcatShawarma,
      'pizza' => s.subcatPizza,
      'burgers' => s.subcatBurgers,
      'small-chops' => s.subcatSmallChops,
      'rice' || 'rice-dishes' => s.subcatRiceDishes,
      'tomatoes' => s.subcatTomatoes,
      'pepper' => s.subcatPepper,
      'onion' => s.subcatOnion,
      'yam' => s.subcatYam,
      'plantain' => s.subcatPlantain,
      'vegetables' => s.subcatVegetables,
      'fresh-fish' => s.subcatFreshFish,
      'fresh-meat' => s.subcatFreshMeat,
      'fruits' => s.subcatFruits,
      'chicken' => s.subcatChicken,
      'beef' => s.subcatBeef,
      'goat' => s.subcatGoat,
      'fish' => s.subcatFish,
      'cookware' => s.subcatCookware,
      'utensils' => s.subcatUtensils,
      'spices-oil' => s.subcatSpicesOil,
      'pantry' => s.subcatPantry,
      'cleaning' => s.subcatCleaning,
      'beans' => s.subcatBeans,
      'garri' => s.subcatGarri,
      'oil' => s.subcatOil,
      'sugar' => s.subcatSugar,
      'milk' => s.subcatMilk,
      'bread' => s.subcatBread,
      'eggs' => s.subcatEggs,
      'spices' => s.subcatSpices,
      'rice-bags' => s.subcatRiceBags,
      'cassava' => s.subcatCassava,
      'palm-oil' => s.subcatPalmOil,
      'cocoa' => s.subcatCocoa,
      'maize' => s.subcatMaize,
      'feed' => s.subcatFeed,
      'fertilizer' => s.subcatFertilizer,
      'bulk-veg' => s.subcatBulkVeg,
      'soft' => s.subcatSoftDrinks,
      'water' => s.subcatWater,
      'juice' => s.subcatJuice,
      'energy' => s.subcatEnergyDrinks,
      'cakes' => s.subcatCakes,
      'pastries' => s.subcatPastries,
      'cookies' => s.subcatCookies,
      'snacks' => s.subcatSnacks,
      'otc' => s.subcatOtcMeds,
      'wellness' => s.subcatWellness,
      'vitamins' => s.subcatVitamins,
      _ => fallback.isNotEmpty ? fallback : id,
    };
  }
}
