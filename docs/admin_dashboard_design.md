# WAWUBasket Admin Dashboard — Design Brief

For the UI/UX designer. Mobile app already exists; this is its web operator console. Match the mobile design DNA but built for desks, not thumbs.

---

## Mood

Calm, monochrome, dense-but-breathable. Think Linear, Notion, Vercel dashboards. Not Salesforce. Not Material. The mobile app is mostly white with a single dark accent and small status dots — keep that same restraint.

Pages should feel like reading a document. Operators sit here for 6 hours; nothing should fight for their attention except an actual incident.

---

## Visual language

Mirror the mobile tokens 1-for-1 so designers can paste swatches and type ramps without a converter.

**Colour**

| Role | Hex | Use |
|---|---|---|
| Surface dark | `#111111` | Headers, dark CTAs, the rider-pin equivalent in fleet view |
| BG primary | `#FFFFFF` | Canvas |
| BG secondary | `#F7F7F6` | Page background behind cards |
| BG soft | `#EFEFED` | Hover, table row stripe |
| BG divider | `#E6E6E3` | 1px borders, hairlines |
| FG header | `#111111` | H1–H3 |
| FG primary | `#1F1F1E` | Body |
| FG secondary | `#6B6B68` | Captions, helper text |
| Status — success | `#1F7A3A` | Approved, paid out, delivered |
| Status — warn | `#B8860B` | Pending review, awaiting funds |
| Status — danger | `#B0322B` | Disputed, suspended, refunded |
| Status — info | `#1F5BB8` | Held in escrow, in transit |

Status colours appear as a 6px dot or a soft 12% tint behind a pill. Never as full backgrounds.

**Type** — Inter. Sizes: H1 28/36, H2 22/30, H3 17/24, body 14/22, caption 12/18. Numbers in tables tabular-figures. No display fonts.

**Spacing** — 4 / 8 / 12 / 16 / 24 / 32 / 48. Cards padded 24. Tables: 14 vertical row padding.

**Radius** — 12 for cards, 8 for inputs, 999 for pills. Buttons stay pill-radius to echo mobile.

**Shadow** — barely there: `0 1px 2px rgba(17,17,17,0.04), 0 0 0 1px rgba(17,17,17,0.05)`. Avoid bigger drop-shadows; they look web-1.0 in dense UIs.

---

## Layout system

12-column grid, 1440 design width, 80px outer margin, 24px gutter. Page max-width 1280. Below 1024, the nav rail collapses to icons.

**Three regions**

1. **Left rail** (64 collapsed / 240 expanded) — the only navigation. Workspace switcher at top, sections below, user chip at bottom.
2. **Top bar** (56 tall) — page title, breadcrumb, contextual filters on the left; global search + notifications + admin avatar on the right. No tabs in the top bar — tabs belong inside the page.
3. **Canvas** — everything else.

Nav sections (in order):
- Overview
- Approvals (badge with count)
- Users
- Orders & escrow
- Fleet *(map screen)*
- Service zones *(map screen)*
- Demand heatmap *(map screen)*
- Disputes
- Finance
- Content & promos
- Audit log
- Settings

---

## Screens

Each screen below is one design. Go in this order.

### 1. Sign in

Centered card, 420 wide, on the `#F7F7F6` canvas. Wordmark, "Sign in to operate WAWUBasket", email + password, "Send me a code instead" link, primary button "Continue". Forgot link below. No social auth. Add a small "Staging" or "Production" pill next to the wordmark on non-prod builds.

States to design: empty, typing, error ("Wrong email or code"), 2FA challenge (single 6-digit input, paste-supported, 60s resend timer).

### 2. Overview (home)

The 6am-glance page. Three rows.

**Row 1 — KPI cards (4 across)**
- Orders today (number, delta vs yesterday in caption with tiny up/down chevron)
- GMV today (₦)
- Escrow held (₦)
- Open disputes

Each card is white, 24 padding, no shadow, just the 1px border. Hover: subtle bg-soft tint. Clickable → deep-links to the relevant section.

**Row 2 — Approval inboxes (3 across)**
"You have 14 approvals waiting." Pending counts per role: vendors, traders, riders, drivers, agents. A row chip per role with the count and a "Review" link.

**Row 3 — Live ribbon (full width)**
Last 10 events as a stream: "Rider #221 went online", "Order #4451 paid → held", "Dispute opened on #4438". Each row 48 tall, timestamp on the right. Auto-updates with a subtle fade-in. Click any row → its detail page.

