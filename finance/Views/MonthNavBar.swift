import SwiftUI

/// Barra de navegação entre meses compartilhada por BillsView e AnalysisView.
struct MonthNavBar: View {
    @Binding var offset: Int

    @State private var goForward = true

    var body: some View {
        HStack(spacing: 0) {
            // Anterior
            Button { navigate(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 36)
            }
            .buttonStyle(TapScaleStyle())

            // Mês atual com animação direcional
            ZStack {
                Text(monthLabel(offset: offset))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .transition(.asymmetric(
                        insertion: .move(edge: goForward ? .trailing : .leading).combined(with: .opacity),
                        removal:   .move(edge: goForward ? .leading  : .trailing).combined(with: .opacity)
                    ))
                    .id(offset)
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: offset)

            // Próximo (esmaecido quando no mês atual)
            Button { navigate(by: +1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(offset >= 0 ? Color.dim : .white)
                    .frame(width: 44, height: 36)
            }
            .buttonStyle(TapScaleStyle())
            .disabled(offset >= 0)
        }
        .glass(cornerRadius: 14, subtle: true)
        .overlay(alignment: .trailing) {
            // Badge "Atual" quando está no mês corrente
            if offset == 0 {
                Text("Atual")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.accentPink.opacity(0.70)))
                    .offset(x: -48, y: 0)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .animation(.spring(response: 0.3), value: offset == 0)
    }

    private func navigate(by delta: Int) {
        goForward = delta > 0
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            offset += delta
        }
    }
}
