import '../../home/domain/models/vendor.dart';
import '../../shopping/domain/models/product.dart';

/// Client-side helpers that strip content owned by blocked users from a list
/// so blocking visibly removes it instantly — before any server refresh.
///
/// Each helper takes the live blocked-user [Set] (read from
/// `blockedUsersProvider`) and returns a filtered copy. Items whose owner id
/// is unknown are kept (we can't prove they're blocked).
extension BlockedContentFilter on Set<String> {
  /// Products whose vendor (owner) the user hasn't blocked.
  List<Product> filterProducts(List<Product> products) => [
        for (final p in products)
          if (p.vendorId == null || !contains(p.vendorId)) p,
      ];

  /// Vendors the user hasn't blocked (by their owner user id).
  List<Vendor> filterVendors(List<Vendor> vendors) => [
        for (final v in vendors)
          if (v.ownerUserId == null || !contains(v.ownerUserId)) v,
      ];
}
