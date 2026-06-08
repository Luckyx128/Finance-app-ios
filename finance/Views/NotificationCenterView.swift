import SwiftUI

struct NotificationCenterView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    var onOpenBill: (String) -> Void

    private var unpaid:   [Bill] { vm.bills.filter { !$0.paid } }
    private var urgent:   [Bill] { (overdue + today).sorted { $0.due < $1.due } }
    private var overdue:  [Bill] { unpaid.filter { daysUntil($0.due) < 0 } }
    private var today:    [Bill] { unpaid.filter { daysUntil($0.due) == 0 } }
    private var thisWeek: [Bill] { unpaid.filter { let d = daysUntil($0.due); return d >= 1 && d <= 7 }.sorted { $0.due < $1.due } }
    private var later:    [Bill] { unpaid.filter { daysUntil($0.due) > 7 }.sorted { $0.due < $1.due } }

    var body: some View {
        VStack(spacing: 0) {
            // Grabber
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notificações")
                        .font(.system(size: 22, weight: .black))
                        .tracking(-0.6)
                        .foregroundStyle(.white)
                    if !unpaid.isEmpty {
                        Text("\(unpaid.count) conta\(unpaid.count == 1 ? "" : "s") pendente\(unpaid.count == 1 ? "" : "s")")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.muted)
                    }
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
            .padding(.bottom, 18)

            ScrollView {
                VStack(spacing: 22) {
                    // Permission banner
                    if !vm.notifAuthorized {
                        permissionBanner.padding(.horizontal, 20)
                    }

                    if !urgent.isEmpty {
                        section(title: "Urgente", tint: .dangerRed, bills: urgent, urgency: .urgent)
                    }
                    if !thisWeek.isEmpty {
                        section(title: "Esta semana", tint: .warnOrange, bills: thisWeek, urgency: .soon)
                    }
                    if !later.isEmpty {
                        section(title: "Em breve", tint: .accentBlue, bills: later, urgency: .later)
                    }
                    if unpaid.isEmpty {
                        emptyState
                    }
                }
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.bgBase.ignoresSafeArea())
    }

    // MARK: – Permission banner

    private var permissionBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.warnOrange)

            VStack(alignment: .leading, spacing: 3) {
                Text("Ative as notificações")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text("Receba lembretes antes do vencimento")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.muted)
            }

            Spacer()

            Button {
                Task {
                    vm.notifAuthorized = await NotificationManager.requestPermission()
                    if vm.notifAuthorized {
                        NotificationManager.scheduleAll(bills: vm.bills)
                    }
                }
            } label: {
                Text("Ativar")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.accentPink, .accentPurple],
                                startPoint: .leading, endPoint: .trailing))
                    }
            }
            .buttonStyle(TapScaleStyle())
        }
        .padding(16)
        .glass(cornerRadius: 20)
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.warnOrange.opacity(0.40), lineWidth: 1)
        }
    }

    // MARK: – Section

    private func section(title: String, tint: Color, bills: [Bill], urgency: Urgency) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(bills.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(tint.opacity(0.35)))
                Spacer()
            }
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(bills) { bill in
                    NotifCard(bill: bill, urgency: urgency) {
                        onOpenBill(bill.id)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: – Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.dim)
            Text("Tudo em dia!")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.muted)
            Text("Nenhuma conta pendente no momento.")
                .font(.system(size: 14))
                .foregroundStyle(Color.dim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 70)
    }

    enum Urgency { case urgent, soon, later }
}

// MARK: – Notification card

private struct NotifCard: View {
    let bill: Bill
    let urgency: NotificationCenterView.Urgency
    let onTap: () -> Void

    private var cat: Category { catById(bill.category) }
    private var days: Int     { daysUntil(bill.due) }

    private var dayLabel: String {
        if days < 0  { return "\(abs(days))d em atraso" }
        if days == 0 { return "Vence hoje" }
        if days == 1 { return "Amanhã" }
        return "Em \(days) dias"
    }

    private var tint: Color {
        switch urgency {
        case .urgent: return .dangerRed
        case .soon:   return .warnOrange
        case .later:  return .accentBlue
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                CategoryIconView(categoryId: bill.category, size: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(bill.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(cat.label)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.muted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(fmtBRL(bill.value))
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white)
                    HStack(spacing: 4) {
                        Circle().fill(tint).frame(width: 5, height: 5)
                        Text(dayLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                }
            }
            .padding(14)
            .glass(cornerRadius: 18)
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Preview

#Preview {
    ZStack {
        WallpaperView()
        NotificationCenterView(onOpenBill: { _ in })
            .environment(AppViewModel())
    }
    .preferredColorScheme(.dark)
}
