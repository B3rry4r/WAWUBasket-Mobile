import 'package:equatable/equatable.dart';

import '../../../category/domain/models/category_kind.dart';
import '../../../category/domain/models/subcategory.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.label,
    this.imageUrl,
    required this.kind,
    required this.tagline,
    required this.subcategories,
    this.svgAsset,
  });

  final String id;
  final String label;
  final String? imageUrl;
  final CategoryKind kind;
  final String tagline;
  final List<Subcategory> subcategories;
  final String? svgAsset;

  factory Category.fromJson(Map<String, dynamic> json) {
    final kindStr = json['kind'] as String? ?? '';
    final kind = switch (kindStr) {
      'restaurant' => CategoryKind.restaurant,
      'livestock' => CategoryKind.livestock,
      'trade' => CategoryKind.trade,
      _ => CategoryKind.marketplace,
    };
    final rawSubs = (json['subcategories'] as List?) ?? const [];
    return Category(
      id: json['id'] as String,
      label: json['label'] as String,
      tagline: json['tagline'] as String? ?? '',
      kind: kind,
      svgAsset: json['svgAsset'] as String?,
      imageUrl: json['imageUrl'] as String?,
      subcategories: rawSubs
          .map((e) => Subcategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, label];
}
