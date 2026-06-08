import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:   Double(r) / 255,
                  green: Double(g) / 255,
                  blue:  Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    // MARK: – Design tokens  (Slate + Cobalt + Ice)
    static let bgBase       = Color(hex: "0d1117")   // slate profundo
    static let bgDeep       = Color(hex: "080c12")
    static let accentPink   = Color(hex: "3b82f6")   // cobalt — CTAs, ativo (era pink)
    static let accentPurple = Color(hex: "a78bfa")   // violet suave (era purple)
    static let accentBlue   = Color(hex: "7dd3fc")   // sky / gelo (era blue)
    static let successGreen = Color(hex: "4ade80")   // verde esmeralda
    static let warnOrange   = Color(hex: "facc15")   // âmbar
    static let dangerRed    = Color(hex: "fb7185")   // vermelho suave
    static let muted        = Color.white.opacity(0.62)
    static let dim          = Color.white.opacity(0.42)

    // MARK: – Wallpaper blobs
    static let blobPink    = Color(hex: "3b82f6")   // cobalt
    static let blobBlue    = Color(hex: "bae6fd")   // ice blue (glow claro)
    static let blobPurple  = Color(hex: "a78bfa")   // violet
    static let blobViolet  = Color(hex: "dbeafe")   // branco-azulado frio
}
