import 'package:equatable/equatable.dart';

class Subcategory extends Equatable {
  const Subcategory({
    required this.id,
    required this.label,
    required this.imageUrl,
  });

  final String id;
  final String label;
  final String imageUrl;

  @override
  List<Object?> get props => [id, label];
}
