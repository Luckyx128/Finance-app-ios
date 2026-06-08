import SwiftUI

struct SplashView: View {
    var onDone: () -> Void

    @State private var haloPhase = false
    @State private var logoIn    = false
    @State private var wordIn    = false

    var body: some View {
        ZStack {
            // Halo radial pulse
            Circle()
                .fill(RadialGradient(
                    colors: [Color.accentPink.opacity(0.35), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 360)
                .blur(radius: 40)
                .scaleEffect(haloPhase ? 1.15 : 1.0)
                .opacity(haloPhase ? 1.0 : 0.7)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: haloPhase)

            VStack(spacing: 24) {
                // Logo mark
                ZStack {
                    // Outer gradient square
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(LinearGradient(
                            colors: [.accentPink, .accentPurple, .accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 116, height: 116)
                        .shadow(color: Color.accentPurple.opacity(0.55), radius: 40, y: 20)

                    // Inner glass disc
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.22))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                        }
                        .frame(width: 76, height: 76)
                        .overlay {
                            // R$ symbol — matches the SVG path in the design
                            Text("R$")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                }
                .scaleEffect(logoIn ? 1 : 0.6)
                .opacity(logoIn ? 1 : 0)

                // Wordmark
                VStack(spacing: 4) {
                    Text("Finanças")
                        .font(.system(size: 34, weight: .black))
                        .tracking(-1)
                        .foregroundStyle(LinearGradient(
                            colors: [.white, Color.white.opacity(0.70)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))

                    Text("seu dinheiro, sem mistério")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(0.3)
                        .foregroundStyle(Color.muted)
                }
                .opacity(wordIn ? 1 : 0)
                .offset(y: wordIn ? 0 : 10)
            }

            // Animated loading dots
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        let phase = (t + Double(i) * 0.15)
                            .truncatingRemainder(dividingBy: 1.2) / 1.2
                        let v = sin(phase * .pi)
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 6, height: 6)
                            .scaleEffect(0.85 + 0.35 * v)
                            .opacity(0.3 + 0.7 * v)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 88)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            haloPhase = true
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) { logoIn = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.22))           { wordIn  = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: onDone)
        }
    }
}

#Preview {
    ZStack {
        WallpaperView()
        SplashView(onDone: {})
    }
    .preferredColorScheme(.dark)
}
