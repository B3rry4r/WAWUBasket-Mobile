import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Shows a soft snackbar at the bottom of the screen — used for placeholder
/// actions while the underlying flow isn't wired to a backend yet.
void wbShowSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: WBTypography.body.copyWith(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: WBColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
}
