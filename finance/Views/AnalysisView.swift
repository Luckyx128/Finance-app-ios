import SwiftUI

struct AnalysisView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var showGoals = false

    // Mês selecionado
    private var monthBills: [Bill] {
        vm.bills.filter { billInMonth($0, offset: vm.selectedMonthOffset) }
    }

    private var monthTotal:     Double { monthBills.reduce(0) { $0 + $1.value } }
    private var monthPaid:      Double { monthBills.filter(\.paid).reduce(0) { $0 + $1.value } }
    private var monthRemaining: Double { vm.user.income - monthTotal }
    private var monthPct:       Double { vm.user.income > 0 ? min(100, (monthTotal / vm.user.income) * 100) : 0 }

    private var byCat: [(cat: Category, value: Double, pct: Double)] {
        allCategories.compactMap { cat in
            let sum = monthBills.filter { $0.category == cat.id }.reduce(0) { $0 + $1.value }
            guard sum > 0 else { return nil }
            let pct = monthTotal > 0 ? (sum / monthTotal) * 100 : 0
            return (cat, sum, pct)
        }
        .sorted { $0.value > $1.value }
    }

    private var donutSegs: [(color: Color, from: Double, to: Double)] {
        var acc = 0.0
        return byCat.map { item in
            let frac = vm.user.income > 0 ? item.value / vm.user.income : 0
            let f = acc; let t = acc + frac * 0.97
            acc += frac
            return (item.cat.color, f, t)
        }
    }

    private var pct: Int { Int(monthPct.rounded()) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Título + navegação de mês
                VStack(alignment: .leading, spacing: 10) {
                    Text("Análise")
                        .font(.system(size: 34, weight: .black))
                        .tracking(-0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)

                    MonthNavBar(offset: Binding(
                        get: { vm.selectedMonthOffset },
                        set: { vm.selectedMonthOffset = $0 }
                    ))
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Donut + summary card
                GlassCard(padding: 20, cornerRadius: 24, strong: true) {
                    HStack(spacing: 18) {
                        // Donut
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 14))
                                .frame(width: 160, height: 160)

                            ForEach(Array(donutSegs.enumerated()), id: \.offset) { _, seg in
                                Circle()
                                    .trim(from: seg.from, to: seg.to)
                                    .stroke(seg.color, style: StrokeStyle(lineWidth: 14, lineCap: .butt))
                                    .shadow(color: seg.color.opacity(0.4), radius: 4)
                                    .frame(width: 160, height: 160)
                                    .rotationEffect(.degrees(-90))
                            }

                            // Center label
                            VStack(spacing: 1) {
                                Text("COMPROMETIDO")
                                    .font(.system(size: 8, weight: .bold))
                                    .tracking(0.5)
                                    .foregroundStyle(Color.muted)
                                Text("\(pct)%")
                                    .font(.system(size: 28, weight: .black).monospacedDigit())
                                    .tracking(-0.8)
                                    .foregroundStyle(.white)
                                Text("\(fmtBRLshort(monthTotal))/\(fmtBRLshort(vm.user.income))")
                                    .font(.system(size: 9).monospacedDigit())
                                    .foregroundStyle(Color.muted)
                            }
                        }
                        .frame(width: 160, height: 160)

                        // Lines
                        VStack(alignment: .leading, spacing: 10) {
                            compareLine(color: .successGreen, label: "RENDA",  value: vm.user.income)
                            compareLine(color: .accentPink,   label: "GASTOS", value: monthTotal)
                            compareLine(color: monthRemaining >= 0 ? Color.accentBlue : Color.dangerRed,
                                        label: "SOBRA", value: monthRemaining)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16)

                // Health card
                GlassCard(padding: 16, cornerRadius: 20) {
                    HStack(spacing: 10) {
                        let isGood = monthPct < 60
                        let isMid  = monthPct < 85
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isGood ? Color.successGreen.opacity(0.2) : isMid ? Color.warnOrange.opacity(0.2) : Color.dangerRed.opacity(0.2))
                                .frame(width: 38, height: 38)
                            Image(systemName: isGood ? "checkmark" : isMid ? "sparkles" : "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isGood ? Color.successGreen : isMid ? Color.warnOrange : Color.dangerRed)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isGood ? "Excelente saúde financeira" : isMid ? "Atenção aos gastos" : "Orçamento apertado")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text(isGood
                                 ? "Você economiza \(fmtBRLshort(monthRemaining)) este mês"
                                 : isMid ? "Considere revisar assinaturas"
                                 : "Gastos superam \(pct)% da renda")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.muted)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Per category
                VStack(spacing: 10) {
                    SectionHeader(title: "Por categoria", action: "Metas") {
                        showGoals = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    ForEach(byCat, id: \.cat.id) { item in
                        analysisCatCard(item: item)
                            .padding(.horizontal, 16)
                    }
                }
                .sheet(isPresented: $showGoals) {
                    GoalsView()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.hidden)
                }
            }
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
    }

    private func analysisCatCard(item: (cat: Category, value: Double, pct: Double)) -> some View {
        let limit     = vm.budgets[item.cat.id]
        let budgetPct = limit.map { min(1.0, item.value / $0) }
        let barColor: Color = {
            guard let bp = budgetPct else { return item.cat.color }
            return bp < 0.7 ? .successGreen : bp < 1.0 ? .warnOrange : .dangerRed
        }()

        return GlassCard(padding: 12, cornerRadius: 18) {
            HStack(spacing: 12) {
                CategoryIconView(categoryId: item.cat.id, size: 36)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.cat.label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(fmtBRL(item.value))
                            .font(.system(size: 14, weight: .bold).monospacedDigit())
                            .foregroundStyle(budgetPct == nil ? .white : barColor)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08)).frame(height: 5)
                            Capsule()
                                .fill(barColor)
                                .frame(width: geo.size.width * (budgetPct ?? (item.pct / 100)), height: 5)
                                .shadow(color: barColor.opacity(0.5), radius: 4)
                        }
                    }
                    .frame(height: 5)

                    if let bp = budgetPct, let lim = limit {
                        HStack {
                            Text(bp >= 1 ? "Limite excedido" : "\(Int((bp * 100).rounded()))% do limite")
                                .font(.system(size: 11))
                                .foregroundStyle(bp >= 1 ? Color.dangerRed : Color.muted)
                            Spacer()
                            Text("de \(fmtBRL(lim))")
                                .font(.system(size: 11).monospacedDigit())
                                .foregroundStyle(Color.muted)
                        }
                    } else {
                        Text("\(Int(item.pct.rounded()))% dos gastos")
                            .font(.system(size: 11).monospacedDigit())
                            .foregroundStyle(Color.muted)
                    }
                }
            }
        }
    }

    private func compareLine(color: Color, label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 5) {
                Circle().fill(color).shadow(color: color.opacity(0.5), radius: 3).frame(width: 8, height: 8)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(Color.muted)
            }
            Text(fmtBRL(value))
                .font(.system(size: 18, weight: .bold).monospacedDigit())
                .tracking(-0.4)
                .foregroundStyle(.white)
        }
    }
}
