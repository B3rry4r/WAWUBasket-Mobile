import 'package:flutter/foundation.dart';

import '../domain/models/corridor.dart';
import '../domain/models/corridor_price.dart';
import '../domain/models/export_listing.dart';

/// Single source of truth for trader-posted export listings + market
/// corridor prices. Both the customer-side `/trade` browse and the
/// trader-side dashboard subscribe to it.
class TradeController {
  TradeController._()
      : listings = ValueNotifier<List<ExportListing>>([]),
        prices = ValueNotifier<List<CorridorPrice>>([]) {
    listings.value = _seedListings();
    prices.value = _seedPrices();
  }
  static final TradeController instance = TradeController._();

  final ValueNotifier<List<ExportListing>> listings;
  final ValueNotifier<List<CorridorPrice>> prices;

  ExportListing? byId(String id) {
    for (final l in listings.value) {
      if (l.id == id) return l;
    }
    return null;
  }

  String add(ExportListing l) {
    listings.value = [l, ...listings.value];
    return l.id;
  }

  void update(ExportListing l) {
    listings.value = [
      for (final cur in listings.value)
        if (cur.id == l.id) l else cur,
    ];
  }

  void remove(String id) {
    listings.value = [
      for (final l in listings.value)
        if (l.id != id) l,
    ];
  }

  /// Increment enquiry count when a buyer taps the enquiry CTA on a
  /// listing. Drives the badge on the trader's dashboard.
  void recordEnquiry(String id) {
    final l = byId(id);
    if (l == null) return;
    l.enquiries += 1;
    listings.value = List.of(listings.value);
  }

  List<ExportListing> _seedListings() => [
        ExportListing(
          id: 'EXP-1042',
          produce: 'Tomatoes',
          quantityKg: 1200,
          pricePerKgNaira: 380,
          harvestDate: DateTime.now().subtract(const Duration(days: 1)),
          originCorridor: Corridor.nigeria,
          destinationCorridor: Corridor.benin,
          farmName: 'Hauwa & Sons Bulk Co.',
          farmRegion: 'Kano',
          enquiries: 7,
          imageUrl:
              'https://images.unsplash.com/photo-1582284540020-8acbe03f4924?w=600&q=80&auto=format&fit=crop',
        ),
        ExportListing(
          id: 'EXP-1038',
          produce: 'Cassava',
          quantityKg: 5000,
          pricePerKgNaira: 220,
          harvestDate: DateTime.now().subtract(const Duration(days: 3)),
          originCorridor: Corridor.nigeria,
          destinationCorridor: Corridor.cameroon,
          farmName: 'Hauwa & Sons Bulk Co.',
          farmRegion: 'Benue',
          enquiries: 12,
          imageUrl:
              'https://images.unsplash.com/photo-1583224944844-5b268c057b72?w=600&q=80&auto=format&fit=crop',
        ),
        ExportListing(
          id: 'EXP-1031',
          produce: 'Maize',
          quantityKg: 8000,
          pricePerKgNaira: 410,
          harvestDate: DateTime.now().subtract(const Duration(days: 5)),
          originCorridor: Corridor.niger,
          destinationCorridor: Corridor.nigeria,
          farmName: 'Sahel Grain Union',
          farmRegion: 'Sokoto',
          enquiries: 4,
          imageUrl:
              'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=600&q=80&auto=format&fit=crop',
        ),
        ExportListing(
          id: 'EXP-1025',
          produce: 'Palm oil',
          quantityKg: 600,
          pricePerKgNaira: 1450,
          harvestDate: DateTime.now().subtract(const Duration(days: 8)),
          originCorridor: Corridor.nigeria,
          destinationCorridor: Corridor.togo,
          farmName: 'Delta Mills',
          farmRegion: 'Edo',
          enquiries: 3,
          imageUrl:
              'https://images.unsplash.com/photo-1604908554049-3a3d3f9d3128?w=600&q=80&auto=format&fit=crop',
        ),
        ExportListing(
          id: 'EXP-1018',
          produce: 'Cocoa',
          quantityKg: 2500,
          pricePerKgNaira: 2800,
          harvestDate: DateTime.now().subtract(const Duration(days: 11)),
          originCorridor: Corridor.nigeria,
          destinationCorridor: Corridor.benin,
          farmName: 'Ondo Cocoa Co-op',
          farmRegion: 'Ondo',
          enquiries: 18,
          imageUrl:
              'https://images.unsplash.com/photo-1606767041004-251eee9c2af4?w=600&q=80&auto=format&fit=crop',
        ),
      ];

  List<CorridorPrice> _seedPrices() => const [
        CorridorPrice(
          produce: 'Tomatoes',
          unit: 'kg',
          trend: 0.06,
          prices: {
            Corridor.nigeria: 380,
            Corridor.benin: 420,
            Corridor.togo: 460,
            Corridor.niger: 350,
            Corridor.cameroon: 510,
          },
        ),
        CorridorPrice(
          produce: 'Cassava',
          unit: 'kg',
          trend: -0.02,
          prices: {
            Corridor.nigeria: 220,
            Corridor.benin: 240,
            Corridor.togo: 260,
            Corridor.niger: 290,
            Corridor.cameroon: 250,
          },
        ),
        CorridorPrice(
          produce: 'Maize',
          unit: 'kg',
          trend: 0.04,
          prices: {
            Corridor.nigeria: 410,
            Corridor.benin: 430,
            Corridor.togo: 445,
            Corridor.niger: 370,
            Corridor.cameroon: 460,
          },
        ),
        CorridorPrice(
          produce: 'Palm oil',
          unit: 'kg',
          trend: 0.10,
          prices: {
            Corridor.nigeria: 1450,
            Corridor.benin: 1520,
            Corridor.togo: 1610,
            Corridor.niger: 1380,
            Corridor.cameroon: 1700,
          },
        ),
        CorridorPrice(
          produce: 'Cocoa',
          unit: 'kg',
          trend: 0.15,
          prices: {
            Corridor.nigeria: 2800,
            Corridor.benin: 2950,
            Corridor.togo: 3100,
            Corridor.niger: 2640,
            Corridor.cameroon: 3220,
          },
        ),
        CorridorPrice(
          produce: 'Onions',
          unit: 'bag',
          trend: -0.04,
          prices: {
            Corridor.nigeria: 35000,
            Corridor.benin: 38000,
            Corridor.togo: 42000,
            Corridor.niger: 30000,
            Corridor.cameroon: 41000,
          },
        ),
        CorridorPrice(
          produce: 'Rice',
          unit: 'kg',
          trend: 0.02,
          prices: {
            Corridor.nigeria: 1200,
            Corridor.benin: 1250,
            Corridor.togo: 1290,
            Corridor.niger: 1180,
            Corridor.cameroon: 1310,
          },
        ),
      ];
}
