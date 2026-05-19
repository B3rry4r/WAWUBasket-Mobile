// WAWUBasket — Customer App: reusable primitives.
// All components consume the design tokens from colors_and_type.css.

const W = {
  bg: '#FFFFFF', bg2: '#F7F7F7', bgSoft: '#EFEFEF', divider: '#E4E4E4',
  fg: '#000000', fgH: '#1A1A1A', fg2: '#4A4A4A', fgPh: '#7A7A7A', fgDis: '#A0A0A0',
  dark: '#111111', input: '#F9F9F9', tag: '#F1F1F1',
  success: '#22C55E', error: '#EF4444', warning: '#F59E0B', info: '#3B82F6',
  shadow: { card: '0 4px 16px rgba(0,0,0,0.04)', float: '0 8px 24px rgba(0,0,0,0.06)', nav: '0 12px 32px rgba(0,0,0,0.08)' },
  r: { btn: 16, input: 16, card: 24, sheet: 32, pill: 999 },
};

// ─── Icon ────────────────────────────────────────────────────
const ICONS = {
  home:     'M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1z',
  search:   'M16 16l5 5 M11 18a7 7 0 1 1 0-14 7 7 0 0 1 0 14z',
  basket:   'M3 6h18l-2 13a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2z M9 10V6a3 3 0 0 1 6 0v4',
  heart:    'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z',
  user:     'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8z M4 21a8 8 0 0 1 16 0',
  pin:      'M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z M12 13a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
  bell:     'M6 8a6 6 0 0 1 12 0c0 7 3 7 3 9H3c0-2 3-2 3-9z M10 21a2 2 0 0 0 4 0',
  clock:    'M12 7v5l3 2 M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18z',
  star:     'M12 3l2.7 6.3 6.8.5-5.2 4.4 1.7 6.8L12 17.3 6 21l1.7-6.8L2.5 9.8l6.8-.5z',
  arrowR:   'M5 12h14 M13 6l6 6-6 6',
  arrowL:   'M19 12H5 M11 18l-6-6 6-6',
  chev:     'M9 6l6 6-6 6',
  chevL:    'M15 6l-6 6 6 6',
  chevD:    'M6 9l6 6 6-6',
  check:    'M5 12l5 5L19 7',
  close:    'M6 6l12 12 M18 6L6 18',
  plus:     'M12 5v14 M5 12h14',
  minus:    'M5 12h14',
  filter:   'M4 6h16 M7 12h10 M10 18h4',
  more:     'M5 12h.01 M12 12h.01 M19 12h.01',
  bike:     'M5 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M19 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M12 18l-3-9h-2 M15 6h3l1 6 M9 9h7',
  phone:    'M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.7a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6a2 2 0 0 1 1.7 2z',
  msg:      'M21 11.5a8.4 8.4 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.7a8.4 8.4 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.4 8.4 0 0 1 3.8-.9h.5a8.5 8.5 0 0 1 8 8z',
  card:     'M2 8h20 M3 5h18a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z',
};
function Icon({ name, size = 20, stroke = 1.5, color = 'currentColor' }) {
  const d = ICONS[name] || '';
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
         stroke={color} strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round"
         style={{ display: 'block', flexShrink: 0 }}>
      {d.split(' M').map((seg, i) => <path key={i} d={(i ? 'M' : '') + seg} />)}
    </svg>
  );
}

// ─── Button ──────────────────────────────────────────────────
function Button({ children, variant = 'primary', size = 'md', icon, onClick, style, full }) {
  const sizes = {
    sm: { h: 40, px: 16, fs: 14 },
    md: { h: 52, px: 24, fs: 16 },
    lg: { h: 56, px: 28, fs: 16 },
  };
  const variants = {
    primary:   { bg: W.dark, fg: '#fff' },
    secondary: { bg: W.bgSoft, fg: W.fgH },
    ghost:     { bg: 'transparent', fg: W.fgH },
  };
  const s = sizes[size]; const v = variants[variant];
  return (
    <button onClick={onClick} style={{
      height: s.h, padding: `0 ${s.px}px`,
      borderRadius: W.r.pill, border: 'none', cursor: 'pointer',
      background: v.bg, color: v.fg,
      fontFamily: 'Inter, sans-serif', fontWeight: 500, fontSize: s.fs,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      width: full ? '100%' : undefined,
      transition: 'transform 120ms cubic-bezier(.32,.72,0,1), background 220ms',
      ...style,
    }}>
      {icon && <Icon name={icon} size={18} />}
      {children}
    </button>
  );
}

