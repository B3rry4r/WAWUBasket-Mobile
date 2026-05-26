import 'package:equatable/equatable.dart';

/// The four serving tiers offered for every recipe. The label values match
/// the API enum (`small` / `medium` / `family` / `party`) — the multiplier
/// scales every ingredient quantity off the canonical recipe definition.
enum RecipeSizeLabel { small, medium, family, party }

extension RecipeSizeLabelX on RecipeSizeLabel {
  String get apiValue => switch (this) {
        RecipeSizeLabel.small => 'small',
        RecipeSizeLabel.medium => 'medium',
        RecipeSizeLabel.family => 'family',
        RecipeSizeLabel.party => 'party',
      };
}

RecipeSizeLabel _parseLabel(String raw) {
  switch (raw.toLowerCase()) {
    case 'small':
      return RecipeSizeLabel.small;
    case 'medium':
      return RecipeSizeLabel.medium;
    case 'family':
      return RecipeSizeLabel.family;
    case 'party':
      return RecipeSizeLabel.party;
    default:
      return RecipeSizeLabel.medium;
  }
}

/// One serving tier on a recipe. Renders as a button in the size picker
/// and carries the canonical pricing inputs (multiplier + optional fixed
/// price) the matching engine uses to scale ingredients.
class RecipeSize extends Equatable {
  const RecipeSize({
    required this.id,
    required this.label,
    required this.servesLabel,
    required this.multiplier,
    required this.isDefault,
    this.fixedPriceNaira,
  });

  final String id;
  final RecipeSizeLabel label;
  final String servesLabel;
  final double multiplier;
  final bool isDefault;
  final int? fixedPriceNaira;

  factory RecipeSize.fromJson(Map<String, dynamic> j) => RecipeSize(
        id: (j['id'] ?? '').toString(),
        label: _parseLabel((j['label'] ?? 'medium').toString()),
        servesLabel: (j['servesLabel'] ?? '').toString(),
        multiplier:
            (j['multiplier'] as num?)?.toDouble() ?? 1.0,
        isDefault: j['isDefault'] == true,
        fixedPriceNaira: (j['fixedPriceNaira'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [id, label, multiplier, isDefault];
}
