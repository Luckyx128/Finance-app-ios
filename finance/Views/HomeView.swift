import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm
    var onOpenBill:   (String) -> Void
    var onShowForm:   () -> Void
    var onGoTo:       (MainTab) -> Void
    var onShowNotifs: () -> Void

    private var upcoming: [Bill] {
        vm.bills.filter { !$0.paid }
            .sorted { $0.due < $1.due }
            .prefix(4)
            .map { $0 }
    }

    private var nearCount: Int {
        vm.bills.filter { !$0.paid && daysUntil($0.due) <= 7 }.count
    }

    private var urgentCount: Int {
        vm.bills.filter { !$0.paid && daysUntil($0.due) <= 3 }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Greeting
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Olá, \(vm.user.name.components(separatedBy: " ").first ?? "")")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.muted)
                        Text(currentMonthYear())
                            .font(.system(size: 22, weight: .bold))
                            .tracking(-0.4)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    // Bell icon
                    Button(action: onShowNotifs) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 17))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .glass(cornerRadius: 22)
                            if urgentCount > 0 {
                                Text(urgentCount > 9 ? "9+" : "\(urgentCount)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(width: 17, height: 17)
                                    .background(Circle().fill(Color.dangerRed))
                                    .offset(x: 3, y: -3)
                            }
                        }
                    }
                    .buttonStyle(TapScaleStyle())
                    // Avatar
                    Button { onGoTo(.profile) } label: {
                        Text(initials(vm.user.name))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(LinearGradient(colors: [.accentPink, .accentBlue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .shadow(color: Color.accentPink.opacity(0.4), radius: 12, y: 4)
                            }
                    }
                    .buttonStyle(TapScaleStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Hero card
                heroCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                // Quick stats
                HStack(spacing: 10) {
                    statCard(
                        icon: "calendar",
                        iconColor: Color.accentBlue,
                        title: "Próximas",
                        value: "\(vm.bills.filter { !$0.paid }.count)",
                        subtitle: "contas a pagar"
                    )
                    statCard(
                        icon: "clock.fill",
                        iconColor: Color.accentPink,
                        title: "Vencendo",
                        value: "\(nearCount)",
                        subtitle: "em 7 dias"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Upcoming bills section
                VStack(spacing: 10) {
                    SectionHeader(title: "Próximas contas", action: "Ver todas") { onGoTo(.bills) }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    if upcoming.isEmpty {
                        GlassCard(padding: 20, cornerRadius: 20) {
                            HStack {
                                Spacer()
                                VStack(spacing: 4) {
                                    Text("🎉").font(.system(size: 32))
                                    Text("Nenhuma conta pendente")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.muted)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ForEach(upcoming) { bill in
                            BillRowView(bill: bill) { onOpenBill(bill.id) }
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: – Hero card

    private var heroCard: some View {
        GlassCard(padding: 20, cornerRadius: 28, strong: true) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TOTAL DO MÊS")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(Color.muted)
                        Text(fmtBRL(vm.totalMonth))
                            .font(.system(size: 38, weight: .black).monospacedDigit())
                            .tracking(-1.2)
                            .foregroundStyle(.white)
                        HStack(spacing: 4) {
                            Text("de")
                            Text(fmtBRL(vm.user.income))
                                .font(.system(size: 13, weight: .semibold).monospacedDigit())
                                .foregroundStyle(.white)
                            Text("de renda")
                        }
                        .font(.system(size: 13))
                        .foregroundStyle(Color.muted)
                    }
                    Spacer()
                    // % badge
                    HStack(spacing: 5) {
                        Image(systemName: vm.remaining >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 11, weight: .bold))
                        Text("\(Int(vm.pct.rounded()))%")
                            .font(.system(size: 12, weight: .bold).monospacedDigit())
                    }
                    .foregroundStyle(vm.remaining >= 0 ? Color.successGreen : Color.dangerRed)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .glass(cornerRadius: 14, subtle: true)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.12)).frame(height: 8)
                        Capsule()
                            .fill(progressGradient)
                            .frame(width: geo.size.width * min(1, vm.pct / 100), height: 8)
                            .shadow(color: Color.accentPink.opacity(0.4), radius: 6)
                    }
                }
                .frame(height: 8)
                .padding(.top, 18)

                // PAGO / PENDENTE / SOBRA
                HStack(spacing: 0) {
                    miniStat(dot: Color.successGreen, label: "PAGO",     value: vm.paidTotal)
                    miniStat(dot: Color.warnOrange,   label: "PENDENTE", value: vm.pending)
                    miniStat(dot: vm.remaining >= 0 ? Color.accentBlue : Color.dangerRed,
                             label: "SOBRA", value: vm.remaining,
                             valueColor: vm.remaining < 0 ? Color.dangerRed : .white)
                }
                .padding(.top, 16)
            }
        }
    }

    private var progressGradient: LinearGradient {
        vm.pct < 70
            ? LinearGradient(colors: [.successGreen, .accentBlue], startPoint: .leading, endPoint: .trailing)
            : vm.pct < 95
            ? LinearGradient(colors: [.warnOrange, .accentPink], startPoint: .leading, endPoint: .trailing)
            : LinearGradient(colors: [.dangerRed, .accentPink], startPoint: .leading, endPoint: .trailing)
    }

    private func miniStat(dot: Color, label: String, value: Double, valueColor: Color = .white) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 5) {
                Circle().fill(dot).frame(width: 6, height: 6)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.muted)
                    .tracking(0.2)
            }
            Text(fmtBRL(value))
                .font(.system(size: 16, weight: .bold).monospacedDigit())
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statCard(icon: String, iconColor: Color, title: String, value: String, subtitle: String) -> some View {
        GlassCard(padding: 14, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(iconColor.opacity(0.22))
                            .frame(width: 30, height: 30)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.muted)
                }
                Text(value)
                    .font(.system(size: 22, weight: .bold).monospacedDigit())
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dim)
            }
        }
    }

    private func initials(_ name: String) -> String {
        name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
}
