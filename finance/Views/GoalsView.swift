import SwiftUI

// MARK: – Goals list

struct GoalsView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @State private var editingCat: Category? = nil

    private var withBudget: [Category] {
        allCategories
            .filter { vm.budgets[$0.id] != nil }
            .sorted { vm.budgets[$0.id]! > vm.budgets[$1.id]! }
    }

    private var withoutBudget: [Category] {
        allCategories
            .filter { vm.budgets[$0.id] == nil }
            .sorted { vm.spent(for: $0.id) > vm.spent(for: $1.id) }
    }

    private var totalBudgeted: Double   { vm.budgets.values.reduce(0, +) }
    private var totalSpentIn: Double    { vm.budgets.keys.reduce(0) { $0 + vm.spent(for: $1) } }

    var body: some View {
        VStack(spacing: 0) {
            // Grabber
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Metas de gasto")
                        .font(.system(size: 22, weight: .black))
                        .tracking(-0.6)
                        .foregroundStyle(.white)
                    Text("Defina limites mensais por categoria")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.muted)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.muted)
                        .frame(width: 32, height: 32)
                        .glass(cornerRadius: 16)
                }
                .buttonStyle(TapScaleStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 22) {
                    // Summary (only when budgets exist)
                    if totalBudgeted > 0 {
                        summaryCard.padding(.horizontal, 20)
                    }

                    // Categories with budgets
                    if !withBudget.isEmpty {
                        catSection(title: "Com meta", cats: withBudget, hasBudget: true)
                    }

                    // Categories without budgets
                    if !withoutBudget.isEmpty {
                        catSection(
                            title: withBudget.isEmpty ? "Categorias" : "Sem meta",
                            cats: withoutBudget,
                            hasBudget: false
                        )
                    }
                }
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.bgBase.ignoresSafeArea())
        .sheet(item: $editingCat) { cat in
            BudgetEditSheet(cat: cat)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: – Summary card

    private var summaryCard: some View {
        let pct      = totalBudgeted > 0 ? min(1.0, totalSpentIn / totalBudgeted) : 0.0
        let barColor: Color = pct < 0.7 ? .successGreen : pct < 1.0 ? .warnOrange : .dangerRed

        return GlassCard(padding: 18, cornerRadius: 22, strong: true) {
            VStack(spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("TOTAL ORÇADO")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(Color.muted)
                        Text(fmtBRL(totalBudgeted))
                            .font(.system(size: 28, weight: .black).monospacedDigit())
                            .tracking(-0.8)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("GASTO")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(Color.muted)
                        Text(fmtBRL(totalSpentIn))
                            .font(.system(size: 22, weight: .bold).monospacedDigit())
                            .foregroundStyle(barColor)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.10)).frame(height: 8)
                        Capsule()
                            .fill(barColor)
                            .frame(width: geo.size.width * pct, height: 8)
                            .shadow(color: barColor.opacity(0.4), radius: 6)
                    }
                }
                .frame(height: 8)

                HStack {
                    Circle().fill(barColor).frame(width: 6, height: 6)
                    Text(pct >= 1 ? "Limite total excedido"
                         : "\(Int((pct * 100).rounded()))% do orçamento utilizado")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(pct >= 1 ? Color.dangerRed : Color.muted)
                    Spacer()
                    Text("\(withBudget.count) categoria\(withBudget.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dim)
                }
            }
        }
    }

    // MARK: – Section

    private func catSection(title: String, cats: [Category], hasBudget: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(cats) { cat in
                    BudgetCatCard(cat: cat, hasBudget: hasBudget) { editingCat = cat }
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: – Category row card

private struct BudgetCatCard: View {
    @Environment(AppViewModel.self) private var vm
    let cat: Category
    let hasBudget: Bool
    let onTap: () -> Void

    private var spent: Double  { vm.spent(for: cat.id) }
    private var limit: Double  { vm.budgets[cat.id] ?? 0 }
    private var pct:   Double  { limit > 0 ? min(1, spent / limit) : 0 }
    private var barColor: Color {
        pct < 0.7 ? .successGreen : pct < 1.0 ? .warnOrange : .dangerRed
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                CategoryIconView(categoryId: cat.id, size: 42)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(cat.label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        if hasBudget {
                            Text(fmtBRL(spent))
                                .font(.system(size: 14, weight: .bold).monospacedDigit())
                                .foregroundStyle(barColor)
                        }
                    }

                    if hasBudget {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.08)).frame(height: 5)
                                Capsule()
                                    .fill(barColor)
                                    .frame(width: geo.size.width * pct, height: 5)
                                    .shadow(color: barColor.opacity(0.5), radius: 4)
                            }
                        }
                        .frame(height: 5)

                        HStack {
                            Text(pct >= 1 ? "Limite excedido"
                                 : "\(Int((pct * 100).rounded()))% do limite")
                                .font(.system(size: 11))
                                .foregroundStyle(pct >= 1 ? Color.dangerRed : Color.muted)
                            Spacer()
                            Text("de \(fmtBRL(limit))")
                                .font(.system(size: 11).monospacedDigit())
                                .foregroundStyle(Color.muted)
                        }
                    } else {
                        HStack(spacing: 4) {
                            if spent > 0 {
                                Text("\(fmtBRL(spent)) gastos  ·")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.muted)
                            }
                            Text("Toque para definir meta")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.accentPink)
                        }
                    }
                }

                Image(systemName: hasBudget ? "pencil" : "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.muted)
                    .frame(width: 26, height: 26)
                    .glass(cornerRadius: 13, subtle: true)
            }
            .padding(14)
            .glass(cornerRadius: 18)
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Budget edit sheet

