import '../../../core/network/api_client.dart';
import '../../../core/network/api_parse.dart';

/// Wraps the `/v1/payment-methods` CRUD endpoints.
///
/// Backend: `PaymentMethodsController` (NestJS). The list endpoint returns a
/// bare JSON array of saved methods ordered default-first.
class PaymentMethodsApi {
  PaymentMethodsApi._();
  static final PaymentMethodsApi instance = PaymentMethodsApi._();

  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _api.get('/payment-methods');
    return safeMapList(res, context: 'paymentMethods');
  }

  /// Adds a saved payment method. Mirrors `AddPaymentMethodDto`:
  /// [type] is `card | bank | mobile`, [label] is the display string
  /// (e.g. "Visa •••• 4218"), and [pspToken] is the PSP-tokenised reference.
  Future<Map<String, dynamic>> add({
    required String type,
    required String label,
    required String pspToken,
    String? lastFour,
    String? expiresAt,
  }) async {
    final res = await _api.post('/payment-methods', body: {
      'type': type,
      'label': label,
      'pspToken': pspToken,
      if (lastFour != null && lastFour.isNotEmpty) 'lastFour': lastFour,
      if (expiresAt != null && expiresAt.isNotEmpty) 'expiresAt': expiresAt,
    });
    return safeMap(res, context: 'addPaymentMethod');
  }

  Future<void> setDefault(String id) =>
      _api.patch('/payment-methods/$id/default');

  Future<void> remove(String id) => _api.delete('/payment-methods/$id');
}
