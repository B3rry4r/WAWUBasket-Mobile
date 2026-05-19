import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import 'app/wawubasket_app.dart';
import 'core/config/secrets.dart';
import 'features/auth/application/role_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the user's last role + KYC progress before the splash routes.
  await RoleController.instance.load();
  // Mapbox: only initialise on the platforms it supports (Android/iOS).
  // On web (or when no token is configured) the rider map falls back to
  // a stylized placeholder, so we just skip the init.
  if (kMapboxConfigured && !kIsWeb) {
    mb.MapboxOptions.setAccessToken(kMapboxPublicToken);
  }
  runApp(const ProviderScope(child: WAWUBasketApp()));
}
