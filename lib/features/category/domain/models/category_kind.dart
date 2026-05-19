/// How a top-level category presents in the UI. Drives the Home body
/// switch and the CategoryScreen body layout.
enum CategoryKind {
  /// Default home state, vendor + product mix, no filter active.
  all,

  /// Vendor-led browsing, restaurants & fast food.
  restaurant,

  /// Product-led browsing, groceries, fresh market, household, drinks,
  /// snacks, pharmacy.
  marketplace,

  /// Wholesale / supplier-driven, farm produce only.
  trade,

  /// Meat / fish, meat-cut selection + butchery instructions + Halal.
  livestock,
}
