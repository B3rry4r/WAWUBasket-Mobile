import 'package:equatable/equatable.dart';

/// A vendor entry shown on home, search and store screens.
class Vendor extends Equatable {
  const Vendor({
    required this.id,
    required this.name,
    required this.shortName,
    required this.cuisine,
    required this.rating,
    required this.reviews,
    required this.etaMin,
    required this.etaMax,
    required this.deliveryFee,
    required this.imageUrl,
    this.badge,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String shortName;
  final String cuisine;
  final double rating;

  /// Pre-formatted review count, e.g. `'2,481'`.
  final String reviews;

  final int etaMin;
  final int etaMax;

  /// Naira fee, e.g. `600`. Use 0 for "Free".
  final int deliveryFee;
  final String imageUrl;
  final String? badge;
  final List<String> tags;

  String get etaLabel => '$etaMin–$etaMax min';
  String get etaShort => '$etaMax';
  String get feeLabel => deliveryFee == 0 ? 'Free' : '₦$deliveryFee';

  /// Builds a [Vendor] from the API's `/v1/vendors` payload. The list
  /// endpoint is sparse, so rating/cuisine/fee fall back to sane defaults
  /// and the storefront detail (`/v1/vendors/:id`) fills the rest in.
  factory Vendor.fromJson(Map<String, dynamic> j) {
    final name = (j['name'] ?? j['businessName'] ?? 'Vendor').toString();
    return Vendor(
      id: (j['id'] ?? j['userId'] ?? '').toString(),
      name: name,
      shortName: (j['shortName'] ?? name).toString(),
      cuisine: (j['cuisine'] ?? j['description'] ?? '').toString(),
      rating: double.tryParse('${j['rating'] ?? ''}') ?? 0.0,
      reviews: (j['reviews'] ?? '').toString(),
      etaMin: (j['etaMin'] as num?)?.toInt() ?? 20,
      etaMax: (j['etaMax'] as num?)?.toInt() ?? 35,
      deliveryFee: (j['deliveryFee'] as num?)?.toInt() ?? 600,
      imageUrl: (j['imageUrl'] ?? j['logoKey'] ?? '').toString(),
      badge: j['badge'] as String?,
      tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props =>
      [id, name, cuisine, rating, etaMin, etaMax, deliveryFee, badge, tags];
}
