import SwiftUI

// MARK: – Payment method

enum PayMethod: String, CaseIterable, Identifiable {
    case pix    = "PIX"
    case credit = "Crédito"
    case debit  = "Débito"
    case cash   = "Dinheiro"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pix:    return "qrcode"
        case .credit: return "creditcard.fill"
        case .debit:  return "creditcard"
        case .cash:   return "banknote.fill"
        }
    }

    var color: Color {
        switch self {
        case .pix:    return .successGreen
        case .credit: return .accentPink
        case .debit:  return .accentPurple
        case .cash:   return .accentBlue
        }
    }
}

// MARK: – Sheet

struct PaymentConfirmSheet: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss)        private var dismiss
    let bill: Bill

    @State private var step           = 0
    @State private var selectedMethod: PayMethod? = nil
    @State private var showCheck      = false

    private var cat: Category { catById(bill.category) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            WallpaperView().ignoresSafeArea()

            VStack(spacing: 0) {
                topHandle
                    .padding(.top, 14)
                    .padding(.bottom, 28)

                ZStack {
                    if step == 0 { resumoStep  .id(0).transition(slide(.trailing)) }
                    if step == 1 { metodoStep  .id(1).transition(slide(.trailing)) }
                    if step == 2 { sucessoStep .id(2).transition(slide(.trailing)) }
                }
                .animation(.spring(response: 0.38, dampingFraction: 0.85), value: step)
                .frame(maxHeight: .infinity)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    // MARK: – Top handle + step pills

    private var topHandle: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)

            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(i <= step ? Color.accentPink : Color.white.opacity(0.20))
                        .frame(width: i == step ? 28 : 8, height: 4)
                }
            }
            .animation(.spring(response: 0.30, dampingFraction: 0.80), value: step)
        }
    }

    private func slide(_ edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal:   .move(edge: edge == .trailing ? .leading : .trailing).combined(with: .opacity)
        )
    }

    // MARK: – Step 0: Resumo

    private var resumoStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("Confirmar pagamento")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text("Revise os dados antes de confirmar")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.muted)
            }

            GlassCard(padding: 24, cornerRadius: 28, strong: true) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        CategoryIconView(categoryId: bill.category, size: 50)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(cat.label.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.5)
                                .foregroundStyle(Color.muted)
                            Text(bill.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                        }
                    }

                    Text(fmtBRL(bill.value))
                        .font(.system(size: 44, weight: .black).monospacedDigit())
                        .tracking(-1.4)
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.muted)
                        Text("Vence em \(fmtDate(bill.due))")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.muted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)

            Spacer()

            GradientButton(label: "Pagar agora", icon: "arrow.right") {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) { step = 1 }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 44)
        }
    }

    // MARK: – Step 1: Método

    private var metodoStep: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("Como você pagou?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text("Toque no método para confirmar")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.muted)
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(PayMethod.allCases) { method in
                    methodCard(method)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    private func methodCard(_ method: PayMethod) -> some View {
        Button {
            selectedMethod = method
            vm.confirmPayment(id: bill.id, method: method.rawValue)
            withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) { step = 2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { dismiss() }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(method.color.opacity(0.18))
                        .frame(width: 62, height: 62)
                    Image(systemName: method.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(method.color)
                }
                Text(method.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .glass(cornerRadius: 22)
        }
        .buttonStyle(TapScaleStyle())
    }

    // MARK: – Step 2: Sucesso

    private var sucessoStep: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                // Pulse ring
                Circle()
                    .stroke(Color.successGreen.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 150, height: 150)
                    .scaleEffect(showCheck ? 1.25 : 1.0)
                    .opacity(showCheck ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 1.1).delay(0.3).repeatForever(autoreverses: false),
                        value: showCheck
                    )

                // Fill
                Circle()
                    .fill(Color.successGreen.opacity(0.12))
                    .frame(width: 130, height: 130)

                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Color.successGreen)
                    .scaleEffect(showCheck ? 1.0 : 0.2)
                    .opacity(showCheck ? 1 : 0)
                    .animation(.spring(response: 0.50, dampingFraction: 0.55), value: showCheck)
            }
            .onAppear { withAnimation { showCheck = true } }

            VStack(spacing: 8) {
                Text("Pagamento confirmado!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                if let method = selectedMethod {
                    HStack(spacing: 6) {
                        Image(systemName: method.icon)
                            .font(.system(size: 13))
                            .foregroundStyle(method.color)
                        Text(method.rawValue)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(Color.muted)
                }
                Text(fmtBRL(bill.value))
                    .font(.system(size: 38, weight: .black).monospacedDigit())
                    .tracking(-1.0)
                    .foregroundStyle(Color.successGreen)
                    .padding(.top, 4)
            }
            .opacity(showCheck ? 1 : 0)
            .animation(.easeIn(duration: 0.35).delay(0.25), value: showCheck)

            Spacer()
        }
    }
}
