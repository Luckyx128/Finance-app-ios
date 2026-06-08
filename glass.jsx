// Glass primitives, icons, helpers — shared by all screens

// ───────── Money / date helpers ─────────
const fmtBRL = (v) => {
  if (v == null || isNaN(v)) return 'R$ 0,00';
  return v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
};
const fmtBRLshort = (v) => {
  if (v == null || isNaN(v)) return 'R$ 0';
  if (Math.abs(v) >= 1000) {
    const k = (v / 1000);
    return 'R$ ' + (Math.round(k * 10) / 10).toString().replace('.', ',') + 'k';
  }
  return 'R$ ' + Math.round(v);
};
const parseBRL = (s) => {
  if (!s) return 0;
  const cleaned = s.toString().replace(/[^\d,.-]/g, '').replace(/\./g, '').replace(',', '.');
  return parseFloat(cleaned) || 0;
};
const fmtDate = (iso) => {
  if (!iso) return '';
  const [y, m, d] = iso.split('-');
  return `${d}/${m}/${y}`;
};
const fmtDateShort = (iso) => {
  if (!iso) return '';
  const [y, m, d] = iso.split('-');
  const months = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'];
  return `${d} ${months[parseInt(m,10)-1]}`;
};
const daysUntil = (iso) => {
  if (!iso) return 999;
  const today = new Date(); today.setHours(0,0,0,0);
  const target = new Date(iso + 'T00:00:00');
  return Math.round((target - today) / 86400000);
};
const todayIso = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
};

// ───────── Categories ─────────
const CATEGORIES = [
  { id: 'moradia',    label: 'Moradia',       icon: 'home',    color: '#ff6ec7' },
  { id: 'casa',       label: 'Contas de casa',icon: 'bolt',    color: '#ffc56e' },
  { id: 'cartao',     label: 'Cartão',        icon: 'card',    color: '#6e8aff' },
  { id: 'assinaturas',label: 'Assinaturas',   icon: 'play',    color: '#c084fc' },
  { id: 'transporte', label: 'Transporte',    icon: 'car',     color: '#6affc4' },
  { id: 'saude',      label: 'Saúde',         icon: 'heart',   color: '#ff5a7a' },
  { id: 'educacao',   label: 'Educação',      icon: 'book',    color: '#f0abfc' },
  { id: 'lazer',      label: 'Lazer',         icon: 'sparkle', color: '#7dd3fc' },
];
const catById = (id) => CATEGORIES.find(c => c.id === id) || CATEGORIES[0];

