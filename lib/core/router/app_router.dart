import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/screens/about_screen.dart';
import '../../features/account/presentation/screens/terms_screen.dart';
import '../../features/account/presentation/screens/privacy_screen.dart';
import '../../features/account/presentation/screens/delete_account_screen.dart';
import '../../features/account/presentation/screens/dev_settings_screen.dart';
import '../../features/account/presentation/screens/dietary_preferences_screen.dart';
import '../../features/account/presentation/screens/security_screen.dart';
import '../../features/account/presentation/screens/add_address_screen.dart';
import '../../features/account/presentation/screens/chat_inbox_screen.dart';
import '../../features/account/presentation/screens/chat_screen.dart';
import '../../features/account/presentation/screens/favorites_screen.dart';
import '../../features/account/presentation/screens/language_screen.dart';
import '../../features/account/presentation/screens/notifications_screen.dart';
import '../../features/account/presentation/screens/operator_account_screen.dart';
import '../../features/account/presentation/screens/order_history_screen.dart';
import '../../features/account/presentation/screens/personal_info_screen.dart';
import '../../features/account/presentation/screens/profile_screen.dart';
import '../../features/account/presentation/screens/receipt_screen.dart';
import '../../features/account/presentation/screens/saved_addresses_screen.dart';
import '../../features/account/presentation/screens/support_screen.dart';
import '../../features/account/presentation/screens/top_up_screen.dart';
import '../../features/account/presentation/screens/wallet_screen.dart';
import '../../features/auth/application/role_controller.dart';
import '../../features/escrow/presentation/screens/bulk_checkout_screen.dart';
import '../../features/escrow/presentation/screens/escrow_dispute_screen.dart';
import '../../features/escrow/presentation/screens/escrow_orders_screen.dart';
import '../../features/escrow/presentation/screens/escrow_status_screen.dart';
import '../../features/escrow/presentation/desktop/bulk_checkout_desktop_screen.dart';
import '../../features/escrow/presentation/desktop/escrow_dispute_desktop_screen.dart';
import '../../features/escrow/presentation/desktop/escrow_orders_desktop_screen.dart';
import '../../features/escrow/presentation/desktop/escrow_status_desktop_screen.dart';
import '../../features/agent/presentation/agent_shell.dart';
import '../../features/agent/presentation/screens/agent_cash_payout_screen.dart';
import '../../features/agent/presentation/screens/agent_earnings_screen.dart';
import '../../features/agent/presentation/screens/agent_home_screen.dart';
import '../../features/agent/presentation/screens/agent_record_txn_screen.dart';
import '../../features/agent/presentation/screens/agent_register_trader_screen.dart';
import '../../features/agent/presentation/screens/agent_screens.dart';
import '../../features/agent/presentation/screens/agent_sync_screen.dart';
import '../../features/agent/presentation/screens/agent_trader_detail_screen.dart';
import '../../features/agent/presentation/screens/agent_traders_screen.dart';
import '../../features/category/presentation/screens/category_screen.dart';
import '../../features/livestock/presentation/screens/meat_cut_screen.dart';
import '../../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../../features/recipes/presentation/screens/recipes_screen.dart';
import '../../features/rider/presentation/rider_shell.dart';
import '../../features/rider/presentation/screens/rider_delivery_complete_screen.dart';
import '../../features/rider/presentation/screens/rider_delivery_screen.dart';
import '../../features/rider/presentation/screens/rider_earnings_screen.dart';
import '../../features/rider/presentation/screens/rider_home_screen.dart';
import '../../features/rider/presentation/screens/rider_screens.dart';
import '../../features/trade/presentation/screens/bulk_lot_detail_screen.dart';
import '../../features/trade/presentation/screens/export_listing_detail_screen.dart';
import '../../features/trade/presentation/screens/supplier_detail_screen.dart';
import '../../features/trade/presentation/screens/trade_screen.dart';
import '../../features/trade/presentation/desktop/bulk_lot_detail_desktop_screen.dart';
import '../../features/trade/presentation/desktop/export_listing_detail_desktop_screen.dart';
import '../../features/trade/presentation/desktop/supplier_detail_desktop_screen.dart';
import '../../features/trade/presentation/desktop/trade_desktop_screen.dart';
import '../../features/trader/presentation/screens/trader_home_screen.dart';
import '../../features/trader/presentation/screens/trader_kyc_screen.dart';
import '../../features/trader/presentation/screens/trader_listing_edit_screen.dart';
import '../../features/trader/presentation/screens/trader_listings_screen.dart';
import '../../features/trader/presentation/screens/trader_login_screen.dart';
import '../../features/trader/presentation/screens/trader_prices_screen.dart';
import '../../features/trader/presentation/screens/trader_transport_screen.dart';
import '../../features/trader/presentation/desktop/trader_home_desktop_screen.dart';
import '../../features/trader/presentation/desktop/trader_listings_desktop_screen.dart';
import '../../features/trader/presentation/desktop/trader_prices_desktop_screen.dart';
import '../../features/trader/presentation/desktop/trader_listing_edit_desktop_screen.dart';
import '../../features/trader/presentation/desktop/trader_transport_desktop_screen.dart';
import '../../features/trader/presentation/desktop/trader_login_desktop_screen.dart';
import '../../features/trader/presentation/desktop/trader_kyc_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_home_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_record_txn_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_cash_payout_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_register_trader_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_sync_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_traders_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_trader_detail_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_earnings_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_login_desktop_screen.dart';
import '../../features/agent/presentation/desktop/agent_kyc_desktop_screen.dart';
import '../../features/trader/presentation/trader_shell.dart';
import '../../features/driver/presentation/driver_shell.dart';
import '../../features/driver/presentation/screens/driver_active_trip_screen.dart';
import '../../features/driver/presentation/screens/driver_bid_screen.dart';
import '../../features/driver/presentation/screens/driver_earnings_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_kyc_screen.dart';
import '../../features/driver/presentation/screens/driver_login_screen.dart';
import '../../features/vendor/presentation/screens/vendor_alerts_screen.dart';
import '../../features/vendor/presentation/screens/vendor_analytics_screen.dart';
import '../../features/vendor/presentation/screens/vendor_home_screen.dart';
import '../../features/agent/presentation/screens/agent_kyc_screen.dart';
import '../../features/rider/presentation/screens/rider_kyc_screen.dart';
import '../../features/vendor/presentation/screens/vendor_inventory_screen.dart';
import '../../features/vendor/presentation/screens/vendor_kyc_screen.dart';
import '../../features/vendor/presentation/screens/vendor_login_screen.dart';
import '../../features/vendor/presentation/screens/vendor_menu_edit_screen.dart';
import '../../features/vendor/presentation/screens/vendor_menu_screen.dart';
import '../../features/vendor/presentation/screens/vendor_order_detail_screen.dart';
import '../../features/vendor/presentation/screens/vendor_orders_screen.dart';
import '../../features/vendor/presentation/screens/vendor_payouts_screen.dart';
import '../../features/vendor/presentation/screens/vendor_reviews_screen.dart';
import '../../features/vendor/presentation/screens/vendor_settings_screen.dart';
import '../../features/vendor/presentation/vendor_shell.dart';
import '../../features/vendor/presentation/desktop/vendor_home_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_orders_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_menu_desktop_screen.dart';
import '../../features/account/presentation/desktop/operator_account_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_order_detail_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_payouts_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_alerts_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_menu_edit_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_inventory_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_analytics_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_reviews_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_settings_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_login_desktop_screen.dart';
import '../../features/vendor/presentation/desktop/vendor_kyc_desktop_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/web_unavailable_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/desktop/welcome_desktop_screen.dart';
import '../../features/auth/presentation/desktop/login_desktop_screen.dart';
import '../../features/auth/presentation/desktop/signup_desktop_screen.dart';
import '../../features/auth/presentation/desktop/otp_desktop_screen.dart';
import '../../features/auth/presentation/desktop/forgot_password_desktop_screen.dart';
import '../../features/auth/presentation/desktop/reset_password_desktop_screen.dart';
import '../../features/auth/presentation/desktop/role_select_desktop_screen.dart';
import '../responsive/wb_responsive_exports.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shell/presentation/customer_shell.dart';
import '../../features/shopping/presentation/screens/cart_screen.dart';
import '../../features/shopping/presentation/screens/checkout_screen.dart';
import '../../features/shopping/presentation/screens/delivery_complete_screen.dart';
import '../../features/shopping/presentation/screens/order_confirmation_screen.dart';
import '../../features/shopping/presentation/screens/product_screen.dart';
import '../../features/shopping/presentation/screens/search_screen.dart';
import '../../features/shopping/presentation/screens/tracking_screen.dart';
import '../../features/shopping/presentation/screens/vendor_screen.dart';
import '../../features/home/presentation/desktop/home_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/search_desktop_screen.dart';
import '../../features/category/presentation/desktop/category_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/vendor_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/product_desktop_screen.dart';
import '../../features/recipes/presentation/desktop/recipes_desktop_screen.dart';
import '../../features/recipes/presentation/desktop/recipe_detail_desktop_screen.dart';
import '../../features/livestock/presentation/desktop/meat_cut_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/cart_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/checkout_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/order_confirmation_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/delivery_complete_desktop_screen.dart';
import '../../features/shopping/presentation/desktop/tracking_desktop_screen.dart';
import '../../features/account/presentation/desktop/order_history_desktop_screen.dart';
import '../../features/account/presentation/desktop/receipt_desktop_screen.dart';
import '../../features/account/presentation/desktop/profile_desktop_screen.dart';
import '../../features/account/presentation/desktop/favorites_desktop_screen.dart';
import '../../features/account/presentation/desktop/wallet_desktop_screen.dart';
import '../../features/account/presentation/desktop/personal_info_desktop_screen.dart';
import '../../features/account/presentation/desktop/saved_addresses_desktop_screen.dart';
import '../../features/account/presentation/desktop/add_address_desktop_screen.dart';
import '../../features/account/presentation/desktop/notifications_desktop_screen.dart';
import '../../features/account/presentation/desktop/support_desktop_screen.dart';
import '../../features/account/presentation/desktop/chat_inbox_desktop_screen.dart';
import '../../features/account/presentation/desktop/chat_desktop_screen.dart';
import '../../features/account/presentation/desktop/top_up_desktop_screen.dart';
import '../../features/account/presentation/desktop/security_desktop_screen.dart';
import '../../features/account/presentation/desktop/dietary_preferences_desktop_screen.dart';
import '../../features/account/presentation/desktop/language_desktop_screen.dart';
import '../../features/account/presentation/desktop/about_desktop_screen.dart';
import '../../features/account/presentation/desktop/terms_desktop_screen.dart';
import '../../features/account/presentation/desktop/privacy_desktop_screen.dart';
import '../../features/account/presentation/desktop/delete_account_desktop_screen.dart';
import '../../features/account/presentation/desktop/dev_settings_desktop_screen.dart';
import '../theme/wb_theme_exports.dart';
import 'app_routes.dart';

