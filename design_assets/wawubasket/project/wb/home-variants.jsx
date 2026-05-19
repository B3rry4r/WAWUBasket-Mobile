// WAWUBasket — Customer Home Screen variants
// Three layouts modeled on the brief + reference image. All monochrome, with
// food photography as the only color anchor (per design-system imagery rules).

// ─── Shared tokens (mirrors colors_and_type.css) ─────────────
const TOK = window.W; // from components.jsx
const PADX = 20;
const SCREEN_BG = '#FFFFFF';

// Real food imagery (Unsplash, lightly cropped/desaturated by URL params)
const IMG = {
  burger: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80&auto=format&fit=crop',
  pizza: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80&auto=format&fit=crop',
  bowl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500&q=80&auto=format&fit=crop',
  pasta: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500&q=80&auto=format&fit=crop',
  salad: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80&auto=format&fit=crop',
  sushi: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80&auto=format&fit=crop',
  drink: 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?w=500&q=80&auto=format&fit=crop',
  ramen: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80&auto=format&fit=crop',
  taco: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&q=80&auto=format&fit=crop',
  jollof: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500&q=80&auto=format&fit=crop',
  grill: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80&auto=format&fit=crop',
  vendor1: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500&q=80&auto=format&fit=crop',
  vendor2: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&q=80&auto=format&fit=crop',
  vendor3: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80&auto=format&fit=crop',
  avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80&auto=format&fit=crop&crop=faces'
};

// ════════════════════════════════════════════════════════════
// DS VENDOR CARD — exact spec from preview/components-card.html
// Inset photo · frosted brand pill · ETA medallion · hairline footer
// ════════════════════════════════════════════════════════════
function DSVendorCard({ name, shortName, cuisine, rating, reviews, etaMins, fee, tags = [], img }) {
  return (
    <div style={{
      width: 300, flexShrink: 0,
      background: '#FFFFFF',
      borderRadius: 28,
      boxShadow: '0 6px 20px rgba(0,0,0,0.05), 0 1px 2px rgba(0,0,0,0.03)',
      padding: 12,
      display: 'flex', flexDirection: 'column',
      position: 'relative',
      fontFamily: 'Inter, -apple-system, sans-serif'
    }}>
      {/* ── Inset photo — 18px radius, inside the 12px card padding ── */}
      <div style={{
        height: 132, borderRadius: 18, overflow: 'hidden', position: 'relative',
        background: img ?
        `url(${img}) center / cover` :
        'linear-gradient(135deg, #2a2a2a 0%, #424242 60%, #1a1a1a 100%)'
      }}>
        {/* Frosted glass brand pill — top left */}
        <div style={{
          position: 'absolute', top: 14, left: 14,
          height: 28, padding: '0 10px 0 6px',
          background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(14px)', WebkitBackdropFilter: 'blur(14px)',
          borderRadius: 999,
          display: 'inline-flex', alignItems: 'center', gap: 6,
          color: '#fff', fontSize: 11, fontWeight: 500
        }}>
          <span style={{ width: 18, height: 18, borderRadius: 999, background: 'rgba(255,255,255,0.92)', flexShrink: 0, display: 'block' }} />
          {shortName || name}
        </div>
        {/* Heart — top right */}
        <div style={{
          position: 'absolute', top: 14, right: 14,
          width: 32, height: 32, borderRadius: 999,
          background: 'rgba(255,255,255,0.94)',
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
          stroke="#1A1A1A" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z" />
          </svg>
        </div>
      </div>

      {/* ── ETA medallion — straddles photo bottom / info top ── */}
      {/* top: 120 = card padding(12) + photo height(132) - 24 overlap, absolute on card */}
      <div style={{
        position: 'absolute', right: 24, top: 120,
        width: 56, height: 56, borderRadius: 999,
        background: '#111111', color: '#fff',
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 8px 18px rgba(0,0,0,0.18), 0 0 0 4px #FFFFFF',
        fontVariantNumeric: 'tabular-nums'
      }}>
        <span style={{ fontSize: 17, fontWeight: 600, lineHeight: 1, letterSpacing: '-0.02em' }}>{etaMins}</span>
        <span style={{ fontSize: 9, opacity: 0.7, marginTop: 3, letterSpacing: '0.06em', textTransform: 'uppercase' }}>min</span>
      </div>

      {/* ── Info block ── */}
      <div style={{ padding: '16px 6px 4px', display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ fontSize: 17, fontWeight: 500, color: '#1A1A1A', letterSpacing: '-0.005em' }}>{name}</div>
        <div style={{ fontSize: 13, color: '#4A4A4A' }}>{cuisine}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 8, fontSize: 13, color: '#4A4A4A' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: '#1A1A1A', fontWeight: 500 }}>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="#1A1A1A">
              <polygon points="12 3 14.7 9.3 21.5 9.8 16.3 14.2 18 21 12 17.3 6 21 7.7 14.2 2.5 9.8 9.3 9.3" />
            </svg>
            {rating}
          </span>
          <span style={{ color: '#7A7A7A' }}>({reviews})</span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: '#C7C7C7', flexShrink: 0 }} />
          <span>{fee} delivery</span>
        </div>
      </div>

      {/* ── Hairline footer ── */}
      <div style={{
        marginTop: 14, padding: '12px 6px 2px',
        borderTop: '1px solid #EFEFEF',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between'
      }}>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {tags.map((t, i) =>
          <span key={i} style={{
            fontSize: 11, fontWeight: 500, color: '#4A4A4A',
            padding: '5px 9px', borderRadius: 999, background: '#F4F4F4'
          }}>{t}</span>
          )}
        </div>
        <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 6,
          fontSize: 12, fontWeight: 500, color: '#1A1A1A', whiteSpace: 'nowrap', marginLeft: 8
        }}>
          View menu
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
          stroke="#1A1A1A" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
            <path d="M5 12h14" /><path d="M13 6l6 6-6 6" />
          </svg>
        </span>
      </div>
    </div>);

}

