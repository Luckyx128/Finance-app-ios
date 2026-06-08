import Foundation
import UserNotifications

enum NotificationManager {

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func checkAuthorizationStatus() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: – Schedule

    static func scheduleAll(bills: [Bill]) {
        for bill in bills where !bill.paid { scheduleBill(bill) }
    }

    static func scheduleBill(_ bill: Bill, daysOffsets: [Int] = [3, 1, 0]) {
        guard !bill.paid, let dueDate = parseISO(bill.due) else { return }
        let center = UNUserNotificationCenter.current()

        for offset in Set(daysOffsets).sorted(by: >) {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: -offset, to: dueDate),
                  fireDate > Date() else { continue }

            var dc = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
            dc.hour = 9; dc.minute = 0

            let body: String = {
                switch offset {
                case 0:  return "Vence hoje"
                case 1:  return "Vence amanhã"
                default: return "Vence em \(offset) dias"
                }
            }()

            let content   = UNMutableNotificationContent()
            content.title = bill.name
            content.body  = "\(body) — \(fmtBRL(bill.value))"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(bill.id)-\(offset)d",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    // MARK: – Cancel

    static func cancel(_ billId: String) {
        // Cover all possible offsets 0-7
        let ids = (0...7).map { "\(billId)-\($0)d" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: – Helpers

    private static func parseISO(_ iso: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: iso)
    }
}
