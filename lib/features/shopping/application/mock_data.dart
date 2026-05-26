import '../../category/domain/models/category_kind.dart';
import '../../category/domain/models/subcategory.dart';
import '../../home/domain/models/category.dart';
import '../../home/domain/models/vendor.dart';
import '../../trade/domain/models/bulk_lot.dart';
import '../../trade/domain/models/supplier.dart';
import '../domain/models/product.dart';
import 'wb_images.dart';

/// Central mock content, categories, subcategories, vendors, products,
/// suppliers, bulk lots. Mirrors the WAWUBasket brand taxonomy.
abstract final class MockData {
  // ─── 9 brand categories — 4 primary verticals lead, then secondary ──
  static final categories = [
    // Primary verticals (shown first in home pill row)
    Category(
      id: 'restaurants',
      label: 'Restaurants',
      imageUrl: WBImages.jollof,
      svgAsset: 'assets/categories/category_restaurants.svg',
      kind: CategoryKind.restaurant,
      tagline: 'Hot meals. Fast.',
      subcategories: [
        Subcategory(id: 'chicken-republic', label: 'Chicken Republic', imageUrl: WBImages.friedChicken, svgAsset: 'assets/categories/sub_chicken_republic.svg'),
        Subcategory(id: 'local', label: 'Local restaurants', imageUrl: WBImages.jollof, svgAsset: 'assets/categories/sub_local.svg'),
        Subcategory(id: 'shawarma', label: 'Shawarma', imageUrl: WBImages.shawarma, svgAsset: 'assets/categories/sub_shawarma.svg'),
        Subcategory(id: 'pizza', label: 'Pizza', imageUrl: WBImages.cake, svgAsset: 'assets/categories/sub_pizza.svg'),
        Subcategory(id: 'burgers', label: 'Burgers', imageUrl: WBImages.friedChicken, svgAsset: 'assets/categories/sub_burgers.svg'),
        Subcategory(id: 'small-chops', label: 'Small chops', imageUrl: WBImages.puffPuff, svgAsset: 'assets/categories/sub_small_chops.svg'),
        Subcategory(id: 'bbq', label: 'BBQ', imageUrl: WBImages.suya, svgAsset: 'assets/categories/sub_bbq.svg'),
        Subcategory(id: 'rice', label: 'Rice dishes', imageUrl: WBImages.jollof, svgAsset: 'assets/categories/sub_rice.svg'),
      ],
    ),
    Category(
      id: 'fresh-market',
      label: 'Fresh Market',
      imageUrl: WBImages.tomato,
      svgAsset: 'assets/categories/category_fresh_market.svg',
      kind: CategoryKind.marketplace,
      tagline: 'Straight from the farm.',
      subcategories: [
        Subcategory(id: 'tomatoes', label: 'Tomatoes', imageUrl: WBImages.tomato, svgAsset: 'assets/categories/sub_tomatoes.svg'),
        Subcategory(id: 'pepper', label: 'Pepper', imageUrl: WBImages.pepper, svgAsset: 'assets/categories/sub_pepper.svg'),
        Subcategory(id: 'onion', label: 'Onion', imageUrl: WBImages.onion, svgAsset: 'assets/categories/sub_onion.svg'),
        Subcategory(id: 'yam', label: 'Yam', imageUrl: WBImages.yam, svgAsset: 'assets/categories/sub_yam.svg'),
        Subcategory(id: 'plantain', label: 'Plantain', imageUrl: WBImages.plantain, svgAsset: 'assets/categories/sub_plantain.svg'),
        Subcategory(id: 'vegetables', label: 'Vegetables', imageUrl: WBImages.vegetables, svgAsset: 'assets/categories/sub_vegetables.svg'),
        Subcategory(id: 'fresh-fish', label: 'Fresh fish', imageUrl: WBImages.freshFish, svgAsset: 'assets/categories/sub_fresh_fish.svg'),
        Subcategory(id: 'fresh-meat', label: 'Fresh meat', imageUrl: WBImages.freshMeat, svgAsset: 'assets/categories/sub_fresh_meat.svg'),
        Subcategory(id: 'fruits', label: 'Fruits', imageUrl: WBImages.fruits, svgAsset: 'assets/categories/sub_fruits.svg'),
      ],
    ),
    Category(
      id: 'livestock',
      label: 'Livestock',
      imageUrl: WBImages.chicken,
      svgAsset: 'assets/categories/category_livestock.svg',
      kind: CategoryKind.livestock,
      tagline: 'Cut exactly how you want.',
      subcategories: [
        Subcategory(id: 'chicken', label: 'Chicken', imageUrl: WBImages.chicken, svgAsset: 'assets/categories/sub_chicken.svg'),
        Subcategory(id: 'beef', label: 'Beef', imageUrl: WBImages.beef, svgAsset: 'assets/categories/sub_beef.svg'),
        Subcategory(id: 'goat', label: 'Goat', imageUrl: WBImages.goat, svgAsset: 'assets/categories/sub_goat.svg'),
        Subcategory(id: 'fish', label: 'Fish', imageUrl: WBImages.fish, svgAsset: 'assets/categories/sub_fish.svg'),
        Subcategory(id: 'seafood', label: 'Seafood', imageUrl: WBImages.seafood, svgAsset: 'assets/categories/sub_seafood.svg'),
      ],
    ),
    Category(
      id: 'kitchen-essentials',
      label: 'Kitchen Essentials',
      imageUrl: WBImages.kitchenSupplies,
      svgAsset: 'assets/categories/category_kitchen_essentials.svg',
      kind: CategoryKind.marketplace,
      tagline: 'Pots, pans, and everything else.',
      subcategories: [
        Subcategory(id: 'cookware', label: 'Cookware', imageUrl: WBImages.kitchenSupplies, svgAsset: 'assets/categories/sub_cookware.svg'),
        Subcategory(id: 'utensils', label: 'Utensils', imageUrl: WBImages.kitchenSupplies, svgAsset: 'assets/categories/sub_utensils.svg'),
        Subcategory(id: 'spices-oil', label: 'Spices & Oil', imageUrl: WBImages.spices, svgAsset: 'assets/categories/sub_spices_oil.svg'),
        Subcategory(id: 'pantry', label: 'Pantry', imageUrl: WBImages.rice, svgAsset: 'assets/categories/sub_pantry.svg'),
        Subcategory(id: 'cleaning', label: 'Cleaning', imageUrl: WBImages.cleaning, svgAsset: 'assets/categories/sub_cleaning.svg'),
      ],
    ),
    // Secondary categories
    Category(
      id: 'groceries',
      label: 'Groceries',
      imageUrl: WBImages.rice,
      svgAsset: 'assets/categories/category_groceries.svg',
      kind: CategoryKind.marketplace,
      tagline: 'Pantry · Daily essentials',
      subcategories: [
        Subcategory(id: 'rice', label: 'Rice', imageUrl: WBImages.rice, svgAsset: 'assets/categories/sub_rice_g.svg'),
        Subcategory(id: 'beans', label: 'Beans', imageUrl: WBImages.beans, svgAsset: 'assets/categories/sub_beans.svg'),
        Subcategory(id: 'garri', label: 'Garri', imageUrl: WBImages.garri, svgAsset: 'assets/categories/sub_garri.svg'),
        Subcategory(id: 'oil', label: 'Oil', imageUrl: WBImages.oil, svgAsset: 'assets/categories/sub_oil.svg'),
        Subcategory(id: 'sugar', label: 'Sugar', imageUrl: WBImages.sugar, svgAsset: 'assets/categories/sub_sugar.svg'),
        Subcategory(id: 'milk', label: 'Milk', imageUrl: WBImages.milk, svgAsset: 'assets/categories/sub_milk.svg'),
        Subcategory(id: 'bread', label: 'Bread', imageUrl: WBImages.bread, svgAsset: 'assets/categories/sub_bread.svg'),
        Subcategory(id: 'eggs', label: 'Eggs', imageUrl: WBImages.eggs, svgAsset: 'assets/categories/sub_eggs.svg'),
        Subcategory(id: 'spices', label: 'Spices', imageUrl: WBImages.spices, svgAsset: 'assets/categories/sub_spices.svg'),
      ],
    ),
    Category(
      id: 'farm-produce',
      label: 'Farm Produce',
      imageUrl: WBImages.riceBag,
      svgAsset: 'assets/categories/category_farm_produce.svg',
      kind: CategoryKind.trade,
      tagline: 'Bulk · Wholesale · Direct from farm',
      subcategories: [
        Subcategory(id: 'rice-bags', label: 'Bags of rice', imageUrl: WBImages.riceBag, svgAsset: 'assets/categories/sub_rice_bags.svg'),
        Subcategory(id: 'cassava', label: 'Cassava', imageUrl: WBImages.cassava, svgAsset: 'assets/categories/sub_cassava.svg'),
        Subcategory(id: 'palm-oil', label: 'Palm oil', imageUrl: WBImages.palmOil, svgAsset: 'assets/categories/sub_palm_oil.svg'),
        Subcategory(id: 'cocoa', label: 'Cocoa', imageUrl: WBImages.cocoa, svgAsset: 'assets/categories/sub_cocoa.svg'),
        Subcategory(id: 'maize', label: 'Maize', imageUrl: WBImages.maize, svgAsset: 'assets/categories/sub_maize.svg'),
        Subcategory(id: 'feed', label: 'Livestock feed', imageUrl: WBImages.livestockFeed, svgAsset: 'assets/categories/sub_feed.svg'),
        Subcategory(id: 'fertilizer', label: 'Fertilizer', imageUrl: WBImages.fertilizer, svgAsset: 'assets/categories/sub_fertilizer.svg'),
        Subcategory(id: 'bulk-veg', label: 'Bulk vegetables', imageUrl: WBImages.vegetables, svgAsset: 'assets/categories/sub_bulk_veg.svg'),
      ],
    ),
    Category(
      id: 'drinks',
      label: 'Drinks',
      imageUrl: WBImages.softDrinks,
      svgAsset: 'assets/categories/category_drinks.svg',
      kind: CategoryKind.marketplace,
      tagline: 'Soft drinks · Water · Juice',
      subcategories: [
        Subcategory(id: 'soft', label: 'Soft drinks', imageUrl: WBImages.softDrinks, svgAsset: 'assets/categories/sub_soft.svg'),
        Subcategory(id: 'water', label: 'Water', imageUrl: WBImages.water, svgAsset: 'assets/categories/sub_water.svg'),
        Subcategory(id: 'juice', label: 'Juice', imageUrl: WBImages.juice, svgAsset: 'assets/categories/sub_juice.svg'),
        Subcategory(id: 'energy', label: 'Energy drinks', imageUrl: WBImages.energyDrink, svgAsset: 'assets/categories/sub_energy.svg'),
      ],
    ),
    Category(
      id: 'snacks',
      label: 'Snacks',
      imageUrl: WBImages.cake,
      svgAsset: 'assets/categories/category_snacks.svg',
      kind: CategoryKind.marketplace,
      tagline: 'Bakery · Treats',
      subcategories: [
        Subcategory(id: 'cakes', label: 'Cakes', imageUrl: WBImages.cake, svgAsset: 'assets/categories/sub_cakes.svg'),
        Subcategory(id: 'bread', label: 'Bread', imageUrl: WBImages.bread, svgAsset: 'assets/categories/sub_bread_snacks.svg'),
        Subcategory(id: 'pastries', label: 'Pastries', imageUrl: WBImages.pastry, svgAsset: 'assets/categories/sub_pastries.svg'),
        Subcategory(id: 'cookies', label: 'Cookies', imageUrl: WBImages.cookies, svgAsset: 'assets/categories/sub_cookies.svg'),
        Subcategory(id: 'snacks', label: 'Snacks', imageUrl: WBImages.snacks, svgAsset: 'assets/categories/sub_snacks.svg'),
      ],
    ),
    Category(
      id: 'pharmacy',
      label: 'Pharmacy',
      imageUrl: WBImages.pharmacy,
      svgAsset: 'assets/categories/category_pharmacy.svg',
      kind: CategoryKind.marketplace,
      tagline: 'Wellness · OTC',
      subcategories: [
        Subcategory(id: 'otc', label: 'OTC medication', imageUrl: WBImages.pharmacy, svgAsset: 'assets/categories/sub_otc.svg'),
        Subcategory(id: 'wellness', label: 'Wellness', imageUrl: WBImages.vitamins, svgAsset: 'assets/categories/sub_wellness.svg'),
        Subcategory(id: 'vitamins', label: 'Vitamins', imageUrl: WBImages.vitamins, svgAsset: 'assets/categories/sub_vitamins.svg'),
      ],
    ),
  ];