// ════════════════════════════════════════════════════════════
// DS BOTTOM NAV — exact spec from preview/components-bottomnav.html
// White pill · 5 items · soft shadow · 10px labels
// ════════════════════════════════════════════════════════════
function DSBottomNav({ active = 'home' }) {
  const items = [
  { id: 'home', label: 'Home',
    path: 'M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1z' },
  { id: 'search', label: 'Search',
    path: 'M21 21l-4.3-4.3 M11 18a7 7 0 1 1 0-14 7 7 0 0 1 0 14z' },
  { id: 'orders', label: 'Orders',
    path: 'M3 6h18l-2 13a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2z M9 10V6a3 3 0 0 1 6 0v4' },
  { id: 'favs', label: 'Favorites',
    path: 'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z' },
  { id: 'profile', label: 'Profile',
    path: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8z M4 21a8 8 0 0 1 16 0' }];

  return (
    <div style={{
      position: 'absolute', left: 16, right: 16, bottom: 8,
      background: '#FFFFFF', borderRadius: 999,
      boxShadow: '0 12px 32px rgba(0,0,0,0.08)',
      padding: '8px 18px',
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      zIndex: 30
    }}>
      {items.map((it) => {
        const isActive = it.id === active;
        return (
          <div key={it.id} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            padding: '6px 10px', cursor: 'pointer',
            color: isActive ? '#111111' : '#7A7A7A'
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              {it.path.split(' M').map((seg, i) =>
              <path key={i} d={(i ? 'M' : '') + seg} />
              )}
            </svg>
            <span style={{ fontSize: 10, fontWeight: 500, letterSpacing: '0.02em' }}>{it.label}</span>
          </div>);

      })}
    </div>);

}

// ════════════════════════════════════════════════════════════
// VARIANT 1 — "Hungry? Order & Eat" hero (matches reference)
// ════════════════════════════════════════════════════════════
function HomeV1() {
  const cats = [
  { id: 'drinks', label: 'Drinks', img: IMG.drink },
  { id: 'all', label: 'All', img: IMG.salad, active: true },
  { id: 'burger', label: 'Burger', img: IMG.burger },
  { id: 'pizza', label: 'Pizza', img: IMG.pizza },
  { id: 'sushi', label: 'Sushi', img: IMG.sushi }];

  const featured = [
  { name: 'McChicken Burger', vendor: "McDonald's", price: '$13', img: IMG.burger, dot: '#D7282F' },
  { name: 'Pepperoni Pizza', vendor: "Domino's Pizza", price: '$19', img: IMG.pizza, dot: '#0066B3' }];

  return (
    <div style={{ background: SCREEN_BG, minHeight: '100%', position: 'relative', paddingTop: 56 }}>
      <div style={{ padding: `12px ${PADX}px 140px`, display: 'flex', flexDirection: 'column', gap: 22 }}>
        {/* ── Header row ── */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, minWidth: 0 }}>
            <div style={{
              width: 44, height: 44, borderRadius: 999, overflow: 'hidden', flexShrink: 0,
              background: TOK.bgSoft, backgroundImage: `url(${IMG.avatar})`, backgroundSize: 'cover', backgroundPosition: 'center'
            }} />
            <div style={{ display: 'flex', flexDirection: 'column', minWidth: 0 }}>
              <span style={{ fontSize: 17, fontWeight: 600, color: TOK.fgH, letterSpacing: '-0.01em' }}>Hi, Brooks</span>
              <span style={{ fontSize: 12, color: TOK.fgPh, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                2118 Thornridge Cir, Syra…
              </span>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 10 }}>
            <IconBtn icon="bell" badge />
            <IconBtn icon="basket" />
          </div>
        </div>

        {/* ── Hero ── */}
        <div style={{ marginTop: 4, lineHeight: 1.1, letterSpacing: '-0.025em' }}>
          <span style={{ fontSize: 32, fontWeight: 700, color: TOK.fgH }}>Hungry? </span>
          <span style={{ fontSize: 32, fontWeight: 400, color: TOK.fgPh }}>Order &amp; Eat</span>
        </div>

        {/* ── Search + filter ── */}
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{
            flex: 1, height: 52, background: TOK.bg, borderRadius: TOK.r.input,
            padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12,
            boxShadow: TOK.shadow.float
          }}>
            <Icon name="search" size={20} color={TOK.fgPh} />
            <span style={{ color: TOK.fgPh, fontSize: 15 }}>Search for foods…</span>
          </div>
          <button style={{
            width: 52, height: 52, borderRadius: 999, background: TOK.dark, border: 'none',
            display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
            boxShadow: TOK.shadow.float
          }}>
            <Icon name="filter" size={20} color="#fff" />
          </button>
        </div>

        {/* ── Category circles ── */}
        <div style={{
          display: 'flex', gap: 18, overflowX: 'auto',
          margin: `4px -${PADX}px -8px`, padding: `8px ${PADX}px 16px`,
          scrollbarWidth: 'none'
        }}>
          {cats.map((c) =>
          <div key={c.id} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, flexShrink: 0, width: 64,
            position: 'relative'
          }}>
              <div style={{
              width: 56, height: 56, borderRadius: 999, overflow: 'hidden',
              background: `url(${c.img}) center/cover`, boxShadow: TOK.shadow.card,
              border: c.active ? `2px solid ${TOK.fgH}` : '2px solid transparent'
            }} />
              <span style={{
              fontSize: 13, fontWeight: c.active ? 600 : 400,
              color: c.active ? TOK.fgH : TOK.fg2
            }}>{c.label}</span>
              {c.active && <span style={{
              width: 16, height: 2, borderRadius: 999, background: TOK.fgH, marginTop: -4
            }} />}
            </div>
          )}
        </div>

        {/* ── Featured floating cards ── */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
          {featured.map((f, i) =>
          <div key={i} style={{
            background: TOK.bg, borderRadius: TOK.r.card, padding: 12,
            boxShadow: TOK.shadow.float, display: 'flex', flexDirection: 'column', gap: 10
          }}>
              <div style={{
              aspectRatio: '1 / 1', borderRadius: 18, overflow: 'hidden',
              background: `url(${f.img}) center/cover`
            }} />
              <div style={{ padding: '0 4px 4px', display: 'flex', flexDirection: 'column', gap: 6 }}>
                <span style={{ fontSize: 14, fontWeight: 600, color: TOK.fgH, lineHeight: 1.25 }}>{f.name}</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                  <span style={{
                  width: 12, height: 12, borderRadius: 999, background: f.dot,
                  display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 7, fontWeight: 700, color: '#fff'
                }}>{f.vendor[0]}</span>
                  <span style={{ fontSize: 11, color: TOK.fgPh }}>{f.vendor}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 2 }}>
                  <span style={{ fontSize: 18, fontWeight: 700, color: TOK.fgH }}>
                    <span style={{ fontSize: 11, fontWeight: 500, color: TOK.fg2, verticalAlign: 'top', marginRight: 1 }}>$</span>
                    {f.price.replace('$', '')}
                  </span>
                  <button style={{
                  width: 30, height: 30, borderRadius: 999, background: TOK.bgSoft, border: 'none',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
                }}>
                    <Icon name="plus" size={14} stroke={2} color={TOK.fgH} />
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      <V1Nav />
    </div>);

}

function IconBtn({ icon, badge }) {
  return (
    <button style={{
      width: 40, height: 40, borderRadius: 999, background: TOK.bg, border: `1px solid ${TOK.divider}`,
      display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', position: 'relative'
    }}>
      <Icon name={icon} size={18} color={TOK.fgH} />
      {badge && <span style={{
        position: 'absolute', top: 9, right: 10, width: 7, height: 7, borderRadius: 999,
        background: TOK.error, boxShadow: '0 0 0 2px #fff'
      }} />}
    </button>);

}

