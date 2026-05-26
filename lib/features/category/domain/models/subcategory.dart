import 'package:equatable/equatable.dart';

class Subcategory extends Equatable {
  const Subcategory({
    required this.id,
    required this.label,
    this.imageUrl,
    this.svgAsset,
  });

  final String id;
  final String label;
  final String? imageUrl;
  final String? svgAsset;

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as String,
      label: json['label'] as String,
      imageUrl: json['imageUrl'] as String?,
      svgAsset: json['svgAsset'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, label];
}
