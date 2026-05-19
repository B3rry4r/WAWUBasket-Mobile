// WAWUBasket Customer App — Screens
// Each screen returns the inner contents of an IOSDevice viewport.

const SCREEN_BG = '#F7F7F7';
const PADX = 20; // 20px horizontal safe area
const NAV_PAD_BOTTOM = 108; // space for floating bottom nav

// ── Mock data ───────────────────────────────────────────────
const CATEGORIES = [
  { id: 'all', label: 'All' },
  { id: 'rice', label: 'Rice' },
  { id: 'snacks', label: 'Snacks' },
  { id: 'drinks', label: 'Drinks' },
  { id: 'fast', label: 'Fast food' },
  { id: 'fruits', label: 'Fruits' },
  { id: 'veg', label: 'Vegetables' },
];

const VENDORS = [
  { id: 'v1', name: 'Mama Cass Kitchen', cuisine: 'Nigerian · Local', rating: 4.8, eta: '25–35 min', fee: '₦600', badge: 'Popular', accent: 'linear-gradient(135deg,#2a2a2a,#404040)' },
  { id: 'v2', name: 'The Daily Grain',  cuisine: 'Bowls · Healthy', rating: 4.7, eta: '20–30 min', fee: '₦500', badge: 'Free delivery', accent: 'linear-gradient(135deg,#3d3d3d,#1f1f1f)' },
  { id: 'v3', name: 'Suya & Smoke',     cuisine: 'Grill · Street food', rating: 4.9, eta: '30–40 min', fee: '₦700', accent: 'linear-gradient(135deg,#111,#3a3a3a)' },
];

const MENU = [
  { id: 'p1', name: 'Jollof rice & grilled chicken', desc: 'Smoky party-style jollof, charcoal-grilled chicken, fried plantain.', price: '₦4,500', accent: 'linear-gradient(135deg,#2a2a2a,#444)' },
  { id: 'p2', name: 'Egusi & pounded yam',            desc: 'Hand-pounded yam served with rich egusi soup and assorted meats.', price: '₦5,200', accent: 'linear-gradient(135deg,#3a3a3a,#1a1a1a)' },
  { id: 'p3', name: 'Plantain & beans',               desc: 'Soft beans porridge served with ripe fried plantain.',  price: '₦3,200', accent: 'linear-gradient(135deg,#4a4a4a,#222)' },
  { id: 'p4', name: 'Suya platter',                   desc: 'Char-grilled spiced beef strips, onions, fresh tomato salad.', price: '₦4,800', accent: 'linear-gradient(135deg,#2c2c2c,#0a0a0a)' },
];

