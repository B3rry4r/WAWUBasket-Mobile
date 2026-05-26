import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps device biometric unlock (Face ID / fingerprint) plus the opt-in
/// flag recording whether the returning user enabled it.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  static const _kEnabled = 'wb.biometric.enabled';

  final _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// True when the device has biometric hardware with an enrolled identity.
  Future<bool> isAvailable() async {
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
  ///
  /// TODO(i18n): key=biometricLabelFace / biometricLabelFingerprint /
  /// biometricLabelGeneric — these labels are not localised yet.
  Future<String> label() async {
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
  Future<bool> isEnabled() async =>
      (await _storage.read(key: _kEnabled)) == 'true';

  Future<void> setEnabled(bool value) =>
      _storage.write(key: _kEnabled, value: value ? 'true' : 'false');

  /// Shows the device biometric sheet; returns true only on success.
  Future<bool> authenticate({String reason = 'Unlock WAWUBasket'}) async {
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
