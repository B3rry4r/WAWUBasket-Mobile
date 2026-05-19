# WAWUBasket Backend API — Build Prompt

Use this prompt verbatim to brief a fresh AI session that will build the
backend API for the WAWUBasket mobile app. The Flutter app already exists
in this repo (`lib/`); your job is to design and implement the server
that will power it.

---

## 1. Product, in one paragraph

WAWUBasket is a West-African mobile marketplace that wires together six
distinct user roles into one logistics + commerce loop: **customers** buy
groceries, food, household goods; **vendors** are retailers/restaurants
listing items; **traders** are bulk wholesalers selling to other traders
or to vendors; **trade-agents** are field officers placing orders on
behalf of offline traders in markets; **riders** deliver small/medium
packages on bikes; **drivers** move bulk loads in vans and trucks
(including cross-border ECOWAS / AfCFTA freight). Payments are held in
escrow until the customer confirms delivery. Vendor → rider matching
happens at handover time based on basket size/value. Tracking is live
on Mapbox. There is **no loan or credit feature** — everything is paid
up-front into escrow.

## 2. What already exists (read this first)

Before writing any code, read the Flutter app so the API surface aligns
exactly with what the client calls:

- `lib/features/` — every feature has `application/` controllers that
  currently use in-memory `ValueNotifier`s. Each controller is the
  source of truth for what API endpoints/events are needed for that
  feature.
- `lib/core/config/` — endpoints, secrets, environment hooks.
- `docs/admin_dashboard_design.html` (also `.pdf`) — the web admin
  dashboard spec. Every approval / dispute / config workflow shown there
  is a server-side flow you'll back.
- `WAWUBASKET PLATFORM BUILD GUIDE.pdf` and
  `WAWUBASKET PLATFORM CONTENT BUILD GUIDE.pdf` — original product
  brief, in case the code is ambiguous.
- `WAWUAfrica HYBRID-TRADE.pdf` — context for the trader / trade-agent
  bulk-trade flow.

Treat the Flutter controllers as the contract. If the controller exposes
`acceptOffer(offerId)`, you owe it a `POST /rider/offers/:id/accept`.

## 3. The six roles, precisely

| Role | What they do | Key surfaces |
|---|---|---|
| **Customer** | Browse, order, pay into escrow, track, rate | Catalogue, cart, checkout, orders, chat, address book |
| **Vendor** (retailer) | List own SKUs, fulfil orders, request rider | Products CRUD, orders queue, KYC, payouts |
| **Trader** (bulk wholesaler) | List wholesale lots, sell to vendors/traders | Lots CRUD, bulk orders, KYC (incl. cross-border), payouts |
| **Trade-Agent** | Place orders on behalf of offline traders in markets | Linked trader profiles, order capture, commission |
| **Rider** (bike/moto) | Accept delivery offers, navigate, deliver | Live location, offers feed, KYC, earnings, withdraw |
| **Driver** (van/truck) | Accept bulk-haul jobs incl. cross-border | Live location, jobs feed, ECOWAS/AfCFTA papers, customs licence, earnings |

**Vendor ≠ Trader.** Different listings, different KYC, different payout
flows, different fulfilment patterns. Do not collapse them into one
"seller" entity.

## 4. Non-negotiable constraints

- **UI-only on the client side right now.** The mobile app uses
  ValueNotifier in-memory state. Your job is to give it real persistence
  and real-time signals; do not propose client refactors beyond what
  the API contract requires.
- **No loan / no credit.** Customers pre-fund every order. Don't design
  ledger flows that imply credit.
- **Escrow via Flutterwave** (or whichever PSP we pick — design the
  escrow service behind a `PaymentProvider` interface so we can swap).
- **Mapbox for location** (rider/driver live tracking, vendor pickup
  pin, customer delivery pin). The client already holds a public token;
  the server needs no Mapbox SDK except for optional geocoding /
  isochrone calls.
- **Authoring identity:** commits authored by `B3rry4r
  <excelpatrick917@gmail.com>` if you commit on this user's behalf.

## 5. Recommended stack

Pick one and commit to it; don't blend:

- **Primary recommendation: NestJS (Node 20+, TypeScript).** Mature
  module system, first-class WebSocket gateway, dependency injection,
  good Prisma/TypeORM integration, deployable as a single container.
- Alternatives that also fit: Go with Fiber + Gorm, Django + Channels,
  Rails + Action Cable. Avoid serverless-only for v1 because of the
  long-lived rider/driver socket sessions.

- **Database:** PostgreSQL 16. Use PostGIS for geographic columns
  (rider location, vendor pickup, delivery destination). One database,
  not microservice-per-table.
- **Cache + pub/sub:** Redis. Backs the WebSocket fan-out for live
  location and offer broadcast.
- **Object storage:** S3-compatible (Cloudflare R2 or AWS S3) for KYC
  uploads, product photos, chat attachments. Always issue pre-signed
  URLs; never proxy uploads through the API.
- **Queue:** BullMQ on Redis for payouts, KYC reviews, push fan-out,
  reconciliation jobs.
