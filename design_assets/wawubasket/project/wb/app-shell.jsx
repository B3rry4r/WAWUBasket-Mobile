// WAWUBasket — App Shell
// The persistent bottom navigation that lives across the 4 tab destinations:
// Home · Favorites · Orders · Profile.
//
// Matches the dark-pill nav pattern from the verified Customer Home — same
// floating black pill, same active treatment (white capsule with label).
// Search is NOT a tab — it's pushed from the home search bar.

const W_NAV = window.W;

function AppNav({ active = 'home' }) {
  const items = [
    { id: 'home',      icon: 'home',   label: 'Home' },
    { id: 'favorites', icon: 'heart',  label: 'Favorites' },
    { id: 'orders',    icon: 'basket', label: 'Orders' },
    { id: 'profile',   icon: 'user',   label: 'Profile' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 20, right: 20, bottom: 28,
      background: W_NAV.dark, borderRadius: 999, padding: 8,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      boxShadow: '0 12px 32px rgba(0,0,0,0.18)',
      zIndex: 30,
    }}>
      {items.map(it => {
        const isActive = it.id === active;
        return isActive ? (
          <div key={it.id} style={{
            display: 'flex', alignItems: 'center', gap: 8,
            background: '#fff', color: W_NAV.fgH,
            padding: '10px 18px 10px 12px', borderRadius: 999,
          }}>
            <span style={{
              width: 28, height: 28, borderRadius: 999, background: W_NAV.fgH,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0,
            }}>
              <Icon name={it.icon} size={15} color="#fff" />
            </span>
            <span style={{ fontSize: 13, fontWeight: 600, letterSpacing: '-0.005em' }}>{it.label}</span>
          </div>
        ) : (
          <button key={it.id} style={{
            width: 44, height: 44, borderRadius: 999, background: 'transparent', border: 'none',
            display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
          }}>
            <Icon name={it.icon} size={20} color="rgba(255,255,255,0.85)" />
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, { AppNav });
