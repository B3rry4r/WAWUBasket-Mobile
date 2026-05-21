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