  // ─── Vendors (restaurants only, for vendor carousel) ────────
  static const vendors = [
    Vendor(
      id: 'v1',
      name: 'Mama Cass Kitchen',
      shortName: 'Mama Cass',
      cuisine: 'Nigerian · Local · Lagos Island',
      rating: 4.8,
      reviews: '2,481',
      etaMin: 22,
      etaMax: 28,
      deliveryFee: 600,
      imageUrl: WBImages.jollof,
      tags: ['Free delivery', 'Halal'],
    ),
    Vendor(
      id: 'v2',
      name: 'Suya & Smoke',
      shortName: 'Suya & Smoke',
      cuisine: 'Grill · Street food · Lekki',
      rating: 4.9,
      reviews: '3,820',
      etaMin: 30,
      etaMax: 35,
      deliveryFee: 700,
      imageUrl: WBImages.suya,
      tags: ['Popular'],
    ),
    Vendor(
      id: 'v3',
      name: 'Iya Basira Buka',
      shortName: 'Iya Basira',
      cuisine: 'Amala · Ewedu · Surulere',
      rating: 4.7,
      reviews: '1,612',
      etaMin: 18,
      etaMax: 25,
      deliveryFee: 500,
      imageUrl: WBImages.poundedYam,
      tags: ['Free delivery'],
    ),
    Vendor(
      id: 'v4',
      name: 'Chicken Republic',
      shortName: 'Chicken Republic',
      cuisine: 'Fast food · Fried chicken · Ikoyi',
      rating: 4.6,
      reviews: '4,920',
      etaMin: 25,
      etaMax: 35,
      deliveryFee: 800,
      imageUrl: WBImages.friedChicken,
      tags: ['Combo deals'],
    ),
  ];

