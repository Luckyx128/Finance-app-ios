# Handoff — App Finanças (pessoal)

## Visão geral
App mobile (iOS) de controle financeiro pessoal em português brasileiro. O usuário cadastra contas a pagar (fixas e variáveis), acompanha o quanto está comprometido da renda mensal, recebe lembretes de vencimento e visualiza análises por categoria.

Estética: **Liquid Glass** (estilo iOS 18) sobre wallpaper colorido animado, com dark mode permanente, tipografia Inter / SF Pro Display, paleta rosa-roxo-azul.

## Sobre os arquivos de design
Os arquivos neste bundle são **referências de design feitas em HTML/React** — protótipos mostrando aparência e comportamento pretendidos, **não código de produção para copiar direto**. A tarefa é **recriar esses designs no ambiente do seu projeto** (React Native, SwiftUI, Flutter, Next.js, etc.) usando os padrões e bibliotecas já estabelecidos. Se não houver projeto ainda, escolha o framework mais adequado (recomendação: **React Native + Expo** ou **SwiftUI**, dado que é um app mobile).

## Fidelidade
**Alta fidelidade (hifi)**: mocks com cores finais, tipografia, espaçamento e interações funcionando. Recrie pixel-perfect usando as bibliotecas do seu codebase.

## Stack sugerida
- **Framework**: React Native (Expo) ou SwiftUI
- **Storage local**: AsyncStorage / SwiftData / SQLite — não há backend ainda
- **Notificações**: expo-notifications / UNUserNotificationCenter (para Etapa 4)
- **Fontes**: Inter (Google Fonts) + SF Pro Display (sistema iOS) + JetBrains Mono (mono)
- **Idioma**: pt-BR

---

## Status das etapas (roadmap)

| # | Etapa | Status |
|---|---|---|
| — | App base (Home, Lista, Detalhe, Cadastro/Edição, Análise, Perfil) | ✅ Pronto no design |
| 1 | Splash + Onboarding (3 páginas) | ✅ Pronto no design |
| 2 | Login / Cadastro / Esqueci senha | ⏳ A fazer |
| 3 | Setup inicial (nome, renda, categorias) | ⏳ A fazer |
| 4 | Notificações (central de avisos) | ⏳ A fazer |
| 5 | Metas / Orçamento por categoria | ⏳ A fazer |
| 6 | Histórico mensal (navegar meses) | ⏳ A fazer |
| 7 | Calendário (contas no calendário) | ⏳ A fazer |
| 8 | Confirmação de pagamento (fluxo passo-a-passo) | ⏳ A fazer |
| 9 | Configurações detalhadas | ⏳ A fazer |
| 10 | Exportar / Backup (CSV, PDF) | ⏳ A fazer |

---

## Design tokens

> **⚠️ Paleta alterada (Jun 2026):** As cores do protótipo HTML/React (rosa-roxo) **não refletem a implementação real**. A implementação SwiftUI usa a paleta **Slate + Cobalt + Ice** descrita abaixo. Os arquivos `.jsx` de referência continuam com as cores originais apenas para fins de layout — ignore os valores de cor neles.

### Cores (implementação SwiftUI — Slate + Cobalt + Ice)
```
--bg               #0d1117   (slate profundo — fundo base)
--bg-deep          #080c12
--fg               #ffffff
--muted            rgba(255,255,255,0.62)
--dim              rgba(255,255,255,0.42)

--accent-pink      #3b82f6   (cobalt — botões, CTAs, ativo)
--accent-purple    #a78bfa   (violet suave — secundário)
--accent-blue      #7dd3fc   (sky/gelo — terciário, info)

--success          #4ade80   (esmeralda)
--warn             #facc15   (âmbar)
--danger           #fb7185   (rose)

Wallpaper gradient: #0d1117 → #161b2e → #1e2a45
+ blobs animados em #3b82f6 (cobalt), #bae6fd (ice), #a78bfa (violet), #dbeafe (branco-azulado)
```

### Cores originais do protótipo (apenas referência — NÃO usar na implementação)
```
rosa-roxo original: #ff6ec7 / #c084fc / #6e8aff / fundo #0e0420
```

### Categorias (cada uma com cor + ícone)
```
moradia        #f472b6   house.fill      (rose-400)
casa           #facc15   bolt.fill       (amber — contas de luz, água, gás, internet)
cartao         #60a5fa   creditcard.fill (blue-400)
assinaturas    #a78bfa   play.rectangle  (violet-400)
transporte     #34d399   car.fill        (emerald)
saude          #fb7185   heart.fill      (rose-500)
educacao       #c4b5fd   book.fill       (violet-300)
lazer          #7dd3fc   sparkles        (sky-300)
```