Empty state for each region: lockup with the WAWUBasket basket mark muted at 12% and one helper sentence.

### 3. Approvals

The screen operators live in. Tab strip up top: Vendors · Traders · Riders · Drivers · Agents. Each tab is its own queue, same layout.

**Left** (480 wide) — list of pending applicants. Card per row: avatar, name, applied date, two-line summary, status pill ("Pending 4h"). Filters above: search, "Submitted today", "Has flags", sort. Bulk-select with a top action bar that appears on selection ("Approve 6 · Reject 6").

**Right** (rest of the canvas) — detail panel for the selected applicant. Sections:
- Identity (name, phone, email, address)
- Documents (each KYC doc as a thumbnail tile, click to lightbox; for cross-border drivers/traders this includes ECOWAS, AfCFTA and customs licence)
- Vehicle (riders/drivers only)
- Bank / payout details
- Notes thread (admins can leave each other notes; threaded, latest at bottom)
- Decision footer: sticky bar with "Approve", "Request more info", "Reject". The reject button opens a reason picker; the request-info one opens a templated message composer.

Each document tile has a small status icon: unverified, auto-checked, manually verified. Hovering shows uploaded date.

Design the empty-queue state too — a single "All caught up" lockup with the next-newest applicant timestamp.

### 4. Users

A single people table. Columns: name, role(s), location, joined, status, last active. Each row is a chip stack on the right for the user's roles (a person can be more than one). Click a row → user detail.

**User detail** uses the same right-panel pattern as approvals. Top hero with avatar, name, role chips, suspended toggle. Sections: Activity, Orders, Payouts, Documents, Devices, Audit. Each section is a card you can collapse.

A red `Suspend` action sits in a destructive zone at the bottom — confirm modal asks for reason and notifies the user.

### 5. Orders & escrow

Same shape as Users: table left, detail right.

Table columns: order id, customer, vendor/trader, total, escrow state (pill), placed, age. Filter bar: by state (placed → paid → preparing → in-transit → delivered → confirmed → settled → disputed → refunded), date range, zone, role.

**Order detail** is the most important screen after approvals. Top: order summary card. Middle: timeline as a vertical state stepper with timestamps and actor (system / customer / vendor / rider). Right column: parties (customer + vendor + rider cards), chat preview, attachments. Footer: admin actions — release escrow, refund (partial / full), reassign rider, open dispute, cancel.

Disputed orders have a red ribbon across the hero and an extra "Dispute" tab.

### 6. Fleet *(Mapbox)*

The first map screen. Full-canvas Mapbox map, light style to match the rider app. Riders and drivers shown as dark dots; clicking one opens a slide-in drawer on the right with their info, current trip, and a "Message" button.

Filters as a floating bar at the top of the map: vehicle type, status (online / on-trip / break / offline), zone. A side panel can list "Online now" as a scrollable list, with each entry mirroring its dot on the map (hover = ping).

Don't try to be Google Maps. The map is the canvas; the data is in the panels.

Empty state when no one's online in the filter: a hint card overlay — "No riders match. Try clearing the vehicle filter."

### 7. Service zones *(Mapbox)*

A polygon editor. Map fills the canvas. Left rail (320 wide) lists existing zones with a colour swatch, name, member count, status. Click a zone → it highlights on the map and the right panel opens with name, polygon coords (read-only nerd-detail), pricing overrides, active toggle.

Drawing controls float over the top-right: ✏️ new polygon, ↩︎ undo, 🗑 delete vertex, ✓ finish. On finish, name modal pops, zone gets added.

Show overlapping zones with a soft striped fill so operators can fix it.

### 8. Demand heatmap *(Mapbox)*

Same map base; toggle between "Orders last 24h", "Orders last 7d", "Rider supply", "Rider supply vs demand (gap)". The last option is the useful one — green where supply meets demand, red where it doesn't. A time-scrubber at the bottom lets ops play the day forward.

Right rail: a leaderboard of zones by gap, with a "Recruit drivers here" CTA that drops a pin and creates a recruitment task (parked as v2).

### 9. Disputes

Table of disputes with columns: id, order, opener (customer/vendor/rider), reason, age, state. Detail panel mirrors order detail with a focus on the dispute thread — every message in order, both sides, with attached photos shown as inline thumbnails. Sticky action bar: "Refund customer", "Release to vendor", "Split refund", "Escalate". Split refund opens a small split tool with two sliders that sum to 100%.