/// Single source of truth for mapping a `wawubasket://payment/...` deep link
/// to the in-app route it should open. Returns null when [uri] isn't a
/// recognised payment callback. Used by BOTH the warm-start handler
/// (`wawubasket_app._handleDeepLink`) and GoRouter's [onException] so the two
/// paths can never drift apart.
String? paymentDeepLinkRoute(Uri uri) {
  if (uri.scheme != 'wawubasket' || uri.host != 'payment') return null;
  final orderId = uri.queryParameters['orderId'] ?? '';
  final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
  if (segment == 'success' && orderId.isNotEmpty) {
    return '${AppRoutes.orderConfirmation}?orderId=$orderId&paymentStatus=success';
  }
  if (segment == 'success') {
    // Paid, but we didn't get the order id back — land on the orders list.
    return AppRoutes.orders;
  }
  if (orderId.isNotEmpty) {
    // cancelled/failed redirect but the order was created — show the order
    // confirmation screen so the user sees the real API status (the webhook
    // may have already confirmed it).
    return '${AppRoutes.orderConfirmation}?orderId=$orderId&paymentStatus=pending';
  }
  return AppRoutes.checkout;
}

/// Handles URIs that GoRouter cannot match — primarily the payment deep links
/// the platform routing layer delivers before app_links can intercept.
void _onRouterException(
  BuildContext context,
  GoRouterState state,
  GoRouter router,
) {
  final route = paymentDeepLinkRoute(state.uri);
  // Unknown non-payment location — go to splash so auth state is re-evaluated.
  router.go(route ?? AppRoutes.splash);
}

