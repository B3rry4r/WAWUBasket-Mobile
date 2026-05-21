import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/network/api_client.dart';

/// Raised when a WAWU+ purchase cannot complete.
class IapException implements Exception {
  const IapException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Drives the WAWU+ subscription purchase through the App Store / Play
/// Store. The product ids must match those configured in App Store
/// Connect and Google Play Console.
class WawuPlusIap {
  WawuPlusIap._();
  static final WawuPlusIap instance = WawuPlusIap._();

  static const monthlyId = 'wawu_plus_monthly';
  static const yearlyId = 'wawu_plus_yearly';
  static const _ids = {monthlyId, yearlyId};

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Buys [productId]. Completes once the purchase has been recorded
  /// server-side; throws [IapException] on cancellation or failure.
  Future<void> buy(String productId) async {
    if (!await _iap.isAvailable()) {
      throw const IapException(
        'In-app purchases are unavailable on this device.',
      );
    }
    final resp = await _iap.queryProductDetails(_ids);
    final matches =
        resp.productDetails.where((p) => p.id == productId).toList();
    if (matches.isEmpty) {
      throw const IapException('That plan is not available right now.');
    }

    final completer = Completer<void>();
    await _sub?.cancel();
    _sub = _iap.purchaseStream.listen((purchases) async {
      for (final p in purchases) {
        if (p.productID != productId) continue;
        switch (p.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            try {
              await _record(p);
              if (p.pendingCompletePurchase) {
                await _iap.completePurchase(p);
              }
              if (!completer.isCompleted) completer.complete();
            } catch (_) {
              if (!completer.isCompleted) {
                completer.completeError(const IapException(
                  "Purchase went through but we couldn't record it — "
                  'contact support.',
                ));
              }
            }
          case PurchaseStatus.error:
            if (!completer.isCompleted) {
              completer.completeError(
                IapException(p.error?.message ?? 'The purchase failed.'),
              );
            }
          case PurchaseStatus.canceled:
            if (!completer.isCompleted) {
              completer.completeError(
                const IapException('Purchase cancelled.'),
              );
            }
          case PurchaseStatus.pending:
            break;
        }
      }
    });

    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: matches.first),
    );
    try {
      await completer.future.timeout(const Duration(minutes: 5));
    } finally {
      await _sub?.cancel();
      _sub = null;
    }
  }

  /// Sends the store receipt to the API. Server-side verification of the
  /// receipt is a later step — for now the purchase is recorded as-is.
  Future<void> _record(PurchaseDetails p) async {
    await ApiClient.instance.post('/subscriptions/verify', body: {
      'platform': Platform.isIOS ? 'ios' : 'android',
      'productId': p.productID,
      'purchaseToken': p.verificationData.serverVerificationData,
      'transactionId': p.purchaseID ?? '',
    });
  }
}