Escalated disputes get a red side stripe.

### 10. Finance

Three sub-tabs:

- **Reconciliation** — daily rollup table: date, orders, gross, fees, escrow movements, net to vendors, net to riders, platform take. Click a row → drill-down by hour.
- **Payouts** — table of pending and recent payouts to vendors, traders, riders, drivers, agents. Bulk-select to "Approve batch", row-level "Retry" on failures.
- **Promotions** — promo codes and campaign tiles (the WAWU+ subscription lives here; remember WAWU+ is a delivery *discount*, not free delivery).

Design an export button on each tab → CSV download modal.

### 11. Content & promos

Editorial control of what the customer sees on the home screen: banner spots, featured categories, curated vendor rows, "This week" promo card copy. Each spot has a small scheduler: starts, ends, audience (all / WAWU+ only / zone).

Also where the "tagline pool" for the home screen lives — the random short copy on the customer/vendor/trader home tops up from here.

### 12. Audit log

A read-only paginated table of every admin action. Columns: admin, action, target, timestamp. Filter by admin and action type. Each row expands inline to show the before/after diff. There is no edit; this is the trust ledger.

### 13. Settings

- Team (list of admins, invite, roles: super, ops, finance, support — view-only matrix on a separate row)
- Commissions (per role percentage with effective-from dates)
- Service hours per zone
- Feature flags (named toggles with on/off + audience selector)
- Webhooks (read-only — the engineers manage these)
- About / version / build sha (small footer card)

---

## Components catalog

Design these once, reuse everywhere.

- **Pill** — 24 tall, 12px horizontal, caption text. Variants: neutral, success, warn, danger, info.
- **Status dot** — 6px coloured circle + label.
- **Card** — white, 1px border, 12 radius, 24 padding.
- **Table row** — 56 tall, hover bg-soft, selected bg-soft + 2px left accent in surface-dark.
- **Side drawer** — 480 wide, slides from the right, has its own scroll. Esc to close.
- **Confirm modal** — 420 wide, centered, dimmed canvas, a single primary + ghost cancel.
- **Inline toast** — bottom-right, 3s dismiss, success / info / danger variants.
- **Sticky action bar** — 64 tall, surface-dark for destructive, white for routine.
- **Filter chip** — 32 tall, removable, with caret if it opens a popover.
- **Empty state lockup** — basket mark 64px muted at 12%, headline 17, helper 14 secondary, optional small CTA.

All buttons stay pill-radius. Primary = surface-dark + white text. Secondary = white + 1.5px border + dark text. Ghost = no border, dark text. Danger = `#B0322B` background.

---

## Tone of copy

- Short, plain, never marketing.
- Verbs in action labels: "Approve", not "Approval".
- Status copy reads as facts: "Held in escrow", "Awaiting rider", "Released to vendor".
- Errors are kind: "We couldn't load this order. Try again." Not "Error 500".
- Never use em-dashes (`—`). The mobile app banned them; the dashboard inherits the rule. Use periods.
- Numbers always with the ₦ symbol and a thousands separator.

---

## States designers must hand off for every screen

For each screen above, deliver:

1. **Default loaded** — happy data.
2. **Empty** — no rows / no results.
3. **Loading** — skeleton rows for tables, shimmer cards for KPIs.
4. **Error** — a calm card with a retry button.
5. **One destructive flow** — what the confirm modal looks like for the worst thing on that screen.

---

## Accessibility

- Body text 14 minimum, never below 12 for captions.
- Contrast AA against the background (the muted greys must be ≥ 4.5:1 against white).
- Focus rings always visible — 2px outline in surface-dark at 40% on focus.
- Every interactive element keyboard-reachable; the slide-in drawer must trap focus while open.
- Colour is never the only signal — pair status colour with a dot + label.

---

## Out of scope for the first design pass

- Mobile breakpoints (operators work at desks; ≥1024 is the target)
- Dark mode (later)
- Localisation (English first; the copy strings must still be externalised — designers should leave room for ~20% longer strings)

---

## Reference material

- Mobile app (this repo) — the design DNA the dashboard inherits.
- `docs/admin_dashboard_design.html` — earlier, more technical spec; use as a backstop for which fields exist on each entity but ignore the engineering bits.

---

Build the screens in the order they appear above. Approvals and Order detail are the daily-use cores; design those tightest.
