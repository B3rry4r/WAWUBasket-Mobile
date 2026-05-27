# WAWUBasket — Known Issues & Improvement Backlog

Last updated: 2026-05-27

---

## FIXED (this sprint)

| # | Area | Issue | File(s) |
|---|------|-------|---------|
| 1 | Call buttons | All Call buttons now open `tel:` URI via `url_launcher` | rider_delivery_screen, escrow_status_screen, support_screen |
| 2 | Email button | Support email now opens `mailto:` via `url_launcher` | support_screen.dart |
| 3 | Vendor home rating | Rating now loaded from `GET /vendor/analytics` instead of hardcoded `★ 4.8` | vendor_home_screen.dart |
| 4 | Cart/checkout fees | Service fee now computed as 1.5% of subtotal (mirrors API); delivery shows ₦600 dynamic | cart_screen.dart, checkout_screen.dart |
| 5 | Agent sync time | "Last sync" now shows real elapsed time instead of hardcoded "2 hr ago" | agent_sync_screen.dart, agent_controller.dart |
| 6 | Dev/feature flags | Feature flag screen only shows home-UI flags; app-level flags removed from toggle | dev_settings_screen.dart |
| 7 | Escrow buyer phone | API now includes buyer phone in bulk order response; call button wired to real number | escrow.service.ts, bulk_order.dart, escrow_status_screen.dart |
| 8 | Rider vendor phone | API now includes vendor user phone in rider offer; hardcoded +234 802 800 4400 removed | rider.service.ts, rider_controller.dart, rider_delivery_screen.dart |
| 9 | Stale role statuses | syncFromApi resets operator roles before applying API response (cross-session leak fixed) | role_controller.dart |
| 10 | Biometric persistence | Biometric flag cleared on session expiry; re-offer shown on next password sign-in | wawubasket_app.dart |
| 11 | Inline biometric toggle | Biometric setting is now an inline switch on the account/profile screen | profile_screen.dart, account_menu.dart |
| 12 | Rider accept offer 500 | audit.log was passed Delivery UUID as orderId FK; fixed to order UUID | rider.service.ts |
| 13 | Vendor alerts 500 | Raw SQL used Prisma model names instead of mapped DB column names | vendor-extras.service.ts |
| 14 | Login active role | Login no longer hardcodes customer activeRole; rider/driver get correct token | auth.service.ts |
| 15 | "Cook Tonight" naming | Renamed to "Meal Kits" — previous name was time-restricted and misleading | home_screen.dart, dev_settings_screen.dart |
| 16 | Numeric dash fallbacks | All `'–'` fallbacks in stats/earnings/counts replaced with `'0'` | profile_screen, operator_account_screen, driver/rider earnings |
| 17 | Vendor rating 4.6 default | `Vendor.fromJson` no longer defaults to 4.6; shows "New" badge when rating is 0 | vendor.dart, ds_vendor_card.dart |
| 18 | Deep link / payment callback | `wawubasket://` scheme registered; app navigates back from Flutterwave on success/cancel | AndroidManifest.xml, Info.plist, wawubasket_app.dart, checkout_screen.dart |
| 19 | Payment method picker | Checkout screen now shows Card / Bank Transfer / Mobile Money selector | checkout_screen.dart, orders_api.dart, orders.service.ts |
| 20 | Session access token | Access token extended from 15 m to 60 m to reduce aggressive re-auth prompts | configuration.ts |
| 21 | Orbital category selector | Feature-flagged `new_categories_ui` now shows spinning orbital selector with physics | home_screen.dart |
| 22 | Scroll bounce physics | Main home screen and key screens use `BouncingScrollPhysics` for iOS-like feel | home_screen.dart + others |

---

## OPEN — HIGH PRIORITY

| # | Area | Issue | Notes |
|---|------|-------|-------|
| H1 | Dispute photo upload | `escrow_dispute_screen.dart:135` shows "Photo upload coming soon" snackbar | Need `image_picker` integration; upload via `POST /v1/uploads` then attach to dispute |
| H2 | Agent KYC photo | `agent_register_trader_screen.dart:139,147` — camera buttons show snackbar | Wire `image_picker` for trader photo + ID document capture |
| H3 | Marketplace categories | Categories must never be optional; show loading skeleton, not empty state | `category_controller.dart` — improve error handling so fallback always shows |
| H4 | Trader-only categories | Category screen shows restaurant-facing categories in trader bulk flow | Need separate category list for trader checkout vs customer checkout |

---

## OPEN — MEDIUM PRIORITY

| # | Area | Issue | Notes |
|---|------|-------|-------|
| M1 | Bundle add-to-basket | `category_screen.dart:352` snackbar "Bundle added to basket" | Wire `POST /v1/cart/items` for the bundle products |
| M2 | Reorder last basket | `category_screen.dart:455` snackbar "Last basket reordered" | Implement reorder via `GET /v1/orders` → `POST /v1/cart/items` for each line |
| M3 | CSV analytics export | `vendor_analytics_screen.dart:316` snackbar "CSV export started" | Generate CSV client-side from analytics data + share via `share_plus` |
| M4 | Payment method picker (wallet) | `top_up_screen.dart:250` snackbar "Method picker, coming soon" | Implement card/bank selector or remove the picker button |
| M5 | Saved payment methods | `top_up_screen.dart:184` shows hardcoded Visa card | Fetch from API or remove the display |
| M6 | Wallet tx tap | `wallet_screen.dart:250` shows snackbar on transaction row tap | Navigate to transaction detail or remove tap handler |
| M7 | Farmer spotlight | `category_screen.dart:362` snackbar "Farmer spotlight coming soon" | Implement or remove the UI element |
| M8 | Meat cut "Butcher" stats | `meat_cut_screen.dart` hardcoded "Butcher John · 4.9★" | Connect to a real butcher/supplier entity or remove |
| M9 | Customer order phone | `order['customerPhone']` in rider offer may be empty | Verify API includes customerPhone in rider offer response |
| M10 | Checkout delivery fee | Still ₦600 flat; should use vendor's `deliveryFee` field from catalog | `Vendor.fromJson` already parses `deliveryFee`; thread it to checkout |

---

## OPEN — LOW PRIORITY / DEBT

| # | Area | Issue | Notes |
|---|------|-------|-------|
| L1 | i18n — biometric strings | `login_screen.dart:193,210,308` TODO(i18n) | Add keys: `loginBiometricDynamic`, `loginBiometricFirstSignInHint`, `loginBiometricFailed` |
| L2 | i18n — guest profile | `profile_screen.dart:91` TODO(i18n) | Add keys: `profileGuestTitle`, `profileGuestBody`, `profileGuestCta` |
| L3 | i18n — product guest | `product_screen.dart:69` TODO(i18n) | Add key: `guestActionFavorite` |
| L4 | WAWU+ pricing | `wawu_plus_screen.dart` hardcoded ₦18,000/year, ₦1,800/month | Fetch pricing from API config endpoint when pricing becomes dynamic |

---

## NOTES

- All API base URL: `https://wawubasket-api-production.up.railway.app/v1`
- Staging OTP bypass: any phone + code `123456`
- All test users password: `Test1234!`
- Dev admin user (all roles): `dev@wawu.test` / `+2348030000099`
- Payment deep link scheme: `wawubasket://payment/success?orderId=<id>` and `wawubasket://payment/cancelled?orderId=<id>`
