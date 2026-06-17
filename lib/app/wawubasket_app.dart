import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/locale_controller.dart';
import '../core/network/api_client.dart';
import '../core/network/token_store.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../core/theme/wb_theme_exports.dart';
import '../features/moderation/application/blocked_users_controller.dart';
import '../l10n/app_localizations.dart';

/// Lets the desktop web build be dragged/scrolled with a mouse and trackpad,
/// not just a touch screen. Harmless on native (those devices are already in
/// the default set) but essential for the browser layouts.
class _WBScrollBehavior extends MaterialScrollBehavior {
  const _WBScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class WAWUBasketApp extends ConsumerStatefulWidget {
  const WAWUBasketApp({super.key});

  @override
  ConsumerState<WAWUBasketApp> createState() => _WAWUBasketAppState();
}

class _WAWUBasketAppState extends ConsumerState<WAWUBasketApp> {
  late final _router = buildRouter();
  StreamSubscription<Uri>? _deepLinkSub;
  VoidCallback? _tokenListener;

  @override
  void initState() {
    super.initState();

    ApiClient.instance.onSessionExpired = () {
      _router.go(AppRoutes.login);
    };

    // Hydrate the blocked-users set so the client-side content filters work
    // from first paint, then re-hydrate on login / clear on logout.
    final blocked = ref.read(blockedUsersProvider.notifier);
    if (TokenStore.instance.hasSession) {
      unawaited(blocked.hydrate());
    }
    _tokenListener = () {
      if (TokenStore.instance.accessToken != null) {
        unawaited(blocked.hydrate());
      } else {
        blocked.clear();
      }
    };
    TokenStore.instance.tokenNotifier.addListener(_tokenListener!);

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
    if (_tokenListener != null) {
      TokenStore.instance.tokenNotifier.removeListener(_tokenListener!);
    }
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
          scrollBehavior: const _WBScrollBehavior(),
          routerConfig: _router,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