// ───────── Icon ─────────
function Icon({ name, size = 20, color = 'currentColor', strokeWidth = 1.8 }) {
  const s = { width: size, height: size, fill: 'none', stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const filled = { width: size, height: size, fill: color };
  switch (name) {
    case 'home': return <svg viewBox="0 0 24 24" {...s}><path d="M3 11l9-7 9 7v9a2 2 0 0 1-2 2h-4v-6h-6v6H5a2 2 0 0 1-2-2z"/></svg>;
    case 'bolt': return <svg viewBox="0 0 24 24" {...s}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></svg>;
    case 'card': return <svg viewBox="0 0 24 24" {...s}><rect x="2.5" y="5" width="19" height="14" rx="2.5"/><path d="M2.5 10h19"/></svg>;
    case 'play': return <svg viewBox="0 0 24 24" {...s}><rect x="3" y="3" width="18" height="18" rx="4"/><path d="M10 8l6 4-6 4z" fill={color}/></svg>;
    case 'car': return <svg viewBox="0 0 24 24" {...s}><path d="M4 16V11l2-5h12l2 5v5"/><rect x="3" y="13" width="18" height="5" rx="1.5"/><circle cx="7.5" cy="18.5" r="1.5"/><circle cx="16.5" cy="18.5" r="1.5"/></svg>;
    case 'heart': return <svg viewBox="0 0 24 24" {...s}><path d="M12 21s-7-4.5-9.5-9C1 9 3 5 6.5 5c2 0 3.5 1 5.5 3 2-2 3.5-3 5.5-3C21 5 23 9 21.5 12 19 16.5 12 21 12 21z"/></svg>;
    case 'book': return <svg viewBox="0 0 24 24" {...s}><path d="M4 4h7a3 3 0 0 1 3 3v13H6a2 2 0 0 1-2-2z"/><path d="M20 4h-3a3 3 0 0 0-3 3v13h6a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z"/></svg>;
    case 'sparkle': return <svg viewBox="0 0 24 24" {...s}><path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/></svg>;
    case 'plus': return <svg viewBox="0 0 24 24" {...s} strokeWidth="2.2"><path d="M12 5v14M5 12h14"/></svg>;
    case 'back': return <svg viewBox="0 0 24 24" {...s} strokeWidth="2.2"><path d="M15 5l-7 7 7 7"/></svg>;
    case 'check': return <svg viewBox="0 0 24 24" {...s} strokeWidth="2.4"><path d="M5 12l5 5 9-11"/></svg>;
    case 'calendar': return <svg viewBox="0 0 24 24" {...s}><rect x="3" y="5" width="18" height="16" rx="2.5"/><path d="M3 10h18M8 3v4M16 3v4"/></svg>;
    case 'dot': return <svg viewBox="0 0 24 24" {...filled}><circle cx="12" cy="12" r="3"/></svg>;
    case 'chevron': return <svg viewBox="0 0 24 24" {...s} strokeWidth="2"><path d="M9 5l7 7-7 7"/></svg>;
    case 'wallet': return <svg viewBox="0 0 24 24" {...s}><rect x="3" y="6" width="18" height="14" rx="3"/><path d="M3 10h14a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2H3"/><circle cx="16" cy="14" r="1" fill={color}/></svg>;
    case 'pie': return <svg viewBox="0 0 24 24" {...s}><path d="M12 3a9 9 0 1 0 9 9h-9z"/><path d="M12 3a9 9 0 0 1 9 9"/></svg>;
    case 'user': return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/></svg>;
    case 'list': return <svg viewBox="0 0 24 24" {...s}><path d="M8 6h13M8 12h13M8 18h13"/><circle cx="4" cy="6" r="1" fill={color}/><circle cx="4" cy="12" r="1" fill={color}/><circle cx="4" cy="18" r="1" fill={color}/></svg>;
    case 'trash': return <svg viewBox="0 0 24 24" {...s}><path d="M4 7h16M10 11v6M14 11v6M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13M9 7V4h6v3"/></svg>;
    case 'edit': return <svg viewBox="0 0 24 24" {...s}><path d="M14 4l6 6L9 21H3v-6z"/></svg>;
    case 'close': return <svg viewBox="0 0 24 24" {...s} strokeWidth="2.2"><path d="M6 6l12 12M18 6l-12 12"/></svg>;
    case 'arrow-up': return <svg viewBox="0 0 24 24" {...s}><path d="M12 19V5M5 12l7-7 7 7"/></svg>;
    case 'arrow-down': return <svg viewBox="0 0 24 24" {...s}><path d="M12 5v14M5 12l7 7 7-7"/></svg>;
    case 'bell': return <svg viewBox="0 0 24 24" {...s}><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9M10 21a2 2 0 0 0 4 0"/></svg>;
    case 'shield': return <svg viewBox="0 0 24 24" {...s}><path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/></svg>;
    case 'language': return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>;
    case 'logout': return <svg viewBox="0 0 24 24" {...s}><path d="M15 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 17l-5-5 5-5M5 12h12"/></svg>;
    case 'tag': return <svg viewBox="0 0 24 24" {...s}><path d="M3 12V4h8l10 10-8 8z"/><circle cx="8" cy="9" r="1.5" fill={color}/></svg>;
    case 'clock': return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>;
    default: return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="12" r="9"/></svg>;
  }
}

// ───────── Wallpaper ─────────
function Wallpaper({ hueShift = 0 }) {
  return (
    <div className="wallpaper" style={{ filter: hueShift ? `hue-rotate(${hueShift}deg)` : 'none' }}>
      <div className="blob b1"></div>
      <div className="blob b2"></div>
      <div className="blob b3"></div>
      <div className="blob b4"></div>
      {/* subtle noise */}
      <div style={{
        position: 'absolute', inset: 0, opacity: 0.04, mixBlendMode: 'overlay',
        backgroundImage: 'url("data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'200\' height=\'200\'><filter id=\'n\'><feTurbulence type=\'fractalNoise\' baseFrequency=\'0.9\' numOctaves=\'3\'/></filter><rect width=\'100%25\' height=\'100%25\' filter=\'url(%23n)\'/></svg>")',
      }} />
    </div>
  );
}

// ───────── Glass card / row / chip ─────────
function GlassCard({ children, style = {}, strong = false, subtle = false, padding = 16, radius = 24, onClick, className = '' }) {
  const cls = strong ? 'glass-strong shine' : subtle ? 'glass-subtle' : 'glass shine';
  return (
    <div
      className={cls + ' ' + className}
      onClick={onClick}
      style={{ borderRadius: radius, padding, ...style, cursor: onClick ? 'pointer' : undefined }}
    >
      {children}
    </div>
  );
}

function GlassPillBtn({ children, onClick, style = {}, accent = false }) {
  return (
    <button
      onClick={onClick}
      className={'tap ' + (accent ? '' : 'glass shine')}
      style={{
        border: 'none', cursor: 'pointer',
        borderRadius: 9999, padding: '12px 18px',
        background: accent ? 'linear-gradient(135deg, #ff6ec7, #c084fc)' : undefined,
        color: '#fff', fontWeight: 600, fontSize: 14,
        boxShadow: accent ? '0 8px 24px rgba(255,110,199,0.4), inset 0 1px 0 rgba(255,255,255,0.4)' : undefined,
        display: 'inline-flex', alignItems: 'center', gap: 6,
        ...style,
      }}
    >
      {children}
    </button>
  );
}

function CategoryIcon({ id, size = 40 }) {
  const c = catById(id);
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.32,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: `linear-gradient(135deg, ${c.color}cc, ${c.color}66)`,
      boxShadow: `inset 0 1px 0 rgba(255,255,255,0.35), 0 4px 12px ${c.color}40`,
      border: `0.5px solid rgba(255,255,255,0.25)`,
      flexShrink: 0,
    }}>
      <Icon name={c.icon} size={size * 0.5} color="#fff" />
    </div>
  );
}

