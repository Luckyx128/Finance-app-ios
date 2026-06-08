import SwiftUI

struct BillsView: View {
    @Environment(AppViewModel.self) private var vm
    var onOpenBill: (String) -> Void
    var onShowForm:  () -> Void

    @State private var filter:       Filter  = .all
    @State private var catFilter:    String? = nil
    @State private var calendarMode          = false

    enum Filter: String, CaseIterable {
        case all = "Todas"; case pending = "Pendentes"; case paid = "Pagas"
    }

    private var monthBills: [Bill] {
        vm.bills.filter { billInMonth($0, offset: vm.selectedMonthOffset) }
    }

    private var filtered: [Bill] {
        monthBills.filter { b in
            let statusOk: Bool = {
                switch filter {
                case .all:     return true
                case .pending: return !b.paid
                case .paid:    return b.paid
                }
            }()
            let catOk = catFilter == nil || b.category == catFilter
            return statusOk && catOk
        }
        .sorted { a, b in
            if a.paid != b.paid { return !a.paid }
            return a.due < b.due
        }
    }

    private var monthTotal:   Double { monthBills.reduce(0) { $0 + $1.value } }
    private var monthPaid:    Double { monthBills.filter(\.paid).reduce(0) { $0 + $1.value } }
    private var monthPending: Double { monthTotal - monthPaid }

    var body: some View {
        VStack(spacing: 0) {
            // Título + toggle modo
            HStack(alignment: .bottom) {
                Text("Contas")
                    .font(.system(size: 34, weight: .black))
                    .tracking(-0.8)
                    .foregroundStyle(.white)
                Spacer()
                modeToggle
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)

            // MonthNavBar (compartilhada entre list e calendar)
            MonthNavBar(offset: Binding(
                get: { vm.selectedMonthOffset },
                set: { vm.selectedMonthOffset = $0 }
            ))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            if calendarMode {
                calendarContent
            } else {
                listContent
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.85), value: calendarMode)
    }

    // MARK: – Mode toggle

    private var modeToggle: some View {
        HStack(spacing: 0) {
            modeBtn(icon: "list.bullet", active: !calendarMode) {
                calendarMode = false
            }
            modeBtn(icon: "calendar", active: calendarMode) {
                calendarMode = true
            }
        }
        .glass(cornerRadius: 12, subtle: true)
        .padding(.bottom, 4)
    }

    private func modeBtn(icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button { withAnimation(.spring(response: 0.3)) { action() } } label: {
            Image(systemName: icon)
                .font(.system(size: 15, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? .white : Color.muted)
                .frame(width: 38, height: 32)
                .background {
                    if active {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                    }
                }
        }
        .buttonStyle(TapScaleStyle())
    }

    // MARK: – Calendar content

    private var calendarContent: some View {
        ScrollView {
            CalendarView(onOpenBill: onOpenBill)
                .padding(.top, 8)
                .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal:   .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: – List content

    private var listContent: some View {
        VStack(spacing: 0) {
            // Resumo do mês
            if !monthBills.isEmpty {
                monthSummary
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }

            // Segmented filter
            HStack(spacing: 2) {
                ForEach(Filter.allCases, id: \.self) { f in
                    Button(f.rawValue) {
                        withAnimation(.spring(response: 0.3)) { filter = f }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(filter == f ? .white : Color.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if filter == f {
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .fill(Color.white.opacity(0.18))
                                .shadow(color: .black.opacity(0.20), radius: 4, y: 2)
                        }
                    }
                }
            }
            .padding(4)
            .glass(cornerRadius: 14, subtle: true)
            .padding(.horizontal, 16)

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chipButton("Todas", color: nil, selected: catFilter == nil) { catFilter = nil }
                    ForEach(allCategories) { cat in
                        chipButton(cat.label, color: cat.color, selected: catFilter == cat.id) {
                            catFilter = catFilter == cat.id ? nil : cat.id
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 10)

            // Bill list
            ScrollView {
                LazyVStack(spacing: 8) {
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        ForEach(filtered) { bill in
                            BillRowView(bill: bill) { onOpenBill(bill.id) }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 110)
                .animation(.spring(response: 0.4), value: vm.selectedMonthOffset)
            }
            .scrollIndicators(.hidden)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal:   .move(edge: .trailing).combined(with: .opacity)
        ))
    }

    // MARK: – Month summary strip

    private var monthSummary: some View {
        HStack(spacing: 0) {
            summaryPill(label: "TOTAL",    value: fmtBRLshort(monthTotal),   color: .white)
            GlassDivider().frame(width: 1, height: 28)
            summaryPill(label: "PAGO",     value: fmtBRLshort(monthPaid),    color: .successGreen)
            GlassDivider().frame(width: 1, height: 28)
            summaryPill(label: "PENDENTE", value: fmtBRLshort(monthPending),
                        color: monthPending > 0 ? .warnOrange : Color.muted)
        }
        .padding(.vertical, 10)
        .glass(cornerRadius: 16, subtle: true)
    }

    private func summaryPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(Color.muted)
            Text(value)
                .font(.system(size: 14, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: – Empty state

    private var emptyState: some View {
        GlassCard(padding: 36, cornerRadius: 24) {
            VStack(spacing: 10) {
                Image(systemName: vm.selectedMonthOffset < 0 ? "calendar.badge.clock" : "tray")
                    .font(.system(size: 38))
                    .foregroundStyle(Color.muted)
                Text(vm.selectedMonthOffset < 0
                     ? "Nenhuma conta em \(monthLabel(offset: vm.selectedMonthOffset).components(separatedBy: " · ").first ?? "")"
                     : "Nenhuma conta aqui")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                if vm.selectedMonthOffset == 0 {
                    Text("Toque no + para cadastrar")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.muted)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: – Chip button

    private func chipButton(_ label: String, color: Color?, selected: Bool,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let c = color { Circle().fill(c).frame(width: 8, height: 8) }
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .glass(cornerRadius: 18, strong: selected, subtle: !selected)
        }
        .buttonStyle(TapScaleStyle())
    }
}
