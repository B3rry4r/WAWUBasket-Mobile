// WAWUBasket — Global System Screens
// Splash · Welcome · Login · Signup · OTP · Forgot · Reset · Role Select
//
// Visual rules: monochrome, soft shadows, Inter only, pill CTAs, 16px inputs,
// 24px cards, 20px horizontal safe area. Title Case on buttons, sentence case
// on body, no emoji. Voice = calm concierge.

const TOK = window.W;
const PADX = 20;
const SCREEN_W = 390;
const SCREEN_H = 844;
const LOGO_W_MARK = 'wb/logo-w-mark.svg';

// ════════════════════════════════════════════════════════════
// SHARED CHROME
// ════════════════════════════════════════════════════════════

// Status bar — slim, mocked. Dark variant inverts glyphs for dark surfaces.
function StatusBar({ dark = false }) {
  const c = dark ? '#FFFFFF' : '#1A1A1A';
  return (
    <div style={{
      height: 44, padding: '0 24px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      flexShrink: 0, position: 'relative', zIndex: 5,
    }}>
      <span style={{
        fontSize: 15, fontWeight: 600, color: c,
        fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.01em',
      }}>9:41</span>
      <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
        {/* Signal — 4 dots */}
        <svg width="17" height="11" viewBox="0 0 17 11" fill={c}>
          <rect x="0"  y="7" width="3" height="4" rx="0.5" />
          <rect x="5"  y="4" width="3" height="7" rx="0.5" />
          <rect x="10" y="2" width="3" height="9" rx="0.5" />
          <rect x="14" y="0" width="3" height="11" rx="0.5" />
        </svg>
        {/* Wi-Fi */}
        <svg width="15" height="11" viewBox="0 0 15 11" fill="none"
             stroke={c} strokeWidth="1.4" strokeLinecap="round">
          <path d="M1 3.4a10 10 0 0 1 13 0" />
          <path d="M3.4 6a6.5 6.5 0 0 1 8.2 0" />
          <path d="M5.8 8.4a3.2 3.2 0 0 1 3.4 0" />
          <circle cx="7.5" cy="10" r="0.6" fill={c} stroke="none" />
        </svg>
        {/* Battery */}
        <svg width="26" height="12" viewBox="0 0 26 12" fill="none">
          <rect x="0.5" y="0.5" width="22" height="11" rx="3" stroke={c} strokeOpacity="0.4" />
          <rect x="2"   y="2"   width="19" height="8"  rx="1.5" fill={c} />
          <rect x="23"  y="4"   width="1.5" height="4" rx="0.5" fill={c} fillOpacity="0.4" />
        </svg>
      </div>
    </div>
  );
}

function HomeIndicator({ dark = false }) {
  return (
    <div style={{
      position: 'absolute', bottom: 8, left: 0, right: 0,
      display: 'flex', justifyContent: 'center', pointerEvents: 'none',
    }}>
      <div style={{
        width: 134, height: 5, borderRadius: 999,
        background: dark ? '#FFFFFF' : '#1A1A1A',
      }} />
    </div>
  );
}

// Outer screen frame — 390 × 844, bg + status bar + home indicator. Children
// fill the body between status bar and home indicator.
function Screen({ children, bg = TOK.bg, statusDark = false }) {
  return (
    <div style={{
      width: SCREEN_W, height: SCREEN_H, background: bg, overflow: 'hidden',
      fontFamily: 'Inter, -apple-system, sans-serif',
      WebkitFontSmoothing: 'antialiased',
      position: 'relative', display: 'flex', flexDirection: 'column',
      color: TOK.fg,
    }}>
      <StatusBar dark={statusDark} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
        {children}
      </div>
      <HomeIndicator dark={statusDark} />
    </div>
  );
}

// W-mark — uses the brand asset. Optional padRight compensates for the
// asymmetric mass so the mark reads as visually centered.
function WMark({ size = 72, invert = false, padRight = true }) {
  return (
    <img
      src={LOGO_W_MARK}
      alt="WAWUBasket"
      style={{
        width: size, height: 'auto', display: 'block',
        filter: invert ? 'invert(1) brightness(2)' : 'none',
        paddingRight: padRight ? size * 0.13 : 0,
        boxSizing: 'content-box',
      }} />
  );
}