function V1Nav() {
  const items = [
  { id: 'home', icon: 'home', label: 'Home', active: true },
  { id: 'favs', icon: 'heart' },
  { id: 'bag', icon: 'basket' },
  { id: 'me', icon: 'user' }];

  return (
    <div style={{
      position: 'absolute', left: 20, right: 20, bottom: 28,
      background: TOK.dark, borderRadius: 999, padding: 8,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      boxShadow: TOK.shadow.nav, zIndex: 30
    }}>
      {items.map((it) => it.active ?
      <div key={it.id} style={{
        display: 'flex', alignItems: 'center', gap: 8,
        background: '#fff', color: TOK.fgH,
        padding: '10px 18px 10px 12px', borderRadius: 999
      }}>
          <span style={{
          width: 28, height: 28, borderRadius: 999, background: TOK.fgH,
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
            <Icon name="home" size={15} color="#fff" />
          </span>
          <span style={{ fontSize: 13, fontWeight: 600 }}>Home</span>
        </div> :

      <button key={it.id} style={{
        width: 44, height: 44, borderRadius: 999, background: 'transparent', border: 'none',
        display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
      }}>
          <Icon name={it.icon} size={20} color="rgba(255,255,255,0.85)" />
        </button>
      )}
    </div>);

}

// ════════════════════════════════════════════════════════════
// VARIANT 2 — "Popular Near You" (brief example 1)
// ════════════════════════════════════════════════════════════
function HomeV2() {
  const cats = ['All', 'Rice', 'Snacks', 'Drinks', 'Fast food', 'Fruits'];
  const popular = [
  { name: 'Mama Cass Kitchen', cuisine: 'Nigerian · Local', rating: 4.8, eta: '25–35 min', fee: '$3', img: IMG.jollof, badge: 'Popular' },
  { name: 'The Daily Grain', cuisine: 'Bowls · Healthy', rating: 4.7, eta: '20–30 min', fee: 'Free', img: IMG.bowl, badge: 'Free delivery' },
  { name: 'Suya & Smoke', cuisine: 'Grill · Streetfood', rating: 4.9, eta: '30–40 min', fee: '$4', img: IMG.grill }];

  const products = [
  { name: 'Margherita Slice', vendor: 'Slice & Co.', price: '$8', img: IMG.pizza },
  { name: 'Tonkotsu Ramen', vendor: 'Mensho', price: '$14', img: IMG.ramen },
  { name: 'Chicken Tacos', vendor: 'El Pastor', price: '$11', img: IMG.taco }];

  return (
    <div style={{ background: '#F7F7F7', minHeight: '100%', position: 'relative', paddingTop: 56 }}>
      <div style={{ padding: `8px ${PADX}px 140px`, display: 'flex', flexDirection: 'column', gap: 22 }}>
        {/* Greeting */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            <span style={{ fontSize: 13, color: TOK.fgPh, fontWeight: 500 }}>Good evening</span>
            <span style={{ fontSize: 26, fontWeight: 600, color: TOK.fgH, letterSpacing: '-0.02em' }}>David</span>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 4, color: TOK.fg2 }}>
              <Icon name="pin" size={13} color={TOK.fg2} />
              <span style={{ fontSize: 13 }}>12 Adeola Odeku St</span>
              <Icon name="chevD" size={13} color={TOK.fg2} />
            </div>
          </div>
          <button style={{
            width: 44, height: 44, borderRadius: 999, background: TOK.bg, border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
            boxShadow: TOK.shadow.card
          }}>
            <Icon name="bell" size={20} color={TOK.fgH} />
            <span style={{ position: 'absolute', top: 11, right: 12, width: 7, height: 7, background: TOK.error, borderRadius: 999, boxShadow: '0 0 0 2px #fff' }} />
          </button>
        </div>

        {/* Search */}
        <div style={{
          height: 56, background: TOK.bg, borderRadius: TOK.r.input,
          padding: '0 20px', display: 'flex', alignItems: 'center', gap: 12,
          boxShadow: TOK.shadow.float
        }}>
          <Icon name="search" size={20} color={TOK.fgPh} />
          <span style={{ color: TOK.fgPh, fontSize: 15, flex: 1 }}>Search vendors or dishes</span>
          <span style={{ width: 1, height: 22, background: TOK.divider }} />
          <Icon name="filter" size={18} color={TOK.fgH} />
        </div>

        {/* Category pills */}
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', margin: `0 -${PADX}px`, padding: `2px ${PADX}px 4px`, scrollbarWidth: 'none' }}>
          {cats.map((c, i) => <Tag key={c} active={i === 0}>{c}</Tag>)}
        </div>

        {/* Popular Near You */}
        <SectionHeader title="Popular Near You" />
        <div style={{ display: 'flex', gap: 14, overflowX: 'auto', margin: `0 -${PADX}px`, padding: `4px ${PADX}px 8px`, scrollbarWidth: 'none' }}>
          {popular.map((v, i) => <V2VendorCard key={i} {...v} />)}
        </div>

        {/* Recommended products */}
        <SectionHeader title="Recommended" />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {products.map((p, i) =>
          <div key={i} style={{
            background: TOK.bg, borderRadius: TOK.r.card, padding: 14,
            display: 'flex', gap: 14, alignItems: 'center', boxShadow: TOK.shadow.card
          }}>
              <div style={{
              width: 64, height: 64, borderRadius: 16,
              background: `url(${p.img}) center/cover`, flexShrink: 0
            }} />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
                <span style={{ fontSize: 15, fontWeight: 500, color: TOK.fgH }}>{p.name}</span>
                <span style={{ fontSize: 13, color: TOK.fg2 }}>{p.vendor}</span>
                <span style={{ fontSize: 15, fontWeight: 600, color: TOK.fgH, marginTop: 2 }}>{p.price}</span>
              </div>
              <button style={{
              width: 36, height: 36, borderRadius: 999, background: TOK.dark, color: '#fff', border: 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
              boxShadow: TOK.shadow.card
            }}>
                <Icon name="plus" size={16} stroke={2} color="#fff" />
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Floating nav (component lib) */}
      <BottomNav tab="home" />
    </div>);

}

function SectionHeader({ title, action = 'See all' }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
      <span style={{ fontSize: 18, fontWeight: 600, color: TOK.fgH, letterSpacing: '-0.01em' }}>{title}</span>
      {action && <span style={{ fontSize: 13, color: TOK.fg2, fontWeight: 500 }}>{action}</span>}
    </div>);

}

function V2VendorCard({ name, cuisine, rating, eta, fee, img, badge }) {
  return (
    <div style={{
      width: 240, background: TOK.bg, borderRadius: TOK.r.card,
      boxShadow: TOK.shadow.card, overflow: 'hidden', flexShrink: 0
    }}>
      <div style={{
        height: 130, background: `url(${img}) center/cover`, position: 'relative'
      }}>
        {badge && <div style={{
          position: 'absolute', top: 12, left: 12,
          background: 'rgba(255,255,255,0.94)', backdropFilter: 'blur(10px)',
          padding: '6px 10px', borderRadius: 999, fontSize: 11, fontWeight: 600, color: TOK.fgH
        }}>{badge}</div>}
        <button style={{
          position: 'absolute', top: 10, right: 10, width: 32, height: 32, borderRadius: 999,
          background: 'rgba(255,255,255,0.94)', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
          <Icon name="heart" size={15} color={TOK.fgH} />
        </button>
      </div>
      <div style={{ padding: '12px 16px 16px', display: 'flex', flexDirection: 'column', gap: 4 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: TOK.fgH }}>{name}</div>
        <div style={{ fontSize: 12, color: TOK.fg2 }}>{cuisine}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4, fontSize: 12, color: TOK.fg2 }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3 }}>
            <Icon name="star" size={12} color={TOK.fgH} />
            <b style={{ color: TOK.fgH, fontWeight: 600 }}>{rating}</b>
          </span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: TOK.fgDis }} />
          <span>{eta}</span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: TOK.fgDis }} />
          <span>{fee}</span>
        </div>
      </div>
    </div>);

}

