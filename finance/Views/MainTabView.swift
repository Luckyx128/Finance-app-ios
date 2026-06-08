import SwiftUI

enum MainTab: String, Equatable { case home, bills, compare, profile }

struct MainTabView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var activeTab:    MainTab = .home
    @State private var detailId:    String? = nil
    @State private var editingId:   String? = nil
    @State private var showForm           = false
    @State private var showNotifCenter    = false
    @State private var notifPendingBillId: String? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            // Screen content
            Group {
                switch activeTab {
                case .home:
                    HomeView(
                        onOpenBill:   { id in withAnimation(.spring(response: 0.4)) { detailId = id } },
                        onShowForm:   { editingId = nil; showForm = true },
                        onGoTo:       { tab in withAnimation(.spring(response: 0.4)) { activeTab = tab } },
                        onShowNotifs: { showNotifCenter = true }
                    )
                case .bills:
                    BillsView(
                        onOpenBill: { id in withAnimation(.spring(response: 0.4)) { detailId = id } },
                        onShowForm:  { editingId = nil; showForm = true }
                    )
                case .compare:
                    AnalysisView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Detail overlay
            if let id = detailId {
                BillDetailView(
                    billId: id,
                    onBack: { withAnimation(.spring(response: 0.4)) { detailId = nil } },
                    onEditBill: { bid in
                        editingId = bid
                        showForm = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.bgBase)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }

            // Tab bar
            if detailId == nil {
                customTabBar
                    .zIndex(20)
            }
        }
        .sheet(isPresented: $showForm, onDismiss: {
            if let did = detailId, vm.bills.first(where: { $0.id == did }) == nil {
                withAnimation(.spring(response: 0.4)) { detailId = nil }
            }
        }) {
            BillFormView(editingId: editingId, onDismiss: { showForm = false })
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(.clear)
                .interactiveDismissDisabled(false)
        }
        .sheet(isPresented: $showNotifCenter, onDismiss: {
            if let id = notifPendingBillId {
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.4)) { detailId = id }
                }
                notifPendingBillId = nil
            }
        }) {
            NotificationCenterView(onOpenBill: { id in
                notifPendingBillId = id
                showNotifCenter = false
            })
        }
        .task {
            vm.checkNotificationAuthorization()
        }
        // Toast overlay
        .overlay(alignment: .top) {
            if let toast = vm.toast {
                toastBanner(toast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.toast?.id)
    }

    // MARK: – Custom tab bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(.home,    symbol: "creditcard.fill",  label: "Início")
            tabItem(.bills,   symbol: "list.bullet",      label: "Contas")
            // FAB
            Button {
                editingId = nil
                showForm  = true
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.accentPink, .accentPurple, .accentBlue],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.accentPurple.opacity(0.45), radius: 12, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 52, height: 52)
            }
            .buttonStyle(TapScaleStyle())
            .padding(.horizontal, -4)
            tabItem(.compare, symbol: "chart.pie.fill",   label: "Análise")
            tabItem(.profile, symbol: "person.fill",      label: "Perfil")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glass(cornerRadius: 30, strong: true)
        .padding(.horizontal, 14)
        .padding(.bottom, 22)
    }

    private func tabItem(_ tab: MainTab, symbol: String, label: String) -> some View {
        let isActive = activeTab == tab
        return Button {
            withAnimation(.spring(response: 0.3)) { activeTab = tab }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: symbol)
                    .font(.system(size: 21, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.accentPink : Color.white.opacity(0.55))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isActive ? Color.accentPink : Color.white.opacity(0.55))
                    .tracking(0.1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(TapScaleStyle())
    }

    // MARK: – Toast banner

    private func toastBanner(_ toast: ToastMsg) -> some View {
        HStack(spacing: 8) {
            Image(systemName: toast.isSuccess ? "checkmark" : "trash.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(toast.isSuccess ? Color.successGreen : Color.dangerRed)
            Text(toast.message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(toast.isSuccess ? Color.successGreen : Color.dangerRed)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glass(cornerRadius: 22, strong: true)
    }
}
