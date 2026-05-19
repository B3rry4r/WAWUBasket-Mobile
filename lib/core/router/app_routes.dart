/// Centralised route names. Using a sealed class of constants keeps the
/// router-side and the call-sites in sync (no magic strings).
abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const roleSelect = '/role';

  // Shell tabs
  static const home = '/home';
  static const orders = '/orders';
  static const favorites = '/favorites';
  static const profile = '/profile';

  // Pushed routes — shopping
  static const search = '/search';

  /// Customer-side vendor storefront (a restaurant / essentials shop the
  /// customer is browsing). Distinct from [vendorHome] which is the
  /// vendor operator's own dashboard.
  static const vendor = '/storefront';
  static const product = '/product';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const tracking = '/tracking';

  // Category & trade
  static const categoryDetail = '/category'; // append `/:id`
  static const trade = '/trade';
  static const tradeSupplier = '/trade/supplier'; // append `/:id`
  static const tradeLot = '/trade/lot'; // append `/:id`
  static const tradeListing = '/trade/listing'; // append `/:id`

  // Escrow (cross-border bulk-order checkout). Buyer enters via
  // `/escrow/checkout/:listingId`; the success / status screen takes the
  // generated bulk-order id.
  static const escrowCheckout = '/escrow/checkout'; // append `/:listingId`
  static const escrowStatus = '/escrow/status'; // append `/:orderId`
  static const escrowDispute = '/escrow/dispute'; // append `/:orderId`
  static const escrowOrders = '/escrow/orders'; // buyer-side list

  // Account tools
  static const wallet = '/wallet';
  static const notifications = '/notifications';
  static const support = '/support';
  static const personalInfo = '/account/personal-info';
  static const savedAddresses = '/account/addresses';
  static const addAddress = '/account/addresses/edit';
  static const language = '/account/language';
  static const about = '/account/about';

  // Wallet sub-flows
  static const walletTopUp = '/wallet/top-up';
  static const walletSend = '/wallet/send';
  static const walletWithdraw = '/wallet/withdraw';
  static const walletCards = '/wallet/cards';

  // Conversations & receipts
  static const chatInbox = '/chat';
  static const chatRider = '/chat/rider';
  static const chatSupport = '/chat/support';
  static const receipt = '/receipt';

  // Livestock
  static const meatCut = '/livestock/cut'; // append `/:id`

  // Vendor (mobile, gated by KYC). Home / Orders / Menu / Account are the
  // four shell tabs; the rest are pushed routes reached from Home or Account.
  static const vendorLogin = '/vendor/login';
  static const vendorKyc = '/vendor/apply';
  static const vendorHome = '/vendor';
  static const vendorOrders = '/vendor/orders';
  static const vendorMenu = '/vendor/menu';
  static const vendorAccount = '/vendor/account';
  static const vendorOrderDetail = '/vendor/orders/detail'; // append `/:id`
  static const vendorMenuEdit = '/vendor/menu/edit'; // optional `?id=`
  static const vendorInventory = '/vendor/inventory';
  static const vendorAnalytics = '/vendor/analytics';
  static const vendorPayouts = '/vendor/payouts';
  static const vendorReviews = '/vendor/reviews';
  static const vendorSettings = '/vendor/settings';
  static const vendorAlerts = '/vendor/alerts';
  static const vendorStaff = '/vendor/settings/staff';

  // Agent (offline-first mobile, gated by KYC). Home / Record / Payout /
  // Account are the shell tabs; register-trader and sync are pushed.
  static const agentLogin = '/agent/login';
  static const agentKyc = '/agent/apply';
  static const agentHome = '/agent';
  static const agentRegisterTrader = '/agent/register-trader';
  static const agentRecordTxn = '/agent/record-transaction';
  static const agentCashPayout = '/agent/cash-payout';
  static const agentSync = '/agent/sync';
  static const agentAccount = '/agent/account';
  static const agentTraders = '/agent/traders';
  static const agentTraderDetail = '/agent/traders/detail'; // append `/:id`
  static const agentEarnings = '/agent/earnings';

  // Rider (food couriers, gated by KYC). Home / Active / Earnings / Account.
  static const riderLogin = '/rider/login';
  static const riderKyc = '/rider/apply';
  static const riderHome = '/rider';
  static const riderDelivery = '/rider/delivery';
  static const riderEarnings = '/rider/earnings';
  static const riderAccount = '/rider/account';

  // Trader (bulk wholesaler / cross-border seller). Shell built in batch C;
  // the route constants exist now so RoleController & the role switcher can
  // refer to them safely.
  static const traderLogin = '/trader/login';
  static const traderKyc = '/trader/apply';
  static const traderHome = '/trader';
  static const traderListings = '/trader/listings';
  static const traderPrices = '/trader/prices';
  static const traderTransport = '/trader/transport';
  static const traderAccount = '/trader/account';

  // Driver (long-haul transport union). Shell built in batch E.
  static const driverLogin = '/driver/login';
  static const driverKyc = '/driver/apply';
  static const driverHome = '/driver';
  static const driverActiveTrip = '/driver/trip';
  static const driverEarnings = '/driver/earnings';
  static const driverAccount = '/driver/account';
}
