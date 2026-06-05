import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps device biometric unlock (Face ID / fingerprint) plus the opt-in
/// flag recording whether the returning user enabled it.
///
/// The enabled flag is stored in SharedPreferences (not flutter_secure_storage)
/// because it is a non-sensitive preference and SharedPreferences works
/// reliably across all platforms including web.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  static const _kEnabled = 'wb.biometric.enabled';
  static const _kOfferDismissed = 'wb.biometric.offerDismissed';

  final _auth = LocalAuthentication();

  /// True when the device has biometric hardware with an enrolled identity.
  /// Always false on web (local_auth has no web implementation).
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Returns the user-facing name of the most prominent biometric the OS
  /// reports. Falls back to the generic "Biometric" so copy never claims
  /// Face ID on a fingerprint-only Android phone.
  Future<String> label() async {
    if (kIsWeb) return 'Biometric';
    try {
      if (!await _auth.isDeviceSupported()) return 'Biometric';
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return 'Face ID';
      if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
      if (types.contains(BiometricType.iris)) return 'Iris';
      if (types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak)) {
        return 'Biometric';
      }
    } catch (_) {
      // Fall through to the generic label.
    }
    return 'Biometric';
  }

  /// Whether the user opted into biometric unlock on this device.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
  }

  /// Whether the user has already dismissed the "turn on biometric unlock"
  /// offer. Persisted so we never nag a user who said "Not now" on every
  /// subsequent password sign-in. Cleared on explicit logout so a fresh
  /// account on the same device is offered it again.
  Future<bool> offerDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOfferDismissed) ?? false;
  }

  Future<void> setOfferDismissed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOfferDismissed, value);
  }

  /// Clears the opt-in + offer-dismissed flags. Call on EXPLICIT logout only
  /// (not on session expiry) so the next user on this device starts clean,
  /// while a returning user whose token merely expired keeps biometrics on.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEnabled);
    await prefs.remove(_kOfferDismissed);
  }

  /// Shows the device biometric sheet; returns true only on success.
  Future<bool> authenticate({String reason = 'Unlock WAWUBasket'}) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