/// Routes reachable without a session — onboarding, sign-in surfaces, and the
/// per-operator login / KYC entry points (a signed-out user must be able to
/// authenticate INTO an operator role).
bool _isPublicRoute(String loc) {
  const exact = <String>{
    AppRoutes.splash,
    AppRoutes.welcome,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.otp,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
    AppRoutes.roleSelect,
    AppRoutes.onboarding,
  };
  if (exact.contains(loc)) return true;
  if (loc.startsWith('/web-unavailable')) return true;
  for (final p in const ['/vendor', '/agent', '/rider', '/trader', '/driver']) {
    if (loc == '$p/login' || loc == '$p/apply') return true;
  }
  return false;
}

/// The role an operator/admin area requires, or null for customer-facing and
/// browse routes (which stay open to guests — actions inside them are gated by
/// `GuestModeController.requireAccount`). The customer storefront lives at
/// `/storefront`, NOT `/vendor`, so there's no clash with the vendor shell.
AppRole? _requiredRoleFor(String loc) {
  if (loc == AppRoutes.devSettings || loc.startsWith('/dev-settings')) {
    return AppRole.admin;
  }
  if (loc == AppRoutes.vendorHome || loc.startsWith('/vendor/')) {
    return AppRole.vendor;
  }
  if (loc == AppRoutes.agentHome || loc.startsWith('/agent/')) {
    return AppRole.agent;
  }
  if (loc == AppRoutes.riderHome || loc.startsWith('/rider/')) {
    return AppRole.rider;
  }
  if (loc == AppRoutes.traderHome || loc.startsWith('/trader/')) {
    return AppRole.trader;
  }
  if (loc == AppRoutes.driverHome || loc.startsWith('/driver/')) {
    return AppRole.driver;
  }
  return null;
}

