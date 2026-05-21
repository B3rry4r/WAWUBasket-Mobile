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

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: (j['userId'] ?? j['id'] ?? '').toString(),
        name: (j['businessName'] ?? j['name'] ?? 'Supplier').toString(),
        region: (j['farmRegion'] ?? j['region'] ?? '').toString(),
        capacity: (j['capacity'] ?? '').toString(),
        rating: double.tryParse('${j['rating'] ?? ''}') ?? 0,
        reviews: (j['reviews'] as num?)?.toInt() ?? 0,
        avatarUrl: (j['logoKey'] ?? j['avatarUrl'] ?? '').toString(),
        specialties: (j['specialties'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [id, name, region];
}