  // ─── Menu, restaurant dishes (used in vendor screen + home) ──
  static const menu = [
    Product(
      id: 'm1',
      name: 'Jollof rice & grilled chicken',
      description:
          'Smoky party-style jollof, charcoal-grilled chicken, fried plantain.',
      priceNaira: 4500,
      vendorName: 'Mama Cass Kitchen',
      imageUrl: WBImages.jollof,
      categoryId: 'restaurants',
      subcategoryId: 'rice',
    ),
    Product(
      id: 'm2',
      name: 'Egusi & pounded yam',
      description:
          'Hand-pounded yam served with rich egusi soup and assorted meats.',
      priceNaira: 5200,
      vendorName: 'Mama Cass Kitchen',
      imageUrl: WBImages.egusi,
      categoryId: 'restaurants',
      subcategoryId: 'local',
    ),
    Product(
      id: 'm3',
      name: 'Suya platter',
      description:
          'Char-grilled spiced beef strips, onions, fresh tomato salad.',
      priceNaira: 4800,
      vendorName: 'Suya & Smoke',
      imageUrl: WBImages.suya,
      categoryId: 'restaurants',
      subcategoryId: 'bbq',
    ),
    Product(
      id: 'm4',
      name: 'Plantain & beans',
      description: 'Soft beans porridge served with ripe fried plantain.',
      priceNaira: 3200,
      vendorName: 'Mama Cass Kitchen',
      imageUrl: WBImages.friedPlantain,
      categoryId: 'restaurants',
      subcategoryId: 'local',
    ),
    Product(
      id: 'm5',
      name: 'Shawarma, chicken',
      description: 'Grilled chicken, garlic sauce, fresh vegetables, soft wrap.',
      priceNaira: 2800,
      vendorName: 'Chicken Republic',
      imageUrl: WBImages.shawarma,
      categoryId: 'restaurants',
      subcategoryId: 'shawarma',
    ),
    Product(
      id: 'm6',
      name: 'Small chops platter',
      description: 'Puff puff, samosa, spring roll, peppered gizzard.',
      priceNaira: 3500,
      vendorName: 'Suya & Smoke',
      imageUrl: WBImages.puffPuff,
      categoryId: 'restaurants',
      subcategoryId: 'small-chops',
    ),
  ];

