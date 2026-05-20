import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/wb_theme_exports.dart';

/// Hands turn-by-turn navigation off to the device's maps app, routing to
/// [lat]/[lng]. Uses the universal Google Maps directions URL, which opens
/// Google Maps when installed and otherwise falls back to the browser /
/// Apple Maps. [label] is only used for the failure snackbar.
Future<void> wbLaunchNavigation(
  BuildContext context,
  double lat,
  double lng, {
  String label = 'destination',
}) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=$lat,$lng&travelmode=driving',
  );
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    wbShowSnack(context, "Couldn't open maps for $label");
  }
}

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
