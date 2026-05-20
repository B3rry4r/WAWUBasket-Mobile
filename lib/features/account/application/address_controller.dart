import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/address_api.dart';

/// A saved delivery address.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.line,
    this.apartment = '',
    this.noteForRider = '',
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String line;
  final String apartment;
  final String noteForRider;
  final bool isDefault;

  /// Secondary line shown under the street — apartment + rider note.
  String get detail =>
      [apartment, noteForRider].where((s) => s.isNotEmpty).join(' · ');

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: (j['id'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        line: (j['line'] ?? '').toString(),
        apartment: (j['apartment'] ?? '').toString(),
        noteForRider: (j['noteForRider'] ?? '').toString(),
        isDefault: j['isDefault'] == true,
      );
}

/// Live store for the signed-in user's saved addresses, backed by
/// `/v1/addresses`. Screens listen to [addresses]; every mutation reloads
/// from the server so the default flag stays consistent.
class AddressController {
  AddressController._();
  static final AddressController instance = AddressController._();

  final _api = AddressApi.instance;

  final ValueNotifier<List<Address>> addresses =
      ValueNotifier<List<Address>>([]);

  /// Null before the first load completes, then false.
  final ValueNotifier<bool> loading = ValueNotifier<bool>(true);

  Address? byId(String id) {
    for (final a in addresses.value) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final raw = await _api.list();
      addresses.value = [
        for (final e in raw)
          Address.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } on ApiException {
      // Leave the current list in place — a later refresh retries.
    } finally {
      loading.value = false;
    }
  }

  Future<void> create({
    required String label,
    required String line,
    String apartment = '',
    String noteForRider = '',
    bool isDefault = false,
  }) async {
    await _api.create({
      'label': label,
      'line': line,
      'apartment': ?(apartment.isEmpty ? null : apartment),
      'noteForRider': ?(noteForRider.isEmpty ? null : noteForRider),
      'isDefault': isDefault,
    });
    await load();
  }

  Future<void> update(
    String id, {
    required String label,
    required String line,
    String apartment = '',
    String noteForRider = '',
    bool? isDefault,
  }) async {
    await _api.update(id, {
      'label': label,
      'line': line,
      'apartment': apartment,
      'noteForRider': noteForRider,
      'isDefault': ?isDefault,
    });
    await load();
  }

  Future<void> setDefault(String id) async {
    await _api.setDefault(id);
    await load();
  }

  Future<void> remove(String id) async {
    await _api.remove(id);
    await load();
  }
}
