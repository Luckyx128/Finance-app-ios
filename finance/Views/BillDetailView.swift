import SwiftUI

struct BillDetailView: View {
    @Environment(AppViewModel.self) private var vm
    let billId: String
    var onBack:       () -> Void
    var onEditBill:   (String) -> Void

    private var bill: Bill? { vm.bills.first { $0.id == billId } }
    private var cat:  Category { catById(bill?.category ?? "") }
    private var days: Int { daysUntil(bill?.due ?? "") }

    @State private var showPayConfirm = false

    var body: some View {
        Group {
            if let bill {
                ScrollView {
                    VStack(spacing: 12) {
                        // Top nav
                        HStack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .glass(cornerRadius: 20)
                            }
                            .buttonStyle(TapScaleStyle())

                            Spacer()

                            Text("Conta")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)

                            Spacer()

                            Button { onEditBill(bill.id) } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .glass(cornerRadius: 20)
                            }
                            .buttonStyle(TapScaleStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Hero
                        GlassCard(padding: 24, cornerRadius: 28, strong: true) {
                            VStack(alignment: .leading, spacing: 0) {
                                // Category glow
                                ZStack(alignment: .topTrailing) {
                                    Color.clear
                                    Circle()
                                        .fill(RadialGradient(
                                            colors: [cat.color.opacity(0.40), .clear],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 100
                                        ))
                                        .frame(width: 200, height: 200)
                                        .blur(radius: 20)
                                        .offset(x: 40, y: -40)
                                        .allowsHitTesting(false)
                                }
                                .frame(height: 0)

                                HStack(spacing: 12) {
                                    CategoryIconView(categoryId: bill.category, size: 52)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(cat.label.uppercased())
                                            .font(.system(size: 11, weight: .semibold))
                                            .tracking(0.4)
                                            .foregroundStyle(Color.muted)
                                        Text(bill.name)
                                            .font(.system(size: 22, weight: .bold))
                                            .tracking(-0.4)
                                            .foregroundStyle(.white)
                                    }
                                }

                                Text(fmtBRL(bill.value))
                                    .font(.system(size: 44, weight: .black).monospacedDigit())
                                    .tracking(-1.4)
                                    .foregroundStyle(.white)
                                    .padding(.top, 18)

                                HStack(spacing: 10) {
                                    statusPill(bill: bill)
                                    if bill.recurring {
                                        HStack(spacing: 5) {
                                            Image(systemName: "clock.fill")
                                                .font(.system(size: 11))
                                            Text("Mensal")
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .glass(cornerRadius: 14, subtle: true)
                                    }
                                }
                                .padding(.top, 14)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Details card
                        VStack(spacing: 0) {
                            detailRow(icon: "calendar", label: "Vencimento", value: fmtDate(bill.due))
                            GlassDivider()
                            detailRow(icon: "tag.fill", label: "Categoria", value: cat.label)
                            GlassDivider()
                            detailRow(icon: "clock.fill", label: "Recorrência", value: bill.recurring ? "Todo mês" : "Apenas uma vez")
                        }
                        .glass(cornerRadius: 20)
                        .padding(.horizontal, 16)

                        // Note card
                        if !bill.note.isEmpty {
                            GlassCard(padding: 16, cornerRadius: 20) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("OBSERVAÇÃO")
                                        .font(.system(size: 11, weight: .semibold))
                                        .tracking(0.3)
                                        .foregroundStyle(Color.muted)
                                    Text(bill.note)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                        .lineSpacing(3)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                        }

                        // Toggle paid CTA
                        if bill.paid {
                            // Unmark — immediate, no confirmation needed
                            Button {
                                withAnimation(.spring(response: 0.4)) { vm.togglePaid(bill.id) }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 17, weight: .bold))
                                    Text("Marcar como não paga")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.white.opacity(0.10))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(Color.white.opacity(0.20), lineWidth: 0.5)
                                        }
                                }
                            }
                            .buttonStyle(TapScaleStyle())
                            .padding(.horizontal, 16)
                        } else {
                            // Pay — step-by-step confirmation
                            GradientButton(
                                label: "Marcar como paga",
                                leadingIcon: "checkmark",
                                gradient: LinearGradient(
                                    colors: [.successGreen, .accentBlue],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            ) {
                                showPayConfirm = true
                            }
                            .padding(.horizontal, 16)
                            .shadow(color: Color.successGreen.opacity(0.35), radius: 14, y: 6)
                            .sheet(isPresented: $showPayConfirm) {
                                PaymentConfirmSheet(bill: bill)
                            }
                        }
                    }
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func statusPill(bill: Bill) -> some View {
        let text: String = {
            if bill.paid { return "✓ Paga" }
            if days < 0  { return "\(abs(days)) dias em atraso" }
            if days == 0 { return "Vence hoje" }
            return "Vence em \(days) dias"
        }()
        return Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .glass(cornerRadius: 14, subtle: true)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.80))
            }
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.muted)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(14)
    }
}
