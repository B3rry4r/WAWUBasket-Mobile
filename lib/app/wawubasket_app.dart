import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/router/app_router.dart';
import '../core/theme/wb_theme_exports.dart';

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
    return MaterialApp.router(
      title: 'WAWUBasket',
      debugShowCheckedModeBanner: false,
      theme: buildWBTheme(),
      routerConfig: _router,
    );
  }
}
