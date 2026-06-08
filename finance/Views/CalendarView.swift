import SwiftUI

// MARK: – Calendar grid

struct CalendarView: View {
    @Environment(AppViewModel.self) private var vm
    var onOpenBill: (String) -> Void

    @State private var selectedDay: Int? = nil

    private let weekdays = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    // MARK: Computed

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month,
                               for: monthDate(offset: vm.selectedMonthOffset))?.count ?? 30
    }

    private var leadingEmpties: Int {
        let cal = Calendar.current
        var dc = cal.dateComponents([.year, .month], from: monthDate(offset: vm.selectedMonthOffset))
        dc.day = 1
        guard let first = cal.date(from: dc) else { return 0 }
        return cal.component(.weekday, from: first) - 1   // 1=Sun→0 offset
    }

    private var todayDay: Int? {
        vm.selectedMonthOffset == 0 ? Calendar.current.component(.day, from: Date()) : nil
    }

    private func billsFor(_ day: Int) -> [Bill] {
        let iso = dayISO(day)
        return vm.bills.filter { $0.due == iso }
    }

    private var selectedBills: [Bill] {
        guard let d = selectedDay else { return [] }
        return billsFor(d).sorted { !$0.paid && $1.paid }
    }

    private func dayISO(_ day: Int) -> String {
        "\(monthISO(offset: vm.selectedMonthOffset))-\(String(format: "%02d", day))"
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            // Week header
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { wd in
                    Text(wd)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.muted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 6)

            // Day grid
            LazyVGrid(columns: cols, spacing: 4) {
                ForEach(0..<leadingEmpties, id: \.self) { _ in Color.clear.frame(height: 54) }

                ForEach(1...max(1, daysInMonth), id: \.self) { day in
                    CalDayCell(
                        day:        day,
                        bills:      billsFor(day),
                        isSelected: selectedDay == day,
                        isToday:    todayDay == day
                    ) {
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.78)) {
                            selectedDay = (selectedDay == day) ? nil : day
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .animation(.spring(response: 0.38), value: vm.selectedMonthOffset)

            // Selected day detail
            if selectedDay != nil {
                dayDetail
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .opacity
                    ))
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedDay)
            }
        }
        .onChange(of: vm.selectedMonthOffset) { _, _ in
            withAnimation { selectedDay = nil }
        }
    }

    // MARK: – Day detail panel

    private var dayDetail: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 0.5)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

            HStack {
                if let day = selectedDay {
                    Text("Dia \(day)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text("·  \(selectedBills.count) conta\(selectedBills.count == 1 ? "" : "s")")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.muted)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            if selectedBills.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(Color.successGreen)
                        .font(.system(size: 15))
                    Text("Nenhuma conta neste dia")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.muted)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                VStack(spacing: 7) {
                    ForEach(selectedBills) { bill in
                        CalBillRow(bill: bill) { onOpenBill(bill.id) }
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: – Day cell

private struct CalDayCell: View {
    let day:        Int
    let bills:      [Bill]
    let isSelected: Bool
    let isToday:    Bool
    let onTap:      () -> Void

    private var dotColors: [Color] {
        Array(bills.prefix(3).map { catById($0.category).color.opacity($0.paid ? 0.35 : 1.0) })
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.accentPink, .accentPurple],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 34, height: 34)
                            .shadow(color: Color.accentPink.opacity(0.45), radius: 8, y: 2)
                    } else if isToday {
                        Circle()
                            .stroke(Color.accentPink, lineWidth: 1.5)
                            .frame(width: 34, height: 34)
                    } else if !bills.isEmpty {
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 34, height: 34)
                    }

                    Text("\(day)")
                        .font(.system(size: 14,
                                      weight: (isToday || isSelected) ? .bold : .regular))
                        .foregroundStyle(
                            isSelected ? .white : isToday ? Color.accentPink : Color.white.opacity(0.90)
                        )
                }
                .frame(height: 36)

                // Dot indicators
                HStack(spacing: 2) {
                    ForEach(Array(dotColors.enumerated()), id: \.offset) { _, color in
                        Circle().fill(color).frame(width: 4, height: 4)
                    }
                    if bills.count > 3 {
                        Circle().fill(Color.muted).frame(width: 4, height: 4)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Bill row for calendar detail

private struct CalBillRow: View {
    let bill: Bill
    let onTap: () -> Void

    private var cat: Category { catById(bill.category) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(cat.color.opacity(0.20)).frame(width: 34, height: 34)
                    Image(systemName: cat.symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(cat.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(bill.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(cat.label)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.muted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(fmtBRL(bill.value))
                        .font(.system(size: 13, weight: .bold).monospacedDigit())
                        .foregroundStyle(bill.paid ? Color.muted : .white)
                        .strikethrough(bill.paid, color: Color.muted)
                    if bill.paid {
                        Text("Paga")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.successGreen)
                    }
                }
            }
            .padding(10)
            .glass(cornerRadius: 14)
        }
        .buttonStyle(TapScaleStyle())
    }
}
