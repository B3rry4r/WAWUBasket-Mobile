import 'api_client.dart';

class BankItem {
  const BankItem({required this.id, required this.name, required this.code});
  final int id;
  final String name;
  final String code;
}

/// Thin wrapper around the WAWUBasket payouts endpoints.
class PayoutsApi {
  PayoutsApi._();
  static final PayoutsApi instance = PayoutsApi._();

  final _api = ApiClient.instance;
  List<BankItem>? _bankCache;

  /// Returns the Flutterwave bank list for [country] (default NG).
  /// Result is cached in memory for the app session.
  Future<List<BankItem>> fetchBanks({String country = 'NG'}) async {
    if (_bankCache != null) return _bankCache!;
    final res = await _api.get('/payouts/banks', query: {'country': country});
    final list = ((res as List?) ?? const [])
        .map((e) => BankItem(
              id: (e['id'] as num).toInt(),
              name: e['name'].toString(),
              code: e['code'].toString(),
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _bankCache = list;
    return list;
  }
}
