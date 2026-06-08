import UIKit
import SwiftUI

// MARK: – CSV

enum ExportManager {

    static func generateCSV(bills: [Bill], title: String) -> URL? {
        var lines = ["Nome,Valor,Vencimento,Categoria,Recorrente,Pago,Método,Observação"]
        for b in bills.sorted(by: { $0.due < $1.due }) {
            let row = [
                b.name.csvEscaped,
                String(format: "%.2f", b.value),
                b.due,
                catById(b.category).label.csvEscaped,
                b.recurring  ? "Sim" : "Não",
                b.paid       ? "Sim" : "Não",
                b.paymentMethod.csvEscaped,
                b.note.csvEscaped
            ].joined(separator: ",")
            lines.append(row)
        }
        let content = lines.joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("financas_\(safeFilename(title)).csv")
        try? content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: – PDF

    static func generatePDF(bills: [Bill], user: UserProfile, title: String) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("financas_\(safeFilename(title)).pdf")

        let sorted  = bills.sorted { $0.due < $1.due }
        let total   = bills.reduce(0.0)          { $0 + $1.value }
        let paidAmt = bills.filter(\.paid).reduce(0.0) { $0 + $1.value }
        let pending = total - paidAmt

        let byCat: [(cat: Category, val: Double)] = allCategories.compactMap { cat in
            let sum = bills.filter { $0.category == cat.id }.reduce(0.0) { $0 + $1.value }
            return sum > 0 ? (cat, sum) : nil
        }.sorted { $0.val > $1.val }

        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: page)

        do {
            try renderer.writePDF(to: url) { ctx in
                var p = PDFPainter(ctx: ctx, title: title, user: user)
                p.beginPage()

                // Summary
                p.drawSummary(total: total, paid: paidAmt, pending: pending)
                p.y += 24

                // Categories
                if !byCat.isEmpty {
                    p.section("Por Categoria")
                    for item in byCat { p.categoryRow(item, total: total) }
                    p.y += 8
                }

                p.separator()

                // Bills table
                p.section("Contas (\(sorted.count))")
                p.tableHeader()
                for (i, bill) in sorted.enumerated() { p.billRow(bill, alt: i.isMultiple(of: 2)) }

                // Footer
                p.footer()
            }
            return url
        } catch {
            return nil
        }
    }

    // MARK: – Helpers

    static func safeFilename(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "_", options: .regularExpression)
    }
}

private extension String {
    var csvEscaped: String {
        if contains(",") || contains("\"") || contains("\n") {
            return "\"" + replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return self
    }
}

// MARK: – PDF Painter

private struct PDFPainter {
    let ctx:   UIGraphicsPDFRendererContext
    let title: String
    let user:  UserProfile

    var y:  CGFloat = 0
    let W:  CGFloat = 595
    let H:  CGFloat = 842
    let M:  CGFloat = 40
    var CW: CGFloat { W - M * 2 }

    // Header repeated on each page
    let headerH: CGFloat = 72

    // Colors
    let headerBg = UIColor(red: 0.08, green: 0.07, blue: 0.18, alpha: 1)   // dark indigo
    let rowAlt   = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
    let border   = UIColor(red: 0.88, green: 0.88, blue: 0.92, alpha: 1)
    let textMain = UIColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1)
    let textMuted = UIColor(red: 0.45, green: 0.47, blue: 0.54, alpha: 1)

    // MARK: Page management

    mutating func beginPage() {
        ctx.beginPage()
        y = drawHeader()
        y += 20
    }

    mutating func check(_ needed: CGFloat) {
        if y + needed > H - 44 {
            footer()
            beginPage()
        }
    }

    // MARK: Header