// ─── Tag / Chip ──────────────────────────────────────────────
function Tag({ children, active, onClick }) {
  return (
    <span onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '9px 16px', borderRadius: W.r.pill,
      fontSize: 13, fontWeight: 500,
      background: active ? W.dark : W.tag,
      color: active ? '#fff' : W.fgH,
      cursor: onClick ? 'pointer' : 'default',
      whiteSpace: 'nowrap',
      transition: 'background 220ms',
    }}>{children}</span>
  );
}

// ─── StatusPill ──────────────────────────────────────────────
function StatusPill({ kind = 'info', children }) {
  const map = {
    success: { bg: 'rgba(34,197,94,0.12)',  fg: '#15803d' },
    error:   { bg: 'rgba(239,68,68,0.12)',  fg: '#b91c1c' },
    warning: { bg: 'rgba(245,158,11,0.14)', fg: '#b45309' },
    info:    { bg: 'rgba(59,130,246,0.12)', fg: '#1d4ed8' },
  };
  const c = map[kind];
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '6px 12px', borderRadius: W.r.pill,
      fontSize: 12, fontWeight: 500, background: c.bg, color: c.fg,
    }}>
      <span style={{ width: 6, height: 6, borderRadius: 999, background: c.fg }} />
      {children}
    </span>
  );
}

// ─── Search bar ──────────────────────────────────────────────
function SearchBar({ placeholder = 'Search for vendors or dishes', onClick }) {
  return (
    <div onClick={onClick} style={{
      height: 52, background: W.input, borderRadius: W.r.input,
      padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12,
      cursor: onClick ? 'pointer' : 'text',
      boxShadow: W.shadow.card,
    }}>
      <Icon name="search" size={20} color={W.fgPh} />
      <span style={{ color: W.fgPh, fontSize: 16 }}>{placeholder}</span>
    </div>
  );
}

// ─── Greeting Header ─────────────────────────────────────────
function GreetingHeader({ name = 'David', location = '12 Adeola Odeku St', onNotif }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <span style={{ fontSize: 13, color: W.fgPh, fontWeight: 500 }}>Good evening</span>
        <span style={{ fontSize: 24, fontWeight: 600, color: W.fgH, letterSpacing: '-0.015em' }}>{name}</span>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 6, color: W.fg2 }}>
          <Icon name="pin" size={14} color={W.fg2} />
          <span style={{ fontSize: 13 }}>{location}</span>
          <Icon name="chevD" size={14} color={W.fg2} />
        </div>
      </div>
      <button onClick={onNotif} style={{
        width: 44, height: 44, borderRadius: 999, background: W.bg,
        boxShadow: W.shadow.card, border: 'none', cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
      }}>
        <Icon name="bell" size={20} color={W.fgH} />
        <span style={{
          position: 'absolute', top: 11, right: 12, width: 7, height: 7,
          background: W.error, borderRadius: 999, boxShadow: '0 0 0 2px #FFF',
        }} />
      </button>
    </div>
  );
}

// ─── VendorCard ──────────────────────────────────────────────
function VendorCard({ name, cuisine, rating, eta, fee, badge, onClick, accent, full }) {
  return (
    <div onClick={onClick} style={{
      width: full ? '100%' : 260, background: W.bg, borderRadius: W.r.card,
      boxShadow: W.shadow.card, overflow: 'hidden', cursor: onClick ? 'pointer' : 'default',
      flexShrink: 0,
      transition: 'box-shadow 220ms, transform 220ms cubic-bezier(.32,.72,0,1)',
    }}>
      <div style={{
        height: 130,
        background: accent || `linear-gradient(135deg, ${W.bgSoft} 0%, ${W.divider} 100%)`,
        position: 'relative',
      }}>
        {badge && <div style={{
          position: 'absolute', top: 12, left: 12,
          background: 'rgba(255,255,255,0.94)', backdropFilter: 'blur(10px)',
          padding: '6px 10px', borderRadius: 999, fontSize: 11, fontWeight: 500, color: W.fgH,
        }}>{badge}</div>}
      </div>
      <div style={{ padding: '14px 18px 18px', display: 'flex', flexDirection: 'column', gap: 4 }}>
        <div style={{ fontSize: 17, fontWeight: 500, color: W.fgH }}>{name}</div>
        <div style={{ fontSize: 13, color: W.fg2 }}>{cuisine}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 6, fontSize: 13, color: W.fg2 }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            <Icon name="star" size={13} color={W.fgH} /> <b style={{ color: W.fgH, fontWeight: 500 }}>{rating}</b>
          </span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: W.fgDis }} />
          <span>{eta}</span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: W.fgDis }} />
          <span>{fee}</span>
        </div>
      </div>
    </div>
  );
}

