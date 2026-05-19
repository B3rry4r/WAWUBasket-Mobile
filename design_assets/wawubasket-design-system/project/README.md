# WAWUBasket Design System

> A monochrome-first, premium, calm marketplace experience. Black, white, generous whitespace, rounded floating surfaces, and a single sanctioned set of status accents.

## What WAWUBasket is

WAWUBasket is a multi-role marketplace platform (with an emphasis on food / fresh-goods ordering). The same product is used by three audiences:

- **Customers** — browse vendors, order food and fresh produce, track delivery.
- **Vendors** — manage their store, products, orders, revenue.
- **Riders** — pick up and deliver orders, track earnings.

All three share one product feeling: minimal, premium, fast, clean, calm, modern, highly organized, lightweight, **black & white first**.

The design fingerprint — what makes the product recognizable even without a logo — comes from:

- monochrome grayscale hierarchy
- generous, intentional whitespace
- rounded floating cards & navigation
- thin, outline, monochrome iconography
- consistent Inter typography
- soft, single-layer shadows
- pill-shaped primary CTAs

It should feel like a modern premium consumer app (think marketplace + fintech), **not** a traditional enterprise dashboard.

## Sources

This system was generated from a written product brief titled *"WAWUBASKET — UI/UX Design System & Product Experience Guide"*. **No Figma, codebase, or visual asset files were attached.** All visual decisions (logos, icons, illustrations, layouts) are first-principles translations of the brief and should be treated as a v1 to iterate against real materials when they are available.

If you have:

- a Figma library → please attach it; we'll re-derive components from the source of truth.
- a codebase → import it so we can match exact tokens, paths, and component implementations.
- existing logo / illustration files → drop them into `assets/` (current logo is a placeholder wordmark).

---

## CONTENT FUNDAMENTALS

Copy in WAWUBasket is **short, warm, and direct**. It speaks like a thoughtful concierge — not a cheerful mascot, not a corporate voice.

**Voice & tone**

- **Calm and confident.** No exclamation marks, no urgency tactics, no hype words ("amazing!", "incredible!"). The product is premium because it doesn't have to shout.
- **Personal but not chummy.** Address the user by first name in greetings ("Good evening, David"). Use **"you"**; never use **"we"** marketing-speak in the product itself.
- **Plain English.** Prefer the shortest correct word. "Delivery" not "logistics". "Add" not "Add to basket".
- **Action-led.** Buttons are verbs in title case: **Add**, **Checkout**, **Confirm order**, **Track order**.
- **Quiet about errors.** Errors are short, factual, and offer the next step. "Card declined. Try another payment method." — not "Oops! Something went wrong 😱".

**Casing**

- **Title Case** for buttons, tab labels, section titles, and page titles. ("Popular Near You", "Confirm Order", "Order Tracking")
- **Sentence case** for body copy, descriptions, and helper text.
- **UPPERCASE** is reserved for small labels (11px) with letter-spacing — category eyebrows, status pills, micro-tags.

**Emoji**

- **No emoji in product UI.** Emoji are explicitly off-brand. They break the monochrome fingerprint and feel cartoonish.
- Status is communicated through type, the four sanctioned status colors, and outline icons — never through 🎉 / ✅ / ⚠️.

**Example copy patterns**

| Context | Do | Don't |
|---|---|---|
| Greeting | Good evening, David | Hey there! 👋 Welcome back!! |
| Empty cart | Your basket is empty. | Oh no, nothing here yet! 😢 |
| CTA | Confirm order | Place my order now! → |
| Delivery ETA | Arrives in 25–35 min | Super fast delivery 🚀 |
| Error | Card declined. Try another payment method. | Oops! Something went wrong. |
| Section header | Popular Near You | 🔥 Trending in your area |

**Numbers and prices**

- Always show currency symbol attached: `₦4,500` (no space).
- Use thousands separators. Avoid `.00` on whole amounts unless the rest of the screen also shows decimals.
- ETAs are ranges, not points: "25–35 min".
- Ratings are one decimal: `4.8` (never `4.80`).

---

## VISUAL FOUNDATIONS

### Color

- **Monochrome first.** The entire interface lives on a black → white grayscale. See `colors_and_type.css` for the eight gray tokens (4 background, 5 text, 4 surface).
- **Accents are reserved for status only.** Success / Error / Warning / Info — and nothing else. There is no brand accent color. If a screen needs visual interest, solve it with **scale, weight, and whitespace**, not color.
- **Imagery vibe.** Photos in cards (vendor headers, product shots) are full-color, but the chrome around them is monochrome — so photos become the only color on the screen and read as the content.

### Typography

- One family only: **Inter**, with **SF Pro Display** as the iOS-native fallback.
- Weights used: 400 / 500 / 600 / 700. No italics, no all-caps for body, no condensed.
- Tracking is tightened on display sizes (`-0.02em` on hero, `-0.015em` on page) and opened slightly on the 11px label (`+0.04em` + uppercase).
- Line-height is generous — 1.5 on body, 1.15–1.25 on headlines — to create the "breathing" feel.

### Spacing

- Strict **8pt grid**: 4 / 8 / 16 / 24 / 32 / 48. Half-steps (e.g. 12, 20) are *not* tokens; use 8 or 16 instead.
- **Horizontal safe area on mobile is always 20px.** Nothing touches the screen edge.
- Cards have 24px internal padding (`--space-lg`). Section gaps are 32px (`--space-xl`).

### Backgrounds

