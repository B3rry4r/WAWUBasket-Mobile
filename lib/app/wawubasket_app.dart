import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/auth/biometric_service.dart';
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
      BiometricService.instance.setEnabled(false);
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

    _initDeepLinks();
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
    if (uri.scheme != 'wawubasket') return;
    final host = uri.host;
    final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    final orderId = uri.queryParameters['orderId'] ?? '';

    if (host == 'payment') {
      if (path == 'success') {
        // Payment confirmed — navigate to order confirmation / tracking.
        if (orderId.isNotEmpty) {
          _router.go('${AppRoutes.orderConfirmation}?orderId=$orderId&paymentStatus=success');
        } else {
          _router.go(AppRoutes.orders);
        }
      } else if (path == 'cancelled') {
        // Payment cancelled or failed — go back to checkout so user can retry.
        _router.go(AppRoutes.checkout);
      }
    }
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