// ════════════════════════════════════════════════════════════
// VARIANT 3 — Minimal hero + 2-col categories (brief example 2)
// ════════════════════════════════════════════════════════════
function HomeV3() {
  const quickCats = [
  { label: 'Fresh produce', sub: '120+ items', img: IMG.salad },
  { label: 'Hot meals', sub: '80+ vendors', img: IMG.bowl },
  { label: 'Bakery', sub: '24 vendors', img: IMG.pasta },
  { label: 'Drinks', sub: '60+ items', img: IMG.drink }];

  const products = [
  { name: 'Suya platter', vendor: 'Suya & Smoke', price: '$12', img: IMG.grill },
  { name: 'Garden bowl', vendor: 'The Daily Grain', price: '$9', img: IMG.bowl },
  { name: 'Salmon nigiri', vendor: 'Hako Sushi', price: '$16', img: IMG.sushi }];

  const vendors = [
  { name: 'Mama Cass', rating: 4.8, eta: '25 min', img: IMG.vendor1 },
  { name: 'Hako Sushi', rating: 4.9, eta: '30 min', img: IMG.vendor2 },
  { name: 'Pasta Bar', rating: 4.7, eta: '20 min', img: IMG.vendor3 }];

  return (
    <div style={{ background: TOK.bg, minHeight: '100%', position: 'relative', paddingTop: 56 }}>
      <div style={{ padding: `8px ${PADX}px 160px`, display: 'flex', flexDirection: 'column', gap: 28 }}>
        {/* Minimal greeting */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <span style={{ fontSize: 11, fontWeight: 500, letterSpacing: '0.08em', textTransform: 'uppercase', color: TOK.fgPh }}>
              Delivering to
            </span>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
              <span style={{ fontSize: 15, fontWeight: 600, color: TOK.fgH }}>12 Adeola Odeku St</span>
              <Icon name="chevD" size={14} color={TOK.fgH} />
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <button style={{
              width: 40, height: 40, borderRadius: 999, background: TOK.bg2, border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center'
            }}>
              <Icon name="search" size={18} color={TOK.fgH} />
            </button>
            <button style={{
              width: 40, height: 40, borderRadius: 999, background: TOK.bg2, border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative'
            }}>
              <Icon name="bell" size={18} color={TOK.fgH} />
              <span style={{ position: 'absolute', top: 9, right: 10, width: 7, height: 7, borderRadius: 999, background: TOK.error, boxShadow: '0 0 0 2px ' + TOK.bg2 }} />
            </button>
          </div>
        </div>

        {/* Hero banner — single monochrome */}
        <div style={{
          background: TOK.dark, color: '#fff', borderRadius: TOK.r.card, padding: 26,
          display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', gap: 14,
          minHeight: 180, position: 'relative', overflow: 'hidden'
        }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, flex: 1, zIndex: 1 }}>
            <span style={{ fontSize: 11, fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.55)' }}>
              This week
            </span>
            <span style={{ fontSize: 26, fontWeight: 600, letterSpacing: '-0.02em', lineHeight: 1.15 }}>
              Free delivery<br />over $25.
            </span>
            <button style={{
              alignSelf: 'flex-start', marginTop: 8,
              background: '#fff', color: TOK.fgH, border: 'none', cursor: 'pointer',
              padding: '10px 18px', borderRadius: 999, fontSize: 13, fontWeight: 600,
              display: 'inline-flex', alignItems: 'center', gap: 6
            }}>
              Order now <Icon name="arrowR" size={14} stroke={2} />
            </button>
          </div>
          {/* decorative offset thumbnail */}
          <div style={{
            position: 'absolute', right: -30, bottom: -30, width: 180, height: 180,
            borderRadius: 999, background: `url(${IMG.jollof}) center/cover`,
            border: '8px solid #111', opacity: 0.92
          }} />
        </div>

        {/* Quick categories — 2 col blocks */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <SectionHeader title="Browse" />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {quickCats.map((c, i) =>
            <div key={i} style={{
              background: TOK.bg2, borderRadius: TOK.r.card, padding: 16,
              display: 'flex', alignItems: 'center', gap: 12, minHeight: 84
            }}>
                <div style={{
                width: 52, height: 52, borderRadius: 16, flexShrink: 0,
                background: `url(${c.img}) center/cover`
              }} />
                <div style={{ display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
                  <span style={{ fontSize: 14, fontWeight: 600, color: TOK.fgH, lineHeight: 1.2 }}>{c.label}</span>
                  <span style={{ fontSize: 11, color: TOK.fg2 }}>{c.sub}</span>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Recommended */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <SectionHeader title="Recommended for you" />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
            {products.map((p, i) =>
            <div key={i} style={{
              display: 'flex', gap: 14, alignItems: 'center', padding: '14px 0',
              borderBottom: i < products.length - 1 ? `1px solid ${TOK.divider}` : 'none'
            }}>
                <div style={{
                width: 60, height: 60, borderRadius: 16,
                background: `url(${p.img}) center/cover`, flexShrink: 0
              }} />
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
                  <span style={{ fontSize: 15, fontWeight: 500, color: TOK.fgH }}>{p.name}</span>
                  <span style={{ fontSize: 12, color: TOK.fg2 }}>{p.vendor}</span>
                </div>
                <span style={{ fontSize: 15, fontWeight: 600, color: TOK.fgH }}>{p.price}</span>
                <button style={{
                width: 32, height: 32, borderRadius: 999, background: TOK.bg2, border: 'none',
                display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
              }}>
                  <Icon name="plus" size={14} stroke={2} color={TOK.fgH} />
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Nearby vendors */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <SectionHeader title="Nearby vendors" />
          <div style={{ display: 'flex', gap: 12, overflowX: 'auto', margin: `0 -${PADX}px`, padding: `2px ${PADX}px`, scrollbarWidth: 'none' }}>
            {vendors.map((v, i) =>
            <div key={i} style={{
              width: 150, flexShrink: 0, display: 'flex', flexDirection: 'column', gap: 10
            }}>
                <div style={{
                width: '100%', aspectRatio: '1 / 1', borderRadius: TOK.r.card,
                background: `url(${v.img}) center/cover`
              }} />
                <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                  <span style={{ fontSize: 14, fontWeight: 600, color: TOK.fgH }}>{v.name}</span>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: TOK.fg2 }}>
                    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3 }}>
                      <Icon name="star" size={11} color={TOK.fgH} />
                      <b style={{ color: TOK.fgH, fontWeight: 600 }}>{v.rating}</b>
                    </span>
                    <span style={{ width: 3, height: 3, borderRadius: 999, background: TOK.fgDis }} />
                    <span>{v.eta}</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Floating cart indicator */}
      <div style={{
        position: 'absolute', left: 20, right: 20, bottom: 28,
        background: TOK.dark, color: '#fff', borderRadius: 999,
        padding: '12px 16px 12px 12px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        boxShadow: TOK.shadow.nav, zIndex: 30
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{
            width: 36, height: 36, borderRadius: 999, background: 'rgba(255,255,255,0.12)',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            position: 'relative'
          }}>
            <Icon name="basket" size={18} color="#fff" />
            <span style={{
              position: 'absolute', top: -2, right: -2, minWidth: 16, height: 16, padding: '0 4px',
              background: '#fff', color: TOK.fgH, borderRadius: 999,
              fontSize: 10, fontWeight: 700, display: 'inline-flex', alignItems: 'center', justifyContent: 'center'
            }}>3</span>
          </span>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <span style={{ fontSize: 13, fontWeight: 600 }}>3 items in basket</span>
            <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.65)' }}>From Mama Cass</span>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 14, fontWeight: 600 }}>$24</span>
          <span style={{
            width: 32, height: 32, borderRadius: 999, background: '#fff', color: TOK.fgH,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center'
          }}>
            <Icon name="arrowR" size={14} stroke={2} color={TOK.fgH} />
          </span>
        </div>
      </div>
    </div>);

}

// ════════════════════════════════════════════════════════════
// VARIANT 4 — V1 top bar + categories + DS VendorCards + promo banner
// ════════════════════════════════════════════════════════════
function HomeV4() {
  const [activeCat, setActiveCat] = React.useState('all');
  const cats = [
  { id: 'all', label: 'All', img: IMG.jollof },
  { id: 'burger', label: 'Burger', img: IMG.burger },
  { id: 'pizza', label: 'Pizza', img: IMG.pizza },
  { id: 'sushi', label: 'Sushi', img: IMG.sushi },
  { id: 'drinks', label: 'Drinks', img: IMG.drink },
  { id: 'bowls', label: 'Bowls', img: IMG.bowl }];


  // Exact DS card data — shortName, etaMins (number), reviews, tags
  const vendors = [
  {
    id: 'v1', name: 'Mama Cass Kitchen', shortName: 'Mama Cass',
    cuisine: 'Nigerian · Local · Lagos Island',
    rating: 4.8, reviews: '2,481', etaMins: 28, fee: '₦600',
    tags: ['Free delivery', 'Halal'], img: IMG.jollof
  },
  {
    id: 'v2', name: 'The Daily Grain', shortName: 'Daily Grain',
    cuisine: 'Bowls · Healthy · Victoria Island',
    rating: 4.7, reviews: '1,104', etaMins: 22, fee: '₦500',
    tags: ['Vegan', 'Gluten-free'], img: IMG.bowl
  },
  {
    id: 'v3', name: 'Suya & Smoke', shortName: 'Suya & Smoke',
    cuisine: 'Grill · Street food · Lekki',
    rating: 4.9, reviews: '3,820', etaMins: 35, fee: '₦700',
    tags: ['Popular'], img: IMG.grill
  },
  {
    id: 'v4', name: 'Hako Sushi', shortName: 'Hako',
    cuisine: 'Japanese · Sushi · Ikoyi',
    rating: 4.6, reviews: '892', etaMins: 40, fee: '₦800',
    tags: ['New'], img: IMG.sushi
  }];


  return (
    <div style={{ background: '#FFFFFF', minHeight: '100%', position: 'relative', paddingTop: 16 }}>
      <div style={{ padding: `12px ${PADX}px 140px`, display: 'flex', flexDirection: 'column', gap: 22 }}>

        {/* ── V1 header ── */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, minWidth: 0 }}>
            <div style={{
              width: 44, height: 44, borderRadius: 999, overflow: 'hidden', flexShrink: 0,
              backgroundImage: `url(${IMG.avatar})`, backgroundSize: 'cover', backgroundPosition: 'center'
            }} />
            <div style={{ display: 'flex', flexDirection: 'column', minWidth: 0 }}>
              <span style={{ fontSize: 17, fontWeight: 600, color: '#1A1A1A', letterSpacing: '-0.01em' }}>Hi, Brooks</span>
              <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4, minWidth: 0, overflow: 'hidden' }}>
                <svg viewBox="0 0 24 24" width="11" height="11" fill="none" stroke="#7A7A7A" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0 }}><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle cx="12" cy="10" r="3" /></svg>
                <span style={{ fontSize: 12, color: '#7A7A7A', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>2118 Thornridge Cir…</span>
                <svg viewBox="0 0 24 24" width="11" height="11" fill="none" stroke="#7A7A7A" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0 }}><path d="M6 9l6 6 6-6" /></svg>
              </div>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8, flexShrink: 0 }}>
            <IconBtn icon="bell" badge />
            <IconBtn icon="basket" />
          </div>
        </div>

        {/* ── Hero text ── */}
        <div style={{ lineHeight: 1.1, letterSpacing: '-0.025em' }}>
          <span style={{ fontSize: 32, fontWeight: 700, color: '#1A1A1A' }}>Hungry? </span>
          <span style={{ fontSize: 32, fontWeight: 400, color: '#7A7A7A' }}>Order &amp; Eat</span>
        </div>

        {/* ── Search — DS spec: 52px · #F9F9F9 · 16px radius · icon 20px/1.5 ── */}
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <div style={{
            flex: 1, minWidth: 0, height: 52,
            padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12,
            fontSize: 16, border: '1px solid transparent', overflow: 'hidden', color: "rgb(0, 0, 0)", borderRadius: "2px", background: "rgb(247, 247, 247)"
          }}>
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none"
            stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"
            style={{ flexShrink: 0 }}>
              <circle cx="11" cy="11" r="7" /><path d="m21 21-4.3-4.3" />
            </svg>
            <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Search for vendors or dishes</span>
          </div>
          {/* Filter — DS primary button, icon-only, 52px ── */}
          <button style={{
            width: 52, height: 52, borderRadius: 999,
            background: '#111111', border: 'none', cursor: 'pointer',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            flexShrink: 0
          }}>
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none"
            stroke="#fff" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M4 6h16M7 12h10M10 18h4" />
            </svg>
          </button>
        </div>

        {/* ── Category pills — modernized image+label horizontal pill ── */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto',
          margin: `0 -${PADX}px`, padding: `4px ${PADX}px 8px`,
          scrollbarWidth: 'none'
        }}>
          {cats.map((c) => {
            const active = c.id === activeCat;
            return (
              <div key={c.id} onClick={() => setActiveCat(c.id)} style={{
                display: 'inline-flex', alignItems: 'center', gap: 9,
                height: 44, padding: '0 16px 0 6px',
                borderRadius: 999, flexShrink: 0, cursor: 'pointer',
                background: active ? '#111111' : '#F1F1F1',
                transition: 'background 220ms'
              }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 999, overflow: 'hidden', flexShrink: 0,
                  background: `url(${c.img}) center/cover`,
                  opacity: active ? 1 : 0.8
                }} />
                <span style={{
                  fontSize: 13, fontWeight: 500,
                  color: active ? '#FFFFFF' : '#1A1A1A',
                  whiteSpace: 'nowrap'
                }}>{c.label}</span>
              </div>);

          })}
        </div>

        {/* ── DS VendorCards — horizontal scroll, straight under categories ── */}
        <div style={{
          display: 'flex', gap: 14, overflowX: 'auto',
          margin: `0 -${PADX}px`, padding: `4px ${PADX}px 12px`,
          scrollbarWidth: 'none'
        }}>
          {vendors.map((v) =>
          <DSVendorCard key={v.id} {...v} />
          )}
        </div>

        {/* ── Subtitle before banner ── */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <span style={{ fontSize: 18, fontWeight: 600, color: '#1A1A1A', letterSpacing: '-0.01em' }}>Offers for you</span>
          <span style={{ fontSize: 13, fontWeight: 500, color: '#7A7A7A' }}>See all</span>
        </div>

        {/* ── Campaign banner — dark, offset food disc ── */}
        <div style={{
          background: '#111111', color: '#fff', borderRadius: 24, padding: 24,
          minHeight: 160, position: 'relative', overflow: 'hidden',
          display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', gap: 8
        }}>
          <span style={{
            fontSize: 11, fontWeight: 500, letterSpacing: '0.08em',
            textTransform: 'uppercase', color: 'rgba(255,255,255,0.5)'
          }}>This week</span>
          <span style={{ fontSize: 24, fontWeight: 600, letterSpacing: '-0.02em', lineHeight: 1.15 }}>
            Free delivery<br />on orders over ₦5,000
          </span>
          <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.6)', marginTop: 2 }}>Until Sunday. No code needed.</span>
          <button style={{
            alignSelf: 'flex-start', marginTop: 12,
            background: '#fff', color: '#111111', border: 'none', cursor: 'pointer',
            height: 40, padding: '0 18px', borderRadius: 999, fontSize: 14, fontWeight: 500,
            display: 'inline-flex', alignItems: 'center', gap: 6
          }}>
            Order now
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="#111111" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
              <path d="M5 12h14" /><path d="M13 6l6 6-6 6" />
            </svg>
          </button>
          <div style={{ ...{
              position: 'absolute', right: -24, bottom: -24,
              borderRadius: 999, background: `url(${IMG.jollof}) center/cover`,
              border: '6px solid #111111', opacity: 0.9, width: "14px", height: "1px"
            }, background: "url(\"https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500&q=80&auto=format&fit=crop\") center center / cover" }} />
        </div>

      </div>
      {/* ── V1 dark pill nav — matching reference ── */}
      <V1Nav />
    </div>);

}

