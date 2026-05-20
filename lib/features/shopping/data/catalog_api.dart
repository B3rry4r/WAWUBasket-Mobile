import '../../../core/network/api_client.dart';
import '../../home/domain/models/vendor.dart';
import '../domain/models/product.dart';

/// Read access to the public catalog — vendors, products and categories.
/// None of these calls need a token; they work signed-out too.
class CatalogApi {
  CatalogApi._();
  static final CatalogApi instance = CatalogApi._();

  final _api = ApiClient.instance;

  /// Open vendors, optionally filtered by service zone / search query.
  Future<List<Vendor>> vendors({String? zoneId, String? query}) async {
    final q = <String, dynamic>{};
    if (zoneId != null) q['zoneId'] = zoneId;
    if (query != null && query.isNotEmpty) q['q'] = query;
    final res = await _api.get('/vendors', query: q);
    final list = (res['vendors'] as List?) ?? const [];
    return list
        .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// One vendor's storefront — profile fields + its active menu.
  Future<({Vendor vendor, List<Product> menu})> vendorDetail(
      String vendorId) async {
    final res = await _api.get('/vendors/$vendorId') as Map<String, dynamic>;
    final menu = ((res['menu'] as List?) ?? const [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    return (vendor: Vendor.fromJson(res), menu: menu);
  }

  /// Catalog items, filterable by category / vendor / search.
  Future<List<Product>> items({
    String? category,
    String? vendorId,
    String? query,
  }) async {
    final q = <String, dynamic>{};
    if (category != null && category != 'all') q['category'] = category;
    if (vendorId != null) q['vendorId'] = vendorId;
    if (query != null && query.isNotEmpty) q['q'] = query;
    final res = await _api.get('/catalog/items', query: q);
    final list = (res['items'] as List?) ?? const [];
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// One catalog item by id.
  Future<Product> item(String id) async {
    final res = await _api.get('/catalog/items/$id') as Map<String, dynamic>;
    return Product.fromJson(res);
  }

  /// The category tree used by the home + category screens.
  Future<List<dynamic>> categories() async {
    final res = await _api.get('/categories') as Map<String, dynamic>;
    return (res['categories'] as List?) ?? const [];
  }
}