- Solid `#FFFFFF` for primary screens. Use `#F7F7F7` as a backdrop when floating cards need to read as "lifted".
- **No gradients.** Not for buttons, not for hero banners, not for splash screens. If depth is needed, it comes from elevation (shadow) and color contrast (dark surface on light bg), never from a gradient.
- **No textures, patterns, or repeating motifs.** The brand is restful — visual noise is the enemy.
- **No full-bleed hand-drawn illustrations on production screens.** Illustrations are reserved for empty states, onboarding, and category headers, and they follow the minimal-line / monochrome style.

### Borders

- **No borders by default.** Surfaces are separated by background color steps (`#FFFFFF` card on `#F7F7F7` bg) and soft shadow, not by 1px strokes.
- When a hairline is necessary (table rows, list dividers), use `#E4E4E4` at 1px.
- Inputs use a `transparent` border that becomes `--fg-primary` (1px) on focus — no thick rings, no glow.

### Shadows

- One shadow system, **always soft, always single-layer**:
  - `--shadow-card`: `0 4px 16px rgba(0,0,0,0.04)` — resting cards.
  - `--shadow-float`: `0 8px 24px rgba(0,0,0,0.06)` — floating search bars, sticky CTAs.
  - `--shadow-nav`: `0 12px 32px rgba(0,0,0,0.08)` — the floating bottom nav.
- **Forbidden**: layered shadows, dark/black shadows, inner shadows, drop-shadow filters.

### Corner radius

The radius system is the single biggest fingerprint:

- Buttons & inputs: **16px**
- Cards: **24px**
- Bottom sheets: **32px**
- Floating elements (pill nav, primary CTAs, chips, tags): **999px**

Mixing radii **within the same component** is forbidden — if a card contains a button, the card is 24, the button is 16 or 999, but never something in between.

### Motion

- Easing: a single custom curve, `cubic-bezier(0.32, 0.72, 0, 1)` — soft-out, no overshoot, no bounce.
- Durations: 120ms (fast tap), 220ms (default transition), 360ms (sheet / page transition).
- Allowed: fade, scale (0.96 → 1.0), smooth slide-up for sheets, cross-fade for tabs.
- Forbidden: bounce, elastic, spring overshoot, rotate, color-shift transitions, parallax.

### Hover & press states

- **Hover (web)**: lift a card with `--shadow-float` (no scale, no color shift). Buttons darken one step.
- **Press**: scale to `0.98` with `--dur-fast`. No color change. No haptic-mimicking flash.
- **Disabled**: text drops to `--fg-disabled` (`#A0A0A0`), no opacity hack, no strikethrough.
- **Focus (a11y)**: 1px solid `--fg-primary` outline at 2px offset. Never the browser default blue ring.

### Transparency & blur

- Used sparingly. The two places blur is allowed:
  1. The bottom nav over a scrolling list — `backdrop-filter: blur(20px)` over `rgba(255,255,255,0.8)`.
  2. The sticky add-to-cart bar on Product Details — same treatment.
- Sheets and modals use opaque white, never frosted.

### Imagery

- Product photos: square or 4:3, **24px radius**, full color, slightly desaturated (the brand prefers calm color over saturated food porn).
- Maps in order tracking are **grayscale** — strip Mapbox / Google styling down to gray roads, no points of interest, no colored road shields.

### Cards

A WAWUBasket card is:
- `#FFFFFF` background, `24px` radius, `--shadow-card`.
- `24px` internal padding (or `16px` for compact list-style cards).
- **No border**. Float above `#F7F7F7` body bg.
- Image (if present) lives flush to the top-left/top-right inside the card padding, with its own 16px radius — never breaking out of the card.

---

## ICONOGRAPHY

WAWUBasket uses **one icon system, used everywhere**: outline, rounded, thin stroke, monochrome.

- **Library: [Lucide](https://lucide.dev/)** — pulled from CDN. Lucide matches the brief's "outline / rounded / thin stroke" requirement and ships every icon needed by the customer / vendor / rider flows.
- **Stroke width**: 1.5px (Lucide default is 2px — we override to 1.5 to keep icons feeling lightweight). Stroke linecap and linejoin are `round`.
- **Sizes**: 16px (inline with secondary text), 20px (inline with body), 24px (nav, buttons, list items), 28px (vendor card headers).
- **Color**: icons inherit `currentColor`. Active nav icon is `--fg-primary`; inactive nav icon is `--fg-placeholder`. There are no two-tone or colored icons.
- **No mixing.** Lucide only. Do not introduce Heroicons, Feather, Material, Phosphor, or emoji icons alongside.

**Emoji policy** — emoji are not used as icons or as decorative content anywhere in product UI. This is non-negotiable; it breaks the monochrome fingerprint.

**Unicode characters as icons** — avoid. The one exception is `→` in inline "Read more →" links, which is part of the type, not an icon.

**Illustrations** (empty states, onboarding, category headers) follow the same rules: monochrome, 1.5px stroke, outline, rounded. They are line-only, not filled. Stored in `assets/illustrations/` when generated.

---

## Index

Root files:

- `README.md` — this file
- `colors_and_type.css` — design tokens (colors, type, spacing, radius, shadow, motion) and core primitive classes (`.wb-card`, `.wb-input`, `.wb-btn`, `.wb-tag`)
- `SKILL.md` — Claude-Code-compatible skill manifest

Folders:

- `assets/` — logo, illustrations, raw visual assets
- `preview/` — design-system card HTML files surfaced in the Design System tab
- `ui_kits/customer-app/` — mobile customer experience (home, search, vendor store, product, cart, checkout, tracking)
- `ui_kits/vendor-dashboard/` — vendor operational dashboard

To see the visual system at a glance, open the **Design System** tab in the project — it renders every card in `preview/` grouped by Type / Colors / Spacing / Components / Brand.