### Tipografia
- **Display/títulos**: Inter 700/800, letter-spacing -0.4 a -1.4
- **Corpo**: Inter 400/500/600
- **Mono (tabular numbers)**: `font-variant-numeric: tabular-nums` em valores monetários

Escala (px): 38 (hero), 28-34 (h1), 22 (h2), 18 (h3), 15-16 (corpo), 13 (small), 11-12 (label/caption)

### Glass primitive
```css
.glass {
  backdrop-filter: blur(28px) saturate(180%);
  background: rgba(255,255,255,0.10);
  border: 0.5px solid rgba(255,255,255,0.22);
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.35),
    inset 0 -1px 0 rgba(255,255,255,0.06),
    0 8px 24px rgba(0,0,0,0.25);
}
```
Variantes: `glass-strong` (mais blur, mais opaco, headers/heros/modais), `glass-subtle` (menos blur, cards secundários).

### Espaçamento + raios
- Padding interno cards: 12, 16, 20, 24
- Border radius: 14 (chip), 16-18 (botão/card pequeno), 20-24 (card médio), 28-32 (hero, modal)
- Gap entre cards na lista: 8-10
- Padding horizontal das telas: 16-20

### Animações
- Entrada de tela: `translateY(12px) scale(0.985)` → 0, 360ms cubic-bezier(.32,.72,.24,1)
- Modal sheet sobe: `translateY(40px)` → 0, 380ms mesma curva
- Pop-in de cards: 260ms com delay sequencial (i * 30~50ms)
- Tap: `scale(0.96)` 120ms

---

## Telas já desenhadas (referência)

### Home / Dashboard
- Greeting "Olá, {firstName}" + mês corrente, avatar circular gradiente
- **Hero card** (glass-strong, radius 28): total do mês em fonte gigante (38px, peso 800), "de R$ X de renda", badge % no canto, barra de progresso colorida por % (verde<70% → laranja<95% → vermelho), 3 colunas: PAGO/PENDENTE/SOBRA
- 2 stat cards menores: "Próximas (N contas a pagar)" + "Vencendo (N em 7 dias)"
- Lista "Próximas contas" (top 4, ordenado por data)

### Lista de contas (`BillsScreen`)
- TopNav grande "Contas" com subtítulo "N contas · R$ X"
- Segmented filter glass: Todas / Pendentes / Pagas
- Chips horizontais de categoria
- Lista de BillRow agrupada por status

### BillRow (linha de conta)
- Glass card padding 12, radius 20
- CategoryIcon 42px à esquerda, nome + status colorido + categoria, valor à direita (tabular, line-through se pago)

### Cadastro/Edição (modal bottom sheet `BillForm`)
- Grabber + header (Cancelar / título / Salvar)
- Campo "Valor" gigante centralizado (44px peso 800)
- Form rows: Nome, Vencimento (date picker), Repetir mês (toggle)
- Grade 4x2 de categorias (cada uma é um botão com glow quando selecionada)
- Textarea de observação
- Se edição: botão "Excluir conta" em vermelho

### Detalhe da conta (`BillDetail`)
- Hero glass com glow da cor da categoria, ícone grande + nome + valor 44px
- Pílulas de status (paga / vence em Xd / mensal)
- Card com Vencimento / Categoria / Recorrência
- Card de observação (se houver)
- CTA grande "Marcar como paga" (gradiente verde→azul) ou "Marcar como não paga"

### Análise (`CompareScreen`)
- Donut grande (R=70, stroke 14) com segmentos por categoria, centro mostrando % comprometido
- 3 linhas: Renda / Gastos / Sobra
- Card de saúde financeira (verde<60% / laranja<85% / vermelho)
- Lista por categoria com barra de progresso colorida

### Perfil (`ProfileScreen`)
- Avatar gradiente grande, nome, email
- Card "Renda mensal" editável inline (Editar → input → Salvar/Cancelar)
- Settings rows: Notificações, Idioma, Segurança, Sair

### Tab bar (bottom)
- 5 itens: Início, Contas, **+ (FAB central com gradiente)**, Análise, Perfil
- Glass-strong radius 30, ícone ativo em #ff6ec7

---

## Etapa 1 — Splash + Onboarding (PRONTA)

### Splash (`SplashScreen`)
- Halo radial #ff6ec7 com `haloPulse` 2.2s infinite
- Logo 116×116 radius 36 com gradient pink→purple→blue, glass-strong inner disc 76×76 com símbolo "R$" desenhado em SVG (stroke 3)
- Wordmark "Finanças" 34px peso 800 em gradient branco
- Subtitle "seu dinheiro, sem mistério"
- 3 dots animados com `dotPulse` staggered
- Auto-avança em **2200ms**

