// Etapa 1 — Splash + Onboarding
// Depends on globals from glass.jsx

// ═══════════════════════════════════════════════
// SPLASH
// ═══════════════════════════════════════════════
function SplashScreen({ onDone }) {
  React.useEffect(() => {
    const t = setTimeout(onDone, 2200);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <div className="screen-enter" style={{
      position: 'absolute', inset: 0,
      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
      gap: 24,
    }}>
      {/* halo */}
      <div style={{
        position: 'absolute', width: 360, height: 360, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(255,110,199,0.35), transparent 60%)',
        filter: 'blur(40px)',
        animation: 'haloPulse 2.2s ease-in-out infinite',
      }} />

      {/* logo mark */}
      <div style={{
        position: 'relative',
        width: 116, height: 116, borderRadius: 36,
        background: 'linear-gradient(135deg, #ff6ec7, #c084fc 55%, #6e8aff)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 30px 80px rgba(192,132,252,0.55), inset 0 2px 0 rgba(255,255,255,0.5), inset 0 -2px 0 rgba(0,0,0,0.15)',
        animation: 'logoIn 700ms cubic-bezier(.32,1.6,.32,1) both',
      }}>
        {/* inner glass disc */}
        <div className="glass-strong" style={{
          width: 76, height: 76, borderRadius: 22,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          background: 'rgba(255,255,255,0.22)',
        }}>
          <svg width="44" height="44" viewBox="0 0 44 44" fill="none">
            <path d="M14 10h12a6 6 0 0 1 0 12h-8m0 0h8a6 6 0 0 1 0 12H14m4-24v28M9 16h6M9 28h13"
              stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
      </div>

      {/* wordmark */}
      <div style={{
        textAlign: 'center',
        animation: 'wordIn 700ms 220ms cubic-bezier(.32,.72,.24,1) both',
      }}>
        <div style={{
          fontSize: 34, fontWeight: 800, letterSpacing: -1,
          background: 'linear-gradient(135deg, #fff, rgba(255,255,255,0.7))',
          WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
        }}>Finanças</div>
        <div style={{ color: 'var(--muted)', fontSize: 13, fontWeight: 500, marginTop: 4, letterSpacing: 0.3 }}>
          seu dinheiro, sem mistério
        </div>
      </div>

      {/* loader */}
      <div style={{
        position: 'absolute', bottom: 88,
        display: 'flex', gap: 6,
      }}>
        {[0,1,2].map(i => (
          <span key={i} style={{
            width: 6, height: 6, borderRadius: 4,
            background: 'rgba(255,255,255,0.8)',
            animation: `dotPulse 1.2s ${i * 0.15}s ease-in-out infinite`,
          }} />
        ))}
      </div>

      <style>{`
        @keyframes haloPulse {
          0%, 100% { transform: scale(1); opacity: 0.7; }
          50% { transform: scale(1.15); opacity: 1; }
        }
        @keyframes logoIn {
          from { opacity: 0; transform: scale(0.6); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes wordIn {
          from { opacity: 0; transform: translateY(10px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes dotPulse {
          0%, 100% { opacity: 0.3; transform: scale(0.85); }
          50%      { opacity: 1;   transform: scale(1.2); }
        }
      `}</style>
    </div>
  );
}

// ═══════════════════════════════════════════════
// ONBOARDING — 3 pages, swipeable + paginated
// ═══════════════════════════════════════════════
const ONB_PAGES = [
  {
    id: 'control',
    eyebrow: 'CONTROLE',
    title: 'Todas as suas contas em um só lugar',
    body: 'Cadastre contas fixas e variáveis, defina recorrência e nunca mais perca um vencimento.',
    art: 'wallet',
    accent: '#ff6ec7',
  },
  {
    id: 'insights',
    eyebrow: 'CLAREZA',
    title: 'Veja para onde seu dinheiro vai',
    body: 'Análise mensal por categoria, comparação entre renda e gastos e indicadores de saúde financeira.',
    art: 'donut',
    accent: '#c084fc',
  },
  {
    id: 'alerts',
    eyebrow: 'TRANQUILIDADE',
    title: 'Lembretes na hora certa',
    body: 'Receba avisos antes do vencimento e evite juros, multas ou aquela conta esquecida.',
    art: 'bell',
    accent: '#6e8aff',
  },
];

