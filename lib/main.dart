import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import 'app/wawubasket_app.dart';
import 'core/config/secrets.dart';
import 'core/i18n/locale_controller.dart';
import 'core/network/token_store.dart';
import 'core/services/feature_flag_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/websocket_service.dart';
import 'features/account/application/notifications_controller.dart';
import 'features/account/data/chat_local_store.dart';
import 'features/auth/application/role_controller.dart';

/// Top-level category SVGs that show on the home screen the moment the
/// user lands. Pre-decoded into the [flutter_svg] cache so the very first
/// render doesn't flash a blank square while the asset bytes are read +
/// parsed. Subcategories are intentionally not preloaded — too many, and
/// they're only seen one category at a time.
const _criticalSvgs = <String>[
  'assets/categories/category_restaurants.svg',
  'assets/categories/category_fresh_market.svg',
  'assets/categories/category_livestock.svg',
  'assets/categories/category_kitchen_essentials.svg',
  'assets/categories/category_farm_produce.svg',
  'assets/categories/category_drinks.svg',
  'assets/categories/category_snacks.svg',
  'assets/categories/category_groceries.svg',
  'assets/categories/category_pharmacy.svg',
];

Future<void> _precacheCriticalSvgs() async {
  await Future.wait(_criticalSvgs.map((path) async {
    final loader = SvgAssetLoader(path);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the user's last role + KYC progress and JWT session before
  // the splash routes.
  await RoleController.instance.load();
  // flutter_secure_storage uses platform keychains/keystores that are not
  // available on all web environments — catch and continue gracefully.
  try {
    await TokenStore.instance.load();
  } catch (_) {}
  await LocaleController.instance.load();
  // Pre-decode the home-screen category SVGs so the first paint has them
  // in the flutter_svg in-memory cache. Failures are non-fatal — the
  // assets will still load lazily on demand.
  try {
    await _precacheCriticalSvgs();
  } catch (_) {}
  // Feature flags drive the home categories UI variant. The endpoint is
  // optional — when it 404s we fall back to the compiled-in defaults so
  // the launch never blocks on this call.
  await FeatureFlagService.instance.load();
  // Firebase / push notifications. Skip entirely on web — Firebase web
  // requires a separate JS SDK config that is not included in this build,
  // and flutter_local_notifications has no web implementation.
  if (!kIsWeb) {
    try {
      await NotificationService.instance.init();
    } catch (_) {
      // Firebase not configured — push notifications will be unavailable.
    }
  }
  // Refresh the notifications badge from the backend so the red dot only
  // appears when there's at least one unread message. Skipped when the
  // user has no token yet — the call would 401 immediately.
  if (TokenStore.instance.hasSession) {
    // Fire-and-forget — first paint must not wait on this.
    unawaited(NotificationsController.instance.refresh());
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
  // never sees the previous user's threads. sqflite has no web
  // implementation so the chat store is skipped on web.
  TokenStore.instance.tokenNotifier.addListener(() {
    if (TokenStore.instance.accessToken == null) {
      if (!kIsWeb) ChatLocalStore.instance.clearAll().ignore();
      NotificationsController.instance.markAllRead();
    }
  });
  runApp(const ProviderScope(child: WAWUBasketApp()));
}
