import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/wawubasket_app.dart';
import 'features/auth/application/role_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the user's last role + KYC progress before the splash routes.
  await RoleController.instance.load();
  runApp(const ProviderScope(child: WAWUBasketApp()));
}