struct BudgetEditSheet: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    let cat: Category

    @FocusState private var focused: Bool
    @State private var limitStr = ""

    private var limitDouble:    Double { Double(limitStr) ?? 0 }
    private var currentLimit:   Double { vm.budgets[cat.id] ?? 0 }
    private var spent:          Double { vm.spent(for: cat.id) }
    private var displayText:    String { limitDouble > 0 ? fmtBRL(limitDouble) : "R$ —" }

    private var presets: [Int] {
        let base = max(spent, currentLimit)
        guard base > 0 else {
            switch cat.id {
            case "moradia":     return [800,  1200, 1500, 2000]
            case "cartao":      return [300,   500, 1000, 1500]
            case "casa":        return [150,   250,  350,  500]
            case "assinaturas": return [50,    100,  150,  200]
            case "transporte":  return [150,   250,  350,  500]
            case "saude":       return [200,   400,  600, 1000]
            case "educacao":    return [100,   200,  300,  500]
            default:            return [100,   200,  300,  500]
            }
        }
        return [0.75, 1.0, 1.25, 1.5].map { snap($0 * base) }.filter { $0 > 0 }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Grabber
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Category header
            HStack(spacing: 14) {
                CategoryIconView(categoryId: cat.id, size: 52)
                VStack(alignment: .leading, spacing: 3) {
                    Text(cat.label)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text(spent > 0 ? "\(fmtBRL(spent)) gastos este mês" : "Nenhum gasto este mês")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.muted)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.muted)
                        .frame(width: 30, height: 30)
                        .glass(cornerRadius: 15)
                }
                .buttonStyle(TapScaleStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)

            // Big number input
            VStack(spacing: 6) {
                Text("LIMITE MENSAL")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(Color.muted)

                ZStack {
                    Text(displayText)
                        .font(.system(size: 44, weight: .black).monospacedDigit())
                        .tracking(-1.4)
                        .foregroundStyle(.white)
                        .allowsHitTesting(false)

                    TextField("", text: $limitStr)
                        .keyboardType(.numberPad)
                        .focused($focused)
                        .opacity(0.001)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .onChange(of: limitStr) { _, new in
                            let digits = new.filter { $0.isNumber }
                            let capped = String(digits.prefix(8))
                            if capped != limitStr { limitStr = capped }
                        }
                }
                .onTapGesture { focused = true }

                Text("Toque no valor para editar")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.dim)
                    .opacity(focused ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: focused)
            }

            // Preset chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { v in
                        let active = Int(limitDouble) == v
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                limitStr = String(v)
                                focused = false
                            }
                        } label: {
                            Text(fmtBRLshort(Double(v)))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(active ? cat.color : Color.muted)
                                .padding(.horizontal, 16).padding(.vertical, 9)
                                .glass(cornerRadius: 999)
                                .overlay {
                                    if active { Capsule().stroke(cat.color.opacity(0.60), lineWidth: 1) }
                                }
                        }
                        .buttonStyle(TapScaleStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 22)

            Spacer()

            // Actions
            VStack(spacing: 12) {
                GradientButton(label: "Salvar meta", icon: nil, action: save)
                    .disabled(limitDouble == 0)
                    .opacity(limitDouble == 0 ? 0.45 : 1)

                if currentLimit > 0 {
                    Button(action: remove) {
                        Text("Remover meta")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.dangerRed)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.bgBase.ignoresSafeArea())
        .onAppear {
            if currentLimit > 0 { limitStr = String(Int(currentLimit)) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { focused = true }
        }
    }

    private func save() {
        vm.setBudget(categoryId: cat.id, limit: limitDouble)
        dismiss()
    }

    private func remove() {
        vm.removeBudget(categoryId: cat.id)
        dismiss()
    }

    private func snap(_ v: Double) -> Int { Int((v / 50).rounded()) * 50 }
}

// MARK: – Preview

#Preview {
    ZStack {
        WallpaperView()
        GoalsView()
            .environment(AppViewModel())
    }
    .preferredColorScheme(.dark)
}
