import '../../../core/network/api_client.dart';

/// Wraps the `/v1/profile` endpoints.
class ProfileApi {
  ProfileApi._();
  static final ProfileApi instance = ProfileApi._();

  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> get() async {
    final res = await _api.get('/profile');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> update(Map<String, dynamic> dto) =>
      _api.patch('/profile', body: dto);

  /// Persists a freshly-uploaded avatar key to the active role profile.
  ///
  /// **Cache note:** after calling this, evict the old URL from the
  /// CachedNetworkImage disk cache so the new avatar is fetched immediately:
  ///   `await CachedNetworkImage.evictFromCache(oldAvatarUrl);`
  Future<void> updateAvatar(String avatarKey) =>
      _api.patch('/profile/avatar', body: {'avatarKey': avatarKey});

  Future<Map<String, dynamic>> stats() async {
    final res = await _api.get('/profile/stats');
    return (res as Map).cast<String, dynamic>();
  }

  Future<void> deleteAccount({String? reason}) =>
      _api.delete('/profile/account', body: reason != null ? {'reason': reason} : null);

  Future<void> saveQuizPreferences({
    required List<String> wantCategories,
    String? deliverySpeed,
    String? avoidFoods,
  }) =>
      _api.post('/profile/preferences', body: {
        'wantCategories': wantCategories,
        if (deliverySpeed != null && deliverySpeed.isNotEmpty)
          'deliverySpeed': deliverySpeed,
        if (avoidFoods != null && avoidFoods.isNotEmpty)
          'avoidFoods': avoidFoods,
      });

  Future<Map<String, dynamic>?> getQuizPreferences() async {
    final res = await _api.get('/profile/preferences');
    final prefs = (res as Map<String, dynamic>)['quizPreferences'];
    if (prefs == null) return null;
    return (prefs as Map).cast<String, dynamic>();
  }

  Future<List<String>> getDietaryPreferences() async {
    final profile = await get();
    final customer = profile['profileCustomer'];
    if (customer == null) return [];
    final list = customer['dietaryPreferences'];
    if (list == null) return [];
    return (list as List).cast<String>();
  }

  Future<void> saveDietaryPreferences(List<String> preferences) =>
      _api.patch('/profile/dietary-preferences', body: {'preferences': preferences});
}
