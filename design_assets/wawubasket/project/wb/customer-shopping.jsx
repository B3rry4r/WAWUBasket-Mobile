// WAWUBasket — Customer Shopping Flow
// Search · Product Details · Cart · Checkout · Order Tracking

const _S = window; // shorthand for window-exported primitives
const TOK2 = window.W;
const PX = 20; // horizontal safe area

// ── Shared helpers ────────────────────────────────────────────
// Section label + "See all" link
function SectionHead({ title, action = 'See all', onAction }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
      <span style={{ fontSize: 18, fontWeight: 600, color: TOK2.fgH, letterSpacing: '-0.01em' }}>{title}</span>
      {action && <span style={{ fontSize: 13, fontWeight: 500, color: TOK2.fg2 }}>{action}</span>}
    </div>
  );
}

// Row separator
function Divider() {
  return <div style={{ height: 1, background: TOK2.divider }} />;
}

// Map placeholder — abstract monochrome street grid
function MapPlaceholder({ height = 220 }) {
  const W = 350, H = height;
  const blocks = [
    [0,0,110,90],[130,0,90,90],[240,0,110,90],
    [0,110,80,H-110],[100,110,120,H-110],[240,110,110,H-110],
  ];
  return (
    <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`}
         style={{ display:'block', background:'#EBEBEB' }}>
      {blocks.map(([x,y,w,h],i) => (
        <rect key={i} x={x} y={y} width={w} height={h} fill="#DEDEDE" />
      ))}
      {/* route */}
      <polyline points={`80,50 175,50 175,${H-40} 280,${H-40}`}
        fill="none" stroke="#111111" strokeWidth="2.5"
        strokeLinecap="round" strokeDasharray="10 6" />
      {/* destination */}
      <circle cx="280" cy={H-40} r="11" fill="#111111" />
      <circle cx="280" cy={H-40} r="4.5" fill="#FFFFFF" />
      {/* rider */}
      <circle cx="80" cy="50" r="18" fill="#FFFFFF" stroke="#D4D4D4" strokeWidth="1.5" />
      <circle cx="80" cy="50" r="12" fill="#BDBDBD" />
    </svg>
  );
}

// Product image placeholder
function ImgBox({ w, h, r = 16, label = '' }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: r, flexShrink: 0,
      background: `#DDDCDB`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <span style={{
        fontSize: 10, fontWeight: 500, color: '#9A9A9A',
        letterSpacing: '0.04em', textTransform: 'uppercase',
        textAlign: 'center', padding: '0 6px',
      }}>{label}</span>
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// SEARCH SCREEN
// ════════════════════════════════════════════════════════════
function SearchScreen() {
  const { Screen, BackChip } = window;
  const filters = ['All', 'Vendors', 'Dishes', 'Near me', '4.5+', 'Free delivery'];
  const recent = ['Jollof rice', 'Suya platter', 'Smoothies', 'Pasta'];
  const vendors = [
    { name: 'Mama Cass Kitchen', cuisine: 'Nigerian · Local', rating: 4.8, eta: '25–35 min', fee: '₦600', badge: 'Popular' },
    { name: 'The Daily Grain',   cuisine: 'Bowls · Healthy',  rating: 4.7, eta: '20–30 min', fee: 'Free'  },
  ];
  const dishes = [
    { name: 'Jollof rice & chicken', vendor: 'Mama Cass', price: '₦4,500' },
    { name: 'Garden bowl',            vendor: 'Daily Grain', price: '₦3,200' },
    { name: 'Suya platter',           vendor: 'Suya & Smoke', price: '₦4,800' },
  ];
  return (
    <Screen bg="#FFFFFF" height={1020}>
      <div style={{ padding: `12px ${PX}px 32px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Top bar */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <BackChip />
          <div style={{
            flex: 1, height: 52, background: TOK2.input, borderRadius: 16,
            padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12,
            border: '1px solid #D4D4D4',
          }}>
            <Icon name="search" size={20} color={TOK2.fgH} />
            <span style={{ fontSize: 16, color: TOK2.fgH, flex: 1 }}>Jollof rice</span>
            <Icon name="close" size={16} color={TOK2.fgPh} />
          </div>
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto',
          margin: `0 -${PX}px`, padding: `0 ${PX}px 4px`, scrollbarWidth: 'none' }}>
          {filters.map((f, i) => (
            <span key={f} style={{
              display: 'inline-flex', alignItems: 'center', height: 36,
              padding: '0 14px', borderRadius: 999, flexShrink: 0,
              background: i === 0 ? TOK2.dark : TOK2.bgSoft,
              color: i === 0 ? '#fff' : TOK2.fgH,
              fontSize: 13, fontWeight: 500,
            }}>{f}</span>
          ))}
        </div>

        {/* Recent searches */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <SectionHead title="Recent searches" action="Clear" />
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {recent.map(r => (
              <span key={r} style={{
                display: 'inline-flex', alignItems: 'center', gap: 8,
                padding: '8px 12px', borderRadius: 999, background: TOK2.bgSoft,
                fontSize: 13, fontWeight: 500, color: TOK2.fgH,
              }}>
                <Icon name="clock" size={14} color={TOK2.fgPh} />
                {r}
                <Icon name="close" size={12} color={TOK2.fgPh} />
              </span>
            ))}
          </div>
        </div>

        <Divider />

        {/* Vendors */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <SectionHead title="Vendors" />
          {vendors.map((v, i) => (
            <div key={i} style={{
              display: 'flex', gap: 14, alignItems: 'center',
              padding: 14, background: TOK2.bg, borderRadius: TOK2.r.card,
              boxShadow: TOK2.shadow.card,
            }}>
              <ImgBox w={72} h={72} r={16} label="vendor" />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
                <span style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH }}>{v.name}</span>
                <span style={{ fontSize: 12, color: TOK2.fg2 }}>{v.cuisine}</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: TOK2.fg2 }}>
                  <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3 }}>
                    <Icon name="star" size={12} color={TOK2.fgH} />
                    <b style={{ color: TOK2.fgH, fontWeight: 600 }}>{v.rating}</b>
                  </span>
                  <span>·</span><span>{v.eta}</span>
                  <span>·</span><span>{v.fee}</span>
                </div>
              </div>
              {v.badge && (
                <span style={{
                  padding: '5px 10px', borderRadius: 999, background: TOK2.bgSoft,
                  fontSize: 11, fontWeight: 600, color: TOK2.fgH,
                }}>{v.badge}</span>
              )}
            </div>
          ))}
        </div>

        <Divider />

        {/* Dishes */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          <SectionHead title="Dishes" />
          {dishes.map((d, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 14,
              padding: '14px 0',
              borderBottom: i < dishes.length - 1 ? `1px solid ${TOK2.divider}` : 'none',
            }}>
              <ImgBox w={56} h={56} r={12} label="dish" />
              <div style={{ flex: 1 }}>
                <span style={{ fontSize: 15, fontWeight: 500, color: TOK2.fgH }}>{d.name}</span>
                <div style={{ fontSize: 12, color: TOK2.fg2, marginTop: 2 }}>{d.vendor}</div>
              </div>
              <span style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH }}>{d.price}</span>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// PRODUCT DETAILS SCREEN
// ════════════════════════════════════════════════════════════
function ProductScreen() {
  const { Screen } = window;
  return (
    <Screen bg="#FFFFFF" height={1060}>
      {/* Hero image */}
      <div style={{ height: 280, background: '#D9D8D7', position: 'relative', flexShrink: 0 }}>
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <span style={{ fontSize: 11, fontWeight: 500, color: '#8A8A8A', letterSpacing: '0.04em', textTransform: 'uppercase' }}>
            product photo
          </span>
        </div>
        {/* Controls */}
        <div style={{ position: 'absolute', top: 12, left: PX, right: PX, display: 'flex', justifyContent: 'space-between' }}>
          <button style={{
            width: 44, height: 44, borderRadius: 999, background: 'rgba(255,255,255,0.92)',
            border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="chevL" size={20} color={TOK2.fgH} />
          </button>
          <button style={{
            width: 44, height: 44, borderRadius: 999, background: 'rgba(255,255,255,0.92)',
            border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="heart" size={18} color={TOK2.fgH} />
          </button>
        </div>
        {/* Vendor badge */}
        <div style={{
          position: 'absolute', bottom: 16, left: PX,
          display: 'inline-flex', alignItems: 'center', gap: 8,
          padding: '6px 12px 6px 8px', borderRadius: 999,
          background: 'rgba(255,255,255,0.88)',
        }}>
          <span style={{ width: 22, height: 22, borderRadius: 999, background: TOK2.bgSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="home" size={12} color={TOK2.fgH} />
          </span>
          <span style={{ fontSize: 12, fontWeight: 600, color: TOK2.fgH }}>Mama Cass Kitchen</span>
        </div>
      </div>

      {/* Content */}
      <div style={{ flex: 1, padding: `20px ${PX}px 120px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Title + price */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
          <div style={{ flex: 1 }}>
            <h2 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: TOK2.fgH, letterSpacing: '-0.015em', lineHeight: 1.2 }}>
              Jollof rice &amp; grilled chicken
            </h2>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 8 }}>
              <Icon name="star" size={14} color={TOK2.fgH} />
              <span style={{ fontSize: 14, fontWeight: 600, color: TOK2.fgH }}>4.8</span>
              <span style={{ fontSize: 14, color: TOK2.fg2 }}>(2,481)</span>
            </div>
          </div>
          <span style={{ fontSize: 26, fontWeight: 600, color: TOK2.fgH, letterSpacing: '-0.02em', whiteSpace: 'nowrap' }}>
            ₦4,500
          </span>
        </div>

        {/* Meta row */}
        <div style={{ display: 'flex', gap: 16, fontSize: 13, color: TOK2.fg2 }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <Icon name="clock" size={14} color={TOK2.fgPh} /> 25–35 min
          </span>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <Icon name="bike" size={14} color={TOK2.fgPh} /> ₦600 delivery
          </span>
        </div>

        <Divider />

        {/* Description */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: TOK2.fg2, textTransform: 'uppercase', letterSpacing: '0.06em' }}>About</span>
          <p style={{ margin: 0, fontSize: 15, color: TOK2.fg2, lineHeight: 1.55 }}>
            Smoky party-style jollof rice slow-cooked over firewood, paired with charcoal-grilled chicken and fried plantain.
          </p>
        </div>

        {/* Options */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <span style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH }}>Protein</span>
            <span style={{ fontSize: 12, color: TOK2.fg2 }}>Choose one</span>
          </div>
          {[
            { label: 'Grilled chicken', sub: 'Included', selected: true },
            { label: 'Beef', sub: '+₦500', selected: false },
            { label: 'Fish', sub: '+₦800', selected: false },
          ].map((o, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '14px 16px', borderRadius: 16,
              background: o.selected ? TOK2.bg : TOK2.bgSoft,
              border: `1.5px solid ${o.selected ? TOK2.fgH : 'transparent'}`,
            }}>
              <span style={{
                width: 20, height: 20, borderRadius: 999, flexShrink: 0,
                background: o.selected ? TOK2.dark : TOK2.bg,
                border: `1.5px solid ${o.selected ? TOK2.dark : TOK2.divider}`,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {o.selected && <Icon name="check" size={11} stroke={2.5} color="#fff" />}
              </span>
              <span style={{ flex: 1, fontSize: 14, fontWeight: 500, color: TOK2.fgH }}>{o.label}</span>
              <span style={{ fontSize: 13, color: TOK2.fg2 }}>{o.sub}</span>
            </div>
          ))}
        </div>

        {/* Notes */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <span style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH }}>Notes <span style={{ fontWeight: 400, color: TOK2.fgPh }}>(optional)</span></span>
          <div style={{
            height: 52, background: TOK2.input, borderRadius: 16, border: '1px solid transparent',
            padding: '0 18px', display: 'flex', alignItems: 'center',
          }}>
            <span style={{ fontSize: 15, color: TOK2.fgPh }}>e.g. Extra spicy, no onions</span>
          </div>
        </div>

        {/* Qty */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH }}>Quantity</span>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 16,
            padding: '4px 4px', background: TOK2.bgSoft, borderRadius: 999,
          }}>
            <button style={{ width: 36, height: 36, borderRadius: 999, background: TOK2.bg, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="minus" size={14} stroke={2} color={TOK2.fgH} />
            </button>
            <span style={{ fontSize: 16, fontWeight: 600, color: TOK2.fgH, minWidth: 16, textAlign: 'center' }}>1</span>
            <button style={{ width: 36, height: 36, borderRadius: 999, background: TOK2.dark, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="plus" size={14} stroke={2} color="#fff" />
            </button>
          </div>
        </div>
      </div>

      {/* Sticky add bar */}
      <div style={{
        position: 'absolute', left: PX, right: PX, bottom: 28,
        background: TOK2.dark, borderRadius: 999, height: 56,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 8px 0 24px', zIndex: 10,
      }}>
        <span style={{ fontSize: 16, fontWeight: 500, color: '#fff' }}>Add to basket</span>
        <span style={{
          background: '#fff', color: TOK2.fgH, borderRadius: 999,
          padding: '8px 18px', fontSize: 15, fontWeight: 600,
        }}>₦4,500</span>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// CART SCREEN
// ════════════════════════════════════════════════════════════
function CartScreen() {
  const { Screen } = window;
  const items = [
    { name: 'Jollof rice & grilled chicken', note: 'Extra spicy', qty: 2, price: '₦9,000' },
    { name: 'Suya platter',                  qty: 1, price: '₦4,800' },
  ];
  return (
    <Screen bg="#F7F7F7" height={960}>
      <div style={{ padding: `16px ${PX}px 120px`, display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <h1 style={{ margin: 0, fontSize: 28, fontWeight: 600, color: TOK2.fgH, letterSpacing: '-0.02em' }}>Your basket</h1>
          <span style={{ fontSize: 13, color: TOK2.fg2, fontWeight: 500 }}>3 items</span>
        </div>

        {/* Vendor group */}
        <div style={{ background: TOK2.bg, borderRadius: TOK2.r.card, overflow: 'hidden', boxShadow: TOK2.shadow.card }}>
          {/* Vendor header */}
          <div style={{ padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 10, borderBottom: `1px solid ${TOK2.divider}` }}>
            <ImgBox w={36} h={36} r={8} />
            <div style={{ flex: 1 }}>
              <span style={{ fontSize: 14, fontWeight: 600, color: TOK2.fgH }}>Mama Cass Kitchen</span>
              <div style={{ fontSize: 12, color: TOK2.fg2, marginTop: 1 }}>Arrives in 25–35 min</div>
            </div>
          </div>
          {/* Items */}
          {items.map((it, i) => (
            <div key={i} style={{
              padding: '14px 16px', display: 'flex', gap: 12, alignItems: 'center',
              borderBottom: i < items.length - 1 ? `1px solid ${TOK2.divider}` : 'none',
            }}>
              <ImgBox w={60} h={60} r={12} label="food" />
              <div style={{ flex: 1, minWidth: 0 }}>
                <span style={{ fontSize: 14, fontWeight: 500, color: TOK2.fgH, lineHeight: 1.3 }}>{it.name}</span>
                {it.note && <div style={{ fontSize: 12, color: TOK2.fg2, marginTop: 2 }}>{it.note}</div>}
                <div style={{ fontSize: 14, fontWeight: 600, color: TOK2.fgH, marginTop: 6 }}>{it.price}</div>
              </div>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 10,
                padding: '4px 4px', background: TOK2.bgSoft, borderRadius: 999,
              }}>
                <button style={{ width: 28, height: 28, borderRadius: 999, background: TOK2.bg, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Icon name="minus" size={12} stroke={2} color={TOK2.fgH} />
                </button>
                <span style={{ fontSize: 14, fontWeight: 600, color: TOK2.fgH }}>{it.qty}</span>
                <button style={{ width: 28, height: 28, borderRadius: 999, background: TOK2.dark, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Icon name="plus" size={12} stroke={2} color="#fff" />
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Add more */}
        <button style={{
          width: '100%', height: 48, borderRadius: 999, border: `1px dashed ${TOK2.divider}`,
          background: 'transparent', cursor: 'pointer',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          fontSize: 14, fontWeight: 500, color: TOK2.fg2,
        }}>
          <Icon name="plus" size={16} color={TOK2.fg2} /> Add more items
        </button>

        {/* Promo code */}
        <div style={{
          display: 'flex', gap: 10, alignItems: 'center',
          padding: 4, background: TOK2.bg, borderRadius: 999,
          border: `1px solid ${TOK2.divider}`, boxShadow: TOK2.shadow.card,
        }}>
          <div style={{ flex: 1, height: 44, padding: '0 16px', display: 'flex', alignItems: 'center', gap: 10 }}>
            <Icon name="star" size={16} color={TOK2.fgPh} />
            <span style={{ fontSize: 14, color: TOK2.fgPh }}>Promo code</span>
          </div>
          <button style={{ height: 44, padding: '0 20px', borderRadius: 999, background: TOK2.dark, border: 'none', cursor: 'pointer', fontSize: 14, fontWeight: 500, color: '#fff' }}>
            Apply
          </button>
        </div>

        {/* Summary */}
        <div style={{ background: TOK2.bg, borderRadius: TOK2.r.card, padding: 20, boxShadow: TOK2.shadow.card }}>
          {[
            { label: 'Subtotal', value: '₦13,800' },
            { label: 'Delivery fee', value: '₦600' },
            { label: 'Service fee', value: '₦200' },
          ].map((r, i) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 14, color: TOK2.fg2, marginBottom: 12 }}>
              <span>{r.label}</span><span>{r.value}</span>
            </div>
          ))}
          <Divider />
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 17, fontWeight: 700, color: TOK2.fgH, marginTop: 14 }}>
            <span>Total</span><span>₦14,600</span>
          </div>
        </div>
      </div>

      {/* Sticky CTA */}
      <div style={{
        position: 'absolute', left: PX, right: PX, bottom: 28,
        background: TOK2.dark, borderRadius: 999, height: 56,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 8px 0 24px', zIndex: 10,
      }}>
        <span style={{ fontSize: 16, fontWeight: 500, color: '#fff' }}>Checkout</span>
        <span style={{ background: '#fff', color: TOK2.fgH, borderRadius: 999, padding: '8px 18px', fontSize: 15, fontWeight: 600 }}>
          ₦14,600
        </span>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// CHECKOUT SCREEN
// ════════════════════════════════════════════════════════════
function CheckoutScreen() {
  const { Screen, BackChip } = window;
  const payMethods = [
    { id: 'card',   label: 'Debit card',     sub: '•••• 4218', icon: 'card', selected: true },
    { id: 'wallet', label: 'Wallet',          sub: 'Balance ₦12,500', icon: 'star' },
    { id: 'xfer',   label: 'Bank transfer',   sub: 'Pay directly from app', icon: 'arrowR' },
    { id: 'mobile', label: 'Mobile money',    sub: 'OPay, Palmpay, others', icon: 'phone' },
  ];
  return (
    <Screen bg="#F7F7F7" height={1160}>
      <div style={{ padding: `12px ${PX}px 120px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <BackChip />
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: TOK2.fgH, letterSpacing: '-0.015em' }}>Checkout</h1>
        </div>

        {/* Section card helper */}
        {[
          {
            label: 'Delivery address',
            content: (
              <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
                <span style={{ width: 40, height: 40, borderRadius: 999, background: TOK2.bgSoft, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, marginTop: 2 }}>
                  <Icon name="pin" size={18} color={TOK2.fgH} />
                </span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH }}>2118 Thornridge Cir</div>
                  <div style={{ fontSize: 13, color: TOK2.fg2, marginTop: 2 }}>Surulere, Lagos · Apt 4B</div>
                </div>
                <span style={{ fontSize: 13, fontWeight: 500, color: TOK2.fgH }}>Change</span>
              </div>
            ),
          },
          {
            label: 'Delivery time',
            content: (
              <div style={{ display: 'flex', gap: 10 }}>
                {[
                  { id: 'now', label: 'Order now', sub: 'Arrives in 25–35 min', active: true },
                  { id: 'later', label: 'Schedule', sub: 'Pick a time slot', active: false },
                ].map(opt => (
                  <div key={opt.id} style={{
                    flex: 1, padding: 14, borderRadius: 16, cursor: 'pointer',
                    background: opt.active ? TOK2.dark : TOK2.bgSoft,
                    border: `1.5px solid ${opt.active ? TOK2.dark : 'transparent'}`,
                  }}>
                    <div style={{ fontSize: 14, fontWeight: 600, color: opt.active ? '#fff' : TOK2.fgH }}>{opt.label}</div>
                    <div style={{ fontSize: 12, color: opt.active ? 'rgba(255,255,255,0.65)' : TOK2.fg2, marginTop: 3 }}>{opt.sub}</div>
                  </div>
                ))}
              </div>
            ),
          },
          {
            label: 'Payment method',
            content: (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {payMethods.map(m => (
                  <div key={m.id} style={{
                    display: 'flex', alignItems: 'center', gap: 12,
                    padding: '12px 14px', borderRadius: 16,
                    background: m.selected ? TOK2.bg : TOK2.bgSoft,
                    border: `1.5px solid ${m.selected ? '#D4D4D4' : 'transparent'}`,
                  }}>
                    <span style={{ width: 38, height: 38, borderRadius: 999, background: TOK2.bgSoft, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <Icon name={m.icon} size={16} color={TOK2.fgH} />
                    </span>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 14, fontWeight: 500, color: TOK2.fgH }}>{m.label}</div>
                      <div style={{ fontSize: 12, color: TOK2.fg2, marginTop: 1 }}>{m.sub}</div>
                    </div>
                    <span style={{
                      width: 20, height: 20, borderRadius: 999,
                      background: m.selected ? TOK2.dark : 'transparent',
                      border: `1.5px solid ${m.selected ? TOK2.dark : TOK2.divider}`,
                      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      {m.selected && <Icon name="check" size={10} stroke={2.5} color="#fff" />}
                    </span>
                  </div>
                ))}
              </div>
            ),
          },
          {
            label: 'Order summary',
            content: (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {['Jollof rice × 2', 'Suya platter × 1'].map((it, i) => (
                  <div key={i} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 14, color: TOK2.fg2 }}>
                    <span>{it}</span>
                    <span style={{ color: TOK2.fgH, fontWeight: 500 }}>{i === 0 ? '₦9,000' : '₦4,800'}</span>
                  </div>
                ))}
                <Divider />
                {[['Delivery', '₦600'], ['Service fee', '₦200']].map(([l, v]) => (
                  <div key={l} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13, color: TOK2.fg2 }}>
                    <span>{l}</span><span>{v}</span>
                  </div>
                ))}
                <Divider />
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 16, fontWeight: 700, color: TOK2.fgH }}>
                  <span>Total</span><span>₦14,600</span>
                </div>
              </div>
            ),
          },
        ].map(sec => (
          <div key={sec.label} style={{ background: TOK2.bg, borderRadius: TOK2.r.card, padding: 18, boxShadow: TOK2.shadow.card, display: 'flex', flexDirection: 'column', gap: 14 }}>
            <span style={{ fontSize: 11, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase', color: TOK2.fgPh }}>{sec.label}</span>
            {sec.content}
          </div>
        ))}

        <p style={{ margin: 0, textAlign: 'center', fontSize: 12, color: TOK2.fgPh }}>
          By placing this order you agree to our{' '}
          <span style={{ color: TOK2.fgH, textDecoration: 'underline', textUnderlineOffset: 2 }}>Terms of Service</span>.
        </p>
      </div>

      {/* Sticky CTA */}
      <div style={{ position: 'absolute', left: PX, right: PX, bottom: 28, background: TOK2.dark, borderRadius: 999, height: 56, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 8px 0 24px', zIndex: 10 }}>
        <span style={{ fontSize: 16, fontWeight: 500, color: '#fff' }}>Place order</span>
        <span style={{ background: '#fff', color: TOK2.fgH, borderRadius: 999, padding: '8px 18px', fontSize: 15, fontWeight: 600 }}>₦14,600</span>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// ORDER TRACKING SCREEN
// ════════════════════════════════════════════════════════════
function TrackingScreen() {
  const { Screen, BackChip } = window;
  const steps = [
    { label: 'Order confirmed', time: '12:31', done: true },
    { label: 'Preparing your food', time: '12:34', done: true },
    { label: 'Rider on the way', time: 'Now', done: true, active: true },
    { label: 'Delivered', time: '', done: false },
  ];
  return (
    <Screen bg="#FFFFFF" height={960}>
      {/* Status hero */}
      <div style={{ padding: `12px ${PX}px 20px`, background: TOK2.dark }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <BackChip />
          <button style={{ background: 'transparent', border: 'none', cursor: 'pointer', fontSize: 14, fontWeight: 500, color: 'rgba(255,255,255,0.75)' }}>Support</button>
        </div>
        <div style={{ marginTop: 16, paddingBottom: 8 }}>
          <div style={{ fontSize: 13, fontWeight: 500, color: 'rgba(255,255,255,0.55)', letterSpacing: '0.04em', textTransform: 'uppercase' }}>Estimated arrival</div>
          <div style={{ fontSize: 48, fontWeight: 700, color: '#fff', letterSpacing: '-0.03em', lineHeight: 1.1 }}>12 min</div>
          <div style={{ fontSize: 14, color: 'rgba(255,255,255,0.65)', marginTop: 6 }}>Your food is on the way</div>
          {/* Progress bar */}
          <div style={{ height: 4, background: 'rgba(255,255,255,0.15)', borderRadius: 999, marginTop: 16 }}>
            <div style={{ width: '68%', height: '100%', background: '#fff', borderRadius: 999 }} />
          </div>
        </div>
      </div>

      {/* Map */}
      <div style={{ overflow: 'hidden' }}>
        <MapPlaceholder height={200} />
      </div>

      {/* Rider card */}
      <div style={{ padding: `0 ${PX}px`, marginTop: -20, position: 'relative', zIndex: 2 }}>
        <div style={{ background: TOK2.bg, borderRadius: TOK2.r.card, padding: '16px 18px', boxShadow: TOK2.shadow.float, display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{ width: 52, height: 52, borderRadius: 999, background: TOK2.bgSoft, flexShrink: 0, overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="user" size={24} color={TOK2.fgPh} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 16, fontWeight: 600, color: TOK2.fgH }}>Tunde Adeyemi</div>
            <div style={{ fontSize: 13, color: TOK2.fg2, marginTop: 2, display: 'flex', alignItems: 'center', gap: 4 }}>
              <Icon name="star" size={12} color={TOK2.fgH} />
              <b style={{ color: TOK2.fgH }}>4.9</b>
              <span>· 1,204 deliveries</span>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 10 }}>
            {['phone', 'msg'].map(ic => (
              <button key={ic} style={{ width: 44, height: 44, borderRadius: 999, background: TOK2.bgSoft, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={ic} size={18} color={TOK2.fgH} />
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Timeline */}
      <div style={{ padding: `20px ${PX}px 32px`, display: 'flex', flexDirection: 'column', gap: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: TOK2.fgH, marginBottom: 16 }}>Order progress</div>
        {steps.map((s, i) => (
          <div key={i} style={{ display: 'flex', gap: 14, position: 'relative', paddingBottom: i < steps.length - 1 ? 20 : 0 }}>
            {/* Vertical line */}
            {i < steps.length - 1 && (
              <div style={{ position: 'absolute', left: 13, top: 26, bottom: 0, width: 1.5, background: s.done ? TOK2.dark : TOK2.divider }} />
            )}
            {/* Dot */}
            <span style={{
              width: 28, height: 28, borderRadius: 999, flexShrink: 0,
              background: s.done ? TOK2.dark : (s.active ? TOK2.bgSoft : TOK2.bgSoft),
              border: s.active ? `2px solid ${TOK2.dark}` : 'none',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            }}>
              {s.done && !s.active && <Icon name="check" size={12} stroke={2.5} color="#fff" />}
              {s.active && <span style={{ width: 8, height: 8, borderRadius: 999, background: TOK2.dark }} />}
            </span>
            <div style={{ flex: 1, paddingTop: 4 }}>
              <span style={{ fontSize: 14, fontWeight: s.active ? 600 : 500, color: s.done ? TOK2.fgH : TOK2.fgDis }}>{s.label}</span>
              {s.time && <div style={{ fontSize: 12, color: TOK2.fg2, marginTop: 2 }}>{s.time}</div>}
            </div>
          </div>
        ))}
      </div>
    </Screen>
  );
}

Object.assign(window, {
  SearchScreen, ProductScreen, CartScreen, CheckoutScreen, TrackingScreen,
});