// ───────── Tab bar (bottom) ─────────
function TabBar({ active, onChange, hidden }) {
  if (hidden) return null;
  const items = [
    { id: 'home',     icon: 'wallet', label: 'Início' },
    { id: 'bills',    icon: 'list',   label: 'Contas' },
    { id: 'add',      icon: 'plus',   label: '',       primary: true },
    { id: 'compare',  icon: 'pie',    label: 'Análise' },
    { id: 'profile',  icon: 'user',   label: 'Perfil' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 14, right: 14, bottom: 22,
      zIndex: 30,
    }}>
      <div className="glass-strong shine" style={{
        borderRadius: 30, padding: '8px 10px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        {items.map(it => {
          const isActive = it.id === active && !it.primary;
          if (it.primary) {
            return (
              <button key={it.id} onClick={() => onChange(it.id)} className="tap" style={{
                width: 52, height: 52, borderRadius: 26,
                border: 'none', cursor: 'pointer',
                background: 'linear-gradient(135deg, #ff6ec7, #c084fc 60%, #6e8aff)',
                boxShadow: '0 10px 24px rgba(192,132,252,0.45), inset 0 1px 0 rgba(255,255,255,0.5)',
                color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
                margin: '0 -4px',
              }}>
                <Icon name="plus" size={24} strokeWidth={2.4} />
              </button>
            );
          }
          return (
            <button key={it.id} onClick={() => onChange(it.id)} className="tap" style={{
              flex: 1, border: 'none', background: 'transparent', cursor: 'pointer',
              padding: '8px 0',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
              color: isActive ? '#ff6ec7' : 'rgba(255,255,255,0.55)',
              transition: 'color 200ms',
            }}>
              <Icon name={it.icon} size={22} strokeWidth={isActive ? 2.2 : 1.7} />
              <span style={{ fontSize: 10, fontWeight: 600, letterSpacing: 0.1 }}>{it.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ───────── Top nav (back / title / action) ─────────
function TopNav({ title, onBack, right, large = false, subtitle }) {
  return (
    <div style={{ padding: large ? '12px 20px 8px' : '8px 16px', display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 44 }}>
        {onBack ? (
          <button onClick={onBack} className="tap glass shine" style={{
            width: 40, height: 40, borderRadius: 20, border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff',
          }}>
            <Icon name="back" size={20} />
          </button>
        ) : <div style={{ width: 40 }} />}
        {!large && <div style={{ fontSize: 17, fontWeight: 600 }}>{title}</div>}
        <div style={{ minWidth: 40, display: 'flex', justifyContent: 'flex-end' }}>{right || <div style={{ width: 40 }} />}</div>
      </div>
      {large && (
        <div style={{ padding: '4px 4px 0' }}>
          <div style={{ fontSize: 34, fontWeight: 800, letterSpacing: -0.8, lineHeight: 1.05 }}>{title}</div>
          {subtitle && <div style={{ color: 'var(--muted)', fontSize: 14, marginTop: 4 }}>{subtitle}</div>}
        </div>
      )}
    </div>
  );
}

// expose
Object.assign(window, {
  fmtBRL, fmtBRLshort, parseBRL, fmtDate, fmtDateShort, daysUntil, todayIso,
  CATEGORIES, catById,
  Icon, Wallpaper, GlassCard, GlassPillBtn, CategoryIcon, TabBar, TopNav,
});