  // ─── Marketplace products (non-restaurant cats) ──────────────
  static const marketplaceProducts = [
    // Groceries
    Product(
      id: 'gp1',
      name: 'Long grain rice',
      description: 'Premium parboiled long grain rice.',
      priceNaira: 1200,
      vendorName: 'Pantry Plus',
      imageUrl: WBImages.rice,
      categoryId: 'groceries',
      subcategoryId: 'rice',
      unit: '/ kg',
    ),
    Product(
      id: 'gp2',
      name: 'Honey beans',
      description: 'Clean, hand-sorted honey beans.',
      priceNaira: 1500,
      vendorName: 'Pantry Plus',
      imageUrl: WBImages.beans,
      categoryId: 'groceries',
      subcategoryId: 'beans',
      unit: '/ kg',
    ),
    Product(
      id: 'gp3',
      name: 'Ijebu garri',
      description: 'Coarse, dry Ijebu garri.',
      priceNaira: 900,
      vendorName: 'Pantry Plus',
      imageUrl: WBImages.garri,
      categoryId: 'groceries',
      subcategoryId: 'garri',
      unit: '/ kg',
    ),
    Product(
      id: 'gp4',
      name: 'Groundnut oil, 5 L',
      description: 'Pure, locally pressed groundnut oil.',
      priceNaira: 8500,
      vendorName: 'Pantry Plus',
      imageUrl: WBImages.oil,
      categoryId: 'groceries',
      subcategoryId: 'oil',
    ),
    Product(
      id: 'gp5',
      name: 'Crate of eggs',
      description: 'Farm-fresh, 30 large eggs.',
      priceNaira: 4500,
      vendorName: 'Pantry Plus',
      imageUrl: WBImages.eggs,
      categoryId: 'groceries',
      subcategoryId: 'eggs',
    ),
    Product(
      id: 'gp6',
      name: 'Suya pepper mix',
      description: 'Classic Northern suya spice blend.',
      priceNaira: 700,
      vendorName: 'Pantry Plus',
      imageUrl: WBImages.spices,
      categoryId: 'groceries',
      subcategoryId: 'spices',
      unit: '/ 100g',
    ),

    // Fresh Market
    Product(
      id: 'fm1',
      name: 'Fresh tomatoes',
      description: 'Sun-ripened, hand-picked tomatoes from Jos.',
      priceNaira: 1800,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.tomato,
      categoryId: 'fresh-market',
      subcategoryId: 'tomatoes',
      unit: '/ basket',
    ),
    Product(
      id: 'fm2',
      name: 'Red rodo pepper',
      description: 'Hot, fragrant Nigerian rodo pepper.',
      priceNaira: 1200,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.pepper,
      categoryId: 'fresh-market',
      subcategoryId: 'pepper',
      unit: '/ paint',
    ),
    Product(
      id: 'fm3',
      name: 'Red onion',
      description: 'Large, sharp Sokoto onions.',
      priceNaira: 900,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.onion,
      categoryId: 'fresh-market',
      subcategoryId: 'onion',
      unit: '/ kg',
    ),
    Product(
      id: 'fm4',
      name: 'Puna yam',
      description: 'Premium puna yam, sweet & firm.',
      priceNaira: 2500,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.yam,
      categoryId: 'fresh-market',
      subcategoryId: 'yam',
      unit: '/ tuber',
    ),
    Product(
      id: 'fm5',
      name: 'Ripe plantain',
      description: 'Sweet, perfectly ripe plantain.',
      priceNaira: 1500,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.plantain,
      categoryId: 'fresh-market',
      subcategoryId: 'plantain',
      unit: '/ bunch',
    ),
    Product(
      id: 'fm6',
      name: 'Fresh catfish',
      description: 'Live catfish, cleaned on order.',
      priceNaira: 4000,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.freshFish,
      categoryId: 'fresh-market',
      subcategoryId: 'fresh-fish',
      unit: '/ kg',
    ),
    Product(
      id: 'fm7',
      name: 'Mixed vegetables',
      description: 'Ugu, water leaf, scent leaf bundle.',
      priceNaira: 1100,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.vegetables,
      categoryId: 'fresh-market',
      subcategoryId: 'vegetables',
      unit: '/ bundle',
    ),
    Product(
      id: 'fm8',
      name: 'Fresh meat, beef',
      description: 'Daily-cut beef, bone-in or boneless.',
      priceNaira: 3800,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.freshMeat,
      categoryId: 'fresh-market',
      subcategoryId: 'fresh-meat',
      unit: '/ kg',
    ),
    Product(
      id: 'fm9',
      name: 'Seasonal fruit basket',
      description: 'Pineapple, mango, banana, pawpaw.',
      priceNaira: 5500,
      vendorName: 'Mile 12 Market',
      imageUrl: WBImages.fruits,
      categoryId: 'fresh-market',
      subcategoryId: 'fruits',
      unit: '/ basket',
    ),

    // Livestock
    Product(
      id: 'lv1',
      name: 'Whole chicken',
      description: 'Farm-raised, Halal-certified. Cut to order.',
      priceNaira: 5500,
      vendorName: 'Butcher John',
      imageUrl: WBImages.chicken,
      categoryId: 'livestock',
      subcategoryId: 'chicken',
      unit: '/ kg',
    ),
    Product(
      id: 'lv2',
      name: 'Fresh beef',
      description: 'Daily-cut, bone-in or boneless.',
      priceNaira: 4200,
      vendorName: 'Butcher John',
      imageUrl: WBImages.beef,
      categoryId: 'livestock',
      subcategoryId: 'beef',
      unit: '/ kg',
    ),
    Product(
      id: 'lv3',
      name: 'Goat meat',
      description: 'Pepper-soup ready, fresh cut.',
      priceNaira: 6800,
      vendorName: 'Butcher John',
      imageUrl: WBImages.goat,
      categoryId: 'livestock',
      subcategoryId: 'goat',
      unit: '/ kg',
    ),
    Product(
      id: 'lv4',
      name: 'Catfish',
      description: 'Live catfish, cleaned on order.',
      priceNaira: 4000,
      vendorName: 'Butcher John',
      imageUrl: WBImages.fish,
      categoryId: 'livestock',
      subcategoryId: 'fish',
      unit: '/ kg',
    ),
    Product(
      id: 'lv5',
      name: 'Mixed seafood',
      description: 'Prawns, shrimp, calamari pack.',
      priceNaira: 7500,
      vendorName: 'Butcher John',
      imageUrl: WBImages.seafood,
      categoryId: 'livestock',
      subcategoryId: 'seafood',
      unit: '/ kg',
    ),

    // Household
    Product(
      id: 'hh1',
      name: 'Multi-surface cleaner',
      description: 'Lemon-fresh, 1 L bottle.',
      priceNaira: 1500,
      vendorName: 'HomeStock',
      imageUrl: WBImages.cleaning,
      categoryId: 'kitchen-essentials',
      subcategoryId: 'cleaning',
    ),
    Product(
      id: 'hh2',
      name: 'Wooden spoon set',
      description: 'Pack of 5 — every pot needs one.',
      priceNaira: 1800,
      vendorName: 'HomeStock',
      imageUrl: WBImages.kitchenSupplies,
      categoryId: 'kitchen-essentials',
      subcategoryId: 'utensils',
    ),
    Product(
      id: 'hh3',
      name: 'Non-stick pan set',
      description: 'Two-piece kitchen essential.',
      priceNaira: 8900,
      vendorName: 'HomeStock',
      imageUrl: WBImages.kitchenSupplies,
      categoryId: 'kitchen-essentials',
      subcategoryId: 'cookware',
    ),

    // Drinks
    Product(
      id: 'dr1',
      name: 'Coke 50 cl × 6',
      description: 'Chilled soft drinks, 6-pack.',
      priceNaira: 1800,
      vendorName: 'Cool Crate',
      imageUrl: WBImages.softDrinks,
      categoryId: 'drinks',
      subcategoryId: 'soft',
    ),
    Product(
      id: 'dr2',
      name: 'Bottled water 75 cl × 12',
      description: 'Mineral water, full pack.',
      priceNaira: 1500,
      vendorName: 'Cool Crate',
      imageUrl: WBImages.water,
      categoryId: 'drinks',
      subcategoryId: 'water',
    ),
    Product(
      id: 'dr3',
      name: 'Fresh orange juice',
      description: 'Cold-pressed, 1 L bottle.',
      priceNaira: 2200,
      vendorName: 'Cool Crate',
      imageUrl: WBImages.juice,
      categoryId: 'drinks',
      subcategoryId: 'juice',
    ),

    // Snacks
    Product(
      id: 'sn1',
      name: 'Birthday cake, half slab',
      description: 'Vanilla butter cake, fresh icing.',
      priceNaira: 12000,
      vendorName: 'Sweet Spot',
      imageUrl: WBImages.cake,
      categoryId: 'snacks',
      subcategoryId: 'cakes',
    ),
    Product(
      id: 'sn2',
      name: 'Meat pie box',
      description: 'Six freshly-baked meat pies.',
      priceNaira: 3000,
      vendorName: 'Sweet Spot',
      imageUrl: WBImages.pastry,
      categoryId: 'snacks',
      subcategoryId: 'pastries',
    ),
    Product(
      id: 'sn3',
      name: 'Chin chin family pack',
      description: 'Crunchy traditional snack.',
      priceNaira: 1800,
      vendorName: 'Sweet Spot',
      imageUrl: WBImages.snacks,
      categoryId: 'snacks',
      subcategoryId: 'snacks',
    ),

    // Pharmacy
    Product(
      id: 'ph1',
      name: 'Paracetamol, 24 tabs',
      description: 'For mild pain & fever.',
      priceNaira: 800,
      vendorName: 'HealthDirect',
      imageUrl: WBImages.pharmacy,
      categoryId: 'pharmacy',
      subcategoryId: 'otc',
    ),
    Product(
      id: 'ph2',
      name: 'Multivitamin, 30 tabs',
      description: 'Daily wellness, A–Z support.',
      priceNaira: 4500,
      vendorName: 'HealthDirect',
      imageUrl: WBImages.vitamins,
      categoryId: 'pharmacy',
      subcategoryId: 'vitamins',
    ),
  ];