// ─── ProductRow (vendor menu) ────────────────────────────────
function ProductRow({ name, desc, price, accent, onAdd }) {
  return (
    <div style={{
      display: 'flex', gap: 14, padding: '16px 0', borderBottom: `1px solid ${W.divider}`,
    }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6, minWidth: 0 }}>
        <div style={{ fontSize: 16, fontWeight: 500, color: W.fgH }}>{name}</div>
        <div style={{ fontSize: 13, color: W.fg2, lineHeight: 1.45, display: '-webkit-box',
          WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>{desc}</div>
        <div style={{ fontSize: 15, fontWeight: 500, color: W.fgH, marginTop: 2 }}>{price}</div>
      </div>
      <div style={{ position: 'relative' }}>
        <div style={{
          width: 92, height: 92, borderRadius: 18,
          background: accent || `linear-gradient(135deg, ${W.bgSoft}, ${W.divider})`,
        }} />
        <button onClick={onAdd} style={{
          position: 'absolute', right: -8, bottom: -8,
          width: 32, height: 32, borderRadius: 999,
          background: W.dark, color: '#fff', border: 'none',
          boxShadow: W.shadow.float, cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="plus" size={16} stroke={2} color="#fff" />
        </button>
      </div>
    </div>
  );
}

// ─── BottomNav ───────────────────────────────────────────────
function BottomNav({ tab = 'home', onChange }) {
  const items = [
    { id: 'home',  icon: 'home',   label: 'Home' },
    { id: 'search',icon: 'search', label: 'Search' },
    { id: 'orders',icon: 'basket', label: 'Orders' },
    { id: 'favs',  icon: 'heart',  label: 'Favorites' },
    { id: 'me',    icon: 'user',   label: 'Profile' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 16, right: 16, bottom: 24,
      background: 'rgba(255,255,255,0.92)',
      backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      borderRadius: 999, boxShadow: W.shadow.nav,
      padding: '10px 14px',
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      zIndex: 30,
    }}>
      {items.map(it => {
        const active = tab === it.id;
        return (
          <div key={it.id} onClick={() => onChange && onChange(it.id)} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            padding: '6px 10px', cursor: 'pointer',
            color: active ? W.dark : W.fgPh,
          }}>
            <Icon name={it.icon} size={22} />
            <span style={{ fontSize: 10, fontWeight: 500 }}>{it.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ─── QtyStepper ──────────────────────────────────────────────
function QtyStepper({ value = 1, onChange }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 12,
      background: W.bgSoft, borderRadius: 999, padding: 4,
    }}>
      <button onClick={() => onChange && onChange(Math.max(1, value - 1))} style={{
        width: 36, height: 36, borderRadius: 999, background: W.bg,
        border: 'none', cursor: 'pointer', display: 'flex',
        alignItems: 'center', justifyContent: 'center', color: W.fgH,
      }}><Icon name="minus" size={14} stroke={2} /></button>
      <span style={{ fontSize: 15, fontWeight: 500, color: W.fgH, minWidth: 18, textAlign: 'center' }}>{value}</span>
      <button onClick={() => onChange && onChange(value + 1)} style={{
        width: 36, height: 36, borderRadius: 999, background: W.dark,
        color: '#fff', border: 'none', cursor: 'pointer', display: 'flex',
        alignItems: 'center', justifyContent: 'center',
      }}><Icon name="plus" size={14} stroke={2} color="#fff" /></button>
    </div>
  );
}

// ─── ScreenHeader (back + title) ─────────────────────────────
function ScreenHeader({ title, onBack, right }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '8px 0 16px',
    }}>
      <button onClick={onBack} style={{
        width: 44, height: 44, borderRadius: 999, background: W.bg,
        boxShadow: W.shadow.card, border: 'none', cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon name="chevL" size={20} color={W.fgH} />
      </button>
      <span style={{ fontSize: 17, fontWeight: 600, color: W.fgH }}>{title}</span>
      <div style={{ width: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{right}</div>
    </div>
  );
}

Object.assign(window, {
  W, Icon, Button, Tag, StatusPill, SearchBar, GreetingHeader,
  VendorCard, ProductRow, BottomNav, QtyStepper, ScreenHeader,
});