// Back chip — top-left circular back button. Floats inside top padding.
function BackChip({ onClick }) {
  return (
    <button onClick={onClick} style={{
      width: 44, height: 44, borderRadius: 999, border: 'none', cursor: 'pointer',
      background: TOK.bg, boxShadow: TOK.shadow.card,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
           stroke={TOK.fgH} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M15 6l-6 6 6 6" />
      </svg>
    </button>
  );
}

// Form field — label above input. Optional left icon and right adornment
// (e.g. country code or eye toggle). The label sits on the surface, not
// inside the input — keeps fields readable when filled.
function Field({ label, value, placeholder, type = 'text', leftIcon, right, helper, error }) {
  const [focused, setFocused] = React.useState(false);
  const filled = !!value;
  const showLabel = filled || focused;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && (
        <span style={{
          fontSize: 12, fontWeight: 500, color: TOK.fg2,
          letterSpacing: '0.01em',
        }}>{label}</span>
      )}
      <div style={{
        height: 52, padding: '0 18px',
        background: filled ? TOK.bg : TOK.input,
        border: `1px solid ${error ? TOK.error : (filled ? '#D4D4D4' : 'transparent')}`,
        borderRadius: TOK.r.input,
        display: 'flex', alignItems: 'center', gap: 12,
        transition: 'background 220ms, border-color 220ms',
      }}>
        {leftIcon && (
          <span style={{ color: TOK.fgPh, display: 'flex' }}>
            <Icon name={leftIcon} size={20} color={filled ? TOK.fgH : TOK.fgPh} />
          </span>
        )}
        <span style={{
          flex: 1, fontSize: 16, color: filled ? TOK.fgH : TOK.fgPh,
          whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
          fontVariantNumeric: type === 'tel' ? 'tabular-nums' : 'normal',
        }}>{filled ? value : placeholder}</span>
        {right}
      </div>
      {helper && (
        <span style={{ fontSize: 12, color: error ? TOK.error : TOK.fgPh, paddingLeft: 4 }}>
          {helper}
        </span>
      )}
    </div>
  );
}

// Primary CTA — full-width black pill.
function PrimaryCTA({ children, disabled = false, icon }) {
  return (
    <button disabled={disabled} style={{
      width: '100%', height: 56, borderRadius: 999, border: 'none',
      background: disabled ? TOK.bgSoft : TOK.dark,
      color: disabled ? TOK.fgDis : '#FFFFFF',
      fontSize: 16, fontWeight: 500, fontFamily: 'Inter, sans-serif',
      cursor: disabled ? 'not-allowed' : 'pointer',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      transition: 'transform 120ms cubic-bezier(.32,.72,0,1), background 220ms',
    }}>
      {children}
      {icon && <Icon name={icon} size={18} stroke={1.75} color="currentColor" />}
    </button>
  );
}

// Secondary CTA — outlined ghost pill (used sparingly).
function SecondaryCTA({ children, icon }) {
  return (
    <button style={{
      width: '100%', height: 56, borderRadius: 999,
      background: TOK.bg, color: TOK.fgH, border: `1px solid ${TOK.divider}`,
      fontSize: 16, fontWeight: 500, fontFamily: 'Inter, sans-serif', cursor: 'pointer',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 10,
      transition: 'background 220ms',
    }}>
      {icon && <Icon name={icon} size={18} color={TOK.fgH} />}
      {children}
    </button>
  );
}

