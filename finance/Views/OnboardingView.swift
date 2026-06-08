import SwiftUI

// MARK: – Page model

private struct OnbPage {
    let id: String
    let eyebrow: String
    let title: String
    let body: String
    let art: ArtKind
    let accent: Color

    enum ArtKind { case wallet, donut, bell }
}

private let pages: [OnbPage] = [
    OnbPage(
        id: "control",
        eyebrow: "CONTROLE",
        title: "Todas as suas contas em um só lugar",
        body: "Cadastre contas fixas e variáveis, defina recorrência e nunca mais perca um vencimento.",
        art: .wallet,
        accent: .accentPink
    ),
    OnbPage(
        id: "insights",
        eyebrow: "CLAREZA",
        title: "Veja para onde seu dinheiro vai",
        body: "Análise mensal por categoria, comparação entre renda e gastos e indicadores de saúde financeira.",
        art: .donut,
        accent: .accentPurple
    ),
    OnbPage(
        id: "alerts",
        eyebrow: "TRANQUILIDADE",
        title: "Lembretes na hora certa",
        body: "Receba avisos antes do vencimento e evite juros, multas ou aquela conta esquecida.",
        art: .bell,
        accent: .accentBlue
    ),
]

// MARK: – OnboardingView

struct OnboardingView: View {
    var onDone: () -> Void

    @State private var page = 0
    @GestureState private var dragOffset: CGFloat = 0

    private var isLast: Bool { page == pages.count - 1 }
    private var current: OnbPage { pages[page] }

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if !isLast {
                    Button("Pular") { onDone() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.muted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .frame(height: 44)

            // Art area
            ZStack {
                switch current.art {
                case .wallet: ArtWalletView().id(current.id)
                case .donut:  ArtDonutView().id(current.id)
                case .bell:   ArtBellView().id(current.id)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { val in
                        if val.translation.width < -40, page < pages.count - 1 { advance() }
                        if val.translation.width > 40,  page > 0               { goBack() }
                    }
            )

            // Dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == page
                              ? AnyShapeStyle(LinearGradient(colors: [.accentPink, .accentPurple], startPoint: .leading, endPoint: .trailing))
                              : AnyShapeStyle(Color.white.opacity(0.22))
                        )
                        .frame(width: i == page ? 22 : 8, height: 8)
                        .shadow(color: i == page ? Color.accentPink.opacity(0.40) : .clear, radius: 6, y: 2)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: page)
                        .onTapGesture { withAnimation(.spring(response: 0.4)) { page = i } }
                }
            }
            .padding(.vertical, 12)

            // Text + CTAs
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(current.eyebrow)
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(current.accent)

                    Text(current.title)
                        .font(.system(size: 28, weight: .black))
                        .tracking(-0.6)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(current.body)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.muted)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .id(current.id)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .padding(.bottom, 22)

                // CTA buttons row
                HStack(spacing: 10) {
                    if page > 0 {
                        Button(action: goBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 52, height: 52)
                                .glass(cornerRadius: 18)
                        }
                        .buttonStyle(TapScaleStyle())
                    }

                    GradientButton(label:
                        isLast ? "Começar agora" : "Próximo",
                        icon: "chevron.right"
                    ) {
                        if isLast { onDone() } else { advance() }
                    }
                }

                if isLast {
                    Text("Ao continuar, você concorda com os **Termos** e **Privacidade**.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dim)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: page)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func advance() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { page += 1 }
    }
    private func goBack() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { page -= 1 }
    }
}

// MARK: – Art: Wallet (page 1)

private struct ArtWalletView: View {
    @State private var appear = false
    @State private var float  = false

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Color.accentPink.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 40)

            // Back card — blue, rotated
            cardView(
                gradient: LinearGradient(colors: [Color.accentBlue.opacity(0.55), Color.accentBlue.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                width: 200, height: 124, radius: 22
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    chipChip()
                    Spacer()
                    Text("•••• 4231")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .tracking(1)
                }
                .padding(16)
            }
            .rotationEffect(.degrees(-10))
            .offset(x: -44, y: -50)
            .offset(y: float ? -6 : 6)
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: float)
            .shadow(color: Color.accentBlue.opacity(0.35), radius: 14, y: 10)

            // Mid card — purple, straight
            cardView(
                gradient: LinearGradient(colors: [Color.accentPurple.opacity(0.70), Color.accentPurple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing),
                width: 220, height: 138, radius: 24
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        chipChip()
                        Spacer()
                        Text("FINANÇAS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(1)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SALDO")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .tracking(1)
                        Text("R$ 4.213")
                            .font(.system(size: 22, weight: .black))
                            .tracking(-0.5)
                            .foregroundStyle(.white)
                    }
                }
                .padding(18)
            }
            .offset(y: float ? 0 : 8)
            .animation(.easeInOut(duration: 5).delay(0.5).repeatForever(autoreverses: true), value: float)
            .shadow(color: Color.accentPurple.opacity(0.45), radius: 18, y: 12)

            // Front gold coin
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "ffd560"), Color(hex: "c08530")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color(hex: "ffd560").opacity(0.5), radius: 14, y: 8)
                Text("R$")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "5a3a00"))
            }
            .frame(width: 64, height: 64)
            .overlay {
                Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: 64, height: 64)
            }
            .offset(x: 70, y: 78)
            .offset(y: float ? -5 : 5)
            .animation(.easeInOut(duration: 4).delay(1).repeatForever(autoreverses: true), value: float)
        }
        .scaleEffect(appear ? 1 : 0.85)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appear)
        .onAppear { appear = true; float = true }
    }

    @ViewBuilder
    private func chipChip() -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(LinearGradient(colors: [Color(hex: "ffd560"), Color(hex: "c08530")], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 28, height: 18)
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 0.5)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
    }

    private func cardView<C: View>(gradient: LinearGradient, width: CGFloat, height: CGFloat, radius: CGFloat, @ViewBuilder _ content: () -> C) -> some View {
        content()
            .frame(width: width, height: height)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(gradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    }
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Color.white.opacity(0.45))
                            .frame(height: 1)
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
            }
    }
}