  // ─── Trade, suppliers + bulk lots (farm-produce only) ───────
  static const suppliers = [
    Supplier(
      id: 's1',
      name: 'Adamu Farms Co-op',
      region: 'Kaduna · Nigeria',
      capacity: '500 bags / week',
      rating: 4.9,
      reviews: 142,
      avatarUrl: WBImages.supplierAvatar1,
      specialties: ['Rice', 'Maize', 'Beans'],
    ),
    Supplier(
      id: 's2',
      name: 'Adeleke Palm Mill',
      region: 'Ondo · Nigeria',
      capacity: '2,000 L / week',
      rating: 4.8,
      reviews: 89,
      avatarUrl: WBImages.supplierAvatar2,
      specialties: ['Palm oil', 'Palm kernel'],
    ),
    Supplier(
      id: 's3',
      name: 'Niger Delta Cassava Hub',
      region: 'Bayelsa · Nigeria',
      capacity: '8 tonnes / month',
      rating: 4.7,
      reviews: 64,
      avatarUrl: WBImages.supplierAvatar3,
      specialties: ['Cassava', 'Garri'],
    ),
    Supplier(
      id: 's4',
      name: 'Plateau Maize Growers',
      region: 'Plateau · Nigeria',
      capacity: '1,200 bags / month',
      rating: 4.8,
      reviews: 117,
      avatarUrl: WBImages.supplierAvatar4,
      specialties: ['Maize', 'Feed'],
    ),
  ];

