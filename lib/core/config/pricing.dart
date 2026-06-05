/// Single source of truth for client-side fee ESTIMATES.
///
/// These drive the fee/total preview on the cart + checkout screens. They are
/// display estimates only — the server is authoritative for what's actually
/// charged (the order/checkout response carries the real subtotal, fees and
/// total). Previously the same numbers were duplicated in both screens, so a
/// rate change risked the two diverging; they now live here in one place.
///
/// TODO(pricing): fetch these from a pricing-config endpoint so a fee change
/// is a server update rather than an app release.
abstract final class WbPricing {
  /// Flat delivery-fee estimate, in naira.
  static const int deliveryFeeNaira = 600;

  /// Service fee = 7.5% of subtotal, clamped to [min, max] naira.
  static const int serviceFeeBasisPoints = 750; // 7.5% of 10_000
  static const int serviceFeeMinNaira = 50;
  static const int serviceFeeMaxNaira = 5000;

  /// Estimated service fee for a given subtotal (naira).
  static int serviceFee(int subtotalNaira) =>
      (subtotalNaira * serviceFeeBasisPoints / 10000)
          .ceil()
          .clamp(serviceFeeMinNaira, serviceFeeMaxNaira);
}
