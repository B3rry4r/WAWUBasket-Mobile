// WAWUBasket — Customer Account Screens
// Order History · Favorites · Profile · Wallet · Notifications · Support

const TOK3 = window.W;
const PAD3 = 20;

// ── Shared helpers ─────────────────────────────────────────
function Divider3() {
  return <div style={{ height: 1, background: TOK3.divider }} />;
}
function SectionHead3({ title, action }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
      <span style={{ fontSize: 16, fontWeight: 600, color: TOK3.fgH, letterSpacing: '-0.01em' }}>{title}</span>
      {action && <span style={{ fontSize: 13, fontWeight: 500, color: TOK3.fg2 }}>{action}</span>}
    </div>
  );
}
function EyebrowLabel({ children }) {
  return (
    <span style={{
      fontSize: 11, fontWeight: 600, letterSpacing: '0.06em',
      textTransform: 'uppercase', color: TOK3.fgPh,
    }}>{children}</span>
  );
}
function ImgBox3({ w, h, r = 12, label = '' }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: r, flexShrink: 0,
      background: '#DDDCDB', display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <span style={{ fontSize: 9, fontWeight: 500, color: '#9A9A9A', letterSpacing: '0.04em', textTransform: 'uppercase' }}>{label}</span>
    </div>
  );
}
// Menu row with chevron
function MenuRow({ icon, label, sub, right, danger }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14, padding: '15px 0',
      borderBottom: `1px solid ${TOK3.divider}`,
    }}>
      {icon && (
        <span style={{
          width: 36, height: 36, borderRadius: 12, background: danger ? 'rgba(239,68,68,0.08)' : TOK3.bgSoft,
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
        }}>
          <Icon name={icon} size={17} color={danger ? TOK3.error : TOK3.fgH} />
        </span>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 500, color: danger ? TOK3.error : TOK3.fgH }}>{label}</div>
        {sub && <div style={{ fontSize: 12, color: TOK3.fg2, marginTop: 1 }}>{sub}</div>}
      </div>
      {right || <Icon name="chev" size={16} color={TOK3.fgPh} />}
    </div>
  );
}

