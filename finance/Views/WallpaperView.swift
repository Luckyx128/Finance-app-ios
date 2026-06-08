import SwiftUI

struct WallpaperView: View {
    @State private var phase = false

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "0d1117"), location: 0),
                    .init(color: Color(hex: "161b2e"), location: 0.45),
                    .init(color: Color(hex: "1e2a45"), location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            blob(color: .blobPink,   opacity: 0.45, size: 300, x: phase ? -50 : -90, y: phase ? -170 : -210)
                .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: phase)

            blob(color: .blobBlue,   opacity: 0.18, size: 260, x: phase ? 110 : 75, y: phase ? 60 : 20)
                .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: phase)

            blob(color: .blobPurple, opacity: 0.30, size: 240, x: phase ? -20 : -55, y: phase ? 230 : 180)
                .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: phase)

            blob(color: .blobViolet, opacity: 0.12, size: 220, x: phase ? 70 : 35, y: phase ? -80 : -130)
                .animation(.easeInOut(duration: 5.2).repeatForever(autoreverses: true), value: phase)
        }
        .ignoresSafeArea()
        .onAppear { phase = true }
    }

    private func blob(color: Color, opacity: Double, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: 60)
            .offset(x: x, y: y)
    }
}