// MARK: – Art: Donut (page 2)

private struct ArtDonutView: View {
    @State private var appear = false
    @State private var float  = false

    private let segs: [(Color, Double)] = [
        (Color(hex: "3b82f6"), 0.32),  // cobalt
        (Color(hex: "a78bfa"), 0.22),  // violet
        (Color(hex: "7dd3fc"), 0.18),  // sky
        (Color(hex: "4ade80"), 0.14),  // emerald
        (Color(hex: "facc15"), 0.14),  // amber
    ]

    private var segments: [(color: Color, from: Double, to: Double)] {
        var acc = 0.0
        return segs.map { (color, pct) in
            let f = acc; let t = acc + pct * 0.97
            acc += pct
            return (color, f, t)
        }
    }

    var body: some View {
        ZStack {
            // Glow
            Circle().fill(Color.accentPurple.opacity(0.35)).frame(width: 260, height: 260).blur(radius: 40)

            ZStack {
                // Donut
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 22))
                        .frame(width: 172, height: 172)
                    // Segments
                    ForEach(Array(segments.enumerated()), id: \.offset) { _, seg in
                        Circle()
                            .trim(from: seg.from, to: seg.to)
                            .stroke(seg.color, style: StrokeStyle(lineWidth: 22, lineCap: .butt))
                            .shadow(color: seg.color.opacity(0.5), radius: 6)
                            .frame(width: 172, height: 172)
                            .rotationEffect(.degrees(-90))
                    }
                }

                // Center glass
                ZStack {
                    VStack(spacing: 1) {
                        Text("MAIO")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(Color.muted)
                        Text("62%")
                            .font(.system(size: 30, weight: .black))
                            .tracking(-1)
                            .foregroundStyle(.white)
                        Text("comprometido")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.muted)
                    }
                }
                .frame(width: 128, height: 128)
                .glass(cornerRadius: 64, strong: true)
            }
            .offset(y: float ? -6 : 6)
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: float)

            // Floating chips
            chipLabel("Moradia", color: Color(hex: "3b82f6"))
                .offset(x: 90, y: -115)
                .offset(y: float ? -5 : 5)
                .animation(.easeInOut(duration: 4).delay(0.3).repeatForever(autoreverses: true), value: float)

            chipLabel("Assinaturas", color: Color(hex: "a78bfa"))
                .offset(x: -110, y: 90)
                .offset(y: float ? 5 : -5)
                .animation(.easeInOut(duration: 5).delay(0.8).repeatForever(autoreverses: true), value: float)
        }
        .scaleEffect(appear ? 1 : 0.85)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appear)
        .onAppear { appear = true; float = true }
    }

    private func chipLabel(_ text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text).font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .glass(cornerRadius: 14, strong: true)
    }
}

// MARK: – Art: Bell (page 3)

private struct ArtBellView: View {
    @State private var appear = false
    @State private var wiggle = false
    @State private var float  = false

    var body: some View {
        ZStack {
            // Glow
            Circle().fill(Color.accentBlue.opacity(0.35)).frame(width: 260, height: 260).blur(radius: 40)

            // Bell icon
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.accentBlue.opacity(0.5), radius: 20, y: 10)
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .fill(Color.white.opacity(0.5))
                                .frame(height: 1)
                                .frame(maxHeight: .infinity, alignment: .top)
                        }
                    Image(systemName: "bell.fill")
                        .font(.system(size: 52, weight: .regular))
                        .foregroundStyle(.white)
                }
                .rotationEffect(.degrees(wiggle ? 12 : 0), anchor: .top)
                .animation(
                    wiggle
                        ? .easeInOut(duration: 0.25).repeatCount(6, autoreverses: true)
                        : .default,
                    value: wiggle
                )

                // Badge
                ZStack {
                    Circle().fill(Color.dangerRed)
                        .shadow(color: Color.dangerRed.opacity(0.5), radius: 6, y: 2)
                    Text("3").font(.system(size: 11, weight: .black)).foregroundStyle(.white)
                }
                .frame(width: 22, height: 22)
                .offset(x: 4, y: -4)
            }
            .offset(y: -20)

            // Notification card 1
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentPink.opacity(0.5))
                    Image(systemName: "house.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Aluguel vence amanhã")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                    Text("R$ 1.850 · Moradia")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.muted)
                }
                Spacer()
                Text("1d").font(.system(size: 9, weight: .bold)).foregroundStyle(Color.warnOrange)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(width: 230)
            .glass(cornerRadius: 16, strong: true)
            .offset(y: 80)
            .offset(y: float ? -5 : 5)
            .animation(.easeInOut(duration: 5).delay(0.2).repeatForever(autoreverses: true), value: float)

            // Notification card 2
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentPurple.opacity(0.5))
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 26, height: 26)

                Text("Netflix em 3 dias")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .frame(width: 200)
            .glass(cornerRadius: 14)
            .opacity(0.85)
            .offset(x: 20, y: 130)
            .offset(y: float ? 5 : -5)
            .animation(.easeInOut(duration: 5).delay(0.9).repeatForever(autoreverses: true), value: float)
        }
        .scaleEffect(appear ? 1 : 0.85)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appear)
        .onAppear {
            appear = true
            float  = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wiggle = true
                // Reset wiggle after animation completes so it can repeat on a timer
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    wiggle = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        WallpaperView()
        OnboardingView(onDone: {})
    }
    .preferredColorScheme(.dark)
}
