/// State an escrow-backed bulk order can be in. Mirrors the API EscrowStatus
/// enum: pending → held → released / refunded / disputed.
enum EscrowStatus { pending, held, released, refunded, disputed }

extension EscrowStatusX on EscrowStatus {
  String get label => switch (this) {
        EscrowStatus.pending => 'Payment pending',
        EscrowStatus.held => 'Held in escrow',
        EscrowStatus.released => 'Released to seller',
        EscrowStatus.refunded => 'Refunded to buyer',
        EscrowStatus.disputed => 'Under review',
      };
}

/// Preferred payment channel hint passed to Flutterwave. Flutterwave's hosted
/// checkout handles the actual processing — Apple Pay and Google Pay are
/// available natively on their page regardless of this selection.
enum PaymentMethod { card, bankTransfer, mobileMoney }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.card => 'Card',
        PaymentMethod.bankTransfer => 'Bank transfer',
        PaymentMethod.mobileMoney => 'Mobile money',
      };

  String get hint => switch (this) {
        PaymentMethod.card => 'Visa, Mastercard, Verve · Apple/Google Pay on Flutterwave',
        PaymentMethod.bankTransfer => 'Direct bank transfer · all currencies',
        PaymentMethod.mobileMoney => 'MTN, Airtel, Moov, M-Pesa',
      };
}

/// A bulk-trade order funded via Flutterwave escrow.
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
    this.checkoutUrl,
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

  /// Flutterwave hosted payment page. Non-null immediately after placing.
  final String? checkoutUrl;

  String? disputeReason;
  bool markedDeliveredBySeller;

  int get subtotalNaira => quantityKg * pricePerKgNaira;
  int get totalNaira => subtotalNaira + feeNaira;

  factory BulkOrder.fromApi(Map<String, dynamic> m) {
    final hold = (m['escrowHold'] as Map?)?.cast<String, dynamic>();
    final listing =
        (m['exportListing'] as Map?)?.cast<String, dynamic>() ?? const {};
    final statusStr = (hold?['status'] ?? 'held').toString().toLowerCase();
    final escrowStatus = EscrowStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => EscrowStatus.held,
    );
    final total = _int(m['total']);
    final fee = _int(m['serviceFee']);
    final qty = _int(m['quantityKg']);
    final pricePerKg = qty > 0 ? (total - fee) ~/ qty : 0;

    return BulkOrder(
      id: (m['id'] ?? '').toString(),
      listingId: (m['exportListingId'] ?? '').toString(),
      produce: (listing['produce'] ?? 'Goods').toString(),
      quantityKg: qty,
      pricePerKgNaira: pricePerKg,
      feeNaira: fee,
      imageUrl: '',
      buyerName: (m['buyerName'] ?? '').toString(),
      buyerPhone: '',
      dropoffAddress: (m['dropoffAddress'] ?? '').toString(),
      sellerName: (listing['farmName'] ?? '').toString(),
      sellerRegion: (listing['farmRegion'] ?? '').toString(),
      method: PaymentMethod.bankTransfer,
      status: escrowStatus,
      placedAt: m['placedAt'] != null
          ? DateTime.tryParse(m['placedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      checkoutUrl: hold?['checkoutUrl']?.toString(),
      markedDeliveredBySeller: m['markedDelivered'] == true,
    );
  }

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
