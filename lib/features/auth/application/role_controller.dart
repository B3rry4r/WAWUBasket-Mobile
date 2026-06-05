import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/biometric_service.dart';
import '../../../core/network/token_store.dart';
import '../../../core/router/app_routes.dart';
import '../data/auth_api.dart';

/// The operator roles in the app. `customer` is the default; every other role
/// is gated behind a KYC onboarding flow and (later) admin approval.
///
/// The full set lives here even when some shells haven't been built yet so
/// the persistence layer and the role-switcher can reference them safely.
/// Trader is added in batch C, driver in batch E.
enum AppRole { customer, vendor, trader, agent, rider, driver, admin }

extension AppRoleX on AppRole {
  String get title => switch (this) {
        AppRole.customer => 'Customer',
        AppRole.vendor => 'Vendor',
        AppRole.trader => 'Trader',
        AppRole.agent => 'Trade Agent',
        AppRole.rider => 'Rider',
        AppRole.driver => 'Driver',
        AppRole.admin => 'Dev',
      };

  /// One-line tagline used on the role-select cards and the in-account
  /// role switcher sheet.
  String get tagline => switch (this) {
        AppRole.customer => 'Order food, groceries and household goods.',
        AppRole.vendor => 'Sell from your kitchen, store or stall.',
        AppRole.trader => 'List bulk lots and reach buyers across corridors.',
        AppRole.agent => 'Register traders. Log sales. Pay them out.',
        AppRole.rider => 'Deliver baskets across your city.',
        AppRole.driver => 'Move long-haul loads across borders.',
        AppRole.admin => 'Toggle features and inspect platform state.',
      };

  /// Where the role's "home" lives in the router. Used right after
  /// role-select and on app cold-start to land in the right shell.
  String get homeRoute => switch (this) {
        AppRole.customer => AppRoutes.home,
        AppRole.vendor => AppRoutes.vendorHome,
        AppRole.trader => AppRoutes.traderHome,
        AppRole.agent => AppRoutes.agentHome,
        AppRole.rider => AppRoutes.riderHome,
        AppRole.driver => AppRoutes.driverHome,
        AppRole.admin => AppRoutes.home,
      };

  /// Where the role's KYC flow starts. Customer and admin have no KYC.
  String? get kycRoute => switch (this) {
        AppRole.customer => null,
        AppRole.vendor => AppRoutes.vendorKyc,
        AppRole.trader => AppRoutes.traderKyc,
        AppRole.agent => AppRoutes.agentKyc,
        AppRole.rider => AppRoutes.riderKyc,
        AppRole.driver => AppRoutes.driverKyc,
        AppRole.admin => null,
      };

  /// Where the role's Account tab lives.
  String? get accountRoute => switch (this) {
        AppRole.customer => AppRoutes.profile,
        AppRole.vendor => AppRoutes.vendorAccount,
        AppRole.trader => AppRoutes.traderAccount,
        AppRole.agent => AppRoutes.agentAccount,
        AppRole.rider => AppRoutes.riderAccount,
        AppRole.driver => AppRoutes.driverAccount,
        AppRole.admin => AppRoutes.profile,
      };

  /// Every role's shell is built and wired into the router. The role
  /// switcher uses this flag to suppress "Coming soon" placeholders.
  bool get shellReady => true;
}

/// Registration status for a given role. Customer is always [approved] —
/// every other role has to submit KYC and be approved before the user can
/// switch into that shell.
enum RoleStatus { unregistered, pending, approved }

extension RoleStatusX on RoleStatus {
  String get label => switch (this) {
        RoleStatus.unregistered => 'Get verified',
        RoleStatus.pending => 'In review',
        RoleStatus.approved => 'Approved',
      };
}

/// Persistent RBAC role state. Loaded from [SharedPreferences] on cold-start
/// so the user lands back in the role they last used.
///
/// The auth flow / role-select screen calls [setRole] to claim a role for
/// the session; KYC screens call [completeKyc] / [markPending] as the user
/// moves through onboarding; shells and the router listen to [notifier] to
/// route the user to the matching home and gate role-scoped pushes.
class RoleController {
  RoleController._();
  static final RoleController instance = RoleController._();

  static const _kRoleKey = 'wb.role';
  static const _kSignedInKey = 'wb.signedIn';
  static const _kHasEverSignedIn = 'wb.hasEverSignedIn';
  static const _kStatusPrefix = 'wb.status.';

  final ValueNotifier<AppRole> notifier = ValueNotifier(AppRole.customer);

  /// True once [setRole] has been called from any auth/role-select/operator
  /// login flow. Drives splash routing, a signed-out user lands on
  /// `/welcome`, a signed-in user lands on their role's home.
  bool _signedIn = false;
  bool get signedIn => _signedIn;

  /// Set the first time the user ever signs in; never cleared on sign-out.
  /// Splash uses this to send returning users directly to /login (where
  /// biometrics auto-triggers) rather than to /welcome (onboarding).
  bool _hasEverSignedIn = false;
  bool get hasEverSignedIn => _hasEverSignedIn;

  final Map<AppRole, RoleStatus> _status = {
    for (final r in AppRole.values)
      r: r == AppRole.customer ? RoleStatus.approved : RoleStatus.unregistered,
  };

  AppRole get role => notifier.value;

  RoleStatus statusOf(AppRole r) => _status[r] ?? RoleStatus.unregistered;