/// Global auth/role guard. Synchronous (reads only in-memory controller
/// state) so it adds no latency. Signed-out users can't deep-link operator or
/// admin shells; signed-in users without a given role are bounced to their own
/// home. Public + customer/browse routes pass through untouched, so splash
/// bootstrap, onboarding, and guest browsing all still work.
/// True when [loc] points anywhere inside a role's area (shell, login, KYC).
/// `home` is the bare prefix (e.g. `/rider`); every other route under it is
/// `home/...` (e.g. `/rider/login`), so both forms have to be checked.
bool _isRoleArea(String loc, String home) =>
    loc == home || loc.startsWith('$home/');

/// Rider & Driver are mobile-only. On the web build any route inside those
/// areas resolves to the matching "get the app" screen — covering deep links,
/// a restored operator session, and the role switcher alike. Returns null on
/// native (the areas work normally) and for every other route.
String? _webMobileOnlyGate(String loc) {
  if (!kIsWeb) return null;
  if (_isRoleArea(loc, AppRoutes.riderHome)) {
    return AppRoutes.webUnavailableRider;
  }
  if (_isRoleArea(loc, AppRoutes.driverHome)) {
    return AppRoutes.webUnavailableDriver;
  }
  return null;
}

String? _authGuard(BuildContext context, GoRouterState state) {
  final loc = state.matchedLocation;
  final webGate = _webMobileOnlyGate(loc);
  if (webGate != null) return webGate;
  if (_isPublicRoute(loc)) return null;
  final required = _requiredRoleFor(loc);
  if (required == null) return null;
  final role = RoleController.instance;
  if (!role.signedIn) return AppRoutes.login;
  final inRole = role.role == required;
  final approved = role.statusOf(required) == RoleStatus.approved;
  if (!inRole && !approved) return role.role.homeRoute;
  return null;
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    onException: _onRouterException,
    redirect: _authGuard,
    routes: [
      // Onboarding & Auth (no shell)
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const WelcomeScreen(),
          desktop: const WelcomeDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const LoginScreen(),
          desktop: const LoginDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const SignupScreen(),
          desktop: const SignupDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: OtpScreen(
            phone: state.uri.queryParameters['phone'] ?? '',
            flow: state.uri.queryParameters['flow'] ?? 'signup',
          ),
          desktop: OtpDesktopScreen(
            phone: state.uri.queryParameters['phone'] ?? '',
            flow: state.uri.queryParameters['flow'] ?? 'signup',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const ForgotPasswordScreen(),
          desktop: const ForgotPasswordDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: ResetPasswordScreen(
            identifier: state.uri.queryParameters['identifier'] ?? '',
            code: state.uri.queryParameters['code'] ?? '',
          ),
          desktop: ResetPasswordDesktopScreen(
            identifier: state.uri.queryParameters['identifier'] ?? '',
            code: state.uri.queryParameters['code'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const RoleSelectScreen(),
          desktop: const RoleSelectDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.webUnavailableRider,
        builder: (_, _) =>
            const WebUnavailableScreen(role: AppRole.rider),
      ),
      GoRoute(
        path: AppRoutes.webUnavailableDriver,
        builder: (_, _) =>
            const WebUnavailableScreen(role: AppRole.driver),
      ),

      // Customer shell — wraps the 4 tabs with the floating bottom nav.
      // Search is NOT a tab; it's pushed from the home search bar.
      ShellRoute(
        builder: (context, state, child) => CustomerShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: HomeScreen(),
              desktop: HomeDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: FavoritesScreen(),
              desktop: FavoritesDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.orders,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: OrderHistoryScreen(),
              desktop: OrderHistoryDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: ProfileScreen(),
              desktop: ProfileDesktopScreen(),
            )),
          ),
        ],
      ),

      // Pushed screens (no shell)
      GoRoute(
        path: AppRoutes.search,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: SearchScreen(),
          desktop: SearchDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendor,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorScreen(),
          desktop: VendorDesktopScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.vendor}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: VendorScreen(vendorId: state.pathParameters['id']),
          desktop: VendorDesktopScreen(vendorId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: AppRoutes.product,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: ProductScreen(),
          desktop: ProductDesktopScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: ProductScreen(productId: state.pathParameters['id']),
          desktop: ProductDesktopScreen(productId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: CartScreen(),
          desktop: CartDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: CheckoutScreen(),
          desktop: CheckoutDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: OrderConfirmationScreen(
            orderId: state.uri.queryParameters['orderId'],
          ),
          desktop: OrderConfirmationDesktopScreen(
            orderId: state.uri.queryParameters['orderId'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.deliveryComplete,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: DeliveryCompleteScreen(
            orderId: state.uri.queryParameters['orderId'] ?? '',
          ),
          desktop: DeliveryCompleteDesktopScreen(
            orderId: state.uri.queryParameters['orderId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: TrackingScreen(
            orderId: state.uri.queryParameters['orderId'],
          ),
          desktop: TrackingDesktopScreen(
            orderId: state.uri.queryParameters['orderId'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.ordersHistory,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: OrderHistoryScreen(standalone: true),
          desktop: OrderHistoryDesktopScreen(standalone: true),
        ),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: WalletScreen(),
          desktop: WalletDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: NotificationsScreen(),
          desktop: NotificationsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: SupportScreen(),
          desktop: SupportDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: PersonalInfoScreen(),
          desktop: PersonalInfoDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.savedAddresses,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: SavedAddressesScreen(),
          desktop: SavedAddressesDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const LanguageScreen(),
          desktop: const LanguageDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const AboutScreen(),
          desktop: const AboutDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const TermsScreen(),
          desktop: const TermsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const PrivacyScreen(),
          desktop: const PrivacyDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dietary,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const DietaryPreferencesScreen(),
          desktop: const DietaryPreferencesDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.security,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const SecurityScreen(),
          desktop: const SecurityDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.deleteAccount,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const DeleteAccountScreen(),
          desktop: const DeleteAccountDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.devSettings,
        builder: (_, _) => WBAdaptiveScreen(
          mobile: const DevSettingsScreen(),
          desktop: const DevSettingsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.trade,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TradeScreen(),
          desktop: TradeDesktopScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.tradeSupplier}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: SupplierDetailScreen(supplierId: state.pathParameters['id']!),
          desktop: SupplierDetailDesktopScreen(
            supplierId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.tradeLot}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: BulkLotDetailScreen(lotId: state.pathParameters['id']!),
          desktop: BulkLotDetailDesktopScreen(lotId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.tradeListing}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: ExportListingDetailScreen(
            listingId: state.pathParameters['id']!,
          ),
          desktop: ExportListingDetailDesktopScreen(
            listingId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.escrowCheckout}/:listingId',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: BulkCheckoutScreen(
            listingId: state.pathParameters['listingId']!,
          ),
          desktop: BulkCheckoutDesktopScreen(
            listingId: state.pathParameters['listingId']!,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.escrowStatus}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: EscrowStatusScreen(orderId: state.pathParameters['id']!),
          desktop: EscrowStatusDesktopScreen(
            orderId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.escrowDispute}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: EscrowDisputeScreen(orderId: state.pathParameters['id']!),
          desktop: EscrowDisputeDesktopScreen(
            orderId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.escrowOrders,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: EscrowOrdersScreen(),
          desktop: EscrowOrdersDesktopScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.categoryDetail}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: CategoryScreen(categoryId: state.pathParameters['id']!),
          desktop:
              CategoryDesktopScreen(categoryId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: AddAddressScreen(
            addressId: state.uri.queryParameters['id'],
          ),
          desktop: AddAddressDesktopScreen(
            addressId: state.uri.queryParameters['id'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletTopUp,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TopUpScreen(kind: WalletActionKind.topUp),
          desktop: TopUpDesktopScreen(kind: WalletActionKind.topUp),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletSend,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TopUpScreen(kind: WalletActionKind.send),
          desktop: TopUpDesktopScreen(kind: WalletActionKind.send),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletWithdraw,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TopUpScreen(kind: WalletActionKind.withdraw),
          desktop: TopUpDesktopScreen(kind: WalletActionKind.withdraw),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletCards,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TopUpScreen(kind: WalletActionKind.cards),
          desktop: TopUpDesktopScreen(kind: WalletActionKind.cards),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatInbox,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: ChatInboxScreen(),
          desktop: ChatInboxDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatRider,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: ChatScreen(
            kind: ChatContextKind.rider,
            orderId: state.uri.queryParameters['orderId'],
            title: state.uri.queryParameters['title'],
          ),
          desktop: ChatDesktopScreen(
            kind: ChatContextKind.rider,
            orderId: state.uri.queryParameters['orderId'],
            title: state.uri.queryParameters['title'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatSupport,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: ChatScreen(kind: ChatContextKind.support),
          desktop: ChatDesktopScreen(kind: ChatContextKind.support),
        ),
      ),
      GoRoute(
        path: AppRoutes.receipt,
        builder: (_, state) => WBAdaptiveScreen(
          mobile: ReceiptScreen(
            orderId: state.uri.queryParameters['orderId'],
          ),
          desktop: ReceiptDesktopScreen(
            orderId: state.uri.queryParameters['orderId'],
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.meatCut}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: MeatCutScreen(productId: state.pathParameters['id']!),
          desktop: MeatCutDesktopScreen(productId: state.pathParameters['id']!),
        ),
      ),

      // Recipe combos
      GoRoute(
        path: AppRoutes.recipes,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: RecipesScreen(),
          desktop: RecipesDesktopScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.recipes}/:slug',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: RecipeDetailScreen(slug: state.pathParameters['slug']!),
          desktop:
              RecipeDetailDesktopScreen(slug: state.pathParameters['slug']!),
        ),
      ),

      // ───────── Vendor (RBAC) ─────────
      GoRoute(
        path: AppRoutes.vendorLogin,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorLoginScreen(),
          desktop: VendorLoginDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorKyc,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorKycScreen(),
          desktop: VendorKycDesktopScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => VendorShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.vendorHome,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: VendorHomeScreen(),
              desktop: VendorHomeDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.vendorOrders,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: VendorOrdersScreen(),
              desktop: VendorOrdersDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.vendorMenu,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: VendorMenuScreen(),
              desktop: VendorMenuDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.vendorAccount,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: OperatorAccountScreen(role: AppRole.vendor),
              desktop: OperatorAccountDesktopScreen(role: AppRole.vendor),
            )),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.vendorOrderDetail}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: VendorOrderDetailScreen(
            orderId: state.pathParameters['id']!,
          ),
          desktop: VendorOrderDetailDesktopScreen(
            orderId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorPayouts,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorPayoutsScreen(),
          desktop: VendorPayoutsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorAlerts,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorAlertsScreen(),
          desktop: VendorAlertsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorMenuEdit,
        builder: (_, state) {
          final id = state.uri.queryParameters['id'];
          return WBAdaptiveScreen(
            mobile: VendorMenuEditScreen(itemId: id),
            desktop: VendorMenuEditDesktopScreen(itemId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.vendorInventory,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorInventoryScreen(),
          desktop: VendorInventoryDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorAnalytics,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorAnalyticsScreen(),
          desktop: VendorAnalyticsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorReviews,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorReviewsScreen(),
          desktop: VendorReviewsDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorSettings,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: VendorSettingsScreen(),
          desktop: VendorSettingsDesktopScreen(),
        ),
      ),

      // ───────── Agent (RBAC) ─────────
      GoRoute(
        path: AppRoutes.agentLogin,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: AgentLoginScreen(),
          desktop: AgentLoginDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentKyc,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: AgentKycScreen(),
          desktop: AgentKycDesktopScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AgentShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.agentHome,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: AgentHomeScreen(),
              desktop: AgentHomeDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.agentRecordTxn,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: AgentRecordTxnScreen(),
              desktop: AgentRecordTxnDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.agentCashPayout,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: AgentCashPayoutScreen(),
              desktop: AgentCashPayoutDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.agentAccount,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: OperatorAccountScreen(role: AppRole.agent),
              desktop: OperatorAccountDesktopScreen(role: AppRole.agent),
            )),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.agentRegisterTrader,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: AgentRegisterTraderScreen(),
          desktop: AgentRegisterTraderDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentSync,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: AgentSyncScreen(),
          desktop: AgentSyncDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentTraders,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: AgentTradersScreen(),
          desktop: AgentTradersDesktopScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.agentTraderDetail}/:id',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: AgentTraderDetailScreen(
            traderId: state.pathParameters['id']!,
          ),
          desktop: AgentTraderDetailDesktopScreen(
            traderId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentEarnings,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: AgentEarningsScreen(),
          desktop: AgentEarningsDesktopScreen(),
        ),
      ),

      // ───────── Rider (RBAC) ─────────
      GoRoute(
        path: AppRoutes.riderKyc,
        builder: (_, _) => const RiderKycScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderLogin,
        builder: (_, _) => const RiderLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => RiderShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.riderHome,
            pageBuilder: (_, _) => _tabFade(const RiderHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.riderDelivery,
            pageBuilder: (_, _) => _tabFade(const RiderDeliveryScreen()),
          ),
          GoRoute(
            path: AppRoutes.riderEarnings,
            pageBuilder: (_, _) => _tabFade(const RiderEarningsScreen()),
          ),
          GoRoute(
            path: AppRoutes.riderAccount,
            pageBuilder: (_, _) =>
                _tabFade(const OperatorAccountScreen(role: AppRole.rider)),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.riderDelivery}/complete',
        builder: (_, _) => const RiderDeliveryCompleteScreen(),
      ),

      // ───────── Trader (RBAC) ─────────
      GoRoute(
        path: AppRoutes.traderLogin,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TraderLoginScreen(),
          desktop: TraderLoginDesktopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.traderKyc,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TraderKycScreen(),
          desktop: TraderKycDesktopScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => TraderShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.traderHome,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: TraderHomeScreen(),
              desktop: TraderHomeDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.traderListings,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: TraderListingsScreen(),
              desktop: TraderListingsDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.traderPrices,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: TraderPricesScreen(),
              desktop: TraderPricesDesktopScreen(),
            )),
          ),
          GoRoute(
            path: AppRoutes.traderAccount,
            pageBuilder: (_, _) => _tabFade(const WBAdaptiveScreen(
              mobile: OperatorAccountScreen(role: AppRole.trader),
              desktop: OperatorAccountDesktopScreen(role: AppRole.trader),
            )),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.traderListings}/edit',
        builder: (_, state) => WBAdaptiveScreen(
          mobile: TraderListingEditScreen(
            listingId: state.uri.queryParameters['id'],
          ),
          desktop: TraderListingEditDesktopScreen(
            listingId: state.uri.queryParameters['id'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.traderTransport,
        builder: (_, _) => const WBAdaptiveScreen(
          mobile: TraderTransportScreen(),
          desktop: TraderTransportDesktopScreen(),
        ),
      ),

      // ───────── Driver (RBAC) ─────────
      GoRoute(
        path: AppRoutes.driverLogin,
        builder: (_, _) => const DriverLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverKyc,
        builder: (_, _) => const DriverKycScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DriverShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.driverHome,
            pageBuilder: (_, _) => _tabFade(const DriverHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.driverActiveTrip,
            pageBuilder: (_, _) => _tabFade(const DriverActiveTripScreen()),
          ),
          GoRoute(
            path: AppRoutes.driverEarnings,
            pageBuilder: (_, _) => _tabFade(const DriverEarningsScreen()),
          ),
          GoRoute(
            path: AppRoutes.driverAccount,
            pageBuilder: (_, _) =>
                _tabFade(const OperatorAccountScreen(role: AppRole.driver)),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.driverHome}/bid/:loadId',
        builder: (_, state) => DriverBidScreen(
          loadId: state.pathParameters['loadId']!,
        ),
      ),
    ],
  );
}

/// Soft cross-fade page transition used for the 4 shell tabs. Honors the
/// design system's motion vocabulary (220 ms · easeSoft) so switching tabs
/// feels calm instead of popping.
CustomTransitionPage<void> _tabFade(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: WBMotion.base,
    reverseTransitionDuration: WBMotion.base,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: WBMotion.easeSoft);
      return FadeTransition(opacity: curved, child: child);
    },
  );
}
