import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  const Supplier({
    required this.id,
    required this.name,
    required this.region,
    required this.capacity,
    required this.rating,
    required this.reviews,
    required this.avatarUrl,
    required this.specialties,
  });

  final String id;
  final String name;
  final String region;

  /// Free-text capacity, e.g. `"500 bags / week"`.
  final String capacity;
  final double rating;
  final int reviews;
  final String avatarUrl;
  final List<String> specialties;

  @override
  List<Object?> get props => [id, name, region];
}
