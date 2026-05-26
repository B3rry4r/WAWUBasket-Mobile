import 'package:equatable/equatable.dart';

/// One line in a recipe's canonical ingredient list. `baseQty` is the
/// quantity for a single-serving recipe — the matching engine multiplies
/// this by the picked size's multiplier before sourcing it.
class RecipeIngredient extends Equatable {
  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.subcategoryId,
    required this.baseQty,
    required this.unit,
    required this.optional,
    this.qualityNote,
  });

  final String id;
  final String name;
  final String subcategoryId;
  final double baseQty;
  final String unit;
  final bool optional;
  final String? qualityNote;

  factory RecipeIngredient.fromJson(Map<String, dynamic> j) => RecipeIngredient(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        subcategoryId: (j['subcategoryId'] ?? '').toString(),
        baseQty: (j['baseQty'] as num?)?.toDouble() ?? 0,
        unit: (j['unit'] ?? '').toString(),
        optional: j['optional'] == true,
        qualityNote: j['qualityNote'] as String?,
      );

  @override
  List<Object?> get props => [id, name, baseQty, unit, optional];
}
