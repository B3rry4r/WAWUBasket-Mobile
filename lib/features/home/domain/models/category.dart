import 'package:equatable/equatable.dart';

import '../../../category/domain/models/category_kind.dart';
import '../../../category/domain/models/subcategory.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.kind,
    required this.tagline,
    required this.subcategories,
  });

  final String id;
  final String label;
  final String imageUrl;
  final CategoryKind kind;
  final String tagline;
  final List<Subcategory> subcategories;

  @override
  List<Object?> get props => [id, label];
}