// ════════════════════════════════════════════════════════════
// VARIANT 5 — Editorial / structural (stories + live order + deal flash + tabs)
// ════════════════════════════════════════════════════════════
function HomeV5() {
  const [tab, setTab] = React.useState('open');

  // Story-ring vendor circles
  const stories = [
  { name: 'Mama Cass', img: IMG.vendor1, open: true },
  { name: 'Hako', img: IMG.vendor2, open: true },
  { name: 'Pasta Bar', img: IMG.vendor3, open: false },
  { name: 'Slice Co.', img: IMG.pizza, open: true },
  { name: 'El Pastor', img: IMG.taco, open: true }];


  // Editorial featured vendor card
  const hero = {
    name: 'Mama Cass Kitchen', cuisine: 'Nigerian · Local · Lagos Island',
    rating: 4.8, reviews: '2.4k', eta: '25–35 min', fee: '₦600', img: IMG.jollof
  };

  // Flash deals
  const deals = [
  { name: 'Suya platter', was: '₦5,800', now: '₦3,200', pct: '-45%', img: IMG.grill, mins: 17 },
  { name: 'Garden bowl', was: '₦3,400', now: '₦2,100', pct: '-38%', img: IMG.bowl, mins: 42 },
  { name: 'Nigiri set', was: '₦7,200', now: '₦4,500', pct: '-37%', img: IMG.sushi, mins: 59 }];


  // Near you cards
  const nearby = [
  { id: 'v1', name: 'Suya & Smoke', cuisine: 'Grill · Streetfood', rating: 4.9, eta: '30 min', fee: '₦700', accent: `url(${IMG.grill}) center/cover`, badge: '🔥 Trending' },
  { id: 'v2', name: 'Hako Sushi', cuisine: 'Japanese · Sushi', rating: 4.6, eta: '35 min', fee: '₦800', accent: `url(${IMG.sushi}) center/cover` },
  { id: 'v3', name: 'Pasta Bar', cuisine: 'Italian · Pasta', rating: 4.7, eta: '20 min', fee: '₦500', accent: `url(${IMG.pasta}) center/cover`, badge: 'New' }];


  return (
    <div style={{ background: '#F7F7F7', minHeight: '100%', position: 'relative', paddingTop: 56 }}>
      <div style={{ paddingBottom: 120, display: 'flex', flexDirection: 'column', gap: 0 }}>

        {/* ── Slim greeting + actions ── */}
        <div style={{
          padding: `10px ${PADX}px 14px`,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          background: TOK.bg
        }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <Icon name="pin" size={13} color={TOK.fgPh} />
              <span style={{ fontSize: 13, color: TOK.fgPh }}>Delivering to</span>
            </div>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <span style={{ fontSize: 16, fontWeight: 700, color: TOK.fgH, letterSpacing: '-0.01em' }}>12 Adeola Odeku St</span>
              <Icon name="chevD" size={14} color={TOK.fgH} />
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <IconBtn icon="bell" badge />
            <div style={{
              width: 40, height: 40, borderRadius: 999, overflow: 'hidden',
              backgroundImage: `url(${IMG.avatar})`, backgroundSize: 'cover', backgroundPosition: 'center'
            }} />
          </div>
        </div>

        {/* ── Search ── */}
        <div style={{ padding: `10px ${PADX}px`, background: TOK.bg }}>
          <div style={{
            height: 52, background: '#F7F7F7', borderRadius: TOK.r.input,
            padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12,
            border: `1px solid ${TOK.divider}`
          }}>
            <Icon name="search" size={18} color={TOK.fgPh} />
            <span style={{ color: TOK.fgPh, fontSize: 15, flex: 1 }}>Restaurants, dishes…</span>
            <div style={{ width: 1, height: 20, background: TOK.divider }} />
            <Icon name="filter" size={16} color={TOK.fgH} />
          </div>
        </div>

        {/* ── Active order tracker strip ── */}
        <div style={{ padding: `0 ${PADX}px 14px`, background: TOK.bg }}>
          <div style={{
            background: TOK.dark, borderRadius: TOK.r.card,
            padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 14
          }}>
            <div style={{
              width: 42, height: 42, borderRadius: 12, overflow: 'hidden', flexShrink: 0,
              backgroundImage: `url(${IMG.jollof})`, backgroundSize: 'cover', backgroundPosition: 'center'
            }} />
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <span style={{ fontSize: 13, fontWeight: 600, color: '#fff' }}>Tunde is on the way</span>
              <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.55)' }}>Mama Cass · Arriving in 12 min</span>
              {/* progress bar */}
              <div style={{ height: 3, background: 'rgba(255,255,255,0.15)', borderRadius: 999, marginTop: 6 }}>
                <div style={{ width: '68%', height: '100%', background: '#fff', borderRadius: 999 }} />
              </div>
            </div>
            <Icon name="arrowR" size={16} color="rgba(255,255,255,0.7)" />
          </div>
        </div>

        {/* ── Vendor stories strip ── */}
        <div style={{
          display: 'flex', gap: 14, overflowX: 'auto',
          padding: `12px ${PADX}px 16px`,
          background: TOK.bg, borderBottom: `1px solid ${TOK.divider}`,
          scrollbarWidth: 'none'
        }}>
          {stories.map((s, i) =>
          <div key={i} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7, flexShrink: 0
          }}>
              <div style={{
              width: 58, height: 58, borderRadius: 999, padding: 2,
              background: s.open ? TOK.fgH : TOK.divider,
              boxShadow: s.open ? TOK.shadow.float : 'none'
            }}>
                <div style={{
                width: '100%', height: '100%', borderRadius: 999, overflow: 'hidden',
                border: '2px solid #fff',
                backgroundImage: `url(${s.img})`, backgroundSize: 'cover', backgroundPosition: 'center'
              }} />
              </div>
              <span style={{ fontSize: 11, fontWeight: 500, color: s.open ? TOK.fgH : TOK.fgPh }}>
                {s.name}
              </span>
            </div>
          )}
        </div>

        {/* ── Tab switcher ── */}
        <div style={{
          display: 'flex', padding: `14px ${PADX}px 10px`,
          gap: 8, background: TOK.bg,
          borderBottom: `1px solid ${TOK.divider}`
        }}>
          {[
          { id: 'open', label: 'Open Now' },
          { id: 'top', label: 'Top Rated' },
          { id: 'new', label: 'New' }].
          map((t) =>
          <button key={t.id} onClick={() => setTab(t.id)} style={{
            padding: '9px 18px', borderRadius: 999, border: 'none', cursor: 'pointer',
            background: tab === t.id ? TOK.fgH : TOK.bgSoft,
            color: tab === t.id ? '#fff' : TOK.fg2,
            fontSize: 13, fontWeight: 600, transition: 'background 200ms, color 200ms'
          }}>{t.label}</button>
          )}
        </div>

        {/* ── Editorial hero vendor ── */}
        <div style={{ padding: `20px ${PADX}px 0` }}>
          <div style={{
            borderRadius: TOK.r.card, overflow: 'hidden',
            boxShadow: TOK.shadow.float, background: TOK.bg
          }}>
            {/* Full-bleed vendor photo */}
            <div style={{
              height: 200, position: 'relative',
              backgroundImage: `url(${hero.img})`, backgroundSize: 'cover', backgroundPosition: 'center'
            }}>
              {/* scrim */}
              <div style={{
                position: 'absolute', inset: 0,
                background: 'linear-gradient(to top, rgba(0,0,0,0.72) 0%, transparent 60%)'
              }} />
              {/* open badge */}
              <div style={{
                position: 'absolute', top: 14, left: 14,
                background: TOK.success, color: '#fff',
                padding: '5px 12px', borderRadius: 999, fontSize: 11, fontWeight: 700
              }}>Open</div>
              {/* heart */}
              <button style={{
                position: 'absolute', top: 10, right: 10, width: 36, height: 36, borderRadius: 999,
                background: 'rgba(255,255,255,0.9)', border: 'none', cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center'
              }}>
                <Icon name="heart" size={16} color={TOK.fgH} />
              </button>
              {/* name overlay */}
              <div style={{
                position: 'absolute', bottom: 14, left: 16, right: 16,
                display: 'flex', flexDirection: 'column', gap: 4
              }}>
                <span style={{ fontSize: 20, fontWeight: 700, color: '#fff', letterSpacing: '-0.01em' }}>{hero.name}</span>
                <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.75)' }}>{hero.cuisine}</span>
              </div>
            </div>
            {/* Info row */}
            <div style={{
              padding: '14px 18px', display: 'flex', alignItems: 'center', gap: 18, fontSize: 13, color: TOK.fg2
            }}>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                <Icon name="star" size={14} color={TOK.fgH} />
                <b style={{ color: TOK.fgH, fontWeight: 600 }}>{hero.rating}</b>
                <span>({hero.reviews})</span>
              </span>
              <span style={{ width: 3, height: 3, borderRadius: 999, background: TOK.fgDis }} />
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                <Icon name="clock" size={13} /> {hero.eta}
              </span>
              <span style={{ width: 3, height: 3, borderRadius: 999, background: TOK.fgDis }} />
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                <Icon name="bike" size={13} /> {hero.fee}
              </span>
            </div>
          </div>
        </div>

        {/* ── Flash deals ── */}
        <div style={{ padding: `24px ${PADX}px 0` }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <span style={{ fontSize: 18, fontWeight: 700, color: TOK.fgH, letterSpacing: '-0.01em' }}>Flash Deals</span>
              {/* countdown pill */}
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 5,
                background: TOK.fgH, color: '#fff',
                padding: '5px 10px', borderRadius: 999, fontSize: 11, fontWeight: 600
              }}>
                <Icon name="clock" size={11} color="#fff" />
                02:14:37
              </div>
            </div>
            <span style={{ fontSize: 13, color: TOK.fg2, fontWeight: 500 }}>See all</span>
          </div>
          <div style={{
            display: 'flex', gap: 12, overflowX: 'auto',
            margin: `0 -${PADX}px`, padding: `4px ${PADX}px 4px`,
            scrollbarWidth: 'none'
          }}>
            {deals.map((d, i) =>
            <div key={i} style={{
              width: 148, flexShrink: 0, background: TOK.bg,
              borderRadius: TOK.r.card, overflow: 'hidden',
              boxShadow: TOK.shadow.card
            }}>
                <div style={{
                height: 110, position: 'relative',
                backgroundImage: `url(${d.img})`, backgroundSize: 'cover', backgroundPosition: 'center'
              }}>
                  <div style={{
                  position: 'absolute', top: 10, right: 10,
                  background: TOK.fgH, color: '#fff',
                  padding: '4px 9px', borderRadius: 999, fontSize: 11, fontWeight: 700
                }}>{d.pct}</div>
                </div>
                <div style={{ padding: '10px 12px 14px', display: 'flex', flexDirection: 'column', gap: 4 }}>
                  <span style={{ fontSize: 13, fontWeight: 600, color: TOK.fgH, lineHeight: 1.2 }}>{d.name}</span>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <span style={{ fontSize: 14, fontWeight: 700, color: TOK.fgH }}>{d.now}</span>
                    <span style={{ fontSize: 11, color: TOK.fgPh, textDecoration: 'line-through' }}>{d.was}</span>
                  </div>
                  <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4, marginTop: 2 }}>
                    <Icon name="clock" size={10} color={TOK.fgPh} />
                    <span style={{ fontSize: 10, color: TOK.fgPh }}>{d.mins} min left</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* ── Near you — DS VendorCards ── */}
        <div style={{ padding: `24px ${PADX}px 0` }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
            <span style={{ fontSize: 18, fontWeight: 700, color: TOK.fgH, letterSpacing: '-0.01em' }}>Near You</span>
            <span style={{ fontSize: 13, color: TOK.fg2, fontWeight: 500 }}>See all</span>
          </div>
          <div style={{
            display: 'flex', gap: 14, overflowX: 'auto',
            margin: `0 -${PADX}px`, padding: `4px ${PADX}px 8px`,
            scrollbarWidth: 'none'
          }}>
            {nearby.map((v) =>
            <div key={v.id} style={{ flexShrink: 0 }}>
                <VendorCard
                name={v.name}
                cuisine={v.cuisine}
                rating={v.rating}
                eta={v.eta}
                fee={v.fee}
                badge={v.badge}
                accent={v.accent} />
              
              </div>
            )}
          </div>
        </div>

        {/* ── Promo banner ── */}
        <div style={{ padding: `20px ${PADX}px 0` }}>
          <div style={{
            background: TOK.dark, color: '#fff', borderRadius: TOK.r.card, padding: 24,
            minHeight: 156, position: 'relative', overflow: 'hidden',
            display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', gap: 8
          }}>
            <span style={{ fontSize: 11, fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.5)' }}>Limited time</span>
            <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-0.02em', lineHeight: 1.15 }}>
              ₦500 off your<br />next 3 orders
            </span>
            <button style={{
              alignSelf: 'flex-start', marginTop: 8,
              background: '#fff', color: TOK.fgH, border: 'none', cursor: 'pointer',
              padding: '9px 18px', borderRadius: 999, fontSize: 13, fontWeight: 600,
              display: 'inline-flex', alignItems: 'center', gap: 6
            }}>
              Claim deal <Icon name="arrowR" size={14} stroke={2} />
            </button>
            <div style={{
              position: 'absolute', right: -24, top: -24, width: 160, height: 160,
              borderRadius: 999, background: `url(${IMG.ramen}) center/cover`,
              border: '6px solid #111', opacity: 0.88
            }} />
          </div>
        </div>

      </div>

      {/* ── V1 dark pill nav ── */}
      <V1Nav />
    </div>);

}