  bool canSwitchTo(AppRole r) => statusOf(r) == RoleStatus.approved;

  /// Roles that the user can switch into right now (KYC completed and the
  /// shell exists in the router). Customer is always included.
  List<AppRole> get switchableRoles => [
        for (final r in AppRole.values)
          if (r == AppRole.customer ||
              (r.shellReady && statusOf(r) == RoleStatus.approved))
            r,
      ];

  /// Called when the user finishes a KYC form. We auto-approve in the
  /// prototype, production would flip this to [pending] until admin
  /// approves.
  void completeKyc(AppRole r) {
    _status[r] = RoleStatus.approved;
    unawaited(_persistStatus(r));
  }

  /// Mark a role's application as awaiting admin review.
  void markPending(AppRole r) {
    _status[r] = RoleStatus.pending;
    unawaited(_persistStatus(r));
  }

  void setRole(AppRole next) {
    notifier.value = next;
    _signedIn = true;
    _hasEverSignedIn = true;
    unawaited(_persistRole());
  }

  /// Drops the user into the customer shell without claiming a session.
  /// Used by guest mode for App Store reviewers — the customer role is
  /// active so the shell renders, but [signedIn] stays false so the
  /// splash never auto-routes to home on the next cold start.
  void setGuest() {
    notifier.value = AppRole.customer;
    _signedIn = false;
    unawaited(_persistRole());
  }

  /// Resets the active role to customer, clears the signed-in flag, wipes
  /// stored JWT tokens, and clears per-role KYC status + biometric opt-in so
  /// the next user on this device starts from a clean slate (no cross-user
  /// leakage of approved operator roles or another person's biometric unlock).
  void signOut() {
    notifier.value = AppRole.customer;
    _signedIn = false;
    unawaited(_persistRole());
    // Reset every operator role's cached status so a stale "approved" flag
    // can't survive into the next session before syncFromApi runs.
    for (final r in AppRole.values) {
      if (r == AppRole.customer) continue;
      _status[r] = RoleStatus.unregistered;
      unawaited(_persistStatus(r));
    }
    TokenStore.instance.clear();
    // Biometric is an explicit per-account opt-in; drop it on real logout.
    BiometricService.instance.clear();
  }

  // ─── Persistence ─────────────────────────────────────────────────────

  SharedPreferences? _prefs;

  /// Load saved role + per-role status from disk. Call once at app boot,
  /// before the splash decides where to route.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // shared_preferences isn't available in tests / unsupported
      // platforms, degrade gracefully to in-memory defaults.
      _prefs = null;
      return;
    }
    final p = _prefs!;
    final savedRole = p.getString(_kRoleKey);
    if (savedRole != null) {
      final match = AppRole.values
          .where((r) => r.name == savedRole)
          .firstOrNull;
      if (match != null) notifier.value = match;
    }
    _signedIn = p.getBool(_kSignedInKey) ?? false;
    _hasEverSignedIn = p.getBool(_kHasEverSignedIn) ?? _signedIn;
    for (final r in AppRole.values) {
      if (r == AppRole.customer) continue;
      final v = p.getString('$_kStatusPrefix${r.name}');
      if (v == null) continue;
      final st = RoleStatus.values.where((s) => s.name == v).firstOrNull;
      if (st != null) _status[r] = st;
    }
  }

  /// Fetches the user's roles and KYC statuses from the backend and updates
  /// the local [_status] map. Should be called immediately after any login so
  /// [RoleSelectScreen] reflects the server's truth rather than stale cache.
  ///
  /// Failures are swallowed — the local state is retained as a fallback.
  Future<void> syncFromApi() async {
    try {
      final roles = await AuthApi.instance.getRoles();
      // API response is authoritative — reset all operator statuses first so
      // a previous user's approved roles don't bleed into a new session.
      for (final r in AppRole.values) {
        if (r == AppRole.customer || r == AppRole.admin) continue;
        _status[r] = RoleStatus.unregistered;
        await _persistStatus(r);
      }
      for (final entry in roles) {
        if (entry is! Map) continue;
        final map = entry.cast<String, dynamic>();
        final roleName = map['role'] as String?;
        final statusName = map['status'] as String?;
        if (roleName == null || statusName == null) continue;
        final role = AppRole.values.where((r) => r.name == roleName).firstOrNull;
        final status =
            RoleStatus.values.where((s) => s.name == statusName).firstOrNull;
        if (role != null && status != null) {
          _status[role] = status;
          await _persistStatus(role);
        }
      }
    } catch (_) {
      // Network unavailable or token expired — keep cached status.
    }
  }

  /// Persists the active role + session flags. Awaits the writes and logs
  /// failures so a storage error is never swallowed. Sync callers invoke this
  /// via [unawaited] (the in-memory state is already updated, the disk write
  /// just needs to complete in the background).
  Future<void> _persistRole() async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setString(_kRoleKey, notifier.value.name);
      await p.setBool(_kSignedInKey, _signedIn);
      if (_hasEverSignedIn) await p.setBool(_kHasEverSignedIn, true);
    } catch (e) {
      debugPrint('[role] failed to persist role: $e');
    }
  }

  Future<void> _persistStatus(AppRole r) async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setString('$_kStatusPrefix${r.name}', _status[r]!.name);
    } catch (e) {
      debugPrint('[role] failed to persist status for ${r.name}: $e');
    }
  }
}
