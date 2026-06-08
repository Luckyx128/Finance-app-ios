import SwiftUI
import LocalAuthentication

struct ProfileView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var editIncome        = false
    @State private var draftIncome       = ""
    @State private var showEditProfile   = false
    @State private var showNotifSheet    = false
    @State private var showExportSheet   = false
    @State private var showSignOutAlert  = false
    @State private var biometryAvailable = false

    private var initials: String {
        vm.user.name.components(separatedBy: " ")
            .prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Large title
                Text("Perfil")
                    .font(.system(size: 34, weight: .black))
                    .tracking(-0.8)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // Avatar block
                VStack(spacing: 10) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.accentPink, .accentPurple, .accentBlue],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.accentPurple.opacity(0.4), radius: 20, y: 8)
                        Text(initials)
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(.white)

                        // Edit badge
                        Button { showEditProfile = true } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.accentPink)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(TapScaleStyle())
                        .offset(x: 2, y: 2)
                    }
                    .frame(width: 92, height: 92)

                    Text(vm.user.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text(vm.user.email)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.muted)
                }
                .padding(.bottom, 24)

                // Income card
                incomeCard
                    .padding(.horizontal, 16)

                // Settings: Preferências
                settingsSection(rows: [
                    AnyView(settingsRowButton(
                        icon: "bell.fill", bg: .accentPink,
                        label: "Notificações",
                        value: "\(vm.notifDaysBefore) dias antes"
                    ) { showNotifSheet = true }),
                    AnyView(GlassDivider()),
                    AnyView(settingsRowButton(
                        icon: "square.and.arrow.up.fill", bg: .accentPurple,
                        label: "Exportar dados",
                        value: "CSV · PDF"
                    ) { showExportSheet = true }),
                    AnyView(GlassDivider()),
                    AnyView(settingsRowStatic(
                        icon: "globe", bg: .accentBlue,
                        label: "Idioma", value: "Português"
                    )),
                ])
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // Settings: Segurança
                settingsSection(rows: [
                    biometryAvailable ? AnyView(faceIDRow) : nil,
                    biometryAvailable ? AnyView(GlassDivider()) : nil,
                    AnyView(settingsRowButton(
                        icon: "arrow.right.square.fill", bg: .dangerRed,
                        label: "Sair da conta", value: nil, danger: true
                    ) { showSignOutAlert = true }),
                ].compactMap { $0 })
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Text("Finanças · v1.0 · \(currentMonthYear())")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dim)
                    .padding(.top, 28)
                    .padding(.bottom, 4)
            }
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
        .onAppear { biometryAvailable = checkBiometry() }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showNotifSheet) {
            NotifSettingsSheet()
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet()
        }
        .alert("Sair da conta?", isPresented: $showSignOutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Sair", role: .destructive) { vm.signOut() }
        } message: {
            Text("Você será redirecionado para a tela inicial. Seus dados não serão apagados.")
        }
    }

    // MARK: – Income card

    private var incomeCard: some View {
        GlassCard(padding: 20, cornerRadius: 24, strong: true) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("RENDA MENSAL")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.4)
                        .foregroundStyle(Color.muted)
                    Spacer()
                    if !editIncome {
                        Button("Editar") {
                            draftIncome = String(format: "%.2f", vm.user.income)
                                .replacingOccurrences(of: ".", with: ",")
                            editIncome = true
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.accentPink)
                    }
                }

                if editIncome {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("R$").font(.system(size: 22, weight: .semibold)).foregroundStyle(Color.muted)
                        TextField("0,00", text: $draftIncome)
                            .font(.system(size: 36, weight: .black).monospacedDigit())
                            .foregroundStyle(.white)
                            .keyboardType(.decimalPad)
                            .onChange(of: draftIncome) { _, v in
                                draftIncome = v.filter { "0123456789,.".contains($0) }
                            }
                    }
                    .padding(.top, 8)

                    HStack(spacing: 8) {
                        Button("Cancelar") { editIncome = false }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .glass(cornerRadius: 14, subtle: true)

                        Button("Salvar") {
                            vm.user.income = parseBRL(draftIncome)
                            editIncome     = false
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [.accentPink, .accentPurple],
                                    startPoint: .leading, endPoint: .trailing))
                                .shadow(color: Color.accentPink.opacity(0.4), radius: 8, y: 3)
                        }
                    }
                    .buttonStyle(TapScaleStyle())
                    .padding(.top, 12)

                } else {
                    Text(fmtBRL(vm.user.income))
                        .font(.system(size: 38, weight: .black).monospacedDigit())
                        .tracking(-1.2)
                        .foregroundStyle(.white)
                        .padding(.top, 4)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.12)).frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [.accentPink, .accentBlue],
                                    startPoint: .leading, endPoint: .trailing))
                                .frame(
                                    width: geo.size.width * min(1, vm.totalMonth / max(1, vm.user.income)),
                                    height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 10)

                    Text("\(Int((vm.totalMonth / max(1, vm.user.income) * 100).rounded()))% comprometido")
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Color.muted)
                        .padding(.top, 6)
                }
            }
        }
    }

    // MARK: – Face ID toggle

    private var faceIDRow: some View {
        HStack(spacing: 12) {
            settingsIcon(icon: "faceid", bg: .accentPurple)
            Text("Face ID")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: Binding(
                get: { vm.appLockEnabled },
                set: { newVal in
                    if newVal {
                        authenticateAndEnable()
                    } else {
                        withAnimation { vm.appLockEnabled = false }
                    }
                }
            ))
            .tint(Color.accentPink)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: – Row builders

    private func settingsSection(rows: [AnyView]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in row }
        }
        .glass(cornerRadius: 20)
    }

    private func settingsRowButton(icon: String, bg: Color, label: String,
                                    value: String?, danger: Bool = false,
                                    action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRowContent(icon: icon, bg: bg, label: label, value: value, danger: danger, showChevron: !danger)
        }
        .buttonStyle(TapScaleStyle())
    }

    private func settingsRowStatic(icon: String, bg: Color, label: String, value: String?) -> some View {
        settingsRowContent(icon: icon, bg: bg, label: label, value: value, danger: false, showChevron: false)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }

    private func settingsRowContent(icon: String, bg: Color, label: String,
                                     value: String?, danger: Bool, showChevron: Bool) -> some View {
        HStack(spacing: 12) {
            settingsIcon(icon: icon, bg: bg)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(danger ? Color.dangerRed : Color.white)
            Spacer()
            if let v = value {
                Text(v).font(.system(size: 13)).foregroundStyle(Color.muted)
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.30))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func settingsIcon(icon: String, bg: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(LinearGradient(
                    colors: [bg, bg.opacity(0.75)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 30, height: 30)
    }

    // MARK: – Biometry

    private func checkBiometry() -> Bool {
        let ctx = LAContext()
        var error: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    private func authenticateAndEnable() {
        let ctx = LAContext()
        ctx.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Confirme sua identidade para ativar o bloqueio do app"
        ) { success, _ in
            DispatchQueue.main.async {
                withAnimation { vm.appLockEnabled = success }
            }
        }
    }
}