// ════════════════════════════════════════════════════════════
// ORDER HISTORY SCREEN
// ════════════════════════════════════════════════════════════
function OrderHistoryScreen() {
  const { Screen, BackChip, AppNav } = window;
  const orders = [
    { id: 'ORD-8821', vendor: 'Mama Cass Kitchen', items: 'Jollof rice, Suya platter', total: '₦14,600', date: 'Today, 12:31', status: 'active', statusLabel: 'On the way' },
    { id: 'ORD-8804', vendor: 'The Daily Grain',   items: 'Garden bowl × 2',           total: '₦7,400',  date: 'Yesterday, 18:02', status: 'done' },
    { id: 'ORD-8790', vendor: 'Suya & Smoke',       items: 'Suya platter, Drinks',       total: '₦6,200',  date: 'Mon 12 May', status: 'done' },
    { id: 'ORD-8771', vendor: 'Hako Sushi',          items: 'Salmon nigiri set',          total: '₦9,800',  date: 'Sat 10 May', status: 'cancelled', statusLabel: 'Cancelled' },
  ];
  const statusColors = {
    active:    { bg: 'rgba(59,130,246,0.1)',  fg: '#1d4ed8', label: 'On the way' },
    done:      { bg: 'rgba(34,197,94,0.1)',   fg: '#15803d', label: 'Delivered' },
    cancelled: { bg: 'rgba(239,68,68,0.1)',   fg: '#b91c1c', label: 'Cancelled' },
  };
  return (
    <Screen bg="#F7F7F7" height={960}>
      <div style={{ padding: `12px ${PAD3}px 120px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <BackChip />
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: TOK3.fgH, letterSpacing: '-0.015em' }}>Orders</h1>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', gap: 8 }}>
          {['All', 'Active', 'Delivered', 'Cancelled'].map((t, i) => (
            <span key={t} style={{
              padding: '9px 16px', borderRadius: 999, fontSize: 13, fontWeight: 500,
              background: i === 0 ? TOK3.dark : TOK3.bg,
              color: i === 0 ? '#fff' : TOK3.fg2,
              boxShadow: i !== 0 ? TOK3.shadow.card : 'none',
              flexShrink: 0,
            }}>{t}</span>
          ))}
        </div>

        {/* Order cards */}
        {orders.map(o => {
          const sc = statusColors[o.status];
          return (
            <div key={o.id} style={{
              background: TOK3.bg, borderRadius: TOK3.r.card,
              padding: 18, boxShadow: TOK3.shadow.card,
              display: 'flex', flexDirection: 'column', gap: 12,
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <div style={{ fontSize: 15, fontWeight: 600, color: TOK3.fgH }}>{o.vendor}</div>
                  <div style={{ fontSize: 12, color: TOK3.fg2, marginTop: 3 }}>{o.items}</div>
                </div>
                <span style={{
                  padding: '5px 10px', borderRadius: 999, fontSize: 11, fontWeight: 600,
                  background: sc.bg, color: sc.fg,
                  whiteSpace: 'nowrap',
                }}>{sc.label}</span>
              </div>
              <Divider3 />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontSize: 16, fontWeight: 700, color: TOK3.fgH }}>{o.total}</div>
                  <div style={{ fontSize: 12, color: TOK3.fg2, marginTop: 2 }}>{o.date}</div>
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                  {o.status === 'active' ? (
                    <button style={{ padding: '10px 18px', borderRadius: 999, background: TOK3.dark, border: 'none', cursor: 'pointer', fontSize: 13, fontWeight: 500, color: '#fff' }}>
                      Track order
                    </button>
                  ) : (
                    <>
                      {o.status === 'done' && (
                        <button style={{ padding: '10px 14px', borderRadius: 999, background: TOK3.bgSoft, border: 'none', cursor: 'pointer', fontSize: 13, fontWeight: 500, color: TOK3.fg2 }}>
                          Receipt
                        </button>
                      )}
                      <button style={{ padding: '10px 18px', borderRadius: 999, background: o.status === 'done' ? TOK3.dark : TOK3.bgSoft, border: 'none', cursor: 'pointer', fontSize: 13, fontWeight: 500, color: o.status === 'done' ? '#fff' : TOK3.fg2 }}>
                        {o.status === 'done' ? 'Reorder' : 'View'}
                      </button>
                    </>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
      <AppNav active="orders" />
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// FAVORITES SCREEN
// ════════════════════════════════════════════════════════════
function FavoritesScreen() {
  const { Screen, BackChip, AppNav } = window;
  const vendors = [
    { name: 'Mama Cass Kitchen', cuisine: 'Nigerian · Local', rating: 4.8, eta: '25–35 min' },
    { name: 'The Daily Grain',   cuisine: 'Bowls · Healthy',  rating: 4.7, eta: '20–30 min' },
    { name: 'Hako Sushi',        cuisine: 'Japanese · Sushi', rating: 4.6, eta: '30–45 min' },
    { name: 'Suya & Smoke',      cuisine: 'Grill · Street',   rating: 4.9, eta: '30–40 min' },
  ];
  const dishes = [
    { name: 'Jollof rice & chicken', vendor: 'Mama Cass', price: '₦4,500' },
    { name: 'Garden bowl',           vendor: 'Daily Grain', price: '₦3,200' },
    { name: 'Salmon nigiri set',     vendor: 'Hako Sushi',  price: '₦7,200' },
  ];
  return (
    <Screen bg="#F7F7F7" height={1060}>
      <div style={{ padding: `12px ${PAD3}px 120px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <BackChip />
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: TOK3.fgH, letterSpacing: '-0.015em' }}>Favorites</h1>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', gap: 0, background: TOK3.bg, borderRadius: 14, padding: 4, boxShadow: TOK3.shadow.card }}>
          {['Vendors', 'Dishes'].map((t, i) => (
            <div key={t} style={{
              flex: 1, textAlign: 'center', padding: '10px 0', borderRadius: 10,
              background: i === 0 ? TOK3.dark : 'transparent',
              fontSize: 14, fontWeight: 600,
              color: i === 0 ? '#fff' : TOK3.fg2,
              cursor: 'pointer',
            }}>{t}</div>
          ))}
        </div>

        {/* Vendors grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {vendors.map((v, i) => (
            <div key={i} style={{
              background: TOK3.bg, borderRadius: TOK3.r.card,
              overflow: 'hidden', boxShadow: TOK3.shadow.card,
            }}>
              <div style={{ position: 'relative' }}>
                <ImgBox3 w="100%" h={110} r={0} label="vendor" />
                <button style={{
                  position: 'absolute', top: 10, right: 10,
                  width: 32, height: 32, borderRadius: 999,
                  background: 'rgba(255,255,255,0.9)', border: 'none', cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <Icon name="heart" size={14} color="#EF4444" />
                </button>
              </div>
              <div style={{ padding: '10px 12px 14px' }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: TOK3.fgH, lineHeight: 1.2 }}>{v.name}</div>
                <div style={{ fontSize: 11, color: TOK3.fg2, marginTop: 2 }}>{v.cuisine}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 6, fontSize: 11, color: TOK3.fg2 }}>
                  <Icon name="star" size={11} color={TOK3.fgH} />
                  <b style={{ color: TOK3.fgH }}>{v.rating}</b>
                  <span>· {v.eta}</span>
                </div>
              </div>
            </div>
          ))}
        </div>

        <Divider3 />
        <SectionHead3 title="Saved dishes" />
        {dishes.map((d, i) => (
          <div key={i} style={{
            display: 'flex', gap: 14, alignItems: 'center',
            padding: 14, background: TOK3.bg, borderRadius: 16, boxShadow: TOK3.shadow.card,
          }}>
            <ImgBox3 w={60} h={60} r={12} label="dish" />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 500, color: TOK3.fgH }}>{d.name}</div>
              <div style={{ fontSize: 12, color: TOK3.fg2, marginTop: 2 }}>{d.vendor}</div>
              <div style={{ fontSize: 14, fontWeight: 600, color: TOK3.fgH, marginTop: 4 }}>{d.price}</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'flex-end' }}>
              <button style={{ width: 32, height: 32, borderRadius: 999, background: TOK3.bgSoft, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="heart" size={14} color="#EF4444" />
              </button>
              <button style={{ width: 32, height: 32, borderRadius: 999, background: TOK3.dark, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="plus" size={14} stroke={2} color="#fff" />
              </button>
            </div>
          </div>
        ))}
      </div>
      <AppNav active="favorites" />
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ════════════════════════════════════════════════════════════
function ProfileScreen() {
  const { Screen, AppNav } = window;
  const sections = [
    {
      title: 'Account',
      rows: [
        { icon: 'user',   label: 'Personal information',  sub: 'Name, email, phone' },
        { icon: 'pin',    label: 'Saved addresses',        sub: '2 saved' },
        { icon: 'card',   label: 'Payment methods',        sub: '1 card, wallet' },
        { icon: 'bell',   label: 'Notifications',          sub: 'All on' },
      ],
    },
    {
      title: 'Preferences',
      rows: [
        { icon: 'msg',    label: 'Language', sub: 'English' },
        { icon: 'star',   label: 'Rate the app' },
        { icon: 'more',   label: 'About WAWUBasket', sub: 'v2.1.0' },
      ],
    },
    {
      title: '',
      rows: [
        { icon: 'phone',  label: 'Help &amp; support' },
        { icon: 'close',  label: 'Sign out', danger: true },
      ],
    },
  ];
  return (
    <Screen bg="#F7F7F7" height={1060}>
      {/* Dark hero */}
      <div style={{ background: TOK3.dark, padding: `16px ${PAD3}px 28px` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{
            width: 64, height: 64, borderRadius: 999, background: '#3A3A3A',
            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            border: '2.5px solid rgba(255,255,255,0.18)',
          }}>
            <Icon name="user" size={28} color="rgba(255,255,255,0.7)" />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 20, fontWeight: 600, color: '#fff', letterSpacing: '-0.01em' }}>Brooks Adesanya</div>
            <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)', marginTop: 3 }}>brooks@wawu.africa</div>
          </div>
          <button style={{ width: 36, height: 36, borderRadius: 999, background: 'rgba(255,255,255,0.12)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="more" size={16} color="#fff" />
          </button>
        </div>
        {/* Quick stats */}
        <div style={{ display: 'flex', gap: 0, marginTop: 20, borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: 18 }}>
          {[['48', 'Orders'], ['₦12.5k', 'Wallet'], ['12', 'Favorites']].map(([val, lbl], i) => (
            <div key={lbl} style={{ flex: 1, textAlign: 'center', borderRight: i < 2 ? '1px solid rgba(255,255,255,0.1)' : 'none' }}>
              <div style={{ fontSize: 20, fontWeight: 700, color: '#fff', letterSpacing: '-0.02em' }}>{val}</div>
              <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', marginTop: 3, fontWeight: 500 }}>{lbl}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Menu sections */}
      <div style={{ padding: `16px ${PAD3}px 120px`, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {sections.map((sec, si) => (
          <div key={si} style={{ background: TOK3.bg, borderRadius: TOK3.r.card, padding: '0 16px', boxShadow: TOK3.shadow.card }}>
            {sec.title && (
              <div style={{ padding: '14px 0 2px' }}>
                <EyebrowLabel>{sec.title}</EyebrowLabel>
              </div>
            )}
            {sec.rows.map((r, ri) => (
              <MenuRow
                key={ri}
                icon={r.icon}
                label={r.label}
                sub={r.sub}
                danger={r.danger}
              />
            ))}
          </div>
        ))}
      </div>
      <AppNav active="profile" />
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// WALLET SCREEN
// ════════════════════════════════════════════════════════════
function WalletScreen() {
  const { Screen, BackChip } = window;
  const actions = [
    { icon: 'plus',   label: 'Top up' },
    { icon: 'arrowR', label: 'Send' },
    { icon: 'arrowL', label: 'Withdraw' },
    { icon: 'card',   label: 'Cards' },
  ];
  const txns = [
    { label: 'Mama Cass Kitchen', sub: 'Order #8821',      amount: '-₦14,600', time: 'Today 12:31', out: true  },
    { label: 'Wallet top-up',      sub: 'Via Paystack',     amount: '+₦20,000', time: 'Today 09:15', out: false },
    { label: 'The Daily Grain',    sub: 'Order #8804',      amount: '-₦7,400',  time: 'Yesterday',   out: true  },
    { label: 'Escrow released',    sub: 'Trade #TR-0041',   amount: '+₦3,000',  time: 'Mon 12 May',  out: false },
    { label: 'Hako Sushi',         sub: 'Order #8790',      amount: '-₦9,800',  time: 'Sat 10 May',  out: true  },
  ];
  return (
    <Screen bg="#F7F7F7" height={1040}>
      {/* Hero */}
      <div style={{ background: TOK3.dark, padding: `12px ${PAD3}px 32px` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <BackChip />
          <span style={{ fontSize: 17, fontWeight: 600, color: '#fff' }}>Wallet</span>
        </div>
        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
          <span style={{ fontSize: 13, fontWeight: 500, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.04em', textTransform: 'uppercase' }}>Available balance</span>
          <span style={{ fontSize: 48, fontWeight: 700, color: '#fff', letterSpacing: '-0.03em', lineHeight: 1.1 }}>₦12,500</span>
        </div>
        {/* Escrow hold notice */}
        <div style={{
          marginTop: 16, padding: '10px 14px', borderRadius: 12,
          background: 'rgba(245,158,11,0.14)', border: '1px solid rgba(245,158,11,0.25)',
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <Icon name="clock" size={15} color="#F59E0B" />
          <span style={{ fontSize: 13, color: '#F59E0B', fontWeight: 500 }}>₦3,000 held in escrow — releases in 48 hrs</span>
        </div>
      </div>

      {/* Quick actions */}
      <div style={{ padding: `20px ${PAD3}px 0` }}>
        <div style={{ display: 'flex', gap: 12 }}>
          {actions.map(a => (
            <div key={a.label} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <button style={{
                width: 52, height: 52, borderRadius: 999, background: TOK3.bg, border: 'none', cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: TOK3.shadow.card,
              }}>
                <Icon name={a.icon} size={20} color={TOK3.fgH} />
              </button>
              <span style={{ fontSize: 11, fontWeight: 500, color: TOK3.fg2 }}>{a.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Transactions */}
      <div style={{ padding: `20px ${PAD3}px 40px`, display: 'flex', flexDirection: 'column', gap: 16 }}>
        <SectionHead3 title="Recent transactions" action="See all" />
        <div style={{ background: TOK3.bg, borderRadius: TOK3.r.card, overflow: 'hidden', boxShadow: TOK3.shadow.card }}>
          {txns.map((t, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 14,
              padding: '14px 18px',
              borderBottom: i < txns.length - 1 ? `1px solid ${TOK3.divider}` : 'none',
            }}>
              <span style={{
                width: 40, height: 40, borderRadius: 999, flexShrink: 0,
                background: t.out ? 'rgba(239,68,68,0.08)' : 'rgba(34,197,94,0.08)',
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name={t.out ? 'arrowR' : 'arrowL'} size={17} color={t.out ? '#EF4444' : '#22C55E'} />
              </span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 500, color: TOK3.fgH }}>{t.label}</div>
                <div style={{ fontSize: 12, color: TOK3.fg2, marginTop: 1 }}>{t.sub}</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: t.out ? '#EF4444' : '#22C55E' }}>{t.amount}</div>
                <div style={{ fontSize: 11, color: TOK3.fgPh, marginTop: 1 }}>{t.time}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN
// ════════════════════════════════════════════════════════════
function NotificationsScreen() {
  const { Screen, BackChip } = window;
  const groups = [
    {
      date: 'Today',
      items: [
        { icon: 'bike',   title: 'Tunde is on the way', body: 'Your order from Mama Cass Kitchen arrives in 12 min.', time: '12:31', unread: true },
        { icon: 'check',  title: 'Order confirmed', body: 'Mama Cass has accepted your order. Preparing now.', time: '12:29', unread: true },
        { icon: 'star',   title: '20% off your next order', body: 'Use code WELCOME20 before Sunday.', time: '09:00', unread: false },
      ],
    },
    {
      date: 'Yesterday',
      items: [
        { icon: 'check',  title: 'Delivered', body: 'Your order from The Daily Grain was delivered.', time: '18:44', unread: false },
        { icon: 'card',   title: 'Payment confirmed', body: '₦7,400 deducted for order #8804.', time: '18:01', unread: false },
      ],
    },
  ];
  return (
    <Screen bg="#F7F7F7" height={940}>
      <div style={{ padding: `12px ${PAD3}px 40px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <BackChip />
            <h1 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: TOK3.fgH, letterSpacing: '-0.015em' }}>Notifications</h1>
          </div>
          <span style={{ fontSize: 13, fontWeight: 500, color: TOK3.fgH }}>Mark all read</span>
        </div>

        {groups.map((g, gi) => (
          <div key={gi} style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <EyebrowLabel>{g.date}</EyebrowLabel>
            <div style={{ background: TOK3.bg, borderRadius: TOK3.r.card, overflow: 'hidden', boxShadow: TOK3.shadow.card }}>
              {g.items.map((n, ni) => (
                <div key={ni} style={{
                  display: 'flex', gap: 14, padding: '14px 18px',
                  borderBottom: ni < g.items.length - 1 ? `1px solid ${TOK3.divider}` : 'none',
                  background: n.unread ? 'rgba(0,0,0,0.015)' : TOK3.bg,
                }}>
                  <span style={{
                    width: 40, height: 40, borderRadius: 999, flexShrink: 0, marginTop: 2,
                    background: TOK3.bgSoft,
                    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <Icon name={n.icon} size={17} color={TOK3.fgH} />
                  </span>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
                      <span style={{ fontSize: 14, fontWeight: n.unread ? 600 : 500, color: TOK3.fgH, lineHeight: 1.3 }}>{n.title}</span>
                      <span style={{ fontSize: 11, color: TOK3.fgPh, whiteSpace: 'nowrap', marginTop: 1 }}>{n.time}</span>
                    </div>
                    <div style={{ fontSize: 13, color: TOK3.fg2, marginTop: 3, lineHeight: 1.4 }}>{n.body}</div>
                  </div>
                  {n.unread && (
                    <span style={{ width: 8, height: 8, borderRadius: 999, background: TOK3.info, flexShrink: 0, marginTop: 6 }} />
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// SUPPORT SCREEN
// ════════════════════════════════════════════════════════════
function SupportScreen() {
  const { Screen, BackChip } = window;
  const faqs = [
    { q: 'How do I track my order?', a: 'Open the order from your Orders tab and tap Track order.' },
    { q: 'Can I cancel after placing?', a: 'Within 2 minutes of placing, cancellations are free. After that, a ₦200 fee applies.' },
    { q: 'My order arrived wrong', a: "Tap Report an issue on the order receipt and we'll resolve it within 24 hrs." },
    { q: 'How long does delivery take?', a: 'Typically 20–45 minutes depending on your distance from the vendor.' },
  ];
  const contacts = [
    { icon: 'msg',   label: 'Live chat',  sub: 'Usually replies in under 2 min', cta: 'Start chat' },
    { icon: 'phone', label: 'Call us',    sub: '+234 800 WAWUBasket', cta: 'Call' },
    { icon: 'bell',  label: 'Email us',   sub: 'support@wawu.africa', cta: 'Send email' },
  ];
  return (
    <Screen bg="#F7F7F7" height={1080}>
      <div style={{ padding: `12px ${PAD3}px 40px`, display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <BackChip />
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: TOK3.fgH, letterSpacing: '-0.015em' }}>Help &amp; support</h1>
        </div>

        {/* Search FAQ */}
        <div style={{ height: 52, background: TOK3.bg, borderRadius: 16, border: '1px solid transparent', padding: '0 18px', display: 'flex', alignItems: 'center', gap: 12, boxShadow: TOK3.shadow.card }}>
          <Icon name="search" size={20} color={TOK3.fgPh} />
          <span style={{ fontSize: 15, color: TOK3.fgPh }}>Search help articles</span>
        </div>

        {/* Contact options */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <EyebrowLabel>Contact us</EyebrowLabel>
          {contacts.map((c, i) => (
            <div key={i} style={{ background: TOK3.bg, borderRadius: 16, padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 14, boxShadow: TOK3.shadow.card }}>
              <span style={{ width: 44, height: 44, borderRadius: 999, background: TOK3.bgSoft, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Icon name={c.icon} size={18} color={TOK3.fgH} />
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: TOK3.fgH }}>{c.label}</div>
                <div style={{ fontSize: 12, color: TOK3.fg2, marginTop: 2 }}>{c.sub}</div>
              </div>
              <button style={{ padding: '9px 16px', borderRadius: 999, background: TOK3.dark, border: 'none', cursor: 'pointer', fontSize: 13, fontWeight: 500, color: '#fff', whiteSpace: 'nowrap' }}>
                {c.cta}
              </button>
            </div>
          ))}
        </div>

        {/* FAQs */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <SectionHead3 title="Common questions" action="See all" />
          <div style={{ background: TOK3.bg, borderRadius: TOK3.r.card, overflow: 'hidden', boxShadow: TOK3.shadow.card }}>
            {faqs.map((f, i) => (
              <div key={i} style={{
                padding: '16px 18px',
                borderBottom: i < faqs.length - 1 ? `1px solid ${TOK3.divider}` : 'none',
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
                  <span style={{ fontSize: 14, fontWeight: 500, color: TOK3.fgH, lineHeight: 1.4 }}>{f.q}</span>
                  <Icon name="chev" size={16} color={TOK3.fgPh} />
                </div>
                <div style={{ fontSize: 13, color: TOK3.fg2, marginTop: 6, lineHeight: 1.5 }}>{f.a}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Active ticket */}
        <div style={{ background: TOK3.bg, borderRadius: TOK3.r.card, padding: 18, boxShadow: TOK3.shadow.card, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <EyebrowLabel>Open ticket</EyebrowLabel>
            <span style={{ padding: '4px 10px', borderRadius: 999, background: 'rgba(245,158,11,0.12)', fontSize: 11, fontWeight: 600, color: '#b45309' }}>Pending</span>
          </div>
          <div style={{ fontSize: 14, fontWeight: 500, color: TOK3.fgH }}>Missing item — Order #8804</div>
          <div style={{ fontSize: 13, color: TOK3.fg2, lineHeight: 1.4 }}>Opened Mon 12 May. Our team will respond within 24 hrs.</div>
          <button style={{ alignSelf: 'flex-start', padding: '9px 16px', borderRadius: 999, background: TOK3.bgSoft, border: 'none', cursor: 'pointer', fontSize: 13, fontWeight: 500, color: TOK3.fgH }}>View ticket</button>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, {
  OrderHistoryScreen, FavoritesScreen, ProfileScreen,
  WalletScreen, NotificationsScreen, SupportScreen,
});
