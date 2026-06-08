import SwiftUI
import Observation

// MARK: – Models

enum AppFlow: Equatable { case splash, onboarding, auth, setup, app }

struct Bill: Identifiable {
    var id: String
    var name: String
    var value: Double
    var due: String       // "YYYY-MM-DD"
    var category: String
    var recurring: Bool
    var paid: Bool
    var note: String
    var paymentMethod: String

    init(id: String = UUID().uuidString, name: String, value: Double, due: String,
         category: String, recurring: Bool = false, paid: Bool = false, note: String = "",
         paymentMethod: String = "") {
        self.id = id; self.name = name; self.value = value; self.due = due
        self.category = category; self.recurring = recurring; self.paid = paid
        self.note = note; self.paymentMethod = paymentMethod
    }
}

struct UserProfile {
    var name: String
    var email: String
    var income: Double
}

struct ToastMsg: Identifiable {
    let id = UUID()
    let message: String
    let isSuccess: Bool
}

// MARK: – ViewModel

@Observable
class AppViewModel {
    var appFlow: AppFlow       = .splash
    var bills: [Bill]          = seedBills
    var user: UserProfile      = UserProfile(name: "Lucas Ribeiro", email: "lucas.ribeiro@email.com", income: 6500)
    var toast: ToastMsg?       = nil
    var notifAuthorized: Bool     = false
    var budgets: [String: Double] = [:]   // categoryId → monthly limit
    var selectedMonthOffset: Int  = 0     // 0 = current month, -1 = last month, …
    var notifDaysBefore: Int      = 3     // days before due to send early reminder
    var appLockEnabled: Bool      = false // Face ID / Touch ID lock

    func spent(for categoryId: String) -> Double {
        bills.filter { $0.category == categoryId }.reduce(0) { $0 + $1.value }
    }

    func setBudget(categoryId: String, limit: Double) {
        budgets[categoryId] = limit
    }

    func removeBudget(categoryId: String) {
        budgets.removeValue(forKey: categoryId)
    }

    func checkNotificationAuthorization() {
        Task { @MainActor in
            notifAuthorized = await NotificationManager.checkAuthorizationStatus()
        }
    }

    // MARK: Computed

    var totalMonth: Double { bills.reduce(0) { $0 + $1.value } }
    var paidTotal: Double  { bills.filter(\.paid).reduce(0) { $0 + $1.value } }
    var pending: Double    { totalMonth - paidTotal }
    var remaining: Double  { user.income - totalMonth }
    var pct: Double        { user.income > 0 ? min(100, (totalMonth / user.income) * 100) : 0 }

    // MARK: Actions

    func togglePaid(_ id: String) {
        guard let i = bills.firstIndex(where: { $0.id == id }) else { return }
        let wasPaid = bills[i].paid
        bills[i].paid.toggle()
        if bills[i].paid {
            NotificationManager.cancel(id)
        } else {
            NotificationManager.scheduleBill(bills[i], daysOffsets: [notifDaysBefore, 0])
        }
        flash(wasPaid ? "Marcada como não paga" : "Pagamento confirmado ✓", success: !wasPaid)
    }

    func saveBill(_ draft: Bill, editingId: String?) {
        if let eid = editingId, let i = bills.firstIndex(where: { $0.id == eid }) {
            NotificationManager.cancel(eid)
            var b = bills[i]
            b.name = draft.name; b.value = draft.value; b.due = draft.due
            b.category = draft.category; b.recurring = draft.recurring; b.note = draft.note
            bills[i] = b
            if !b.paid { NotificationManager.scheduleBill(b, daysOffsets: [notifDaysBefore, 0]) }
            flash("Conta atualizada ✓")
        } else {
            bills.append(draft)
            NotificationManager.scheduleBill(draft, daysOffsets: [notifDaysBefore, 0])
            flash("Conta cadastrada ✓")
        }
    }

    func rescheduleAllBills() {
        NotificationManager.cancelAll()
        for bill in bills where !bill.paid {
            NotificationManager.scheduleBill(bill, daysOffsets: [notifDaysBefore, 0])
        }
        flash("Notificações reagendadas ✓")
    }

    func signOut() {
        bills             = seedBills
        budgets           = [:]
        selectedMonthOffset = 0
        appLockEnabled    = false
        appFlow           = .onboarding
    }

    func confirmPayment(id: String, method: String) {
        guard let i = bills.firstIndex(where: { $0.id == id }) else { return }
        bills[i].paid          = true
        bills[i].paymentMethod = method
        NotificationManager.cancel(id)
        flash("Pagamento confirmado ✓")
    }

    func deleteBill(_ id: String) {
        NotificationManager.cancel(id)
        bills.removeAll { $0.id == id }
        flash("Conta excluída", success: false)
    }

    private func flash(_ msg: String, success: Bool = true) {
        toast = ToastMsg(message: msg, isSuccess: success)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.4))
            toast = nil
        }
    }
}

// MARK: – Seed data

let seedBills: [Bill] = [
    Bill(id:"b1",  name:"Aluguel",        value:1850.00, due:"2026-06-05", category:"moradia",     recurring:true,  paid:true,  note:"Apto 304 — depósito Itaú"),
    Bill(id:"b2",  name:"Conta de luz",   value:187.40,  due:"2026-06-12", category:"casa",        recurring:true,  paid:true,  note:""),
    Bill(id:"b3",  name:"Internet 600MB", value:119.90,  due:"2026-06-15", category:"casa",        recurring:true,  paid:false, note:""),
    Bill(id:"b4",  name:"Cartão Nubank",  value:824.55,  due:"2026-06-20", category:"cartao",      recurring:true,  paid:false, note:"Fatura de Maio"),
    Bill(id:"b5",  name:"Netflix",        value:55.90,   due:"2026-06-22", category:"assinaturas", recurring:true,  paid:false, note:""),
    Bill(id:"b6",  name:"Spotify Family", value:34.90,   due:"2026-06-22", category:"assinaturas", recurring:true,  paid:false, note:""),
    Bill(id:"b7",  name:"Plano de saúde", value:412.30,  due:"2026-06-25", category:"saude",       recurring:true,  paid:false, note:"Bradesco Top"),
    Bill(id:"b8",  name:"Uber/99 do mês", value:286.00,  due:"2026-06-28", category:"transporte",  recurring:false, paid:false, note:"Estimativa"),
    Bill(id:"b9",  name:"Curso UX",       value:199.00,  due:"2026-06-30", category:"educacao",    recurring:true,  paid:false, note:""),
    Bill(id:"b10", name:"Academia",       value:89.90,   due:"2026-06-10", category:"lazer",       recurring:true,  paid:true,  note:""),
]
