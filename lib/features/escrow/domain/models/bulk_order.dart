/// State an escrow-backed bulk order can be in. Mirrors the build-guide
/// escrow service: hold → release / refund / dispute.
enum EscrowStatus { held, released, refunded, disputed }

extension EscrowStatusX on EscrowStatus {
  String get label => switch (this) {
        EscrowStatus.held => 'Held in escrow',
        EscrowStatus.released => 'Released to seller',
        EscrowStatus.refunded => 'Refunded to buyer',
        EscrowStatus.disputed => 'Under review',
      };
}

/// Which Flutterwave-style channel funded the escrow.
enum PaymentMethod { card, bankTransfer, mobileMoney }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.card => 'Card',
        PaymentMethod.bankTransfer => 'Bank transfer',
        PaymentMethod.mobileMoney => 'Mobile money',
      };

  String get hint => switch (this) {
        PaymentMethod.card => 'Visa, Mastercard, Verve',
        PaymentMethod.bankTransfer => 'Direct bank transfer',
        PaymentMethod.mobileMoney => 'MTN, Airtel, Moov',
      };
}

/// A bulk-trade order funded via simulated Flutterwave escrow.
class BulkOrder {
  BulkOrder({
    required this.id,
    required this.listingId,
    required this.produce,
    required this.quantityKg,
    required this.pricePerKgNaira,
    required this.feeNaira,
    required this.imageUrl,
    required this.buyerName,
    required this.buyerPhone,
    required this.dropoffAddress,
    required this.sellerName,
    required this.sellerRegion,
    required this.method,
    required this.status,
    required this.placedAt,
    this.disputeReason,
    this.markedDeliveredBySeller = false,
  });

  final String id;
  final String listingId;
  final String produce;
  final int quantityKg;
  final int pricePerKgNaira;

  /// WAWU service fee on the bulk order, separate from the lot subtotal.
  final int feeNaira;
  final String imageUrl;
  final String buyerName;
  final String buyerPhone;
  final String dropoffAddress;
  final String sellerName;
  final String sellerRegion;
  final PaymentMethod method;
  EscrowStatus status;
  final DateTime placedAt;
  String? disputeReason;

  /// Seller has tapped "Mark delivered" on their side. Drives the
  /// buyer's UI nudge to confirm receipt.
  bool markedDeliveredBySeller;

  int get subtotalNaira => quantityKg * pricePerKgNaira;
  int get totalNaira => subtotalNaira + feeNaira;
}