// ════════════════════════════════════════════════════════════
// 1. SPLASH SCREEN
// ════════════════════════════════════════════════════════════
function SplashScreen() {
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 24,
      }}>
        <WMark size={108} />
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
          <span style={{
            fontSize: 28, fontWeight: 600, color: TOK.fgH, letterSpacing: '-0.02em',
          }}>WAWUBasket</span>
          <span style={{
            fontSize: 14, color: TOK.fgPh, letterSpacing: '0.01em',
          }}>Your everyday basket</span>
        </div>
      </div>
      {/* Loading dots at bottom */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 64,
        display: 'flex', justifyContent: 'center', gap: 6,
      }}>
        {[0, 1, 2].map(i => (
          <span key={i} style={{
            width: 6, height: 6, borderRadius: 999, background: TOK.fgDis,
            opacity: i === 0 ? 1 : (i === 1 ? 0.5 : 0.25),
          }} />
        ))}
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 2. WELCOME SCREEN
// ════════════════════════════════════════════════════════════
function WelcomeScreen() {
  const features = [
    { icon: 'basket', label: 'Order from markets and kitchens' },
    { icon: 'bike',   label: 'Track delivery in real time' },
    { icon: 'card',   label: 'Pay your way — card, transfer, wallet' },
  ];
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `28px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column',
      }}>
        {/* Logo top-left */}
        <WMark size={56} padRight={false} />

        {/* Hero text + features */}
        <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: 32 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <h1 style={{
              margin: 0, fontSize: 36, fontWeight: 600, color: TOK.fgH,
              letterSpacing: '-0.025em', lineHeight: 1.1,
            }}>
              Order what<br/>your city makes.
            </h1>
            <p style={{
              margin: 0, fontSize: 15, color: TOK.fg2, lineHeight: 1.5, maxWidth: 320,
            }}>
              Fresh markets, local kitchens and trusted vendors — delivered across your city.
            </p>
          </div>

          {/* Feature pills */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {features.map((f, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 14,
                padding: '14px 16px',
                background: TOK.bg2, borderRadius: TOK.r.card,
              }}>
                <span style={{
                  width: 36, height: 36, borderRadius: 999, background: TOK.bg,
                  display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <Icon name={f.icon} size={18} color={TOK.fgH} />
                </span>
                <span style={{ fontSize: 14, color: TOK.fgH, fontWeight: 500 }}>{f.label}</span>
              </div>
            ))}
          </div>
        </div>

        {/* CTAs pinned at bottom */}
        <div style={{
          marginTop: 32, paddingBottom: 32,
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          <PrimaryCTA>Create account</PrimaryCTA>
          <SecondaryCTA>Sign in</SecondaryCTA>
          <button style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            fontSize: 14, color: TOK.fgPh, fontWeight: 500,
            padding: '8px 0', marginTop: 4,
          }}>
            Continue as guest
          </button>
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 3. LOGIN SCREEN
// ════════════════════════════════════════════════════════════
function LoginScreen() {
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `12px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column', gap: 32,
      }}>
        <BackChip />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <h1 style={{
            margin: 0, fontSize: 32, fontWeight: 600, color: TOK.fgH,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>Sign in</h1>
          <p style={{ margin: 0, fontSize: 15, color: TOK.fg2, lineHeight: 1.5 }}>
            Welcome back. Pick up where you left off.
          </p>
        </div>

        {/* Form */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <Field
            label="Phone or email"
            value="brooks@wawu.africa"
            leftIcon="user"
          />
          <Field
            label="Password"
            value="••••••••••"
            leftIcon="card"
            right={
              <button style={{
                background: 'transparent', border: 'none', cursor: 'pointer',
                fontSize: 13, color: TOK.fg2, fontWeight: 500, padding: 0,
              }}>Show</button>
            }
          />

          <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
            <button style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              fontSize: 13, color: TOK.fgH, fontWeight: 500, padding: 0,
            }}>Forgot password?</button>
          </div>
        </div>

        {/* CTA + divider + biometric */}
        <div style={{ marginTop: 'auto', paddingBottom: 32, display: 'flex', flexDirection: 'column', gap: 16 }}>
          <PrimaryCTA icon="arrowR">Sign in</PrimaryCTA>

          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '4px 0' }}>
            <span style={{ flex: 1, height: 1, background: TOK.divider }} />
            <span style={{ fontSize: 12, color: TOK.fgPh, fontWeight: 500 }}>or</span>
            <span style={{ flex: 1, height: 1, background: TOK.divider }} />
          </div>

          <SecondaryCTA icon="user">Use Face ID</SecondaryCTA>

          <p style={{
            margin: '8px 0 0', textAlign: 'center', fontSize: 14, color: TOK.fg2,
          }}>
            New to WAWUBasket?{' '}
            <span style={{ color: TOK.fgH, fontWeight: 600 }}>Create account</span>
          </p>
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 4. SIGNUP SCREEN
// ════════════════════════════════════════════════════════════
function SignupScreen() {
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `12px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column', gap: 24, overflow: 'hidden',
      }}>
        <BackChip />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <h1 style={{
            margin: 0, fontSize: 32, fontWeight: 600, color: TOK.fgH,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>Create your account</h1>
          <p style={{ margin: 0, fontSize: 15, color: TOK.fg2, lineHeight: 1.5 }}>
            Takes less than a minute.
          </p>
        </div>

        {/* Form */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field label="Full name" value="Brooks Adesanya" leftIcon="user" />
          <Field
            label="Phone number"
            value="803 421 1820"
            leftIcon="phone"
            type="tel"
            right={
              <span style={{
                display: 'inline-flex', alignItems: 'center', gap: 4,
                padding: '6px 10px', background: TOK.bgSoft, borderRadius: 999,
                fontSize: 13, fontWeight: 500, color: TOK.fgH,
                fontVariantNumeric: 'tabular-nums',
              }}>
                +234
                <Icon name="chevD" size={12} color={TOK.fg2} />
              </span>
            }
          />
          <Field label="Email" value="brooks@wawu.africa" leftIcon="user" />
          <Field
            label="Password"
            placeholder="At least 8 characters"
            leftIcon="card"
          />
        </div>

        {/* Terms + CTA pinned bottom */}
        <div style={{ marginTop: 'auto', paddingBottom: 32, display: 'flex', flexDirection: 'column', gap: 18 }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
            <span style={{
              width: 20, height: 20, borderRadius: 6, background: TOK.dark,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0, marginTop: 1,
            }}>
              <Icon name="check" size={12} stroke={2.5} color="#fff" />
            </span>
            <span style={{ fontSize: 13, color: TOK.fg2, lineHeight: 1.5 }}>
              I agree to the{' '}
              <span style={{ color: TOK.fgH, fontWeight: 500, textDecoration: 'underline', textUnderlineOffset: 2 }}>Terms</span>{' '}
              and{' '}
              <span style={{ color: TOK.fgH, fontWeight: 500, textDecoration: 'underline', textUnderlineOffset: 2 }}>Privacy Policy</span>.
            </span>
          </div>

          <PrimaryCTA icon="arrowR">Continue</PrimaryCTA>

          <p style={{ margin: 0, textAlign: 'center', fontSize: 14, color: TOK.fg2 }}>
            Already have an account?{' '}
            <span style={{ color: TOK.fgH, fontWeight: 600 }}>Sign in</span>
          </p>
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 5. OTP VERIFICATION SCREEN
// ════════════════════════════════════════════════════════════
function OTPScreen() {
  const digits = ['8', '1', '4', '2', '', ''];
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `12px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column', gap: 32,
      }}>
        <BackChip />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <h1 style={{
            margin: 0, fontSize: 32, fontWeight: 600, color: TOK.fgH,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>Enter the code</h1>
          <p style={{ margin: 0, fontSize: 15, color: TOK.fg2, lineHeight: 1.5 }}>
            We sent a 6-digit code to{' '}
            <span style={{ color: TOK.fgH, fontWeight: 500, fontVariantNumeric: 'tabular-nums' }}>
              +234 803 ••• 1820
            </span>
          </p>
          <button style={{
            alignSelf: 'flex-start', marginTop: 4,
            background: 'transparent', border: 'none', padding: 0, cursor: 'pointer',
            fontSize: 13, color: TOK.fgH, fontWeight: 500,
            display: 'inline-flex', alignItems: 'center', gap: 4,
          }}>
            <Icon name="phone" size={13} color={TOK.fgH} />
            Edit number
          </button>
        </div>

        {/* 6-digit boxes */}
        <div style={{ display: 'flex', gap: 10, justifyContent: 'space-between' }}>
          {digits.map((d, i) => {
            const filled = d !== '';
            const active = i === digits.findIndex(x => x === '');
            return (
              <div key={i} style={{
                width: 50, height: 60, borderRadius: 14,
                background: filled ? TOK.bg : TOK.input,
                border: `1.5px solid ${active ? TOK.fgH : (filled ? TOK.divider : 'transparent')}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 24, fontWeight: 600, color: TOK.fgH,
                fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.01em',
                position: 'relative',
              }}>
                {d || (active && (
                  <span style={{
                    width: 2, height: 24, background: TOK.fgH, borderRadius: 1,
                    animation: 'wbblink 1s steps(2) infinite',
                  }} />
                ))}
              </div>
            );
          })}
        </div>

        {/* Resend countdown */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          fontSize: 13, color: TOK.fgPh,
        }}>
          Resend code in
          <span style={{ fontWeight: 600, color: TOK.fgH, fontVariantNumeric: 'tabular-nums' }}>0:42</span>
        </div>

        <div style={{ marginTop: 'auto', paddingBottom: 32 }}>
          <PrimaryCTA disabled>Verify</PrimaryCTA>
        </div>
      </div>
      <style>{`@keyframes wbblink { 0%{opacity:1} 50%{opacity:0} 100%{opacity:1} }`}</style>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 6. FORGOT PASSWORD SCREEN
// ════════════════════════════════════════════════════════════
function ForgotPasswordScreen() {
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `12px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column', gap: 28,
      }}>
        <BackChip />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <h1 style={{
            margin: 0, fontSize: 32, fontWeight: 600, color: TOK.fgH,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>Reset password</h1>
          <p style={{ margin: 0, fontSize: 15, color: TOK.fg2, lineHeight: 1.5 }}>
            Tell us where to send a verification code and we'll help you back in.
          </p>
        </div>

        <Field
          label="Phone or email"
          value="brooks@wawu.africa"
          leftIcon="user"
        />

        {/* Method picker */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <span style={{
            fontSize: 11, fontWeight: 600, letterSpacing: '0.06em',
            textTransform: 'uppercase', color: TOK.fgPh,
          }}>Send code via</span>
          <div style={{ display: 'flex', gap: 10 }}>
            {[
              { id: 'sms', label: 'SMS', sub: '+234 803 ••• 1820', active: true },
              { id: 'email', label: 'Email', sub: 'brooks@…africa', active: false },
            ].map(m => (
              <div key={m.id} style={{
                flex: 1, padding: 14, borderRadius: TOK.r.card,
                background: m.active ? TOK.bg : TOK.bg2,
                border: `1.5px solid ${m.active ? TOK.fgH : 'transparent'}`,
                display: 'flex', flexDirection: 'column', gap: 4,
                cursor: 'pointer',
              }}>
                <span style={{ fontSize: 14, fontWeight: 600, color: TOK.fgH }}>{m.label}</span>
                <span style={{ fontSize: 11, color: TOK.fg2 }}>{m.sub}</span>
              </div>
            ))}
          </div>
        </div>

        <div style={{ marginTop: 'auto', paddingBottom: 32, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <PrimaryCTA icon="arrowR">Send code</PrimaryCTA>
          <p style={{ margin: 0, textAlign: 'center', fontSize: 13, color: TOK.fgPh }}>
            Didn't get a code last time?{' '}
            <span style={{ color: TOK.fgH, fontWeight: 500 }}>Contact support</span>
          </p>
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 7. RESET PASSWORD SCREEN
// ════════════════════════════════════════════════════════════
function ResetPasswordScreen() {
  const rules = [
    { ok: true,  label: 'At least 8 characters' },
    { ok: true,  label: 'One uppercase letter' },
    { ok: true,  label: 'One number' },
    { ok: false, label: 'One symbol' },
  ];
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `12px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column', gap: 28,
      }}>
        <BackChip />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <h1 style={{
            margin: 0, fontSize: 32, fontWeight: 600, color: TOK.fgH,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>Choose a new<br/>password</h1>
          <p style={{ margin: 0, fontSize: 15, color: TOK.fg2, lineHeight: 1.5 }}>
            Make it different from your last one.
          </p>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field
            label="New password"
            value="••••••••••••"
            right={
              <button style={{
                background: 'transparent', border: 'none', cursor: 'pointer',
                fontSize: 13, color: TOK.fg2, fontWeight: 500, padding: 0,
              }}>Show</button>
            }
          />
          <Field
            label="Confirm password"
            value="••••••••••••"
          />
        </div>

        {/* Validation checklist */}
        <div style={{
          padding: 16, background: TOK.bg2, borderRadius: TOK.r.card,
          display: 'flex', flexDirection: 'column', gap: 10,
        }}>
          {rules.map((r, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <span style={{
                width: 18, height: 18, borderRadius: 999,
                background: r.ok ? TOK.dark : TOK.divider,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                {r.ok ? (
                  <Icon name="check" size={11} stroke={2.5} color="#fff" />
                ) : (
                  <span style={{ width: 4, height: 4, borderRadius: 999, background: TOK.bg }} />
                )}
              </span>
              <span style={{
                fontSize: 13, color: r.ok ? TOK.fgH : TOK.fgPh,
                textDecoration: r.ok ? 'none' : 'none', fontWeight: r.ok ? 500 : 400,
              }}>{r.label}</span>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 'auto', paddingBottom: 32 }}>
          <PrimaryCTA icon="arrowR">Save password</PrimaryCTA>
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════════════════════════════════════════
// 8. ROLE SELECT SCREEN
// ════════════════════════════════════════════════════════════
function RoleSelectScreen() {
  const roles = [
    {
      id: 'customer', title: 'Customer', icon: 'basket',
      desc: 'Order food, groceries and household goods.',
      selected: true,
    },
    {
      id: 'vendor', title: 'Vendor', icon: 'home',
      desc: 'Sell from your kitchen, store or stall.',
    },
    {
      id: 'rider', title: 'Rider', icon: 'bike',
      desc: 'Deliver across your city and earn flexibly.',
    },
    {
      id: 'agent', title: 'Trade Agent', icon: 'card',
      desc: 'Coordinate bulk trade and transport.',
    },
  ];
  return (
    <Screen bg="#FFFFFF">
      <div style={{
        flex: 1, padding: `12px ${PADX}px 0`,
        display: 'flex', flexDirection: 'column', gap: 24, overflow: 'hidden',
      }}>
        {/* Top row: back + skip */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <BackChip />
          <button style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            fontSize: 14, color: TOK.fg2, fontWeight: 500, padding: '4px 8px',
          }}>Skip</button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <h1 style={{
            margin: 0, fontSize: 30, fontWeight: 600, color: TOK.fgH,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>How will you use<br/>WAWUBasket?</h1>
          <p style={{ margin: 0, fontSize: 14, color: TOK.fg2, lineHeight: 1.5 }}>
            Pick what you'll do most. You can switch roles anytime from your profile.
          </p>
        </div>

        {/* Role cards */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {roles.map(r => (
            <div key={r.id} style={{
              padding: 16,
              background: r.selected ? TOK.dark : TOK.bg,
              border: `1.5px solid ${r.selected ? TOK.dark : TOK.divider}`,
              borderRadius: TOK.r.card,
              display: 'flex', alignItems: 'center', gap: 14,
              cursor: 'pointer', transition: 'all 220ms',
            }}>
              <span style={{
                width: 44, height: 44, borderRadius: 14,
                background: r.selected ? 'rgba(255,255,255,0.12)' : TOK.bg2,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                <Icon name={r.icon} size={20} color={r.selected ? '#fff' : TOK.fgH} />
              </span>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
                <span style={{
                  fontSize: 15, fontWeight: 600,
                  color: r.selected ? '#fff' : TOK.fgH, letterSpacing: '-0.005em',
                }}>{r.title}</span>
                <span style={{
                  fontSize: 12,
                  color: r.selected ? 'rgba(255,255,255,0.65)' : TOK.fg2,
                  lineHeight: 1.4,
                }}>{r.desc}</span>
              </div>
              {/* Selected ring */}
              <span style={{
                width: 22, height: 22, borderRadius: 999, flexShrink: 0,
                background: r.selected ? '#fff' : 'transparent',
                border: `1.5px solid ${r.selected ? '#fff' : TOK.divider}`,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {r.selected && <Icon name="check" size={12} stroke={2.5} color={TOK.dark} />}
              </span>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 'auto', paddingBottom: 32 }}>
          <PrimaryCTA icon="arrowR">Continue as Customer</PrimaryCTA>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, {
  SplashScreen, WelcomeScreen, LoginScreen, SignupScreen,
  OTPScreen, ForgotPasswordScreen, ResetPasswordScreen, RoleSelectScreen,
  // Shared screen primitives — reused by customer-flow files
  Screen, StatusBar, HomeIndicator, BackChip, Field, PrimaryCTA, SecondaryCTA, WMark,
});
