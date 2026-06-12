import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../responsive/wb_responsive.dart';
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
    wbShowError(context, "Couldn't open maps for $label");
  }
}

/// Opens the device phone dialer pre-filled with [phone]. Strips spaces and
/// hyphens before building the URI so `+234 802 000 0000` works fine.
Future<void> wbCallPhone(BuildContext context, String phone) async {
  final digits = phone.replaceAll(RegExp(r'[\s\-()]'), '');
  final uri = Uri(scheme: 'tel', path: digits);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    wbShowError(context, "Couldn't open the phone app");
  }
}

/// Opens the default mail client with [email] pre-filled in the To field.
Future<void> wbLaunchEmail(BuildContext context, String email) async {
  final uri = Uri(scheme: 'mailto', path: email);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    wbShowError(context, "Couldn't open email app — write to $email");
  }
}

/// Canonical WAWUAfrica legal documents — one source of truth on the web, so a
/// policy update never needs an app release. The single page covers the Privacy
/// Policy, Terms of Use and Consent Framework.
const String wbPrivacyUrl = 'https://wawuafrica.com/privacy';
const String wbTermsUrl = 'https://wawuafrica.com/privacy';

/// Opens an external web URL (legal documents, help pages) in the browser.
Future<void> wbLaunchWebUrl(BuildContext context, String url) async {
  final ok =
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    wbShowError(context, "Couldn't open the link — visit $url");
  }
}

enum _WBSnackKind { info, error }

/// Neutral confirmation / info snackbar (saved, copied, placeholder actions).
void wbShowSnack(BuildContext context, String message) =>
    _wbShowSnack(context, message, _WBSnackKind.info);

/// Error snackbar — same footprint as [wbShowSnack] but flagged with the
/// status-error accent and held on screen a little longer. Use for caught
/// failures (`e.message`) so problems read differently from confirmations.
void wbShowError(BuildContext context, String message) =>
    _wbShowSnack(context, message, _WBSnackKind.error);

/// One standardized snackbar for the whole app.
///
/// Fixes the old behaviour that floated a pill-shaped bar 100px up the screen
/// (it looked like a stranded button): it now sits just above the bottom edge
/// as a rounded card. On desktop/web it becomes a fixed, comfortably-narrow
/// bar centred at the bottom instead of stretching the full monitor width.
void _wbShowSnack(BuildContext context, String message, _WBSnackKind kind) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      wbSnackBar(
        message: message,
        isDesktop: context.isDesktop,
        isError: kind == _WBSnackKind.error,
      ),
    );
}

/// Builds the standardized snackbar widget. Exposed so the rare call site that
/// must keep a `ScaffoldMessenger` captured across a `Navigator.pop()` (where
/// the context is no longer mountable) can still render the identical bar.
SnackBar wbSnackBar({
  required String message,
  required bool isDesktop,
  bool isError = false,
}) {
  final text = Text(
    message,
    style: WBTypography.body.copyWith(color: Colors.white, fontSize: 14),
  );
  final Widget content = isError
      ? Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.error_outline_rounded,
                  size: 20, color: WBColors.statusError),
            ),
            const SizedBox(width: 12),
            Flexible(child: text),
          ],
        )
      : text;

  return SnackBar(
    content: content,
    backgroundColor: WBColors.surfaceDark,
    behavior: SnackBarBehavior.floating,
    elevation: 6,
    // `width` centres a fixed bar (desktop); `margin` keeps a full-width
    // bar inset from the screen edge (mobile). They are mutually exclusive.
    width: isDesktop ? 460 : null,
    margin: isDesktop ? null : const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(WBRadius.button),
    ),
    duration: Duration(milliseconds: isError ? 2800 : 1800),
  );
}
