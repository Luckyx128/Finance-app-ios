// Main app — state, routing, and tweaks

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "glassIntensity": "medium",
  "wallpaperHue": 0,
  "showTabLabels": true,
  "flow": "splash"
}/*EDITMODE-END*/;

// Seed data
const SEED_BILLS = [
  { id: 'b1', name: 'Aluguel',         value: 1850.00, due: '2026-05-05', category: 'moradia',     recurring: true,  paid: true,  note: 'Apto 304 — depósito Itaú' },
  { id: 'b2', name: 'Conta de luz',    value: 187.40,  due: '2026-05-12', category: 'casa',        recurring: true,  paid: true,  note: '' },
  { id: 'b3', name: 'Internet 600MB',  value: 119.90,  due: '2026-05-15', category: 'casa',        recurring: true,  paid: false, note: '' },
  { id: 'b4', name: 'Cartão Nubank',   value: 824.55,  due: '2026-05-20', category: 'cartao',      recurring: true,  paid: false, note: 'Fatura de Abril' },
  { id: 'b5', name: 'Netflix',         value: 55.90,   due: '2026-05-22', category: 'assinaturas', recurring: true,  paid: false, note: '' },
  { id: 'b6', name: 'Spotify Family',  value: 34.90,   due: '2026-05-22', category: 'assinaturas', recurring: true,  paid: false, note: '' },
  { id: 'b7', name: 'Plano de saúde',  value: 412.30,  due: '2026-05-25', category: 'saude',       recurring: true,  paid: false, note: 'Bradesco Top' },
  { id: 'b8', name: 'Uber/99 do mês',  value: 286.00,  due: '2026-05-28', category: 'transporte',  recurring: false, paid: false, note: 'Estimativa' },
  { id: 'b9', name: 'Curso UX',        value: 199.00,  due: '2026-05-30', category: 'educacao',    recurring: true,  paid: false, note: '' },
  { id: 'b10', name: 'Academia',       value: 89.90,   due: '2026-05-10', category: 'lazer',       recurring: true,  paid: true,  note: '' },
];

