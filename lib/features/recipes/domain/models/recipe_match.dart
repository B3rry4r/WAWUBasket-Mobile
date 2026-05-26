import 'package:equatable/equatable.dart';

/// One ingredient successfully sourced to a real seller, with the price the
/// matching engine quoted. `lineTotalKobo` already accounts for the size
/// multiplier and the seller's per-unit price.
class MatchedIngredient extends Equatable {
  const MatchedIngredient({
    required this.ingredientId,
    required this.name,
    required this.subcategoryId,
    required this.qty,
    required this.unit,
    required this.sellerId,
    required this.sellerName,
    required this.unitPriceKobo,
    required this.lineTotalKobo,
    required this.available,
    this.sellerRating,
  });

  final String ingredientId;
  final String name;
  final String subcategoryId;
  final double qty;
  final String unit;
  final String sellerId;
  final String sellerName;
  final double? sellerRating;
  final int unitPriceKobo;
  final int lineTotalKobo;
  final bool available;

  factory MatchedIngredient.fromJson(Map<String, dynamic> j) =>
      MatchedIngredient(
        ingredientId: (j['ingredientId'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        subcategoryId: (j['subcategoryId'] ?? '').toString(),
        qty: (j['qty'] as num?)?.toDouble() ?? 0,
        unit: (j['unit'] ?? '').toString(),
        sellerId: (j['sellerId'] ?? '').toString(),
        sellerName: (j['sellerName'] ?? '').toString(),
        sellerRating: (j['sellerRating'] as num?)?.toDouble(),
        unitPriceKobo: (j['unitPriceKobo'] as num?)?.toInt() ?? 0,
        lineTotalKobo: (j['lineTotalKobo'] as num?)?.toInt() ?? 0,
        available: j['available'] != false,
      );

  @override
  List<Object?> get props =>
      [ingredientId, sellerId, qty, unit, lineTotalKobo, available];
}

/// One ingredient the matching engine couldn't source in the user's area —
/// surfaced to the user before they add the combo to their basket.
class UnavailableIngredient extends Equatable {
  const UnavailableIngredient({required this.name, required this.reason});

  final String name;
  final String reason;

  factory UnavailableIngredient.fromJson(Map<String, dynamic> j) =>
      UnavailableIngredient(
        name: (j['name'] ?? '').toString(),
        reason: (j['reason'] ?? '').toString(),
      );

  @override
  List<Object?> get props => [name, reason];
}

/// The full quote returned by `POST /v1/recipes/:id/match` — the live
/// price the detail screen shows and the contents of the combo the user
/// adds to their basket.
class RecipeMatch extends Equatable {
  const RecipeMatch({
    required this.recipeId,
    required this.sizeId,
    required this.sizeLabel,
    required this.servesLabel,
    required this.ingredients,
    required this.unavailable,
    required this.subtotalKobo,
    required this.serviceFeeKobo,
    required this.packagingFeeKobo,
    required this.deliveryFeeKobo,
    required this.totalKobo,
    required this.currency,
    required this.fullyAvailable,
  });

  final String recipeId;
  final String sizeId;
  final String sizeLabel;
  final String servesLabel;
  final List<MatchedIngredient> ingredients;
  final List<UnavailableIngredient> unavailable;
  final int subtotalKobo;
  final int serviceFeeKobo;
  final int packagingFeeKobo;
  final int deliveryFeeKobo;
  final int totalKobo;
  final String currency;
  final bool fullyAvailable;

  /// Count of distinct sellers the matched ingredients pull from.
  int get vendorCount =>
      ingredients.map((i) => i.sellerId).toSet().length;

  factory RecipeMatch.fromJson(Map<String, dynamic> j) => RecipeMatch(
        recipeId: (j['recipeId'] ?? '').toString(),
        sizeId: (j['sizeId'] ?? '').toString(),
        sizeLabel: (j['sizeLabel'] ?? '').toString(),
        servesLabel: (j['servesLabel'] ?? '').toString(),
        ingredients: ((j['ingredients'] as List?) ?? const [])
            .map((e) =>
                MatchedIngredient.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        unavailable: ((j['unavailable'] as List?) ?? const [])
            .map((e) => UnavailableIngredient.fromJson(
                (e as Map).cast<String, dynamic>()))
            .toList(),
        subtotalKobo: (j['subtotalKobo'] as num?)?.toInt() ?? 0,
        serviceFeeKobo: (j['serviceFeeKobo'] as num?)?.toInt() ?? 0,
        packagingFeeKobo: (j['packagingFeeKobo'] as num?)?.toInt() ?? 0,
        deliveryFeeKobo: (j['deliveryFeeKobo'] as num?)?.toInt() ?? 0,
        totalKobo: (j['totalKobo'] as num?)?.toInt() ?? 0,
        currency: (j['currency'] ?? 'NGN').toString(),
        fullyAvailable: j['fullyAvailable'] == true,
      );

  @override
  List<Object?> get props => [recipeId, sizeId, totalKobo, fullyAvailable];
}