  static const bulkLots = [
    BulkLot(
      id: 'b1',
      produce: 'Long grain rice',
      lotSize: '50 kg bag',
      unitPriceNaira: 68000,
      minOrder: 5,
      supplierName: 'Adamu Farms Co-op',
      region: 'Kaduna',
      imageUrl: WBImages.riceBag,
    ),
    BulkLot(
      id: 'b2',
      produce: 'Palm oil',
      lotSize: '25 L jerry can',
      unitPriceNaira: 42000,
      minOrder: 3,
      supplierName: 'Adeleke Palm Mill',
      region: 'Ondo',
      imageUrl: WBImages.palmOil,
    ),
    BulkLot(
      id: 'b3',
      produce: 'Cassava tubers',
      lotSize: '100 kg sack',
      unitPriceNaira: 28000,
      minOrder: 4,
      supplierName: 'Niger Delta Cassava Hub',
      region: 'Bayelsa',
      imageUrl: WBImages.cassava,
    ),
    BulkLot(
      id: 'b4',
      produce: 'Yellow maize',
      lotSize: '100 kg bag',
      unitPriceNaira: 55000,
      minOrder: 5,
      supplierName: 'Plateau Maize Growers',
      region: 'Plateau',
      imageUrl: WBImages.maize,
    ),
    BulkLot(
      id: 'b5',
      produce: 'Cocoa beans',
      lotSize: '60 kg sack',
      unitPriceNaira: 95000,
      minOrder: 2,
      supplierName: 'Adeleke Palm Mill',
      region: 'Ondo',
      imageUrl: WBImages.cocoa,
    ),
    BulkLot(
      id: 'b6',
      produce: 'Layer mash feed',
      lotSize: '25 kg bag',
      unitPriceNaira: 18000,
      minOrder: 10,
      supplierName: 'Plateau Maize Growers',
      region: 'Plateau',
      imageUrl: WBImages.livestockFeed,
    ),
  ];

