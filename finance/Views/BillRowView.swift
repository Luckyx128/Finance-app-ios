import SwiftUI

struct BillRowView: View {
    let bill: Bill
    var onTap: () -> Void

    private var days: Int { daysUntil(bill.due) }

    private var statusColor: Color {
        if bill.paid       { return .successGreen }
        if days < 0        { return .dangerRed }
        if days == 0       { return .accentPink }
        if days <= 7       { return .warnOrange }
        return .muted
    }

    private var statusText: String {
        if bill.paid       { return "pago" }
        if days < 0        { return "\(abs(days))d atrasada" }
        if days == 0       { return "vence hoje" }
        if days <= 7       { return "em \(days)d" }
        return fmtDateShort(bill.due)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                CategoryIconView(categoryId: bill.category, size: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(bill.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        Circle().fill(statusColor).frame(width: 5, height: 5)
                        Text(statusText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(statusColor)
                        Text("· \(catById(bill.category).label)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.dim)
                    }
                }

                Spacer(minLength: 0)

                Text(fmtBRL(bill.value))
                    .font(.system(size: 16, weight: .bold).monospacedDigit())
                    .foregroundStyle(bill.paid ? Color.white.opacity(0.50) : .white)
                    .strikethrough(bill.paid, color: .white.opacity(0.50))
            }
            .padding(12)
        }
        .buttonStyle(TapScaleStyle())
        .glass(cornerRadius: 20)
    }
}
