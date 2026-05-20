import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/profile_api.dart';

/// The signed-in user's account details.
class UserProfile {
  const UserProfile({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth,
  });

  final String fullName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        fullName: (j['fullName'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        dateOfBirth: DateTime.tryParse('${j['dateOfBirth'] ?? ''}'),
      );
}

/// Live store for the user's profile, backed by `/v1/profile`.
class ProfileController {
  ProfileController._();
  static final ProfileController instance = ProfileController._();

  final _api = ProfileApi.instance;

  final ValueNotifier<UserProfile?> profile = ValueNotifier<UserProfile?>(null);

  Future<void> load() async {
    try {
      final j = await _api.get();
      profile.value = UserProfile.fromJson(j);
    } on ApiException {
      // Leave the current profile in place — a later refresh retries.
    }
  }

  Future<void> update({
    required String fullName,
    required String email,
  }) async {
    await _api.update({'fullName': fullName, 'email': email});
    await load();
  }
}