- **Push:** FCM for Android, APNs for iOS. Single abstraction over both.

## 6. High-level domain model

Sketch the tables; refine names against the Flutter controllers as you
read them.

- `users` (id, phone, email, locale, created_at, status)
- `user_roles` (user_id, role, status, joined_at) — a user can be more
  than one role over time (e.g. become a vendor later), but only one
  role is "active" per session.
- `profiles_customer`, `profiles_vendor`, `profiles_trader`,
  `profiles_agent`, `profiles_rider`, `profiles_driver` — role-specific
  data (business name, vehicle, plate, IBAN, etc.)
- `kyc_documents` (owner_id, role, kind, storage_key, status,
  reviewed_by, reviewed_at, notes) — `kind` enum includes ECOWAS /
  AfCFTA / customs-licence for cross-border drivers and traders.
- `addresses` (user_id, label, line, lat, lng, default)
- `catalog_items` (owner_id, owner_role, kind: retail|wholesale, sku,
  title, description, price, currency, unit, moq, stock,
  images[], status)
- `carts`, `cart_items`
- `orders` (id, customer_id, vendor_id|trader_id, total, currency,
  state, placed_at) — state machine below.
- `order_items`
- `escrow_holds` (order_id, psp_ref, amount, currency, status: held |
  released | refunded | disputed)
- `deliveries` (order_id, rider_id|driver_id, vehicle_type, fee,
  distance_km, eta_min, state, picked_at, delivered_at)
- `delivery_offers` (delivery_id, candidate_id, expires_at, state)
- `rider_locations` (rider_id, lat, lng, heading, recorded_at) —
  PostGIS POINT; keep only last N hours.
- `chats`, `chat_messages` (one thread per order, plus support threads)
- `disputes` (order_id, opened_by, reason, state, resolution, resolved_by)
- `payouts` (recipient_id, recipient_role, amount, currency, state,
  psp_ref)
- `audit_log` (actor_id, action, target, meta, occurred_at) — immutable
- `feature_flags`, `commissions`, `service_zones`, `promos` — admin
  configurable.

### Order state machine (canonical)

`placed → paid (escrow held) → accepted_by_vendor → preparing → ready →
rider_assigned → picked_up → in_transit → delivered →
confirmed (escrow released) → settled`

Side branches: `cancelled_by_customer`, `cancelled_by_vendor`,
`refunded`, `disputed`. Every transition emits an audit log entry and
(for live-impact transitions) a WebSocket event on the order channel.

## 7. API surface (illustrative, not exhaustive)

REST for CRUD + commands, WebSockets for live signals. JSON bodies,
versioned at `/v1/`. Use cursor pagination, never offset.

### Auth

- `POST /v1/auth/phone/start` → sends OTP
- `POST /v1/auth/phone/verify` → returns access + refresh JWT
- `POST /v1/auth/refresh`
- `POST /v1/auth/role/switch` — user with multiple roles changes
  active role for the session

### Customer

- `GET  /v1/catalog/items` (filter by zone, category, vendor, trader)
- `GET  /v1/catalog/items/:id`
- `POST /v1/cart/items`, `PATCH /v1/cart/items/:id`, `DELETE …`
- `POST /v1/orders` — body returns escrow checkout URL / token
- `GET  /v1/orders` and `GET /v1/orders/:id`
- `POST /v1/orders/:id/confirm-delivery` — releases escrow
- `POST /v1/orders/:id/dispute`
- `POST /v1/chats/:orderId/messages`

### Vendor / Trader

- `GET/POST/PATCH /v1/vendor/products` (and `/v1/trader/lots`)
- `GET  /v1/vendor/orders?state=…`
- `POST /v1/vendor/orders/:id/accept|reject|prepare|ready`
- `POST /v1/vendor/orders/:id/request-rider` — body includes
  `vehicleSuggestion: bicycle|motorbike|car|van|truck`. Server posts the
  offer to the matching pool.
- `POST /v1/vendor/kyc/upload` → returns pre-signed PUT URL
- `GET  /v1/vendor/payouts`

### Trade-agent

- `GET  /v1/agent/linked-traders`
- `POST /v1/agent/orders` — places order on behalf of trader_id
- `GET  /v1/agent/commission`

### Rider / Driver

- `GET  /v1/rider/offers` — current pool the rider is eligible for
- `POST /v1/rider/offers/:id/accept|decline`
- `POST /v1/rider/location` — body `{lat, lng, heading}` (also pushed
  via WS; HTTP is fallback)
- `POST /v1/rider/deliveries/:id/picked-up|delivered`
- Same shape under `/v1/driver/...` with vehicle-type filtering.

### Admin

Mirror everything in `docs/admin_dashboard_design.html`: approvals,
disputes, escrow inspector, reconciliation export, audit log, feature
flags, commissions, service zones, promos, monitoring webhooks.

### WebSockets (single gateway, channel-based)

