import SwiftUI

// MARK: – Glass ViewModifier

struct GlassStyle: ViewModifier {
    var cornerRadius: CGFloat
    var strong: Bool
    var subtle: Bool

    private var fillOpacity: Double { strong ? 0.16 : subtle ? 0.04 : 0.10 }
    private var strokeOpacity: Double { strong ? 0.30 : 0.22 }
    private var shadowRadius: CGFloat { strong ? 16 : 12 }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(fillOpacity))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(strokeOpacity), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.25), radius: shadowRadius, x: 0, y: 6)
            }
    }
}

extension View {
    func glass(cornerRadius: CGFloat = 24, strong: Bool = false, subtle: Bool = false) -> some View {
        modifier(GlassStyle(cornerRadius: cornerRadius, strong: strong, subtle: subtle))
    }
}

// MARK: – GlassCard

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var cornerRadius: CGFloat
    var strong: Bool
    var subtle: Bool
    var onTap: (() -> Void)?

    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 24,
        strong: Bool = false,
        subtle: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.strong = strong
        self.subtle = subtle
        self.onTap = onTap
    }

    var body: some View {
        if let tap = onTap {
            Button(action: tap) {
                content.padding(padding)
            }
            .buttonStyle(TapScaleStyle())
            .glass(cornerRadius: cornerRadius, strong: strong, subtle: subtle)
        } else {
            content
                .padding(padding)
                .glass(cornerRadius: cornerRadius, strong: strong, subtle: subtle)
        }
    }
}

// MARK: – Tap scale button style

struct TapScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: – Gradient CTA button

struct GradientButton: View {
    let label: String
    var icon: String?           // trailing icon (shown after label)
    var leadingIcon: String?    // leading icon (shown before label)
    var gradient: LinearGradient = LinearGradient(
        colors: [.accentPink, .accentPurple, .accentBlue],
        startPoint: .leading, endPoint: .trailing
    )
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let li = leadingIcon { Image(systemName: li).fontWeight(.semibold) }
                Text(label).fontWeight(.bold)
                if let icon { Image(systemName: icon).fontWeight(.semibold) }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(gradient)
                    .shadow(color: Color.accentPurple.opacity(0.45), radius: 14, y: 8)
            }
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Glass pill button

struct GlassPillButton: View {
    let label: String
    var icon: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon { Image(systemName: icon).font(.system(size: 14, weight: .semibold)) }
                Text(label).fontWeight(.semibold)
            }
            .font(.system(size: 14))
            .foregroundStyle(Color.muted)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .glass(cornerRadius: 999)
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Section header row

struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            if let lbl = action {
                Button(action: onAction ?? {}) {
                    Text(lbl).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.accentPink)
                }
            }
        }
    }
}

// MARK: – Divider

struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }
}