function OnboardingScreen({ onDone }) {
  const [page, setPage] = React.useState(0);
  const total = ONB_PAGES.length;
  const isLast = page === total - 1;
  const current = ONB_PAGES[page];

  // swipe support
  const startX = React.useRef(null);
  const onTouchStart = (e) => { startX.current = e.touches[0].clientX; };
  const onTouchEnd = (e) => {
    if (startX.current == null) return;
    const dx = e.changedTouches[0].clientX - startX.current;
    if (dx < -40 && page < total - 1) setPage(page + 1);
    if (dx >  40 && page > 0)         setPage(page - 1);
    startX.current = null;
  };

  return (
    <div className="screen-enter" style={{
      position: 'absolute', inset: 0,
      display: 'flex', flexDirection: 'column',
      paddingTop: 0,
    }}
      onTouchStart={onTouchStart} onTouchEnd={onTouchEnd}
    >
      {/* skip */}
      <div style={{ padding: '8px 20px', display: 'flex', justifyContent: 'flex-end' }}>
        {!isLast && (
          <button onClick={onDone} className="tap" style={{
            border: 'none', background: 'transparent', cursor: 'pointer',
            color: 'var(--muted)', fontSize: 14, fontWeight: 600, padding: '6px 4px',
          }}>Pular</button>
        )}
      </div>

      {/* art */}
      <div style={{
        flex: 1, minHeight: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        position: 'relative',
      }}>
        <OnbArt key={current.id} kind={current.art} accent={current.accent} />
      </div>

      {/* dots */}
      <div style={{ display: 'flex', justifyContent: 'center', gap: 8, padding: '8px 0 12px' }}>
        {ONB_PAGES.map((_, i) => (
          <button key={i} onClick={() => setPage(i)} className="tap" style={{
            border: 'none', cursor: 'pointer', padding: 0,
            width: i === page ? 22 : 8, height: 8, borderRadius: 4,
            background: i === page ? 'linear-gradient(135deg, #ff6ec7, #c084fc)' : 'rgba(255,255,255,0.22)',
            boxShadow: i === page ? '0 4px 12px rgba(255,110,199,0.4)' : 'none',
            transition: 'width 280ms cubic-bezier(.32,.72,.24,1)',
          }} />
        ))}
      </div>

      {/* text card */}
      <div style={{ padding: '0 20px 28px' }}>
        <div key={current.id} className="modal-enter">
          <div style={{
            color: current.accent, fontSize: 12, fontWeight: 700, letterSpacing: 1.4,
          }}>{current.eyebrow}</div>
          <div style={{
            fontSize: 28, fontWeight: 800, letterSpacing: -0.6, lineHeight: 1.1,
            marginTop: 8, textWrap: 'pretty',
          }}>{current.title}</div>
          <div style={{
            fontSize: 15, color: 'var(--muted)', lineHeight: 1.45, marginTop: 10, textWrap: 'pretty',
          }}>{current.body}</div>
        </div>

        {/* CTA */}
        <div style={{ display: 'flex', gap: 10, marginTop: 22 }}>
          {page > 0 && (
            <button onClick={() => setPage(page - 1)} className="tap glass shine" style={{
              border: 'none', cursor: 'pointer', padding: '14px 18px',
              borderRadius: 18, color: '#fff', fontSize: 15, fontWeight: 600,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}>
              <Icon name="back" size={16} />
            </button>
          )}
          <button
            onClick={() => isLast ? onDone() : setPage(page + 1)}
            className="tap"
            style={{
              flex: 1, border: 'none', cursor: 'pointer',
              padding: '15px 20px', borderRadius: 18,
              background: 'linear-gradient(135deg, #ff6ec7, #c084fc 60%, #6e8aff)',
              color: '#fff', fontSize: 15, fontWeight: 700,
              boxShadow: '0 12px 28px rgba(192,132,252,0.45), inset 0 1px 0 rgba(255,255,255,0.4)',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              letterSpacing: 0.2,
            }}
          >
            {isLast ? 'Começar agora' : 'Próximo'}
            <Icon name="chevron" size={16} strokeWidth={2.4} />
          </button>
        </div>

        {isLast && (
          <div style={{ textAlign: 'center', marginTop: 14, color: 'var(--dim)', fontSize: 12 }}>
            Ao continuar, você concorda com os <span style={{ color: 'var(--muted)', textDecoration: 'underline' }}>Termos</span> e <span style={{ color: 'var(--muted)', textDecoration: 'underline' }}>Privacidade</span>.
          </div>
        )}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════
// Onboarding ART — illustrative glass pieces, no photos
// ═══════════════════════════════════════════════
function OnbArt({ kind, accent }) {
  if (kind === 'wallet') return <ArtWallet accent={accent} />;
  if (kind === 'donut')  return <ArtDonut accent={accent} />;
  if (kind === 'bell')   return <ArtBell accent={accent} />;
  return null;
}

function ArtFrame({ children, accent }) {
  return (
    <div style={{
      position: 'relative',
      width: 280, height: 280,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      animation: 'artIn 600ms cubic-bezier(.32,1.4,.32,1) both',
    }}>
      {/* glow */}
      <div style={{
        position: 'absolute', inset: -20,
        background: `radial-gradient(circle, ${accent}55, transparent 65%)`,
        filter: 'blur(30px)',
      }} />
      {children}
      <style>{`
        @keyframes artIn {
          from { opacity: 0; transform: scale(0.85) translateY(20px); }
          to   { opacity: 1; transform: scale(1) translateY(0); }
        }
        @keyframes floatY {
          0%,100% { transform: translateY(0); }
          50%     { transform: translateY(-8px); }
        }
        @keyframes spinSlow { from { transform: rotate(0); } to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}

// ── Wallet art: 3 stacked glass cards ──
function ArtWallet({ accent }) {
  return (
    <ArtFrame accent={accent}>
      {/* back card */}
      <div className="glass" style={{
        position: 'absolute', width: 200, height: 124, borderRadius: 22,
        transform: 'translate(-44px, -50px) rotate(-10deg)',
        background: 'linear-gradient(135deg, rgba(110,138,255,0.55), rgba(110,138,255,0.15))',
        boxShadow: '0 14px 30px rgba(110,138,255,0.35), inset 0 1px 0 rgba(255,255,255,0.45)',
        animation: 'floatY 5s ease-in-out infinite',
      }}>
        <div style={{ padding: 16 }}>
          <div style={{ width: 28, height: 18, borderRadius: 4, background: 'linear-gradient(135deg, #ffd560, #c08530)', boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.4)' }} />
          <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 600, marginTop: 36, letterSpacing: 1, color: 'rgba(255,255,255,0.7)' }}>•••• 4231</div>
        </div>
      </div>
      {/* mid card */}
      <div className="glass-strong shine" style={{
        position: 'absolute', width: 220, height: 138, borderRadius: 24,
        transform: 'translate(0, 0) rotate(0deg)',
        background: 'linear-gradient(135deg, rgba(192,132,252,0.7), rgba(192,132,252,0.25))',
        boxShadow: '0 18px 40px rgba(192,132,252,0.45), inset 0 1px 0 rgba(255,255,255,0.5)',
        animation: 'floatY 5s 0.5s ease-in-out infinite',
      }}>
        <div style={{ padding: 18, position: 'relative', height: '100%' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ width: 32, height: 22, borderRadius: 5, background: 'linear-gradient(135deg, #ffd560, #c08530)', boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.5)' }} />
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1 }}>FINANÇAS</div>
          </div>
          <div style={{ position: 'absolute', bottom: 14, left: 18, right: 18 }}>
            <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.7)', fontWeight: 600, letterSpacing: 1 }}>SALDO</div>
            <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.5, fontVariantNumeric: 'tabular-nums', marginTop: 2 }}>R$ 4.213</div>
          </div>
        </div>
      </div>
      {/* front coin */}
      <div className="glass-strong" style={{
        position: 'absolute', width: 64, height: 64, borderRadius: 32,
        transform: 'translate(70px, 78px)',
        background: 'linear-gradient(135deg, #ffd560, #c08530)',
        boxShadow: '0 14px 28px rgba(255,213,96,0.5), inset 0 2px 0 rgba(255,255,255,0.5), inset 0 -2px 0 rgba(0,0,0,0.15)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        animation: 'floatY 4s 1s ease-in-out infinite',
        color: '#5a3a00', fontWeight: 800, fontSize: 28,
      }}>R$</div>
    </ArtFrame>
  );
}

// ── Donut art: spinning category donut ──
function ArtDonut({ accent }) {
  const segs = [
    { color: '#ff6ec7', pct: 32 },
    { color: '#c084fc', pct: 22 },
    { color: '#6e8aff', pct: 18 },
    { color: '#6affc4', pct: 14 },
    { color: '#ffc56e', pct: 14 },
  ];
  const R = 86, C = 2 * Math.PI * R;
  let acc = 0;
  return (
    <ArtFrame accent={accent}>
      <div style={{ position: 'relative', width: 220, height: 220, animation: 'floatY 5s ease-in-out infinite' }}>
        <svg width="220" height="220" viewBox="0 0 220 220" style={{ transform: 'rotate(-90deg)', filter: 'drop-shadow(0 8px 20px rgba(0,0,0,0.25))' }}>
          <circle cx="110" cy="110" r={R} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="22" />
          {segs.map((s, i) => {
            const len = (s.pct / 100) * C;
            const el = <circle key={i} cx="110" cy="110" r={R} fill="none"
              stroke={s.color} strokeWidth="22"
              strokeDasharray={`${len - 4} ${C}`} strokeDashoffset={-acc}
              style={{ filter: `drop-shadow(0 0 8px ${s.color}80)` }} />;
            acc += len;
            return el;
          })}
        </svg>
        {/* center glass */}
        <div className="glass-strong shine" style={{
          position: 'absolute', inset: 38, borderRadius: '50%',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{ fontSize: 11, color: 'var(--muted)', fontWeight: 700, letterSpacing: 1 }}>MAIO</div>
          <div style={{ fontSize: 32, fontWeight: 800, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>62%</div>
          <div style={{ fontSize: 11, color: 'var(--muted)', fontWeight: 600 }}>comprometido</div>
        </div>
        {/* floating category chips */}
        <div className="glass-strong" style={{
          position: 'absolute', top: -8, right: -10, padding: '6px 10px', borderRadius: 14,
          fontSize: 11, fontWeight: 700, display: 'inline-flex', alignItems: 'center', gap: 5,
          animation: 'floatY 4s 0.3s ease-in-out infinite',
        }}>
          <span style={{ width: 8, height: 8, borderRadius: 4, background: '#ff6ec7' }} />Moradia
        </div>
        <div className="glass-strong" style={{
          position: 'absolute', bottom: 10, left: -22, padding: '6px 10px', borderRadius: 14,
          fontSize: 11, fontWeight: 700, display: 'inline-flex', alignItems: 'center', gap: 5,
          animation: 'floatY 5s 0.8s ease-in-out infinite reverse',
        }}>
          <span style={{ width: 8, height: 8, borderRadius: 4, background: '#6e8aff' }} />Assinaturas
        </div>
      </div>
    </ArtFrame>
  );
}

// ── Bell art: notification with attached bill cards ──
function ArtBell({ accent }) {
  return (
    <ArtFrame accent={accent}>
      {/* Bell */}
      <div style={{
        position: 'absolute', width: 120, height: 120, borderRadius: 36,
        transform: 'translate(0, -20px)',
        background: 'linear-gradient(135deg, #6e8aff, #c084fc)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 18px 40px rgba(110,138,255,0.5), inset 0 2px 0 rgba(255,255,255,0.5)',
        animation: 'bellWiggle 2.4s ease-in-out infinite',
      }}>
        <svg width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
          <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9M10 21a2 2 0 0 0 4 0"/>
        </svg>
        {/* badge */}
        <div style={{
          position: 'absolute', top: 8, right: 8,
          width: 22, height: 22, borderRadius: 11,
          background: '#ff5a7a',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 11, fontWeight: 800, color: '#fff',
          boxShadow: '0 4px 12px rgba(255,90,122,0.5), inset 0 1px 0 rgba(255,255,255,0.4)',
        }}>3</div>
      </div>
      {/* notification cards */}
      <div className="glass-strong shine" style={{
        position: 'absolute', width: 230, padding: '10px 12px', borderRadius: 16,
        transform: 'translate(0, 80px)',
        display: 'flex', alignItems: 'center', gap: 10,
        animation: 'floatY 5s 0.2s ease-in-out infinite',
      }}>
        <div style={{ width: 32, height: 32, borderRadius: 10, background: 'linear-gradient(135deg, #ff6ec7cc, #ff6ec766)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="home" size={16} color="#fff" />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 12, fontWeight: 700 }}>Aluguel vence amanhã</div>
          <div style={{ fontSize: 10, color: 'var(--muted)', marginTop: 1 }}>R$ 1.850 · Moradia</div>
        </div>
        <div style={{ fontSize: 9, fontWeight: 700, color: '#ffc56e' }}>1d</div>
      </div>
      <div className="glass shine" style={{
        position: 'absolute', width: 200, padding: '8px 10px', borderRadius: 14,
        transform: 'translate(20px, 130px)',
        display: 'flex', alignItems: 'center', gap: 8,
        opacity: 0.85,
        animation: 'floatY 5s 0.9s ease-in-out infinite',
      }}>
        <div style={{ width: 26, height: 26, borderRadius: 8, background: 'linear-gradient(135deg, #c084fccc, #c084fc66)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="play" size={13} color="#fff" />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 11, fontWeight: 700 }}>Netflix em 3 dias</div>
        </div>
      </div>

      <style>{`
        @keyframes bellWiggle {
          0%, 100% { transform: translate(0, -20px) rotate(0); }
          10%, 30% { transform: translate(0, -20px) rotate(-12deg); }
          20%, 40% { transform: translate(0, -20px) rotate(12deg); }
          50%, 100% { transform: translate(0, -20px) rotate(0); }
        }
      `}</style>
    </ArtFrame>
  );
}

Object.assign(window, { SplashScreen, OnboardingScreen });