// ═══════════════════════════════════════════════════════════
// HOME SCREEN
// ═══════════════════════════════════════════════════════════
function HomeScreen({ go, tab, setTab }) {
  return (
    <div style={{ background: SCREEN_BG, minHeight: '100%', position: 'relative' }}>
      <div style={{ padding: `12px ${PADX}px ${NAV_PAD_BOTTOM}px`, display: 'flex', flexDirection: 'column', gap: 24 }}>
        <GreetingHeader />
        <SearchBar onClick={() => go('search')} />

        {/* Categories */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <span style={{ fontSize: 20, fontWeight: 500, color: W.fgH, letterSpacing: '-0.01em' }}>Categories</span>
            <span style={{ fontSize: 13, color: W.fg2 }}>See all</span>
          </div>
          <div style={{ display: 'flex', gap: 10, overflowX: 'auto', margin: `0 -${PADX}px`, padding: `0 ${PADX}px` }}>
            {CATEGORIES.map((c, i) => <Tag key={c.id} active={i === 0}>{c.label}</Tag>)}
          </div>
        </div>

        {/* Featured */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <span style={{ fontSize: 20, fontWeight: 500, color: W.fgH, letterSpacing: '-0.01em' }}>Popular Near You</span>
            <span style={{ fontSize: 13, color: W.fg2 }}>See all</span>
          </div>
          <div style={{ display: 'flex', gap: 14, overflowX: 'auto', margin: `0 -${PADX}px`, padding: `4px ${PADX}px 8px` }}>
            {VENDORS.map(v => <VendorCard key={v.id} {...v} onClick={() => go('vendor')} />)}
          </div>
        </div>

        {/* Promo */}
        <div style={{
          background: W.dark, color: '#fff', borderRadius: W.r.card, padding: 24,
          display: 'flex', flexDirection: 'column', gap: 10,
        }}>
          <span style={{ fontSize: 11, fontWeight: 500, letterSpacing: '0.08em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.6)' }}>This week</span>
          <span style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.015em', lineHeight: 1.2 }}>Free delivery on<br/>orders over ₦5,000</span>
          <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.7)', marginTop: 4 }}>Until Sunday. No code needed.</span>
        </div>

        {/* Recommended vertical list */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <span style={{ fontSize: 20, fontWeight: 500, color: W.fgH, letterSpacing: '-0.01em' }}>Recommended</span>
          <VendorCard full {...VENDORS[1]} onClick={() => go('vendor')} />
        </div>
      </div>
      <BottomNav tab={tab} onChange={setTab} />
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// VENDOR SCREEN
// ═══════════════════════════════════════════════════════════
function VendorScreen({ go }) {
  const [filter, setFilter] = React.useState('All');
  const tabs = ['All', 'Mains', 'Sides', 'Drinks'];
  return (
    <div style={{ background: W.bg, minHeight: '100%' }}>
      {/* Vendor hero */}
      <div style={{ height: 260, background: 'linear-gradient(135deg,#111 0%,#3a3a3a 100%)', position: 'relative' }}>
        <div style={{
          position: 'absolute', top: 56, left: 20, width: 44, height: 44, borderRadius: 999,
          background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer',
        }} onClick={() => go('home')}>
          <Icon name="chevL" size={20} color={W.fgH} />
        </div>
        <div style={{
          position: 'absolute', top: 56, right: 20, width: 44, height: 44, borderRadius: 999,
          background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer',
        }}>
          <Icon name="heart" size={20} color={W.fgH} />
        </div>
      </div>

      {/* Vendor info card overlapping */}
      <div style={{ padding: `0 ${PADX}px`, marginTop: -36, position: 'relative', zIndex: 2 }}>
        <div style={{ background: W.bg, borderRadius: W.r.card, padding: 20, boxShadow: W.shadow.card, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div style={{ fontSize: 22, fontWeight: 600, color: W.fgH, letterSpacing: '-0.015em' }}>Mama Cass Kitchen</div>
          <div style={{ fontSize: 14, color: W.fg2 }}>Nigerian · Local · Lagos Island</div>
          <div style={{ display: 'flex', gap: 14, marginTop: 8, fontSize: 13, color: W.fg2 }}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <Icon name="star" size={14} color={W.fgH} /> <b style={{ color: W.fgH, fontWeight: 500 }}>4.8</b> <span>(2,481)</span>
            </span>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <Icon name="clock" size={14} /> 25–35 min
            </span>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <Icon name="bike" size={14} /> ₦600
            </span>
          </div>
        </div>
      </div>

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 10, overflowX: 'auto', padding: `24px ${PADX}px 8px` }}>
        {tabs.map(t => <Tag key={t} active={filter === t} onClick={() => setFilter(t)}>{t}</Tag>)}
      </div>

      {/* Menu */}
      <div style={{ padding: `8px ${PADX}px 32px` }}>
        <span style={{ fontSize: 18, fontWeight: 500, color: W.fgH, display: 'block', margin: '12px 0 4px' }}>Mains</span>
        {MENU.map(p => <ProductRow key={p.id} {...p} onAdd={() => go('product')} />)}
      </div>

      {/* Sticky basket bar */}
      <div style={{
        position: 'sticky', bottom: 24, margin: `0 ${PADX}px 24px`,
      }}>
        <Button full variant="primary" size="lg" onClick={() => go('cart')}
          style={{ justifyContent: 'space-between', padding: '0 24px' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 10 }}>
            <span style={{
              width: 26, height: 26, borderRadius: 999, background: 'rgba(255,255,255,0.18)',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 12, fontWeight: 600,
            }}>2</span>
            View basket
          </span>
          <span style={{ fontWeight: 500 }}>₦9,700</span>
        </Button>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// PRODUCT DETAILS
// ═══════════════════════════════════════════════════════════
function ProductScreen({ go }) {
  const [qty, setQty] = React.useState(1);
  return (
    <div style={{ background: W.bg, minHeight: '100%', paddingBottom: 120 }}>
      {/* Product image */}
      <div style={{ height: 380, background: 'linear-gradient(135deg,#2a2a2a 0%, #4a4a4a 100%)', position: 'relative' }}>
        <div style={{
          position: 'absolute', top: 56, left: 20, width: 44, height: 44, borderRadius: 999,
          background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer',
        }} onClick={() => go('vendor')}>
          <Icon name="chevL" size={20} color={W.fgH} />
        </div>
        <div style={{
          position: 'absolute', top: 56, right: 20, width: 44, height: 44, borderRadius: 999,
          background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer',
        }}>
          <Icon name="heart" size={20} color={W.fgH} />
        </div>
      </div>

      <div style={{ padding: `24px ${PADX}px 0`, display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 14 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <span style={{ fontSize: 24, fontWeight: 600, color: W.fgH, letterSpacing: '-0.015em' }}>Jollof rice & grilled chicken</span>
            <span style={{ fontSize: 14, color: W.fg2 }}>Mama Cass Kitchen</span>
          </div>
          <span style={{ fontSize: 22, fontWeight: 600, color: W.fgH }}>₦4,500</span>
        </div>

        <p style={{ fontSize: 15, lineHeight: 1.55, color: W.fg2, margin: 0 }}>
          Smoky party-style jollof rice cooked over open flame, served with a quarter charcoal-grilled chicken and a side of fried plantain. Comes with a side of coleslaw.
        </p>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 8 }}>
          <span style={{ fontSize: 16, fontWeight: 500, color: W.fgH }}>Quantity</span>
          <QtyStepper value={qty} onChange={setQty} />
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 12 }}>
          <span style={{ fontSize: 16, fontWeight: 500, color: W.fgH }}>Notes for the restaurant</span>
          <div style={{
            background: W.input, borderRadius: W.r.input, padding: 16,
            minHeight: 88, fontSize: 14, color: W.fgPh,
          }}>Less spicy please — and no onions on the side.</div>
        </div>
      </div>

      {/* Sticky add */}
      <div style={{
        position: 'fixed', left: 0, right: 0, bottom: 0,
        background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        padding: `16px ${PADX}px 36px`, boxShadow: '0 -8px 24px rgba(0,0,0,0.04)',
      }}>
        <Button full variant="primary" size="lg" onClick={() => go('cart')}
          style={{ justifyContent: 'space-between', padding: '0 24px' }}>
          <span>Add to basket</span>
          <span style={{ fontWeight: 500 }}>₦{(4500 * qty).toLocaleString()}</span>
        </Button>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// CART
// ═══════════════════════════════════════════════════════════
function CartScreen({ go }) {
  const items = [
    { name: 'Jollof rice & grilled chicken', qty: 1, price: 4500, accent: 'linear-gradient(135deg,#2a2a2a,#444)' },
    { name: 'Plantain & beans',              qty: 1, price: 3200, accent: 'linear-gradient(135deg,#444,#1a1a1a)' },
    { name: 'Chapman',                       qty: 2, price: 1000, accent: 'linear-gradient(135deg,#3a3a3a,#0e0e0e)' },
  ];
  const subtotal = items.reduce((s, i) => s + i.qty * i.price, 0);
  const delivery = 600;
  const total = subtotal + delivery;
  return (
    <div style={{ background: W.bg, minHeight: '100%', paddingBottom: 140 }}>
      <div style={{ padding: `12px ${PADX}px 0` }}>
        <ScreenHeader title="Your basket" onBack={() => go('vendor')}
          right={<Icon name="more" size={20} color={W.fgH} />} />

        <div style={{
          background: W.bg2, borderRadius: W.r.card, padding: 16,
          display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16,
        }}>
          <div style={{ width: 36, height: 36, borderRadius: 999, background: W.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="pin" size={18} color={W.fgH} />
          </div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
            <span style={{ fontSize: 13, color: W.fgPh }}>Deliver to</span>
            <span style={{ fontSize: 15, fontWeight: 500, color: W.fgH }}>12 Adeola Odeku St, VI</span>
          </div>
          <Icon name="chev" size={18} color={W.fg2} />
        </div>

        <div style={{ display: 'flex', flexDirection: 'column' }}>
          {items.map((it, i) => (
            <div key={i} style={{
              display: 'flex', gap: 14, alignItems: 'center',
              padding: '16px 0', borderBottom: `1px solid ${W.divider}`,
            }}>
              <div style={{ width: 64, height: 64, borderRadius: 16, background: it.accent }} />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4, minWidth: 0 }}>
                <span style={{ fontSize: 15, fontWeight: 500, color: W.fgH }}>{it.name}</span>
                <span style={{ fontSize: 14, color: W.fg2 }}>₦{it.price.toLocaleString()}</span>
              </div>
              <QtyStepper value={it.qty} />
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 24, fontSize: 14 }}>
          <Row label="Subtotal" value={`₦${subtotal.toLocaleString()}`} />
          <Row label="Delivery" value={`₦${delivery}`} />
          <div style={{ height: 1, background: W.divider, margin: '4px 0' }} />
          <Row label={<b style={{ color: W.fgH, fontWeight: 500 }}>Total</b>} value={<b style={{ color: W.fgH, fontWeight: 600, fontSize: 17 }}>₦{total.toLocaleString()}</b>} />
        </div>
      </div>

      <div style={{
        position: 'fixed', left: 0, right: 0, bottom: 0,
        background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(20px)',
        padding: `16px ${PADX}px 36px`, boxShadow: '0 -8px 24px rgba(0,0,0,0.04)',
      }}>
        <Button full variant="primary" size="lg" onClick={() => go('checkout')}>Checkout</Button>
      </div>
    </div>
  );
}
function Row({ label, value }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', color: W.fg2 }}>
      <span>{label}</span><span>{value}</span>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// CHECKOUT
// ═══════════════════════════════════════════════════════════
function CheckoutScreen({ go }) {
  return (
    <div style={{ background: W.bg, minHeight: '100%', paddingBottom: 140 }}>
      <div style={{ padding: `12px ${PADX}px 0` }}>
        <ScreenHeader title="Checkout" onBack={() => go('cart')} />

        <Section title="Delivery">
          <ListRow icon="pin" label="12 Adeola Odeku St, VI" sub="Add a note for the rider" />
          <ListRow icon="clock" label="As soon as possible" sub="25–35 min" />
        </Section>

        <Section title="Payment">
          <ListRow icon="card" label="•••• 4242" sub="Visa · Default" />
        </Section>

        <Section title="Summary">
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, padding: '4px 4px' }}>
            <Row label="Subtotal" value="₦9,700" />
            <Row label="Delivery" value="₦600" />
            <Row label="Service fee" value="₦200" />
            <div style={{ height: 1, background: W.divider, margin: '4px 0' }} />
            <Row label={<b style={{ color: W.fgH, fontWeight: 500 }}>Total</b>} value={<b style={{ color: W.fgH, fontWeight: 600, fontSize: 17 }}>₦10,500</b>} />
          </div>
        </Section>
      </div>

      <div style={{
        position: 'fixed', left: 0, right: 0, bottom: 0,
        background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(20px)',
        padding: `16px ${PADX}px 36px`, boxShadow: '0 -8px 24px rgba(0,0,0,0.04)',
      }}>
        <Button full variant="primary" size="lg" onClick={() => go('track')}>Confirm order · ₦10,500</Button>
      </div>
    </div>
  );
}
function Section({ title, children }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 20 }}>
      <span style={{ fontSize: 11, fontWeight: 500, letterSpacing: '0.08em', textTransform: 'uppercase', color: W.fgPh }}>{title}</span>
      <div style={{ background: W.bg2, borderRadius: W.r.card, padding: 6, display: 'flex', flexDirection: 'column' }}>
        {children}
      </div>
    </div>
  );
}
function ListRow({ icon, label, sub }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14, padding: 14,
    }}>
      <div style={{ width: 40, height: 40, borderRadius: 999, background: W.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={icon} size={18} color={W.fgH} />
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <span style={{ fontSize: 15, fontWeight: 500, color: W.fgH }}>{label}</span>
        <span style={{ fontSize: 13, color: W.fg2 }}>{sub}</span>
      </div>
      <Icon name="chev" size={18} color={W.fg2} />
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// ORDER TRACKING
// ═══════════════════════════════════════════════════════════
function TrackingScreen({ go }) {
  return (
    <div style={{ background: W.bg, minHeight: '100%', position: 'relative' }}>
      {/* Grayscale map */}
      <div style={{
        height: 380, position: 'relative',
        background: '#EFEFEF',
        backgroundImage: `
          linear-gradient(0deg, transparent 24%, rgba(0,0,0,0.04) 25%, rgba(0,0,0,0.04) 26%, transparent 27%, transparent 74%, rgba(0,0,0,0.04) 75%, rgba(0,0,0,0.04) 76%, transparent 77%),
          linear-gradient(90deg, transparent 24%, rgba(0,0,0,0.04) 25%, rgba(0,0,0,0.04) 26%, transparent 27%, transparent 74%, rgba(0,0,0,0.04) 75%, rgba(0,0,0,0.04) 76%, transparent 77%)
        `,
        backgroundSize: '60px 60px',
        overflow: 'hidden',
      }}>
        {/* Roads */}
        <div style={{ position: 'absolute', inset: 0 }}>
          <svg width="100%" height="100%" viewBox="0 0 400 380" preserveAspectRatio="none">
            <path d="M-10 200 Q 100 180 200 220 T 410 250" stroke="#D8D8D8" strokeWidth="14" fill="none" />
            <path d="M-10 200 Q 100 180 200 220 T 410 250" stroke="#FFFFFF" strokeWidth="2" fill="none" strokeDasharray="6 8" />
            <path d="M150 -10 Q 180 100 230 200 T 280 410" stroke="#D8D8D8" strokeWidth="10" fill="none" />
            {/* Route */}
            <path d="M60 320 Q 140 270 200 220 T 340 90" stroke="#111111" strokeWidth="3" fill="none" strokeLinecap="round" />
          </svg>
        </div>
        {/* Pickup pin */}
        <div style={{ position: 'absolute', left: 50, bottom: 50, width: 20, height: 20, borderRadius: 999, background: '#fff', boxShadow: '0 0 0 4px #111', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ width: 6, height: 6, background: '#111', borderRadius: 999 }} />
        </div>
        {/* Destination pin */}
        <div style={{ position: 'absolute', right: 50, top: 70, width: 32, height: 32, borderRadius: 999, background: W.dark, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 12px rgba(0,0,0,0.2)' }}>
          <Icon name="pin" size={16} color="#fff" />
        </div>
        {/* Back btn */}
        <div style={{
          position: 'absolute', top: 56, left: 20, width: 44, height: 44, borderRadius: 999,
          background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer', boxShadow: W.shadow.card,
        }} onClick={() => go('home')}>
          <Icon name="chevL" size={20} color={W.fgH} />
        </div>
      </div>

      {/* Bottom sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, background: W.bg,
        borderTopLeftRadius: W.r.sheet, borderTopRightRadius: W.r.sheet,
        padding: `28px ${PADX}px 40px`, boxShadow: '0 -8px 24px rgba(0,0,0,0.06)',
      }}>
        <div style={{ width: 40, height: 4, borderRadius: 999, background: W.divider, margin: '0 auto 22px' }} />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 4, marginBottom: 18 }}>
          <StatusPill kind="info">On the way</StatusPill>
          <span style={{ fontSize: 24, fontWeight: 600, color: W.fgH, letterSpacing: '-0.015em', marginTop: 10 }}>Arrives in 12 min</span>
          <span style={{ fontSize: 14, color: W.fg2 }}>Order #WBK-48291 · Mama Cass Kitchen</span>
        </div>

        {/* Rider card */}
        <div style={{
          background: W.bg2, borderRadius: W.r.card, padding: 16,
          display: 'flex', alignItems: 'center', gap: 14, marginBottom: 18,
        }}>
          <div style={{ width: 48, height: 48, borderRadius: 999, background: 'linear-gradient(135deg,#3a3a3a,#1a1a1a)' }} />
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
            <span style={{ fontSize: 15, fontWeight: 500, color: W.fgH }}>Tunde · Rider</span>
            <span style={{ fontSize: 13, color: W.fg2 }}>Honda CG · LAG 4892</span>
          </div>
          <button style={{ width: 44, height: 44, borderRadius: 999, background: W.bg, border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: W.shadow.card, cursor: 'pointer' }}>
            <Icon name="msg" size={18} color={W.fgH} />
          </button>
          <button style={{ width: 44, height: 44, borderRadius: 999, background: W.dark, border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <Icon name="phone" size={18} color="#fff" />
          </button>
        </div>

        {/* Timeline */}
        <Timeline />
      </div>
    </div>
  );
}
function Timeline() {
  const steps = [
    { label: 'Order accepted', time: '7:42 PM', done: true },
    { label: 'Preparing',      time: '7:48 PM', done: true },
    { label: 'On the way',     time: '8:01 PM', done: true, active: true },
    { label: 'Delivered',      time: 'In 12 min', done: false },
  ];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      {steps.map((s, i) => (
        <div key={i} style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 0 }}>
            <div style={{
              width: 22, height: 22, borderRadius: 999,
              background: s.done ? W.dark : W.bg,
              boxShadow: s.done ? 'none' : `inset 0 0 0 1.5px ${W.divider}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              {s.done && <Icon name="check" size={12} stroke={2.5} color="#fff" />}
            </div>
            {i < steps.length - 1 && <div style={{
              width: 2, flex: 1, minHeight: 30,
              background: s.done ? W.dark : W.divider,
            }} />}
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', flex: 1, paddingBottom: 14, paddingTop: 0 }}>
            <span style={{ fontSize: 15, fontWeight: s.active ? 500 : 400, color: s.done ? W.fgH : W.fgPh }}>{s.label}</span>
            <span style={{ fontSize: 13, color: W.fg2 }}>{s.time}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

Object.assign(window, {
  HomeScreen, VendorScreen, ProductScreen, CartScreen, CheckoutScreen, TrackingScreen,
});