- `order:{orderId}` — state changes, chat, ETA updates
- `rider:{riderId}` and `driver:{driverId}` — pushed offer cards, accept
  windows, deactivation alerts
- `delivery:{deliveryId}` — live location frames (rider → fan out to
  customer + vendor)
- `admin:approvals` and `admin:disputes` for the dashboard

Frame format: `{type, ts, payload}`. Authenticate the socket with the
same JWT used for REST; reject anonymous sockets.

## 8. RBAC and security

- One JWT per session. Claims include `userId`, `activeRole`, `scopes[]`,
  `kycLevel`.
- Authorization is per-endpoint + per-row. A vendor can only mutate
  their own orders. A rider can only see offers in their zone.
- Admin uses a separate `admin_*` table and a session cookie (the web
  dashboard is its own client) with stricter MFA.
- Every mutating endpoint writes to `audit_log`.
- Pre-signed S3 URLs scoped to the uploading user, 5-minute TTL.
- Rate-limit `auth/phone/start` and `rider/location` aggressively.
- No PII in logs. Phone numbers and IBANs are encrypted at rest with
  envelope encryption.

## 9. Payments / escrow

Wrap whichever PSP we use behind:

```ts
interface PaymentProvider {
  initEscrow(order): Promise<{ checkoutUrl, providerRef }>;
  capture(providerRef): Promise<void>;        // funds → escrow_held
  release(providerRef, splits): Promise<void>; // splits = vendor + rider + platform
  refund(providerRef, amount): Promise<void>;
  payout(account, amount): Promise<{ providerRef }>;
}
```

First implementation is `FlutterwaveProvider`. Webhooks land at
`/v1/webhooks/payments/flutterwave` and must be signature-verified,
idempotent (use `providerRef + eventId` as the dedupe key), and never
trust amount/order_id from the webhook alone — always re-read from the
PSP API.

Commission split is admin-configurable (`commissions` table) — don't
hard-code 10/5/etc.

## 10. Geo + matching

- Rider/driver pool is partitioned by `service_zone` (admin-defined
  polygons in PostGIS).
- Offer matching algorithm v1: filter eligible candidates (online,
  vehicle type matches request, in zone, not at concurrency cap), rank
  by haversine distance to pickup, send offer to top N with a 30s
  acceptance window; on decline/expiry, slide the window to the next N.
- Customer ETA shown in the app is `distance_to_pickup + prep_time +
  distance_to_dropoff` and is the value the rider sees too — single
  source of truth.

## 11. Realtime location

- Rider client posts a frame every 4 seconds while on a trip
  (configurable). Server upserts into `rider_locations` and broadcasts
  on `delivery:{id}`.
- Off-trip riders post every 30s and are not broadcast — only used for
  matching.
- Retain raw frames for 24h, then downsample to one-per-minute summary.

## 12. Notifications

- Push (FCM/APNs) for: offer received, order state change, chat
  message, payout settled, KYC reviewed, dispute updated.
- SMS fallback only for auth OTP.
- Email for receipts, payouts, admin invites.

## 13. Observability

- Structured JSON logs with `requestId`, `userId`, `role`.
- Per-endpoint latency + error rate metrics (Prometheus or OTel).
- Sentry for exceptions.
- A `/healthz` (DB + Redis + S3 ping) and `/readyz` (warmup-complete)
  endpoint for the load balancer.

## 14. Testing baseline

- Unit tests on all state-machine transitions and price/commission
  math.
- Integration tests against a real Postgres (testcontainers) — no
  database mocking (see project memory on this).
- Webhook-replay tests for the payment provider.
- A `seed` command that creates one of every role with realistic data,
  used by the mobile dev environment.

## 15. Deliverables for the first session

1. Repo layout proposal + module list.
2. ER diagram and Prisma/TypeORM schema for the tables in section 6.
3. Auth (phone OTP + JWT + role switch).
4. Catalog read endpoints + cart + a checkout that hits a *fake*
   `PaymentProvider` so the mobile app can complete the loop end-to-end
   on staging.
5. WebSocket gateway with at least the `order:{id}` and
   `delivery:{id}` channels.
6. The rider offers pool with a single matcher pass.
7. `/healthz` and `/readyz`, plus seed command, plus a minimal CI
   that runs the test suite against Postgres.

Park for the second session: real Flutterwave wiring, cross-border
trader/driver KYC review queue, admin dashboard backend, reconciliation
exports, government data portal.

## 16. Reading order (don't skip)

1. `WAWUBASKET PLATFORM BUILD GUIDE.pdf` — product brief.
2. `WAWUAfrica HYBRID-TRADE.pdf` — bulk-trade rationale.
3. `lib/features/` — every controller's public surface defines an
   endpoint or socket frame you owe.
4. `docs/admin_dashboard_design.html` — admin surface.
5. Memory at `.claude/projects/-workspace-projects-WAWUBasket/memory/` —
   user preferences and durable constraints.

---

Build deliberately. Vendor ≠ trader. Rider ≠ driver. No credit. Escrow
gates settlement. The Flutter app is the contract — when in doubt, read
the controller.
