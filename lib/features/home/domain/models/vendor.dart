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

  @override
  List<Object?> get props =>
      [id, name, cuisine, rating, etaMin, etaMax, deliveryFee, badge, tags];
}