// ════════════════════════════════════════════════════════════
// VARIANT 6 — Reimagined header: mode toggle + location + dark hero band
// Same body as V4. Header pattern is entirely rethought.
// ════════════════════════════════════════════════════════════
function HomeV6() {
  const [activeCat, setActiveCat] = React.useState('all');
  const [mode, setMode] = React.useState('delivery');

  const cats = [
  { id: 'all', label: 'All', img: IMG.jollof },
  { id: 'burger', label: 'Burger', img: IMG.burger },
  { id: 'pizza', label: 'Pizza', img: IMG.pizza },
  { id: 'sushi', label: 'Sushi', img: IMG.sushi },
  { id: 'drinks', label: 'Drinks', img: IMG.drink },
  { id: 'bowls', label: 'Bowls', img: IMG.bowl }];


  const vendors = [
  { id: 'v1', name: 'Mama Cass Kitchen', shortName: 'Mama Cass', cuisine: 'Nigerian · Local · Lagos Island', rating: 4.8, reviews: '2,481', etaMins: 28, fee: '₦600', tags: ['Free delivery', 'Halal'], img: IMG.jollof },
  { id: 'v2', name: 'The Daily Grain', shortName: 'Daily Grain', cuisine: 'Bowls · Healthy · Victoria Island', rating: 4.7, reviews: '1,104', etaMins: 22, fee: '₦500', tags: ['Vegan', 'Gluten-free'], img: IMG.bowl },
  { id: 'v3', name: 'Suya & Smoke', shortName: 'Suya & Smoke', cuisine: 'Grill · Street food · Lekki', rating: 4.9, reviews: '3,820', etaMins: 35, fee: '₦700', tags: ['Popular'], img: IMG.grill },
  { id: 'v4', name: 'Hako Sushi', shortName: 'Hako', cuisine: 'Japanese · Sushi · Ikoyi', rating: 4.6, reviews: '892', etaMins: 40, fee: '₦800', tags: ['New'], img: IMG.sushi }];


  return (
    <div style={{ background: '#FFFFFF', height: '100%', position: 'relative' }}>

      {/* ════ REIMAGINED HEADER BAND ════ */}
      {/* Dark upper section containing mode toggle + location */}
      <div style={{
        background: '#111111', padding: '20px 20px 28px',
        display: 'flex', flexDirection: 'column', gap: 16
      }}>
        {/* Row 1: avatar · mode toggle · bell */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{
            width: 38, height: 38, borderRadius: 999, overflow: 'hidden', flexShrink: 0,
            backgroundImage: `url(${IMG.avatar})`, backgroundSize: 'cover', backgroundPosition: 'center',
            border: '2px solid rgba(255,255,255,0.2)'
          }} />

          {/* Delivery / Pickup toggle */}
          <div style={{
            display: 'flex', alignItems: 'center',
            background: 'rgba(255,255,255,0.1)', borderRadius: 999,
            padding: 4, gap: 2
          }}>
            {['delivery', 'pickup'].map((m) =>
            <button key={m} onClick={() => setMode(m)} style={{
              height: 32, padding: '0 16px', borderRadius: 999, border: 'none', cursor: 'pointer',
              background: mode === m ? '#FFFFFF' : 'transparent',
              color: mode === m ? '#111111' : 'rgba(255,255,255,0.6)',
              fontSize: 13, fontWeight: 600,
              transition: 'background 220ms, color 220ms'
            }}>
                {m.charAt(0).toUpperCase() + m.slice(1)}
              </button>
            )}
          </div>

          {/* Bell */}
          <button style={{
            width: 38, height: 38, borderRadius: 999,
            background: 'rgba(255,255,255,0.1)', border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative'
          }}>
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none"
            stroke="rgba(255,255,255,0.9)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M6 8a6 6 0 0 1 12 0c0 7 3 7 3 9H3c0-2 3-2 3-9z" /><path d="M10 21a2 2 0 0 0 4 0" />
            </svg>
            <span style={{
              position: 'absolute', top: 8, right: 9, width: 7, height: 7, borderRadius: 999,
              background: '#EF4444', boxShadow: '0 0 0 2px #111111'
            }} />
          </button>
        </div>

        {/* Row 2: greeting + location in dark band */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.5)', fontWeight: 400 }}>Good evening, Brooks</span>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none"
            stroke="rgba(255,255,255,0.7)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle cx="12" cy="10" r="3" />
            </svg>
            <span style={{ fontSize: 17, fontWeight: 600, color: '#FFFFFF', letterSpacing: '-0.01em' }}>
              2118 Thornridge Cir, Syra…
            </span>
            <svg viewBox="0 0 24 24" width="14" height="14" fill="none"
            stroke="rgba(255,255,255,0.5)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M6 9l6 6 6-6" />
            </svg>
          </div>
        </div>

        {/* Row 3: Search floats inside the dark band, lifts out */}
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <div style={{
            flex: 1, minWidth: 0, height: 52, background: '#FFFFFF', borderRadius: 16,
            padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12,
            fontSize: 16, color: '#7A7A7A', overflow: 'hidden'
          }}>
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none"
            stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"
            style={{ flexShrink: 0 }}>
              <circle cx="11" cy="11" r="7" /><path d="m21 21-4.3-4.3" />
            </svg>
            <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              Search for vendors or dishes
            </span>
          </div>
          {/* Filter pill — white on dark bg */}
          <button style={{
            width: 52, height: 52, borderRadius: 999,
            background: 'rgba(255,255,255,0.14)', border: '1px solid rgba(255,255,255,0.2)',
            cursor: 'pointer', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0
          }}>
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none"
            stroke="#FFFFFF" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M4 6h16M7 12h10M10 18h4" />
            </svg>
          </button>
        </div>
      </div>
      {/* ════ END HEADER BAND ════ */}

      {/* Body — same as V4 */}
      <div style={{ padding: `20px ${PADX}px 140px`, display: 'flex', flexDirection: 'column', gap: 20 }}>

        {/* Category pills */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto',
          margin: `0 -${PADX}px`, padding: `4px ${PADX}px 8px`,
          scrollbarWidth: 'none'
        }}>
          {cats.map((c) => {
            const active = c.id === activeCat;
            return (
              <div key={c.id} onClick={() => setActiveCat(c.id)} style={{
                display: 'inline-flex', alignItems: 'center', gap: 9,
                height: 44, padding: '0 16px 0 6px',
                borderRadius: 999, flexShrink: 0, cursor: 'pointer',
                background: active ? '#111111' : '#F1F1F1',
                transition: 'background 220ms'
              }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 999, overflow: 'hidden', flexShrink: 0,
                  background: `url(${c.img}) center/cover`, opacity: active ? 1 : 0.8
                }} />
                <span style={{
                  fontSize: 13, fontWeight: 500,
                  color: active ? '#FFFFFF' : '#1A1A1A', whiteSpace: 'nowrap'
                }}>{c.label}</span>
              </div>);

          })}
        </div>

        {/* DS VendorCards horizontal scroll */}
        <div style={{
          display: 'flex', gap: 14, overflowX: 'auto',
          margin: `0 -${PADX}px`, padding: `4px ${PADX}px 12px`,
          scrollbarWidth: 'none'
        }}>
          {vendors.map((v) => <DSVendorCard key={v.id} {...v} />)}
        </div>

        {/* Subtitle */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <span style={{ fontSize: 18, fontWeight: 600, color: '#1A1A1A', letterSpacing: '-0.01em' }}>Offers for you</span>
          <span style={{ fontSize: 13, fontWeight: 500, color: '#7A7A7A' }}>See all</span>
        </div>

        {/* Campaign banner */}
        <div style={{
          background: '#111111', color: '#fff', borderRadius: 24, padding: 24,
          minHeight: 160, position: 'relative', overflow: 'hidden',
          display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', gap: 8
        }}>
          <span style={{ fontSize: 11, fontWeight: 500, letterSpacing: '0.08em', textTransform: 'uppercase', color: 'rgba(255,255,255,0.5)' }}>This week</span>
          <span style={{ fontSize: 24, fontWeight: 600, letterSpacing: '-0.02em', lineHeight: 1.15 }}>
            Free delivery<br />on orders over ₦5,000
          </span>
          <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.6)', marginTop: 2 }}>Until Sunday. No code needed.</span>
          <button style={{
            alignSelf: 'flex-start', marginTop: 12,
            background: '#fff', color: '#111111', border: 'none', cursor: 'pointer',
            height: 40, padding: '0 18px', borderRadius: 999, fontSize: 14, fontWeight: 500,
            display: 'inline-flex', alignItems: 'center', gap: 6
          }}>
            Order now
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="#111111" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
              <path d="M5 12h14" /><path d="M13 6l6 6-6 6" />
            </svg>
          </button>
          <div style={{
            position: 'absolute', right: -24, bottom: -24, width: 164, height: 164,
            borderRadius: 999, background: `url(${IMG.jollof}) center/cover`,
            border: '6px solid #111111', opacity: 0.9
          }} />
        </div>
      </div>

      <V1Nav />
    </div>);

}

Object.assign(window, { HomeV1, HomeV2, HomeV3, HomeV4, HomeV5, HomeV6 });