  static final cart = [
    CartLine(product: menu[0], quantity: 2, note: 'Extra spicy'),
    CartLine(product: menu[2], quantity: 1),
  ];

  // ─── Helpers ─────────────────────────────────────────────────
  static Category? categoryById(String id) {
    // Prefer the live API list when available, fall back to static mock.
    final live = liveCategories();
    if (live != null) {
      return live.firstWhere((c) => c.id == id, orElse: () => categories.first);
    }
    return categories.firstWhere((c) => c.id == id,
        orElse: () => categories.first);
  }

  // Resolved lazily via a function reference to avoid a circular import
  // at class-load time. Assigned by CategoryController once it is initialised.
  static List<Category>? Function() liveCategories = () => null;

  /// Every purchasable product across restaurant menus and the
  /// marketplace, so a detail screen can resolve any tapped id.
  static List<Product> get allProducts => [...menu, ...marketplaceProducts];

  /// Resolve a product by id. Falls back to the first menu item so a
  /// stale / missing id never crashes the detail screen.
  static Product productById(String? id) {
    if (id == null) return menu.first;
    for (final p in allProducts) {
      if (p.id == id) return p;
    }
    return menu.first;
  }

  /// Resolve a vendor by id, falling back to the first vendor.
  static Vendor vendorById(String? id) {
    if (id == null) return vendors.first;
    for (final v in vendors) {
      if (v.id == id) return v;
    }
    return vendors.first;
  }

  /// The menu items a given vendor sells (matched on vendorName, which
  /// is what the mock data carries).
  static List<Product> productsForVendor(String vendorName) => [
        for (final p in menu)
          if (p.vendorName == vendorName) p,
      ];

  static List<Product> productsForCategory(
    String categoryId, {
    String? subcategoryId,
  }) {
    final source = categoryId == 'restaurants' ? menu : marketplaceProducts;
    return [
      for (final p in source)
        if (p.categoryId == categoryId &&
            (subcategoryId == null || p.subcategoryId == subcategoryId))
          p,
    ];
  }

  static List<Vendor> vendorsForCategory(String categoryId) {
    // Today only restaurants have vendor cards; the marketplace shows a
    // single "trusted vendor" handle on each product.
    if (categoryId == 'restaurants') return vendors;
    return const [];
  }
}
