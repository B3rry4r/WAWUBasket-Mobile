import '../../../core/network/api_client.dart';

/// Wraps `POST /v1/kyc/submit` — the operator-onboarding application that
/// every non-customer role submits before it can be approved.
class KycApi {
  KycApi._();
  static final KycApi instance = KycApi._();

  final _api = ApiClient.instance;

  /// Submits a KYC application. [role] is the AppRole name; [profile] holds
  /// the form fields; [documents] is a list of `{label, key}` maps where
  /// `key` is an R2 object key returned by [UploadService].
  Future<Map<String, dynamic>> submit({
    required String role,
    required Map<String, dynamic> profile,
    required List<Map<String, String>> documents,
  }) async {
    final res = await _api.post('/kyc/submit', body: {
      'role': role,
      'profile': profile,
      'documents': documents,
    });
    return (res as Map).cast<String, dynamic>();
  }
}
