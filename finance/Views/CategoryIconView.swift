import SwiftUI

struct CategoryIconView: View {
    let categoryId: String
    var size: CGFloat = 42

    private var cat: Category { catById(categoryId) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(LinearGradient(
                    colors: [cat.color.opacity(0.85), cat.color.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                }
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .fill(Color.white.opacity(0.35))
                        .frame(height: 0.5)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                .shadow(color: cat.color.opacity(0.35), radius: 8, y: 4)

            Image(systemName: cat.symbol)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}
