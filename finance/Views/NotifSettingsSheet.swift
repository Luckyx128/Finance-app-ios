import SwiftUI

struct NotifSettingsSheet: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss)        private var dismiss

    private let options = [1, 3, 5, 7]

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            WallpaperView().ignoresSafeArea()

            VStack(spacing: 0) {
                sheetHeader

                ScrollView {
                    VStack(spacing: 16) {
                        authCard
                        daysCard
                        if vm.notifAuthorized { rescheduleButton }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 44)
                }
                .scrollIndicators(.hidden)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    // MARK: – Header

    private var sheetHeader: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)

            HStack {
                Text("Notificações")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.muted)
                        .frame(width: 30, height: 30)
                        .glass(cornerRadius: 15, subtle: true)
                }
                .buttonStyle(TapScaleStyle())
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    // MARK: – Auth status

    private var authCard: some View {
        GlassCard(padding: 16, cornerRadius: 20) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill((vm.notifAuthorized ? Color.successGreen : Color.dangerRed).opacity(0.18))
                        .frame(width: 42, height: 42)
                    Image(systemName: vm.notifAuthorized ? "bell.fill" : "bell.slash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(vm.notifAuthorized ? Color.successGreen : Color.dangerRed)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(vm.notifAuthorized ? "Notificações ativas" : "Notificações bloqueadas")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(vm.notifAuthorized
                         ? "O app pode enviar alertas de vencimento"
                         : "Ative nas configurações do iOS")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if !vm.notifAuthorized {
                    Button("Ativar") {
                        Task {
                            let granted = await NotificationManager.requestPermission()
                            await MainActor.run { vm.notifAuthorized = granted }
                        }
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accentPink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glass(cornerRadius: 10, subtle: true)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: – Days before picker

    private var daysCard: some View {
        GlassCard(padding: 18, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("ANTECEDÊNCIA DO ALERTA")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(Color.muted)

                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { days in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                vm.notifDaysBefore = days
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(days)")
                                    .font(.system(size: 20, weight: .bold).monospacedDigit())
                                    .foregroundStyle(.white)
                                Text(days == 1 ? "dia" : "dias")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.muted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glass(cornerRadius: 14, strong: vm.notifDaysBefore == days)
                            .overlay {
                                if vm.notifDaysBefore == days {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.accentPink.opacity(0.55), lineWidth: 1)
                                }
                            }
                        }
                        .buttonStyle(TapScaleStyle())
                    }
                }

                Text("Um alerta é enviado \(vm.notifDaysBefore) dia\(vm.notifDaysBefore == 1 ? "" : "s") antes do vencimento e outro no dia da conta.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: – Reschedule

    private var rescheduleButton: some View {
        GradientButton(label: "Reagendar todas as contas", icon: "arrow.clockwise") {
            vm.rescheduleAllBills()
            dismiss()
        }
        .padding(.horizontal, 16)
    }
}
