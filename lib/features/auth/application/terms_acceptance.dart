import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time record that the user has accepted the EULA / Terms of Use and
/// Privacy Policy before reaching login or signup.
///
/// Apple App Review Guideline 1.2 requires UGC apps to present terms before
/// the user registers OR logs in. Acceptance is persisted in
/// [SharedPreferences] (the same local store onboarding + role state use) so
/// the gate is shown only once per install.
class TermsAcceptance {
  TermsAcceptance._();
  static final TermsAcceptance instance = TermsAcceptance._();

  static const _key = 'wb.terms.acceptedV1';

  /// Reactive flag — the splash/router reads this synchronously after [load].
  final ValueNotifier<bool> accepted = ValueNotifier<bool>(false);

  bool get isAccepted => accepted.value;

  /// Restores the persisted flag. Call once during bootstrap. Degrades to
  /// "not accepted" (so the gate shows) if storage is unavailable.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      accepted.value = prefs.getBool(_key) ?? false;
    } catch (_) {
      accepted.value = false;
    }
  }

  /// Records acceptance and persists it. The in-memory flag flips first so
  /// navigation is never blocked on disk I/O.
  Future<void> accept() async {
    accepted.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {
      // Kept in-memory for this session even if persistence fails.
    }
  }
}
