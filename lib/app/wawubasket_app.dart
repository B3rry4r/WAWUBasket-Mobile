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

  @override
  void initState() {
    super.initState();
    ApiClient.instance.onSessionExpired = () {
      // Clear the biometric enabled flag so the next password sign-in
      // re-offers biometric setup (the old refresh token it was guarding
      // is gone, so "enabled" was pointing at nothing).
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
