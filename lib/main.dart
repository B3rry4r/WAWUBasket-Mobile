import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import 'app/wawubasket_app.dart';
import 'core/config/secrets.dart';
import 'core/i18n/locale_controller.dart';
import 'core/network/token_store.dart';
import 'core/services/notification_service.dart';
import 'core/services/websocket_service.dart';
import 'features/account/data/chat_local_store.dart';
import 'features/auth/application/role_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the user's last role + KYC progress and JWT session before
  // the splash routes.
  await RoleController.instance.load();
  await TokenStore.instance.load();
  await LocaleController.instance.load();
  // Firebase / push notifications. Wrapped in try/catch so the app still
  // launches on builds where google-services.json / GoogleService-Info.plist
  // have not yet been added.
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Firebase not configured — push notifications will be unavailable.
  }
  // Mapbox: only initialise on the platforms it supports (Android/iOS).
  // On web (or when no token is configured) the rider map falls back to
  // a stylized placeholder, so we just skip the init.
  if (kMapboxConfigured && !kIsWeb) {
    mb.MapboxOptions.setAccessToken(kMapboxPublicToken);
  }
  // Real-time chat / order pushes. Auto-connects when a session is present
  // and tears down on logout via TokenStore.tokenNotifier — no auth-screen
  // wiring required.
  WebSocketService.instance.init();
  // On logout, wipe the offline chat cache so the next signed-in user
  // never sees the previous user's threads.
  TokenStore.instance.tokenNotifier.addListener(() {
    if (TokenStore.instance.accessToken == null) {
      ChatLocalStore.instance.clearAll().ignore();
    }
  });
  runApp(const ProviderScope(child: WAWUBasketApp()));
}