### Onboarding (`OnboardingScreen`)
3 páginas swipeable + dots animados (8→22px no ativo).

Página 1 — **CONTROLE / "Todas as suas contas em um só lugar"**
- Arte: 3 cartões glass empilhados em ângulos (back -10°, mid 0°, mais uma moeda R$ flutuante)
- Body: "Cadastre contas fixas e variáveis, defina recorrência e nunca mais perca um vencimento."

Página 2 — **CLAREZA / "Veja para onde seu dinheiro vai"**
- Arte: donut 220px com 5 segmentos (pink, purple, blue, green, yellow), centro glass com "MAIO 62% comprometido", chips flutuantes "Moradia" e "Assinaturas"
- Body: "Análise mensal por categoria, comparação entre renda e gastos e indicadores de saúde financeira."

Página 3 — **TRANQUILIDADE / "Lembretes na hora certa"**
- Arte: sino 120px com badge "3" vermelho com animação `bellWiggle` (rotações -12°/+12°), 2 cards de notificação glass abaixo
- Body: "Receba avisos antes do vencimento e evite juros, multas ou aquela conta esquecida."

### Botões/CTAs
- Topo direita: "Pular" (texto cinza, oculto na última página)
- Bottom: voltar (glass redondo, se page>0) + "Próximo" (gradient pink→purple→blue, com chevron) → "Começar agora" na última página
- Última página mostra disclaimer "Ao continuar você concorda com os Termos e Privacidade"

---

## State management (sugestão para o codebase real)

```ts
type Bill = {
  id: string;
  name: string;
  value: number;        // BRL, em reais
  due: string;          // ISO 'YYYY-MM-DD'
  category: 'moradia' | 'casa' | 'cartao' | 'assinaturas' | 'transporte' | 'saude' | 'educacao' | 'lazer';
  recurring: boolean;
  paid: boolean;
  note?: string;
};

type User = {
  name: string;
  email: string;
  income: number;       // BRL/mês
  avatar?: string;
};

type AppFlow = 'splash' | 'onboarding' | 'auth' | 'setup' | 'app';
```

Helpers já implementados (ver `glass.jsx`):
- `fmtBRL(v)` → "R$ 1.234,56"
- `fmtBRLshort(v)` → "R$ 1,2k"
- `parseBRL(s)` → number
- `fmtDate(iso)` → "DD/MM/YYYY"
- `fmtDateShort(iso)` → "12 mai"
- `daysUntil(iso)` → number (negativo = atrasada)

---

## Como continuar com Claude Code

1. **Abra seu projeto** (ou crie um novo com Expo: `npx create-expo-app finanças-app`)
2. **Inicie sessão do Claude Code** na raiz do projeto
3. **Cole esta instrução**:
   > Estou implementando um app de finanças pessoais. Use os arquivos em `design_handoff_finances/` como referência de design. Comece lendo o `README.md` completo, depois implemente as telas na ordem do roadmap. Estamos no [framework escolhido]. Para cada tela, recrie pixel-perfect respeitando design tokens e padrões já definidos.

4. **Para cada etapa**, peça ao Claude Code:
   - "Implemente a Etapa N seguindo o README. Mostre o componente antes de seguir."
   - Ajuste tokens (cores, fontes) para o sistema de design do seu projeto, se já existir.

5. **Arquivos de referência neste bundle**:
   - `Finanças.html` — entry point, scaling do device, CSS base
   - `glass.jsx` — primitivos (Glass, Icon, helpers monetários, Wallpaper, TabBar, TopNav, CategoryIcon)
   - `screens.jsx` — Home, Bills, BillForm, BillDetail, Profile, Compare
   - `onboarding.jsx` — Splash + Onboarding (Etapa 1)
   - `app.jsx` — estado global, routing, seed data
   - `ios-frame.jsx`, `tweaks-panel.jsx` — utilitários do protótipo (não recriar)

---

## Notas

- Todo o protótipo está em **dark mode**; verifique se seu codebase tem tema claro a implementar também.
- **Não há backend**. Tudo é local; planeje persistência (AsyncStorage / Core Data).
- **Liquid Glass real** em iOS 16+ usa `UIBlurEffect(style: .systemUltraThinMaterial)` no SwiftUI ou `expo-blur` (`BlurView intensity={80} tint="dark"`) no React Native. CSS `backdrop-filter` no protótipo é uma aproximação.
- **Notificações locais** (Etapa 4) precisam de permissão na primeira execução — peça depois do onboarding ou no setup.
- O símbolo R$ no splash é desenhado em SVG inline (path com stroke); pode ser substituído por um asset PNG/SVG real do logo quando existir.