const SEED_USER = {
  name: 'Lucas Ribeiro',
  email: 'lucas.ribeiro@email.com',
  income: 6500,
};

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [flow, setFlow] = React.useState(t.flow || 'splash'); // 'splash' | 'onboarding' | 'app'
  React.useEffect(() => { setFlow(t.flow); }, [t.flow]);
  const goFlow = (f) => { setFlow(f); setTweak('flow', f); };
  const [tab, setTab] = React.useState('home');
  const [bills, setBills] = React.useState(SEED_BILLS);
  const [user, setUser] = React.useState(SEED_USER);
  const [detailId, setDetailId] = React.useState(null);
  const [editingId, setEditingId] = React.useState(null); // 'new' or bill id
  const [toast, setToast] = React.useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type, id: Date.now() });
    setTimeout(() => setToast(null), 2400);
  };

  const totalBills = bills.reduce((s, b) => s + b.value, 0);

  const openBill = (id) => setDetailId(id);
  const closeDetail = () => setDetailId(null);

  const saveBill = (data) => {
    if (editingId === 'new') {
      const id = 'b' + Date.now();
      setBills(bs => [...bs, { id, paid: false, ...data }]);
      showToast('Conta cadastrada ✓');
    } else {
      setBills(bs => bs.map(b => b.id === editingId ? { ...b, ...data } : b));
      showToast('Conta atualizada ✓');
    }
    setEditingId(null);
  };

  const deleteBill = (id) => {
    setBills(bs => bs.filter(b => b.id !== id));
    setEditingId(null);
    setDetailId(null);
    showToast('Conta excluída', 'danger');
  };

  const togglePaid = (id) => {
    setBills(bs => bs.map(b => b.id === id ? { ...b, paid: !b.paid } : b));
    const b = bills.find(b => b.id === id);
    if (b) showToast(b.paid ? 'Marcada como não paga' : 'Pagamento confirmado ✓');
  };

  // tab change handling — '+' opens new bill modal
  const onTabChange = (id) => {
    if (id === 'add') {
      setEditingId('new');
    } else {
      setTab(id);
      setDetailId(null);
    }
  };

  // glass intensity → blur values
  const intensityMap = {
    'low':    { blur: 16, sat: 140, alpha: 0.06 },
    'medium': { blur: 28, sat: 180, alpha: 0.10 },
    'high':   { blur: 44, sat: 220, alpha: 0.16 },
  };
  const intensity = intensityMap[t.glassIntensity] || intensityMap.medium;

  React.useEffect(() => {
    // Apply intensity to .glass class via CSS variable
    const r = document.documentElement;
    r.style.setProperty('--glass-blur', intensity.blur + 'px');
    r.style.setProperty('--glass-sat', intensity.sat + '%');
    r.style.setProperty('--glass-alpha', intensity.alpha);
  }, [t.glassIntensity]);

  const detailBill = detailId ? bills.find(b => b.id === detailId) : null;
  const editingBill = editingId && editingId !== 'new' ? bills.find(b => b.id === editingId) : null;

  return (
    <>
      {/* intensity override */}
      <style>{`
        .glass {
          backdrop-filter: blur(${intensity.blur}px) saturate(${intensity.sat}%);
          -webkit-backdrop-filter: blur(${intensity.blur}px) saturate(${intensity.sat}%);
          background: rgba(255,255,255,${intensity.alpha});
        }
        .glass-strong {
          backdrop-filter: blur(${intensity.blur + 12}px) saturate(${intensity.sat + 20}%);
          -webkit-backdrop-filter: blur(${intensity.blur + 12}px) saturate(${intensity.sat + 20}%);
          background: rgba(255,255,255,${intensity.alpha + 0.06});
        }
        .glass-subtle {
          backdrop-filter: blur(${Math.max(10, intensity.blur - 8)}px) saturate(${intensity.sat - 20}%);
          -webkit-backdrop-filter: blur(${Math.max(10, intensity.blur - 8)}px) saturate(${intensity.sat - 20}%);
          background: rgba(255,255,255,${Math.max(0.04, intensity.alpha - 0.04)});
        }
      `}</style>

      <IOSDevice width={402} height={874} dark={true}>
        <div style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
          <Wallpaper hueShift={t.wallpaperHue} />

          {/* Etapa 1 — Splash + Onboarding */}
          {flow === 'splash' && (
            <div style={{ position: 'absolute', inset: 0, paddingTop: 54 }}>
              <SplashScreen onDone={() => goFlow('onboarding')} />
            </div>
          )}
          {flow === 'onboarding' && (
            <div style={{ position: 'absolute', inset: 0, paddingTop: 54 }}>
              <OnboardingScreen onDone={() => goFlow('app')} />
            </div>
          )}

          {/* Main app */}
          {flow === 'app' && <>
          {/* content layer — above wallpaper, below status bar */}
          <div style={{ position: 'absolute', inset: 0, paddingTop: 54 }}>
            {detailBill ? (
              <BillDetail
                bill={detailBill}
                onBack={closeDetail}
                onEdit={(id) => setEditingId(id)}
                onTogglePaid={togglePaid}
                onDelete={deleteBill}
              />
            ) : tab === 'home' ? (
              <HomeScreen bills={bills} income={user.income} user={user}
                onAdd={() => setEditingId('new')}
                onOpenBill={openBill}
                onGoTo={setTab}
              />
            ) : tab === 'bills' ? (
              <BillsScreen bills={bills} onOpenBill={openBill} onAdd={() => setEditingId('new')} />
            ) : tab === 'compare' ? (
              <CompareScreen bills={bills} income={user.income} />
            ) : tab === 'profile' ? (
              <ProfileScreen user={user} onUpdateUser={setUser} billsTotal={totalBills} />
            ) : null}
          </div>

          {/* tab bar */}
          <TabBar active={tab} onChange={onTabChange} hidden={!!detailBill} />
          </>}

          {/* toast */}
          {toast && (
            <div key={toast.id} style={{
              position: 'absolute', top: 56, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 200, pointerEvents: 'none',
              animation: 'toastIn 360ms cubic-bezier(.32,.72,.24,1)',
            }}>
              <div className="glass-strong shine" style={{
                padding: '10px 16px', borderRadius: 22, fontSize: 13, fontWeight: 600,
                display: 'inline-flex', alignItems: 'center', gap: 8,
                color: toast.type === 'danger' ? '#ff5a7a' : '#6affc4',
              }}>
                <Icon name={toast.type === 'danger' ? 'trash' : 'check'} size={15} />
                {toast.msg}
              </div>
            </div>
          )}

          {/* form modal */}
          {editingId && (
            <BillForm
              initial={editingBill}
              onSave={saveBill}
              onCancel={() => setEditingId(null)}
              onDelete={deleteBill}
            />
          )}
        </div>
      </IOSDevice>

      {/* Tweaks panel */}
      <AppTweaks t={t} setTweak={setTweak} />

      <style>{`
        @keyframes toastIn {
          from { opacity: 0; transform: translateY(-14px); }
          to   { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </>
  );
}

function AppTweaks({ t, setTweak }) {
  return (
    <TweaksPanel title="Tweaks">
      <TweakSection label="Fluxo (Etapas)">
        <TweakSelect
          label="Tela inicial"
          value={t.flow}
          onChange={(v) => setTweak('flow', v)}
          options={[
            { value: 'splash',      label: 'Etapa 1a · Splash' },
            { value: 'onboarding',  label: 'Etapa 1b · Onboarding' },
            { value: 'app',         label: 'App principal' },
          ]}
        />
      </TweakSection>
      <TweakSection label="Liquid Glass">
        <TweakRadio
          label="Intensidade"
          value={t.glassIntensity}
          onChange={(v) => setTweak('glassIntensity', v)}
          options={[
            { value: 'low',    label: 'Sutil' },
            { value: 'medium', label: 'Médio' },
            { value: 'high',   label: 'Intenso' },
          ]}
        />
        <TweakSlider
          label="Tom do wallpaper"
          value={t.wallpaperHue}
          onChange={(v) => setTweak('wallpaperHue', v)}
          min={-180} max={180} step={10}
          unit="°"
        />
      </TweakSection>
    </TweaksPanel>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