    @discardableResult
    mutating func drawHeader() -> CGFloat {
        // Background
        headerBg.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 0, width: W, height: headerH)).fill()

        // Left: label + title
        draw("RELATÓRIO FINANCEIRO",
             CGRect(x: M, y: 14, width: CW * 0.55, height: 16),
             .systemFont(ofSize: 8, weight: .semibold), .white.withAlphaComponent(0.55))
        draw(title,
             CGRect(x: M, y: 30, width: CW * 0.55, height: 28),
             .systemFont(ofSize: 20, weight: .black), .white)

        // Right: user + date
        draw(user.name,
             CGRect(x: W * 0.5, y: 22, width: W * 0.5 - M, height: 18),
             .systemFont(ofSize: 12, weight: .semibold), .white, .right)
        draw(exportDateString(),
             CGRect(x: W * 0.5, y: 42, width: W * 0.5 - M, height: 16),
             .systemFont(ofSize: 10), .white.withAlphaComponent(0.55), .right)

        return headerH
    }

    // MARK: Summary boxes

    mutating func drawSummary(total: Double, paid: Double, pending: Double) {
        check(70)
        let items: [(String, Double, UIColor)] = [
            ("TOTAL",    total,   UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)),
            ("PAGO",     paid,    UIColor(red: 0.27, green: 0.86, blue: 0.50, alpha: 1)),
            ("PENDENTE", pending, UIColor(red: 0.98, green: 0.80, blue: 0.08, alpha: 1)),
        ]
        let bw = (CW - 12) / 3
        for (i, item) in items.enumerated() {
            let x = M + CGFloat(i) * (bw + 6)
            let rect = CGRect(x: x, y: y, width: bw, height: 62)

            // Box bg
            item.2.withAlphaComponent(0.10).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 10).fill()

            // Top accent bar
            item.2.setFill()
            UIBezierPath(roundedRect: CGRect(x: x, y: y, width: bw, height: 3), cornerRadius: 1.5).fill()

            // Label
            draw(item.0, CGRect(x: x + 10, y: y + 11, width: bw - 20, height: 14),
                 .systemFont(ofSize: 8, weight: .bold), item.2)

            // Value
            draw(fmtBRL(item.1), CGRect(x: x + 10, y: y + 28, width: bw - 20, height: 22),
                 .systemFont(ofSize: 13, weight: .bold), textMain)
        }
        y += 74
    }

    // MARK: Section title

    mutating func section(_ text: String) {
        check(36)
        draw(text, CGRect(x: M, y: y, width: CW, height: 22),
             .systemFont(ofSize: 13, weight: .bold), textMain)
        y += 26
    }

    // MARK: Category row

    mutating func categoryRow(_ item: (cat: Category, val: Double), total: Double) {
        check(34)
        let rowH: CGFloat = 30
        let dotX = M
        let color = UIColor(item.cat.color)

        // Dot
        color.setFill()
        UIBezierPath(ovalIn: CGRect(x: dotX, y: y + 11, width: 8, height: 8)).fill()

        // Name
        draw(item.cat.label, CGRect(x: dotX + 16, y: y + 7, width: CW * 0.45, height: 18),
             .systemFont(ofSize: 12), textMain)

        // Mini bar background
        let barX = M + CW * 0.52
        let barW = CW * 0.28
        border.setFill()
        UIBezierPath(roundedRect: CGRect(x: barX, y: y + 13, width: barW, height: 5), cornerRadius: 2.5).fill()

        // Mini bar fill
        let frac = total > 0 ? min(1.0, item.val / total) : 0
        color.setFill()
        UIBezierPath(roundedRect: CGRect(x: barX, y: y + 13, width: barW * CGFloat(frac), height: 5), cornerRadius: 2.5).fill()

        // Value
        draw(fmtBRL(item.val), CGRect(x: M + CW * 0.82, y: y + 7, width: CW * 0.18, height: 18),
             .systemFont(ofSize: 12, weight: .semibold), textMain, .right)

        y += rowH
    }

    // MARK: Separator

    mutating func separator() {
        check(16)
        border.setFill()
        UIBezierPath(rect: CGRect(x: M, y: y, width: CW, height: 0.5)).fill()
        y += 16
    }

    // MARK: Bills table

    mutating func tableHeader() {
        check(28)
        rowAlt.setFill()
        UIBezierPath(rect: CGRect(x: M, y: y, width: CW, height: 24)).fill()
        let cols = colsAt(y: y + 6)
        for (text, rect) in cols { draw(text, rect, .systemFont(ofSize: 9, weight: .bold), textMuted) }
        y += 26
    }

    mutating func billRow(_ bill: Bill, alt: Bool) {
        check(38)
        if alt {
            rowAlt.withAlphaComponent(0.5).setFill()
            UIBezierPath(rect: CGRect(x: M, y: y, width: CW, height: 36)).fill()
        }

        // Status dot
        let cat = catById(bill.category)
        UIColor(bill.paid ? .successGreen : .warnOrange).setFill()
        UIBezierPath(ovalIn: CGRect(x: M + 2, y: y + 14, width: 6, height: 6)).fill()

        // Name
        draw(bill.name,
             CGRect(x: M + 14, y: y + 6, width: CW * 0.36, height: 16),
             .systemFont(ofSize: 12, weight: .medium), textMain)

        // Category
        draw(cat.label,
             CGRect(x: M + 14, y: y + 20, width: CW * 0.36, height: 12),
             .systemFont(ofSize: 9), textMuted)

        // Due date
        draw(fmtDate(bill.due),
             CGRect(x: M + CW * 0.52, y: y + 12, width: CW * 0.22, height: 14),
             .systemFont(ofSize: 11), textMuted)

        // Value
        let valColor = bill.paid ? textMuted : textMain
        draw(fmtBRL(bill.value),
             CGRect(x: M + CW * 0.75, y: y + 12, width: CW * 0.25, height: 14),
             .systemFont(ofSize: 12, weight: .semibold), valColor, .right)

        // Status tag
        let tagColor = bill.paid
            ? UIColor(red: 0.27, green: 0.86, blue: 0.50, alpha: 1)
            : UIColor(red: 0.98, green: 0.80, blue: 0.08, alpha: 1)
        let tagText  = bill.paid ? "Pago" : "Pendente"
        draw(tagText,
             CGRect(x: M, y: y + 12, width: 0, height: 0),  // unused; drawn via status dot color
             .systemFont(ofSize: 9), tagColor)

        // Bottom border
        border.setFill()
        UIBezierPath(rect: CGRect(x: M, y: y + 35, width: CW, height: 0.5)).fill()

        y += 37
    }

    // MARK: Footer

    func footer() {
        let text = "Gerado pelo app Finanças · \(exportDateString())"
        draw(text,
             CGRect(x: M, y: H - 28, width: CW, height: 14),
             .systemFont(ofSize: 9), textMuted, .center)
        // Top line
        border.setFill()
        UIBezierPath(rect: CGRect(x: M, y: H - 36, width: CW, height: 0.5)).fill()
    }

    // MARK: Internals

    private func colsAt(y: CGFloat) -> [(String, CGRect)] {[
        ("CONTA",      CGRect(x: M + 14,        y: y, width: CW * 0.38, height: 12)),
        ("VENCIMENTO", CGRect(x: M + CW * 0.52, y: y, width: CW * 0.22, height: 12)),
        ("VALOR",      CGRect(x: M + CW * 0.75, y: y, width: CW * 0.25, height: 12)),
    ]}

    @discardableResult
    func draw(_ text: String, _ rect: CGRect, _ font: UIFont,
               _ color: UIColor, _ align: NSTextAlignment = .left) -> CGFloat {
        let style = NSMutableParagraphStyle()
        style.alignment = align
        style.lineBreakMode = .byTruncatingTail
        text.draw(in: rect, withAttributes: [
            .font: font, .foregroundColor: color, .paragraphStyle: style
        ])
        return rect.maxY
    }
}

private extension UIColor {
    convenience init(_ swiftUIColor: Color) {
        let ui = UIColor(swiftUIColor)
        self.init(cgColor: ui.cgColor)
    }
}

private func exportDateString() -> String {
    let f = DateFormatter()
    f.locale     = Locale(identifier: "pt_BR")
    f.dateFormat = "dd 'de' MMMM 'de' yyyy"
    return f.string(from: Date())
}
