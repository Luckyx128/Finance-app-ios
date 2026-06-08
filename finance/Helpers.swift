import Foundation

func fmtBRL(_ value: Double) -> String {
    let fmt = NumberFormatter()
    fmt.numberStyle = .currency
    fmt.currencyCode = "BRL"
    fmt.locale = Locale(identifier: "pt_BR")
    return fmt.string(from: NSNumber(value: value)) ?? "R$ 0,00"
}

func fmtBRLshort(_ value: Double) -> String {
    if abs(value) >= 1000 {
        let k = value / 1000
        let rounded = (k * 10).rounded() / 10
        let s = rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded))
            : String(format: "%.1f", rounded).replacingOccurrences(of: ".", with: ",")
        return "R$ \(s)k"
    }
    return "R$ \(Int(value.rounded()))"
}

func parseBRL(_ s: String) -> Double {
    let cleaned = s
        .replacingOccurrences(of: "[^\\d,.-]", with: "", options: .regularExpression)
        .replacingOccurrences(of: ".", with: "")
        .replacingOccurrences(of: ",", with: ".")
    return Double(cleaned) ?? 0
}

func fmtDate(_ iso: String) -> String {
    let p = iso.split(separator: "-")
    guard p.count == 3 else { return iso }
    return "\(p[2])/\(p[1])/\(p[0])"
}

func fmtDateShort(_ iso: String) -> String {
    let months = ["jan","fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez"]
    let p = iso.split(separator: "-")
    guard p.count == 3, let m = Int(p[1]), m >= 1, m <= 12 else { return iso }
    return "\(p[2]) \(months[m - 1])"
}

func daysUntil(_ iso: String) -> Int {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd"
    fmt.timeZone = TimeZone(identifier: "UTC")
    guard let target = fmt.date(from: iso) else { return 999 }
    let today = Calendar.current.startOfDay(for: Date())
    let tgt   = Calendar.current.startOfDay(for: target)
    return Calendar.current.dateComponents([.day], from: today, to: tgt).day ?? 999
}

func todayIso() -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd"
    return fmt.string(from: Date())
}

func currentMonthYear() -> String {
    let fmt = DateFormatter()
    fmt.locale = Locale(identifier: "pt_BR")
    fmt.dateFormat = "MMMM · yyyy"
    return fmt.string(from: Date())
        .prefix(1).uppercased() + fmt.string(from: Date()).dropFirst()
}

// MARK: – Month navigation helpers

func monthDate(offset: Int) -> Date {
    Calendar.current.date(byAdding: .month, value: offset, to: Date()) ?? Date()
}

func monthLabel(offset: Int) -> String {
    let fmt = DateFormatter()
    fmt.locale = Locale(identifier: "pt_BR")
    fmt.dateFormat = "MMMM · yyyy"
    let s = fmt.string(from: monthDate(offset: offset))
    return String(s.prefix(1)).uppercased() + s.dropFirst()
}

func monthISO(offset: Int) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM"
    return fmt.string(from: monthDate(offset: offset))
}

func billInMonth(_ bill: Bill, offset: Int) -> Bool {
    bill.due.hasPrefix(monthISO(offset: offset))
}
