import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/profile_api.dart';

/// The signed-in user's base account details.
class UserProfile {
  const UserProfile({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.gender,
    this.avatarUrl,
    this.dateOfBirth,
    // Role-specific display names (populated from the nested role profile
    // objects that `/v1/profile` returns alongside the base user record).
    this.vendorBusinessName,
    this.traderBusinessName,
    this.agentDisplayName,
    this.agentRegionName,
    this.riderDisplayName,
    this.driverDisplayName,
    this.driverPlateNumber,
  });

  final String fullName;
  final String email;
  final String phone;
  /// Canonical lowercase 'male' | 'female' from WAWU-ID (mirrored by the Basket
  /// API on /profile), or null when the user hasn't set it.
  final String? gender;
  final String? avatarUrl;
  final DateTime? dateOfBirth;

  // Operator display names — null when the user hasn't registered that role.
  final String? vendorBusinessName;
  final String? traderBusinessName;
  final String? agentDisplayName;
  final String? agentRegionName;
  final String? riderDisplayName;
  final String? driverDisplayName;
  final String? driverPlateNumber;

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final pv = (j['profileVendor'] as Map?)?.cast<String, dynamic>();
    final pt = (j['profileTrader'] as Map?)?.cast<String, dynamic>();
    final pa = (j['profileAgent'] as Map?)?.cast<String, dynamic>();
    final pr = (j['profileRider'] as Map?)?.cast<String, dynamic>();
    final pd = (j['profileDriver'] as Map?)?.cast<String, dynamic>();
    return UserProfile(
      fullName: (j['fullName'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      gender: _normGender(j['gender']),
      avatarUrl: j['avatarUrl']?.toString(),
      dateOfBirth: DateTime.tryParse('${j['dateOfBirth'] ?? ''}'),
      vendorBusinessName: pv != null ? '${pv['businessName'] ?? ''}' : null,
      traderBusinessName: pt != null ? '${pt['businessName'] ?? ''}' : null,
      agentDisplayName: pa != null ? '${pa['displayName'] ?? ''}' : null,
      agentRegionName: pa != null ? (pa['regionName'] as String?) : null,
      riderDisplayName: pr != null ? '${pr['displayName'] ?? ''}' : null,
      driverDisplayName: pd != null ? '${pd['displayName'] ?? ''}' : null,
      driverPlateNumber: pd != null ? (pd['plateNumber'] as String?) : null,
    );
  }

  /// Maps any backend gender spelling to the canonical lowercase 'male'/'female',
  /// or null. Mirrors WAWU-ID's normalisation so the UI only ever sees the two
  /// canonical values.
  static String? _normGender(dynamic v) {
    final s = v?.toString().trim().toLowerCase();
    if (s == 'male' || s == 'm') return 'male';
    if (s == 'female' || s == 'f') return 'female';
    return null;
  }
}

/// Stats returned by `/v1/profile/stats`. The keys present depend on the
/// user's active role — only the relevant ones are populated.
class ProfileStats {
  const ProfileStats({
    // Customer
    this.orders,
    this.favorites,
    // Vendor
    this.vendorRating,
    this.vendorEarnedNaira,
    // Rider
    this.riderTripsToday,
    this.riderEarnedNaira,
    this.riderRating,
    // Driver
    this.driverTripsThisWeek,
    this.driverEarnedNaira,
    this.driverRating,
    // Trader
    this.traderListings,
    this.traderEnquiries,
    this.traderEarnedNaira,
    // Agent
    this.agentTodayTransactions,
    this.agentTodayCommissionNaira,
    this.agentToSync,
  });

  // Customer
  final int? orders;
  final int? favorites;

  // Vendor — orders comes from the customer field above; rating & earned below
  final String? vendorRating;
  final String? vendorEarnedNaira;

  // Rider
  final int? riderTripsToday;
  final String? riderEarnedNaira;
  final String? riderRating;

  // Driver
  final int? driverTripsThisWeek;
  final String? driverEarnedNaira;
  final String? driverRating;

  // Trader
  final int? traderListings;
  final int? traderEnquiries;
  final String? traderEarnedNaira;

  // Agent
  final int? agentTodayTransactions;
  final int? agentTodayCommissionNaira;
  final int? agentToSync;

  factory ProfileStats.fromJson(Map<String, dynamic> j) => ProfileStats(
        // Customer
        orders: _toInt(j['orders']),
        favorites: _toInt(j['favorites']),
        // Vendor
        vendorRating: j['rating']?.toString(),
        vendorEarnedNaira: j['earnedNaira']?.toString(),
        // Rider
        riderTripsToday: _toInt(j['tripsToday']),
        riderEarnedNaira: j['earnedNaira']?.toString(),
        riderRating: j['rating']?.toString(),
        // Driver
        driverTripsThisWeek: _toInt(j['tripsThisWeek']),
        driverEarnedNaira: j['earnedNaira']?.toString(),
        driverRating: j['rating']?.toString(),
        // Trader
        traderListings: _toInt(j['listings']),
        traderEnquiries: _toInt(j['enquiries']),
        traderEarnedNaira: j['earnedNaira']?.toString(),
        // Agent
        agentTodayTransactions: _toInt(j['todayTransactions']),
        agentTodayCommissionNaira: _toInt(j['todayCommissionNaira']),
        agentToSync: _toInt(j['toSync']),
      );

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse(v.toString());
  }
}

/// Live store for the user's profile and per-role stats, backed by
/// `/v1/profile` and `/v1/profile/stats`.
class ProfileController {
  ProfileController._();
  static final ProfileController instance = ProfileController._();

  final _api = ProfileApi.instance;

  final ValueNotifier<UserProfile?> profile = ValueNotifier<UserProfile?>(null);
  final ValueNotifier<ProfileStats?> stats = ValueNotifier<ProfileStats?>(null);

  Future<void> load() async {
    try {
      final j = await _api.get();
      profile.value = UserProfile.fromJson(j);
    } on ApiException {
      // Leave the current profile in place — a later refresh retries.
    }
  }

  Future<void> loadStats() async {
    try {
      final j = await _api.stats();
      stats.value = ProfileStats.fromJson(j);
    } on ApiException {
      // Leave stale stats; the UI shows '-' when null.
    }
  }

  Future<void> update({
    required String fullName,
    required String email,
    String? gender,
  }) async {
    await _api.update({
      'fullName': fullName,
      'email': email,
      // Only send gender when set to a canonical value; the Basket API mirrors it
      // locally and forwards it to WAWU-ID (the identity authority).
      if (gender == 'male' || gender == 'female') 'gender': gender,
    });
    await load();
  }
}
