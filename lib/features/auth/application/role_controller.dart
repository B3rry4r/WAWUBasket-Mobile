import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_routes.dart';

/// The operator roles in the app. `customer` is the default; every other role
/// is gated behind a KYC onboarding flow and (later) admin approval.
///
/// The full set lives here even when some shells haven't been built yet so
/// the persistence layer and the role-switcher can reference them safely.
/// Trader is added in batch C, driver in batch E.
enum AppRole { customer, vendor, trader, agent, rider, driver }

extension AppRoleX on AppRole {
  String get title => switch (this) {
        AppRole.customer => 'Customer',
        AppRole.vendor => 'Vendor',
        AppRole.trader => 'Trader',
        AppRole.agent => 'Trade Agent',
        AppRole.rider => 'Rider',
        AppRole.driver => 'Driver',
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
      };

  /// Where the role's KYC flow starts. Customer has no KYC.
  String? get kycRoute => switch (this) {
        AppRole.customer => null,
        AppRole.vendor => AppRoutes.vendorKyc,
        AppRole.trader => AppRoutes.traderKyc,
        AppRole.agent => AppRoutes.agentKyc,
        AppRole.rider => AppRoutes.riderKyc,
        AppRole.driver => AppRoutes.driverKyc,
      };

  /// Where the role's Account tab lives (or null for customer, which uses
  /// the existing `/profile`).
  String? get accountRoute => switch (this) {
        AppRole.customer => AppRoutes.profile,
        AppRole.vendor => AppRoutes.vendorAccount,
        AppRole.trader => AppRoutes.traderAccount,
        AppRole.agent => AppRoutes.agentAccount,
        AppRole.rider => AppRoutes.riderAccount,
        AppRole.driver => AppRoutes.driverAccount,
      };

  /// Trader and driver shells aren't wired into the router until batches C
  /// and E. While that's the case, the role-switcher treats those rows as
  /// "Coming soon" so we don't end up navigating to a missing route.
  bool get shellReady => switch (this) {
        AppRole.customer || AppRole.vendor || AppRole.agent ||
            AppRole.rider => true,
        AppRole.trader || AppRole.driver => false,
      };
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
  static const _kStatusPrefix = 'wb.status.';

  final ValueNotifier<AppRole> notifier = ValueNotifier(AppRole.customer);

  /// True once [setRole] has been called from any auth/role-select/operator
  /// login flow. Drives splash routing — a signed-out user lands on
  /// `/welcome`, a signed-in user lands on their role's home.
  bool _signedIn = false;
  bool get signedIn => _signedIn;

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
  /// prototype — production would flip this to [pending] until admin
  /// approves.
  void completeKyc(AppRole r) {
    _status[r] = RoleStatus.approved;
    _persistStatus(r);
  }

  /// Mark a role's application as awaiting admin review.
  void markPending(AppRole r) {
    _status[r] = RoleStatus.pending;
    _persistStatus(r);
  }

  void setRole(AppRole next) {
    notifier.value = next;
    _signedIn = true;
    _persistRole();
  }

  /// Resets the active role to customer and clears the signed-in flag.
  /// KYC progress is preserved so the user can switch back into an
  /// approved role without redoing it.
  void signOut() {
    notifier.value = AppRole.customer;
    _signedIn = false;
    _persistRole();
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
      // platforms — degrade gracefully to in-memory defaults.
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
    for (final r in AppRole.values) {
      if (r == AppRole.customer) continue;
      final v = p.getString('$_kStatusPrefix${r.name}');
      if (v == null) continue;
      final st = RoleStatus.values.where((s) => s.name == v).firstOrNull;
      if (st != null) _status[r] = st;
    }
  }

  void _persistRole() {
    final p = _prefs;
    if (p == null) return;
    p.setString(_kRoleKey, notifier.value.name);
    p.setBool(_kSignedInKey, _signedIn);
  }

  void _persistStatus(AppRole r) {
    final p = _prefs;
    if (p == null) return;
    p.setString('$_kStatusPrefix${r.name}', _status[r]!.name);
  }
}
