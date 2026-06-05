import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/i18n/locale_controller.dart';
import '../core/network/api_client.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../core/theme/wb_theme_exports.dart';
import '../l10n/app_localizations.dart';

class WAWUBasketApp extends StatefulWidget {
  const WAWUBasketApp({super.key});

  @override
  State<WAWUBasketApp> createState() => _WAWUBasketAppState();
}

class _WAWUBasketAppState extends State<WAWUBasketApp> {
  late final _router = buildRouter();
  StreamSubscription<Uri>? _deepLinkSub;

  @override
  void initState() {
    super.initState();

    ApiClient.instance.onSessionExpired = () {
      _router.go(AppRoutes.login);
    };

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: WBColors.bgPrimary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (!kIsWeb) _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();

    // Handle link that opened the app cold (terminated state).
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) _handleDeepLink(initial);
    } catch (_) {}

    // Handle links while app is running (foreground / background).
    _deepLinkSub = appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (_) {},
    );
  }

  void _handleDeepLink(Uri uri) {
    // Shared mapper with GoRouter.onException so warm-start and cold-start
    // deep links resolve to exactly the same route.
    final route = paymentDeepLinkRoute(uri);
    if (route != null) _router.go(route);
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance.locale,
      builder: (_, locale, _) {
        return MaterialApp.router(
          title: 'WAWUBasket',
          debugShowCheckedModeBanner: false,
          theme: buildWBTheme(),
          routerConfig: _router,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
