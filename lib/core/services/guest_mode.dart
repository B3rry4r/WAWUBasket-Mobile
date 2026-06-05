import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/role_controller.dart';
import '../network/token_store.dart';
import '../router/app_routes.dart';
import '../utils/wb_actions.dart';

/// In-memory flag that lets unauthenticated visitors browse read-only
/// surfaces (home, catalogue, vendor pages) without an account.
///
/// App Store / Play Store reviewers require this for apps whose primary
/// value is browsable content; auth-gating everything was previously a
/// rejection risk.
///
/// Auth-gated actions (cart, checkout, favorites, chat) call
/// [requireAccount] which surfaces a snackbar and pushes the login route.
/// The auth flow flips the flag back to false on successful sign-in.
class GuestModeController {
  GuestModeController._();
  static final GuestModeController instance = GuestModeController._();

  /// True while the user is browsing without an account. Listen to gate
  /// nav tiles or surface "Sign in" prompts.
  final ValueNotifier<bool> isGuest = ValueNotifier<bool>(false);

  /// Enter guest mode. Sets the customer role (without flipping signedIn)
  /// so the customer shell can render. Token store is intentionally NOT
  /// touched — guest requests should not carry an Authorization header.
  void enter() {
    RoleController.instance.setGuest();
    isGuest.value = true;
  }

  /// Leave guest mode (called from the auth flow after a successful
  /// sign-in or sign-up). Token + signedIn flag are handled by the auth
  /// layer — this only flips the local flag.
  void exit() {
    isGuest.value = false;
  }

  /// Funnels the caller to the login screen if they don't have a usable
  /// session. Returns true when the action should proceed, false when the
  /// user was redirected to sign in.
  ///
  /// Gating on the actual JWT (not just the guest flag) means a user who
  /// landed in the customer shell without a valid token — guest, signed out,
  /// or a session that was never established — is routed to sign-in instead
  /// of firing an authenticated request that 401s with a confusing error.
  bool requireAccount(BuildContext context, {String? action}) {
    if (!isGuest.value && TokenStore.instance.hasSession) return true;
    // TODO(i18n): key=guestSignInToContinue
    wbShowSnack(
      context,
      action == null
          ? 'Sign in to continue.'
          : 'Sign in to $action.',
    );
    context.push(AppRoutes.login);
    return false;
  }
}
