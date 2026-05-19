import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/screens/about_screen.dart';
import '../../features/account/presentation/screens/delete_account_screen.dart';
import '../../features/account/presentation/screens/dietary_preferences_screen.dart';
import '../../features/account/presentation/screens/security_screen.dart';
import '../../features/account/presentation/screens/wawu_plus_screen.dart';
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
import '../../features/trader/presentation/screens/trader_home_screen.dart';
import '../../features/trader/presentation/screens/trader_kyc_screen.dart';
import '../../features/trader/presentation/screens/trader_listing_edit_screen.dart';
import '../../features/trader/presentation/screens/trader_listings_screen.dart';
import '../../features/trader/presentation/screens/trader_login_screen.dart';
import '../../features/trader/presentation/screens/trader_prices_screen.dart';
import '../../features/trader/presentation/screens/trader_transport_screen.dart';
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
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shell/presentation/customer_shell.dart';
import '../../features/shopping/presentation/screens/cart_screen.dart';
import '../../features/shopping/presentation/screens/checkout_screen.dart';
import '../../features/shopping/presentation/screens/product_screen.dart';
import '../../features/shopping/presentation/screens/search_screen.dart';
import '../../features/shopping/presentation/screens/tracking_screen.dart';
import '../../features/shopping/presentation/screens/vendor_screen.dart';
import '../theme/wb_theme_exports.dart';
import 'app_routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Onboarding & Auth (no shell)
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, _) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, _) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (_, _) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
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
            pageBuilder: (_, _) => _tabFade(const HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            pageBuilder: (_, _) => _tabFade(const FavoritesScreen()),
          ),
          GoRoute(
            path: AppRoutes.orders,
            pageBuilder: (_, _) => _tabFade(const OrderHistoryScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, _) => _tabFade(const ProfileScreen()),
          ),
        ],
      ),

      // Pushed screens (no shell)
      GoRoute(
        path: AppRoutes.search,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendor,
        builder: (_, _) => const VendorScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.vendor}/:id',
        builder: (_, state) =>
            VendorScreen(vendorId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.product,
        builder: (_, _) => const ProductScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        builder: (_, state) =>
            ProductScreen(productId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (_, _) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (_, _) => const TrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (_, _) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (_, _) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (_, _) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.savedAddresses,
        builder: (_, _) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.wawuPlus,
        builder: (_, _) => const WawuPlusScreen(),
      ),
      GoRoute(
        path: AppRoutes.dietary,
        builder: (_, _) => const DietaryPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.security,
        builder: (_, _) => const SecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.deleteAccount,
        builder: (_, _) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.trade,
        builder: (_, _) => const TradeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.tradeSupplier}/:id',
        builder: (_, state) =>
            SupplierDetailScreen(supplierId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${AppRoutes.tradeLot}/:id',
        builder: (_, state) =>
            BulkLotDetailScreen(lotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${AppRoutes.tradeListing}/:id',
        builder: (_, state) => ExportListingDetailScreen(
          listingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.escrowCheckout}/:listingId',
        builder: (_, state) => BulkCheckoutScreen(
          listingId: state.pathParameters['listingId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.escrowStatus}/:id',
        builder: (_, state) =>
            EscrowStatusScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '${AppRoutes.escrowDispute}/:id',
        builder: (_, state) =>
            EscrowDisputeScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.escrowOrders,
        builder: (_, _) => const EscrowOrdersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.categoryDetail}/:id',
        builder: (_, state) =>
            CategoryScreen(categoryId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        builder: (_, _) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletTopUp,
        builder: (_, _) => const TopUpScreen(kind: WalletActionKind.topUp),
      ),
      GoRoute(
        path: AppRoutes.walletSend,
        builder: (_, _) => const TopUpScreen(kind: WalletActionKind.send),
      ),
      GoRoute(
        path: AppRoutes.walletWithdraw,
        builder: (_, _) => const TopUpScreen(kind: WalletActionKind.withdraw),
      ),
      GoRoute(
        path: AppRoutes.walletCards,
        builder: (_, _) => const TopUpScreen(kind: WalletActionKind.cards),
      ),
      GoRoute(
        path: AppRoutes.chatInbox,
        builder: (_, _) => const ChatInboxScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatRider,
        builder: (_, _) => const ChatScreen(kind: ChatContextKind.rider),
      ),
      GoRoute(
        path: AppRoutes.chatSupport,
        builder: (_, _) => const ChatScreen(kind: ChatContextKind.support),
      ),
      GoRoute(
        path: AppRoutes.receipt,
        builder: (_, _) => const ReceiptScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.meatCut}/:id',
        builder: (_, state) =>
            MeatCutScreen(productId: state.pathParameters['id']!),
      ),

      // ───────── Vendor (RBAC) ─────────
      GoRoute(
        path: AppRoutes.vendorLogin,
        builder: (_, _) => const VendorLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorKyc,
        builder: (_, _) => const VendorKycScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => VendorShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.vendorHome,
            pageBuilder: (_, _) => _tabFade(const VendorHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.vendorOrders,
            pageBuilder: (_, _) => _tabFade(const VendorOrdersScreen()),
          ),
          GoRoute(
            path: AppRoutes.vendorMenu,
            pageBuilder: (_, _) => _tabFade(const VendorMenuScreen()),
          ),
          GoRoute(
            path: AppRoutes.vendorAccount,
            pageBuilder: (_, _) =>
                _tabFade(const OperatorAccountScreen(role: AppRole.vendor)),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.vendorOrderDetail}/:id',
        builder: (_, state) => VendorOrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorPayouts,
        builder: (_, _) => const VendorPayoutsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorAlerts,
        builder: (_, _) => const VendorAlertsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorMenuEdit,
        builder: (_, state) {
          final id = state.uri.queryParameters['id'];
          return VendorMenuEditScreen(itemId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.vendorInventory,
        builder: (_, _) => const VendorInventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorAnalytics,
        builder: (_, _) => const VendorAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorReviews,
        builder: (_, _) => const VendorReviewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorSettings,
        builder: (_, _) => const VendorSettingsScreen(),
      ),

      // ───────── Agent (RBAC) ─────────
      GoRoute(
        path: AppRoutes.agentLogin,
        builder: (_, _) => const AgentLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentKyc,
        builder: (_, _) => const AgentKycScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AgentShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.agentHome,
            pageBuilder: (_, _) => _tabFade(const AgentHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.agentRecordTxn,
            pageBuilder: (_, _) => _tabFade(const AgentRecordTxnScreen()),
          ),
          GoRoute(
            path: AppRoutes.agentCashPayout,
            pageBuilder: (_, _) => _tabFade(const AgentCashPayoutScreen()),
          ),
          GoRoute(
            path: AppRoutes.agentAccount,
            pageBuilder: (_, _) =>
                _tabFade(const OperatorAccountScreen(role: AppRole.agent)),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.agentRegisterTrader,
        builder: (_, _) => const AgentRegisterTraderScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentSync,
        builder: (_, _) => const AgentSyncScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentTraders,
        builder: (_, _) => const AgentTradersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.agentTraderDetail}/:id',
        builder: (_, state) => AgentTraderDetailScreen(
          traderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.agentEarnings,
        builder: (_, _) => const AgentEarningsScreen(),
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
        builder: (_, _) => const TraderLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.traderKyc,
        builder: (_, _) => const TraderKycScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => TraderShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.traderHome,
            pageBuilder: (_, _) => _tabFade(const TraderHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.traderListings,
            pageBuilder: (_, _) => _tabFade(const TraderListingsScreen()),
          ),
          GoRoute(
            path: AppRoutes.traderPrices,
            pageBuilder: (_, _) => _tabFade(const TraderPricesScreen()),
          ),
          GoRoute(
            path: AppRoutes.traderAccount,
            pageBuilder: (_, _) =>
                _tabFade(const OperatorAccountScreen(role: AppRole.trader)),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.traderListings}/edit',
        builder: (_, state) => TraderListingEditScreen(
          listingId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.traderTransport,
        builder: (_, _) => const TraderTransportScreen(),
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
