// All app screens — depends on globals from glass.jsx

// ═══════════════════════════════════════════════
// HOME / DASHBOARD
// ═══════════════════════════════════════════════
function HomeScreen({ bills, income, user, onAdd, onOpenBill, onGoTo }) {
  const totalMonth = bills.reduce((s, b) => s + b.value, 0);
  const paid = bills.filter(b => b.paid).reduce((s, b) => s + b.value, 0);
  const pending = totalMonth - paid;
  const remaining = income - totalMonth;
  const pct = income > 0 ? Math.min(100, Math.round((totalMonth / income) * 100)) : 0;

  // upcoming (not paid, sorted by due date asc)
  const upcoming = [...bills].filter(b => !b.paid).sort((a, b) => a.due.localeCompare(b.due)).slice(0, 4);

  return (
    <div className="screen-enter scroll" style={{ height: '100%', overflowY: 'auto', paddingBottom: 110 }}>
      {/* greeting */}
      <div style={{ padding: '8px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <div style={{ color: 'var(--muted)', fontSize: 13, fontWeight: 500 }}>Olá, {user.name.split(' ')[0]}</div>
          <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Maio · 2026</div>
        </div>
        <button onClick={() => onGoTo('profile')} className="tap" style={{
          width: 44, height: 44, borderRadius: 22, border: 'none', cursor: 'pointer',
          background: 'linear-gradient(135deg, #ff6ec7, #6e8aff)',
          color: '#fff', fontWeight: 700, fontSize: 16,
          boxShadow: '0 6px 18px rgba(255,110,199,0.4), inset 0 1px 0 rgba(255,255,255,0.4)',
        }}>{user.name.split(' ').map(p => p[0]).slice(0,2).join('')}</button>
      </div>

      {/* hero card — total */}
      <div style={{ padding: '16px 16px 0' }}>
        <GlassCard strong radius={28} padding={20} style={{ overflow: 'hidden', position: 'relative' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Total do mês</div>
              <div className="tnum" style={{ fontSize: 38, fontWeight: 800, letterSpacing: -1.2, marginTop: 4 }}>{fmtBRL(totalMonth)}</div>
              <div style={{ color: 'var(--muted)', fontSize: 13, marginTop: 2 }}>
                de <span style={{ color: '#fff', fontWeight: 600 }} className="tnum">{fmtBRL(income)}</span> de renda
              </div>
            </div>
            <div className="glass-subtle" style={{
              padding: '6px 10px', borderRadius: 14,
              display: 'flex', alignItems: 'center', gap: 6,
              fontSize: 12, fontWeight: 700, color: remaining >= 0 ? '#6affc4' : '#ff5a7a',
            }}>
              <Icon name={remaining >= 0 ? 'arrow-up' : 'arrow-down'} size={12} strokeWidth={2.6} />
              {pct}%
            </div>
          </div>

          {/* progress bar */}
          <div style={{ marginTop: 18, height: 8, borderRadius: 4, background: 'rgba(255,255,255,0.12)', overflow: 'hidden' }}>
            <div style={{
              width: pct + '%', height: '100%',
              background: pct < 70 ? 'linear-gradient(90deg, #6affc4, #6e8aff)' : pct < 95 ? 'linear-gradient(90deg, #ffc56e, #ff6ec7)' : 'linear-gradient(90deg, #ff5a7a, #ff6ec7)',
              transition: 'width 600ms cubic-bezier(.32,.72,.24,1)',
              borderRadius: 4, boxShadow: '0 0 8px rgba(255,110,199,0.4)',
            }} />
          </div>

          {/* split */}
          <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                <span style={{ width: 6, height: 6, borderRadius: 3, background: '#6affc4' }} />
                <span style={{ color: 'var(--muted)', fontSize: 11, fontWeight: 600 }}>PAGO</span>
              </div>
              <div className="tnum" style={{ fontSize: 16, fontWeight: 700, marginTop: 2 }}>{fmtBRL(paid)}</div>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                <span style={{ width: 6, height: 6, borderRadius: 3, background: '#ffc56e' }} />
                <span style={{ color: 'var(--muted)', fontSize: 11, fontWeight: 600 }}>PENDENTE</span>
              </div>
              <div className="tnum" style={{ fontSize: 16, fontWeight: 700, marginTop: 2 }}>{fmtBRL(pending)}</div>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                <span style={{ width: 6, height: 6, borderRadius: 3, background: remaining >= 0 ? '#6e8aff' : '#ff5a7a' }} />
                <span style={{ color: 'var(--muted)', fontSize: 11, fontWeight: 600 }}>SOBRA</span>
              </div>
              <div className="tnum" style={{ fontSize: 16, fontWeight: 700, marginTop: 2, color: remaining >= 0 ? '#fff' : '#ff5a7a' }}>{fmtBRL(remaining)}</div>
            </div>
          </div>
        </GlassCard>
      </div>

      {/* quick stats row */}
      <div style={{ padding: '12px 16px 0', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <GlassCard padding={14} radius={20}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 30, height: 30, borderRadius: 10, background: 'rgba(110,138,255,0.25)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="calendar" size={16} color="#6e8aff" />
            </div>
            <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600 }}>Próximas</div>
          </div>
          <div className="tnum" style={{ fontSize: 22, fontWeight: 700, marginTop: 6 }}>{bills.filter(b => !b.paid).length}</div>
          <div style={{ color: 'var(--dim)', fontSize: 11 }}>contas a pagar</div>
        </GlassCard>
        <GlassCard padding={14} radius={20}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 30, height: 30, borderRadius: 10, background: 'rgba(255,110,199,0.25)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="clock" size={16} color="#ff6ec7" />
            </div>
            <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600 }}>Vencendo</div>
          </div>
          <div className="tnum" style={{ fontSize: 22, fontWeight: 700, marginTop: 6 }}>{bills.filter(b => !b.paid && daysUntil(b.due) <= 7).length}</div>
          <div style={{ color: 'var(--dim)', fontSize: 11 }}>em 7 dias</div>
        </GlassCard>
      </div>

      {/* upcoming */}
      <div style={{ padding: '20px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>Próximas contas</div>
        <button onClick={() => onGoTo('bills')} style={{
          border: 'none', background: 'transparent', color: '#ff6ec7', fontSize: 13, fontWeight: 600, cursor: 'pointer',
        }}>Ver todas</button>
      </div>

      <div style={{ padding: '10px 16px 0', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {upcoming.length === 0 && (
          <GlassCard padding={20} radius={20} style={{ textAlign: 'center', color: 'var(--muted)' }}>
            Nenhuma conta pendente 🎉
          </GlassCard>
        )}
        {upcoming.map((b, i) => (
          <BillRow key={b.id} bill={b} onClick={() => onOpenBill(b.id)} style={{ animationDelay: (i*40) + 'ms' }} />
        ))}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════
// Reusable BillRow
// ═══════════════════════════════════════════════
function BillRow({ bill, onClick, style = {} }) {
  const days = daysUntil(bill.due);
  let status = { color: 'var(--muted)', text: fmtDateShort(bill.due) };
  if (bill.paid) status = { color: '#6affc4', text: 'pago' };
  else if (days < 0) status = { color: '#ff5a7a', text: `${Math.abs(days)}d atrasada` };
  else if (days === 0) status = { color: '#ff6ec7', text: 'vence hoje' };
  else if (days <= 7) status = { color: '#ffc56e', text: `em ${days}d` };

  return (
    <GlassCard onClick={onClick} padding={12} radius={20} className="pop-in" style={style}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <CategoryIcon id={bill.category} size={42} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 600, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{bill.name}</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 2 }}>
            <span style={{ width: 5, height: 5, borderRadius: 3, background: status.color }} />
            <span style={{ fontSize: 12, color: status.color, fontWeight: 600 }}>{status.text}</span>
            <span style={{ fontSize: 12, color: 'var(--dim)' }}>· {catById(bill.category).label}</span>
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div className="tnum" style={{ fontSize: 16, fontWeight: 700, letterSpacing: -0.3, textDecoration: bill.paid ? 'line-through' : 'none', opacity: bill.paid ? 0.5 : 1 }}>{fmtBRL(bill.value)}</div>
        </div>
      </div>
    </GlassCard>
  );
}

// ═══════════════════════════════════════════════
// BILLS LIST
// ═══════════════════════════════════════════════
function BillsScreen({ bills, onOpenBill, onAdd }) {
  const [filter, setFilter] = React.useState('all');
  const [catFilter, setCatFilter] = React.useState(null);

  const filtered = bills.filter(b => {
    if (filter === 'paid' && !b.paid) return false;
    if (filter === 'pending' && b.paid) return false;
    if (catFilter && b.category !== catFilter) return false;
    return true;
  }).sort((a, b) => {
    if (a.paid !== b.paid) return a.paid ? 1 : -1;
    return a.due.localeCompare(b.due);
  });

  const total = filtered.reduce((s, b) => s + b.value, 0);

  return (
    <div className="screen-enter scroll" style={{ height: '100%', overflowY: 'auto', paddingBottom: 110 }}>
      <TopNav title="Contas" large subtitle={`${filtered.length} conta${filtered.length !== 1 ? 's' : ''} · ${fmtBRL(total)}`} />

      {/* segmented filter */}
      <div style={{ padding: '8px 16px 0' }}>
        <div className="glass-subtle" style={{
          padding: 4, borderRadius: 14, display: 'flex', gap: 2,
        }}>
          {[
            { id: 'all', label: 'Todas' },
            { id: 'pending', label: 'Pendentes' },
            { id: 'paid', label: 'Pagas' },
          ].map(t => (
            <button key={t.id} onClick={() => setFilter(t.id)} className="tap" style={{
              flex: 1, border: 'none', cursor: 'pointer',
              padding: '8px 0', borderRadius: 11,
              fontSize: 13, fontWeight: 600,
              background: filter === t.id ? 'rgba(255,255,255,0.18)' : 'transparent',
              color: filter === t.id ? '#fff' : 'rgba(255,255,255,0.55)',
              boxShadow: filter === t.id ? 'inset 0 1px 0 rgba(255,255,255,0.3), 0 2px 8px rgba(0,0,0,0.2)' : 'none',
              transition: 'all 200ms',
            }}>{t.label}</button>
          ))}
        </div>
      </div>

      {/* category chips */}
      <div style={{ padding: '12px 0 0', overflowX: 'auto' }} className="scroll">
        <div style={{ display: 'flex', gap: 8, padding: '0 16px' }}>
          <button onClick={() => setCatFilter(null)} className={'tap ' + (!catFilter ? 'glass-strong' : 'glass-subtle')} style={{
            border: 'none', cursor: 'pointer', borderRadius: 18, padding: '7px 13px',
            fontSize: 12, fontWeight: 600, color: '#fff', whiteSpace: 'nowrap',
            background: !catFilter ? undefined : undefined,
          }}>Todas categorias</button>
          {CATEGORIES.map(c => (
            <button key={c.id} onClick={() => setCatFilter(catFilter === c.id ? null : c.id)} className={'tap ' + (catFilter === c.id ? 'glass-strong' : 'glass-subtle')} style={{
              border: 'none', cursor: 'pointer', borderRadius: 18, padding: '7px 13px',
              fontSize: 12, fontWeight: 600, color: '#fff', whiteSpace: 'nowrap',
              display: 'inline-flex', alignItems: 'center', gap: 6,
            }}>
              <span style={{ width: 8, height: 8, borderRadius: 4, background: c.color }} />
              {c.label}
            </button>
          ))}
        </div>
      </div>

      <div style={{ padding: '14px 16px 0', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {filtered.length === 0 && (
          <GlassCard padding={32} radius={24} style={{ textAlign: 'center' }}>
            <div style={{ fontSize: 40, marginBottom: 8 }}>✨</div>
            <div style={{ fontWeight: 600 }}>Nenhuma conta aqui</div>
            <div style={{ color: 'var(--muted)', fontSize: 13, marginTop: 4 }}>Toque no + para cadastrar</div>
          </GlassCard>
        )}
        {filtered.map((b, i) => (
          <BillRow key={b.id} bill={b} onClick={() => onOpenBill(b.id)} style={{ animationDelay: (i*30) + 'ms' }} />
        ))}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════
// ADD / EDIT BILL — modal
// ═══════════════════════════════════════════════
function BillForm({ initial, onSave, onCancel, onDelete }) {
  const [name, setName] = React.useState(initial?.name || '');
  const [valueStr, setValueStr] = React.useState(initial ? initial.value.toFixed(2).replace('.', ',') : '');
  const [due, setDue] = React.useState(initial?.due || todayIso());
  const [category, setCategory] = React.useState(initial?.category || 'moradia');
  const [recurring, setRecurring] = React.useState(initial?.recurring ?? true);
  const [note, setNote] = React.useState(initial?.note || '');
  const [step, setStep] = React.useState(0); // 0: name, 1: full form

  const isEdit = !!initial;
  const canSave = name.trim() && parseBRL(valueStr) > 0 && due && category;

  return (
    <div className="modal-enter" style={{
      position: 'absolute', inset: 0, zIndex: 100, display: 'flex', flexDirection: 'column',
    }}>
      {/* backdrop */}
      <div onClick={onCancel} style={{
        position: 'absolute', inset: 0,
        background: 'rgba(0,0,0,0.35)', backdropFilter: 'blur(8px)',
      }} />

      {/* sheet */}
      <div style={{
        marginTop: 'auto', position: 'relative',
        borderRadius: '32px 32px 0 0', overflow: 'hidden',
        maxHeight: '92%', display: 'flex', flexDirection: 'column',
      }} className="glass-strong shine">
        {/* grabber */}
        <div style={{ padding: '10px 0 0', display: 'flex', justifyContent: 'center' }}>
          <div style={{ width: 38, height: 5, borderRadius: 3, background: 'rgba(255,255,255,0.3)' }} />
        </div>

        {/* header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 20px 4px' }}>
          <button onClick={onCancel} className="tap" style={{
            border: 'none', background: 'transparent', color: 'var(--muted)', cursor: 'pointer',
            fontSize: 15, fontWeight: 500,
          }}>Cancelar</button>
          <div style={{ fontSize: 16, fontWeight: 700 }}>{isEdit ? 'Editar conta' : 'Nova conta'}</div>
          <button disabled={!canSave} onClick={() => onSave({
            name: name.trim(), value: parseBRL(valueStr), due, category, recurring, note,
          })} className="tap" style={{
            border: 'none', background: 'transparent', cursor: canSave ? 'pointer' : 'default',
            color: canSave ? '#ff6ec7' : 'rgba(255,255,255,0.3)',
            fontSize: 15, fontWeight: 700,
          }}>Salvar</button>
        </div>

        <div className="scroll" style={{ overflowY: 'auto', padding: '14px 16px 28px', display: 'flex', flexDirection: 'column', gap: 12 }}>
          {/* big value */}
          <GlassCard padding={20} radius={24} style={{ textAlign: 'center' }}>
            <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600, letterSpacing: 0.6, textTransform: 'uppercase' }}>Valor</div>
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', marginTop: 6, gap: 6 }}>
              <span style={{ fontSize: 22, fontWeight: 600, color: 'var(--muted)' }}>R$</span>
              <input
                type="text" inputMode="decimal"
                value={valueStr}
                onChange={e => setValueStr(e.target.value.replace(/[^\d,.]/g, ''))}
                placeholder="0,00"
                style={{
                  background: 'transparent', border: 'none',
                  fontSize: 44, fontWeight: 800, letterSpacing: -1.4,
                  color: '#fff', width: '60%', textAlign: 'center',
                  fontVariantNumeric: 'tabular-nums',
                }}
              />
            </div>
          </GlassCard>

          {/* name */}
          <FormRow icon="tag" label="Nome">
            <input value={name} onChange={e => setName(e.target.value)} placeholder="ex: Aluguel, Netflix..." style={inputStyle} />
          </FormRow>

          {/* date */}
          <FormRow icon="calendar" label="Vencimento">
            <input type="date" value={due} onChange={e => setDue(e.target.value)} style={{ ...inputStyle, colorScheme: 'dark' }} />
          </FormRow>

          {/* recurring */}
          <FormRow icon="clock" label="Repetir todo mês">
            <Toggle on={recurring} onChange={setRecurring} />
          </FormRow>

          {/* category picker */}
          <div>
            <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600, padding: '4px 8px', letterSpacing: 0.4, textTransform: 'uppercase' }}>Categoria</div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8, marginTop: 6 }}>
              {CATEGORIES.map(c => {
                const selected = category === c.id;
                return (
                  <button key={c.id} onClick={() => setCategory(c.id)} className="tap" style={{
                    border: 'none', cursor: 'pointer', borderRadius: 18, padding: '10px 4px',
                    background: selected ? `linear-gradient(135deg, ${c.color}55, ${c.color}22)` : 'rgba(255,255,255,0.06)',
                    boxShadow: selected ? `inset 0 0 0 1.5px ${c.color}, 0 4px 12px ${c.color}40` : 'inset 0 0 0 0.5px rgba(255,255,255,0.15)',
                    display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                    transition: 'all 200ms',
                  }}>
                    <CategoryIcon id={c.id} size={32} />
                    <div style={{ fontSize: 10, fontWeight: 600, color: selected ? '#fff' : 'var(--muted)', textAlign: 'center', lineHeight: 1.1 }}>{c.label}</div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* note */}
          <div style={{ marginTop: 4 }}>
            <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600, padding: '4px 8px', letterSpacing: 0.4, textTransform: 'uppercase' }}>Observação</div>
            <GlassCard padding={12} radius={16} style={{ marginTop: 6 }}>
              <textarea value={note} onChange={e => setNote(e.target.value)} placeholder="Notas opcionais..." rows={2}
                style={{ ...inputStyle, width: '100%', resize: 'none', minHeight: 50 }} />
            </GlassCard>
          </div>

          {isEdit && (
            <button onClick={() => onDelete(initial.id)} className="tap" style={{
              border: 'none', background: 'rgba(255,90,122,0.15)',
              color: '#ff5a7a', fontWeight: 600, fontSize: 15,
              padding: '14px', borderRadius: 16, cursor: 'pointer',
              marginTop: 4,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}>
              <Icon name="trash" size={16} color="#ff5a7a" />
              Excluir conta
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

function FormRow({ icon, label, children }) {
  return (
    <GlassCard padding={12} radius={16}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 32, height: 32, borderRadius: 10, background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name={icon} size={16} color="rgba(255,255,255,0.8)" />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ color: 'var(--muted)', fontSize: 11, fontWeight: 600, letterSpacing: 0.3 }}>{label}</div>
          {children}
        </div>
      </div>
    </GlassCard>
  );
}

const inputStyle = {
  background: 'transparent', border: 'none',
  color: '#fff', fontSize: 15, fontWeight: 500,
  width: '100%', padding: 0, marginTop: 2,
};

function Toggle({ on, onChange }) {
  return (
    <button onClick={() => onChange(!on)} className="tap" style={{
      width: 50, height: 30, borderRadius: 15, border: 'none', cursor: 'pointer',
      background: on ? 'linear-gradient(135deg, #ff6ec7, #c084fc)' : 'rgba(255,255,255,0.15)',
      position: 'relative', boxShadow: on ? '0 4px 12px rgba(255,110,199,0.3)' : 'inset 0 0 0 0.5px rgba(255,255,255,0.2)',
      transition: 'background 200ms',
    }}>
      <div style={{
        position: 'absolute', top: 2, left: on ? 22 : 2,
        width: 26, height: 26, borderRadius: 13, background: '#fff',
        transition: 'left 200ms cubic-bezier(.32,.72,.24,1)',
        boxShadow: '0 2px 6px rgba(0,0,0,0.25)',
      }} />
    </button>
  );
}

// ═══════════════════════════════════════════════
// BILL DETAIL
// ═══════════════════════════════════════════════
function BillDetail({ bill, onBack, onEdit, onTogglePaid, onDelete }) {
  if (!bill) return null;
  const c = catById(bill.category);
  const days = daysUntil(bill.due);

  return (
    <div className="screen-enter" style={{ height: '100%', overflowY: 'auto', paddingBottom: 110 }}>
      <TopNav title="Conta" onBack={onBack} right={
        <button onClick={() => onEdit(bill.id)} className="tap glass shine" style={{
          width: 40, height: 40, borderRadius: 20, border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff',
        }}><Icon name="edit" size={18} /></button>
      } />

      {/* hero */}
      <div style={{ padding: '4px 16px 0' }}>
        <GlassCard strong radius={28} padding={24} style={{ position: 'relative', overflow: 'hidden' }}>
          {/* category glow */}
          <div style={{
            position: 'absolute', top: -60, right: -60,
            width: 200, height: 200, borderRadius: '50%',
            background: `radial-gradient(circle, ${c.color}55, transparent 70%)`,
            filter: 'blur(20px)',
          }} />
          <div style={{ position: 'relative', display: 'flex', alignItems: 'center', gap: 12 }}>
            <CategoryIcon id={bill.category} size={52} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 600, letterSpacing: 0.4 }}>{c.label.toUpperCase()}</div>
              <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4, marginTop: 2 }}>{bill.name}</div>
            </div>
          </div>
          <div className="tnum" style={{ fontSize: 44, fontWeight: 800, letterSpacing: -1.4, marginTop: 18, lineHeight: 1 }}>{fmtBRL(bill.value)}</div>
          <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 10 }}>
            <div className="glass-subtle" style={{ padding: '6px 12px', borderRadius: 14, fontSize: 12, fontWeight: 600 }}>
              {bill.paid ? '✓ Paga' : days < 0 ? `${Math.abs(days)} dias em atraso` : days === 0 ? 'Vence hoje' : `Vence em ${days} dias`}
            </div>
            {bill.recurring && (
              <div className="glass-subtle" style={{ padding: '6px 12px', borderRadius: 14, fontSize: 12, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                <Icon name="clock" size={12} /> Mensal
              </div>
            )}
          </div>
        </GlassCard>
      </div>

      {/* details */}
      <div style={{ padding: '16px 16px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <GlassCard padding={0} radius={20} style={{ overflow: 'hidden' }}>
          <DetailRow icon="calendar" label="Vencimento" value={fmtDate(bill.due)} />
          <Divider />
          <DetailRow icon="tag" label="Categoria" value={c.label} />
          <Divider />
          <DetailRow icon="clock" label="Recorrência" value={bill.recurring ? 'Todo mês' : 'Apenas uma vez'} />
        </GlassCard>

        {bill.note && (
          <GlassCard padding={16} radius={20}>
            <div style={{ color: 'var(--muted)', fontSize: 11, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>Observação</div>
            <div style={{ fontSize: 14, marginTop: 6, lineHeight: 1.5 }}>{bill.note}</div>
          </GlassCard>
        )}

        <button onClick={() => onTogglePaid(bill.id)} className="tap" style={{
          border: 'none', cursor: 'pointer',
          padding: '16px', borderRadius: 20,
          background: bill.paid ? 'rgba(255,255,255,0.1)' : 'linear-gradient(135deg, #6affc4, #6e8aff)',
          color: bill.paid ? '#fff' : '#0e0420', fontWeight: 700, fontSize: 16,
          boxShadow: bill.paid ? 'inset 0 0 0 0.5px rgba(255,255,255,0.2)' : '0 8px 22px rgba(106,255,196,0.35), inset 0 1px 0 rgba(255,255,255,0.4)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          <Icon name="check" size={20} color={bill.paid ? '#fff' : '#0e0420'} />
          {bill.paid ? 'Marcar como não paga' : 'Marcar como paga'}
        </button>
      </div>
    </div>
  );
}

function DetailRow({ icon, label, value }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px' }}>
      <div style={{ width: 30, height: 30, borderRadius: 10, background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={icon} size={15} color="rgba(255,255,255,0.8)" />
      </div>
      <div style={{ flex: 1, fontSize: 14, color: 'var(--muted)' }}>{label}</div>
      <div style={{ fontSize: 14, fontWeight: 600 }}>{value}</div>
    </div>
  );
}
function Divider() {
  return <div style={{ height: 0.5, background: 'rgba(255,255,255,0.1)', margin: '0 16px' }} />;
}

// ═══════════════════════════════════════════════
// PROFILE
// ═══════════════════════════════════════════════
function ProfileScreen({ user, onUpdateUser, billsTotal }) {
  const [editIncome, setEditIncome] = React.useState(false);
  const [draft, setDraft] = React.useState(user.income.toFixed(2).replace('.', ','));

  React.useEffect(() => { setDraft(user.income.toFixed(2).replace('.', ',')); }, [user.income]);

  const save = () => {
    onUpdateUser({ ...user, income: parseBRL(draft) });
    setEditIncome(false);
  };

  return (
    <div className="screen-enter scroll" style={{ height: '100%', overflowY: 'auto', paddingBottom: 110 }}>
      <TopNav title="Perfil" large />

      {/* avatar */}
      <div style={{ padding: '8px 16px 0', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{
          width: 92, height: 92, borderRadius: 46,
          background: 'linear-gradient(135deg, #ff6ec7, #c084fc 50%, #6e8aff)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 32, fontWeight: 800, color: '#fff',
          boxShadow: '0 14px 34px rgba(192,132,252,0.4), inset 0 1px 0 rgba(255,255,255,0.4)',
        }}>{user.name.split(' ').map(p => p[0]).slice(0,2).join('')}</div>
        <div style={{ fontSize: 20, fontWeight: 700, marginTop: 12 }}>{user.name}</div>
        <div style={{ color: 'var(--muted)', fontSize: 13 }}>{user.email}</div>
      </div>

      {/* income card */}
      <div style={{ padding: '24px 16px 0' }}>
        <GlassCard strong radius={24} padding={20}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ color: 'var(--muted)', fontSize: 12, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Renda mensal</div>
            {!editIncome && (
              <button onClick={() => setEditIncome(true)} className="tap" style={{
                border: 'none', background: 'transparent', color: '#ff6ec7', fontWeight: 600, fontSize: 13, cursor: 'pointer',
              }}>Editar</button>
            )}
          </div>
          {editIncome ? (
            <div style={{ marginTop: 8 }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
                <span style={{ fontSize: 22, color: 'var(--muted)', fontWeight: 600 }}>R$</span>
                <input
                  autoFocus value={draft}
                  onChange={e => setDraft(e.target.value.replace(/[^\d,.]/g, ''))}
                  style={{
                    background: 'transparent', border: 'none', color: '#fff',
                    fontSize: 36, fontWeight: 800, letterSpacing: -1, width: '70%',
                    fontVariantNumeric: 'tabular-nums',
                  }}
                />
              </div>
              <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
                <button onClick={() => { setDraft(user.income.toFixed(2).replace('.', ',')); setEditIncome(false); }} className="tap glass-subtle" style={{
                  flex: 1, border: 'none', cursor: 'pointer', padding: '10px', borderRadius: 14, color: '#fff', fontWeight: 600, fontSize: 13,
                }}>Cancelar</button>
                <button onClick={save} className="tap" style={{
                  flex: 1, border: 'none', cursor: 'pointer', padding: '10px', borderRadius: 14, fontWeight: 700, fontSize: 13,
                  background: 'linear-gradient(135deg, #ff6ec7, #c084fc)', color: '#fff',
                  boxShadow: '0 4px 14px rgba(255,110,199,0.4)',
                }}>Salvar</button>
              </div>
            </div>
          ) : (
            <>
              <div className="tnum" style={{ fontSize: 38, fontWeight: 800, letterSpacing: -1.2, marginTop: 4 }}>{fmtBRL(user.income)}</div>
              <div style={{ marginTop: 10, display: 'flex', alignItems: 'center', gap: 8 }}>
                <div style={{ flex: 1, height: 6, borderRadius: 3, background: 'rgba(255,255,255,0.12)', overflow: 'hidden' }}>
                  <div style={{ width: Math.min(100, (billsTotal / user.income) * 100) + '%', height: '100%',
                    background: 'linear-gradient(90deg, #ff6ec7, #6e8aff)', borderRadius: 3,
                  }} />
                </div>
                <div className="tnum" style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 600 }}>
                  {Math.round((billsTotal / user.income) * 100)}% comprometido
                </div>
              </div>
            </>
          )}
        </GlassCard>
      </div>

      {/* settings group */}
      <div style={{ padding: '16px 16px 0' }}>
        <GlassCard padding={0} radius={20} style={{ overflow: 'hidden' }}>
          <SettingsRow icon="bell" iconBg="#ff6ec7" label="Notificações" value="3 dias antes" />
          <Divider />
          <SettingsRow icon="language" iconBg="#6e8aff" label="Idioma" value="Português" />
          <Divider />
          <SettingsRow icon="shield" iconBg="#6affc4" label="Segurança" value="Face ID" />
        </GlassCard>
      </div>

      <div style={{ padding: '12px 16px 0' }}>
        <GlassCard padding={0} radius={20} style={{ overflow: 'hidden' }}>
          <SettingsRow icon="logout" iconBg="#ff5a7a" label="Sair da conta" value="" danger />
        </GlassCard>
      </div>

      <div style={{ padding: '24px 16px', textAlign: 'center', color: 'var(--dim)', fontSize: 11 }}>
        Finanças · v1.0 · Maio 2026
      </div>
    </div>
  );
}
function SettingsRow({ icon, iconBg, label, value, danger }) {
  return (
    <button className="tap" style={{
      border: 'none', background: 'transparent', cursor: 'pointer',
      width: '100%', padding: '14px 16px',
      display: 'flex', alignItems: 'center', gap: 12,
      color: 'inherit', textAlign: 'left',
    }}>
      <div style={{ width: 30, height: 30, borderRadius: 9,
        background: `linear-gradient(135deg, ${iconBg}, ${iconBg}99)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.3)',
      }}>
        <Icon name={icon} size={15} color="#fff" />
      </div>
      <div style={{ flex: 1, fontSize: 15, fontWeight: 500, color: danger ? '#ff5a7a' : '#fff' }}>{label}</div>
      {value && <div style={{ fontSize: 13, color: 'var(--muted)' }}>{value}</div>}
      {!danger && <Icon name="chevron" size={14} color="rgba(255,255,255,0.3)" />}
    </button>
  );
}

// ═══════════════════════════════════════════════
// COMPARE / ANALYSIS
// ═══════════════════════════════════════════════
function CompareScreen({ bills, income }) {
  const total = bills.reduce((s, b) => s + b.value, 0);
  const remaining = income - total;
  const pct = income > 0 ? Math.min(100, (total / income) * 100) : 0;

  // per-category breakdown
  const byCat = CATEGORIES.map(c => {
    const sum = bills.filter(b => b.category === c.id).reduce((s, b) => s + b.value, 0);
    return { ...c, value: sum, pct: total ? (sum / total) * 100 : 0 };
  }).filter(c => c.value > 0).sort((a, b) => b.value - a.value);

  // Donut math
  const R = 70, C = 2 * Math.PI * R;
  let acc = 0;

  return (
    <div className="screen-enter scroll" style={{ height: '100%', overflowY: 'auto', paddingBottom: 110 }}>
      <TopNav title="Análise" large subtitle="Como você está usando seu dinheiro" />

      {/* Renda × Gastos comparison */}
      <div style={{ padding: '4px 16px 0' }}>
        <GlassCard strong radius={24} padding={20}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
            <div style={{ position: 'relative', width: 160, height: 160, flexShrink: 0 }}>
              <svg width="160" height="160" viewBox="0 0 160 160" style={{ transform: 'rotate(-90deg)' }}>
                <circle cx="80" cy="80" r={R} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="14" />
                {byCat.map((c, i) => {
                  const len = (c.value / income) * C;
                  const seg = <circle key={c.id} cx="80" cy="80" r={R} fill="none"
                    stroke={c.color} strokeWidth="14" strokeLinecap="butt"
                    strokeDasharray={`${len} ${C}`} strokeDashoffset={-acc}
                    style={{ transition: 'all 600ms' }} />;
                  acc += len;
                  return seg;
                })}
              </svg>
              <div style={{
                position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
              }}>
                <div style={{ fontSize: 11, color: 'var(--muted)', fontWeight: 600 }}>COMPROMETIDO</div>
                <div className="tnum" style={{ fontSize: 28, fontWeight: 800, letterSpacing: -0.8 }}>{Math.round(pct)}%</div>
                <div className="tnum" style={{ fontSize: 11, color: 'var(--muted)' }}>{fmtBRLshort(total)} / {fmtBRLshort(income)}</div>
              </div>
            </div>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 10 }}>
              <CompareLine color="#6affc4" label="Renda" value={income} />
              <CompareLine color="#ff6ec7" label="Gastos" value={total} />
              <CompareLine color={remaining >= 0 ? '#6e8aff' : '#ff5a7a'} label="Sobra" value={remaining} />
            </div>
          </div>
        </GlassCard>
      </div>

      {/* health indicator */}
      <div style={{ padding: '12px 16px 0' }}>
        <GlassCard padding={16} radius={20}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{
              width: 38, height: 38, borderRadius: 12,
              background: pct < 60 ? 'rgba(106,255,196,0.2)' : pct < 85 ? 'rgba(255,197,110,0.2)' : 'rgba(255,90,122,0.2)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name={pct < 60 ? 'check' : pct < 85 ? 'sparkle' : 'bell'} size={18} color={pct < 60 ? '#6affc4' : pct < 85 ? '#ffc56e' : '#ff5a7a'} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>{pct < 60 ? 'Excelente saúde financeira' : pct < 85 ? 'Atenção aos gastos' : 'Orçamento apertado'}</div>
              <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
                {pct < 60 ? `Você economiza ${fmtBRLshort(remaining)} este mês` : pct < 85 ? `Considere revisar assinaturas` : `Gastos superam ${Math.round(pct)}% da renda`}
              </div>
            </div>
          </div>
        </GlassCard>
      </div>

      {/* by category */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>Por categoria</div>
      </div>
      <div style={{ padding: '10px 16px 0', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {byCat.map((c, i) => (
          <GlassCard key={c.id} padding={12} radius={18} className="pop-in" style={{ animationDelay: (i * 50) + 'ms' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <CategoryIcon id={c.id} size={36} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
                  <div style={{ fontSize: 14, fontWeight: 600 }}>{c.label}</div>
                  <div className="tnum" style={{ fontSize: 14, fontWeight: 700 }}>{fmtBRL(c.value)}</div>
                </div>
                <div style={{ marginTop: 6, height: 5, borderRadius: 3, background: 'rgba(255,255,255,0.08)', overflow: 'hidden' }}>
                  <div style={{
                    width: c.pct + '%', height: '100%',
                    background: c.color, borderRadius: 3, boxShadow: `0 0 8px ${c.color}80`,
                    transition: 'width 600ms cubic-bezier(.32,.72,.24,1)',
                  }} />
                </div>
                <div style={{ fontSize: 11, color: 'var(--muted)', marginTop: 4 }} className="tnum">{Math.round(c.pct)}% dos gastos</div>
              </div>
            </div>
          </GlassCard>
        ))}
      </div>
    </div>
  );
}

function CompareLine({ color, label, value }) {
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <span style={{ width: 8, height: 8, borderRadius: 4, background: color, boxShadow: `0 0 8px ${color}80` }} />
        <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 600 }}>{label.toUpperCase()}</span>
      </div>
      <div className="tnum" style={{ fontSize: 19, fontWeight: 700, letterSpacing: -0.4, marginTop: 1 }}>{fmtBRL(value)}</div>
    </div>
  );
}

Object.assign(window, {
  HomeScreen, BillsScreen, BillForm, BillDetail, BillRow, ProfileScreen, CompareScreen,
});
