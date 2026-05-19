import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around [permission_handler] so screens don't reach for
/// the package directly and Web (which doesn't support the plugin) is
/// short-circuited to a sensible default.
abstract final class WBPermissions {
  /// Ask for foreground location access (while-using-app). Returns true
  /// if the OS granted it.
  static Future<bool> requestLocation() async {
    if (kIsWeb) return false;
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  /// Always-on location (for the rider while a trip is active). Falls
  /// back to a whenInUse request if the user denied Always once.
  static Future<bool> requestLocationAlways() async {
    if (kIsWeb) return false;
    final always = await Permission.locationAlways.request();
    if (always.isGranted) return true;
    final whenInUse = await Permission.locationWhenInUse.request();
    return whenInUse.isGranted || whenInUse.isLimited;
  }

  /// Push notifications (Android 13+ requires runtime grant).
  static Future<bool> requestNotifications() async {
    if (kIsWeb) return false;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Non-prompting check.
  static Future<bool> hasLocation() async {
    if (kIsWeb) return false;
    return Permission.locationWhenInUse.status
        .then((s) => s.isGranted || s.isLimited);
  }
}
