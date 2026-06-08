import SwiftUI

// MARK: – Container (gerencia sub-telas com animação direcional)

struct AuthView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var screen: AuthScreen = .login
    @State private var forward = true

    enum AuthScreen { case login, signup, forgotPassword }

    var body: some View {
        ZStack {
            switch screen {
            case .login:
                LoginScreen(
                    onLogin:  { vm.appFlow = .setup },
                    onSignup: { nav(.signup) },
                    onForgot: { nav(.forgotPassword) }
                )
                .transition(slide(forward))
                .id("login")

            case .signup:
                SignupScreen(
                    onBack:    { nav(.login, back: true) },
                    onSuccess: { vm.appFlow = .setup }
                )
                .transition(slide(forward))
                .id("signup")

            case .forgotPassword:
                ForgotPasswordScreen(onBack: { nav(.login, back: true) })
                    .transition(slide(forward))
                    .id("forgot")
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: screen)
    }

    private func nav(_ next: AuthScreen, back: Bool = false) {
        forward = !back
        screen  = next
    }

    private func slide(_ isForward: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: isForward ? .trailing : .leading).combined(with: .opacity),
            removal:   .move(edge: isForward ? .leading  : .trailing).combined(with: .opacity)
        )
    }
}

// MARK: – Login

private struct LoginScreen: View {
    var onLogin:  () -> Void
    var onSignup: () -> Void
    var onForgot: () -> Void

    @State private var email    = ""
    @State private var password = ""
    @State private var error: String? = nil
    @State private var attempted = false

    @Environment(AppViewModel.self) private var vm

    private var emailOk:    Bool { isValidEmail(email) }
    private var passwordOk: Bool { password.count >= 6  }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Logo + wordmark
                VStack(spacing: 14) {
                    AppLogoMark(size: 80)
                    VStack(spacing: 3) {
                        Text("Finanças")
                            .font(.system(size: 28, weight: .black))
                            .tracking(-0.8)
                            .foregroundStyle(LinearGradient(
                                colors: [.white, Color.white.opacity(0.70)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text("Bem-vindo de volta")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.muted)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Fields
                VStack(spacing: 10) {
                    AuthField(icon: "envelope.fill", placeholder: "E-mail",
                              text: $email, keyboardType: .emailAddress)
                        .overlay(alignment: .bottom) {
                            if attempted && !emailOk {
                                ValidationMsg("E-mail inválido").padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(y: 22)
                            }
                        }
                        .padding(.bottom, attempted && !emailOk ? 18 : 0)

                    AuthField(icon: "lock.fill", placeholder: "Senha",
                              text: $password, isSecure: true)
                        .overlay(alignment: .bottom) {
                            if attempted && !passwordOk {
                                ValidationMsg("Mínimo 6 caracteres").padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(y: 22)
                            }
                        }
                        .padding(.bottom, attempted && !passwordOk ? 18 : 0)
                }
                .padding(.horizontal, 20)

                // Esqueci senha
                HStack {
                    Spacer()
                    Button(action: onForgot) {
                        Text("Esqueci a senha")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.accentPink)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Erro geral
                if let err = error {
                    ErrorBanner(err)
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                }

                Spacer(minLength: 40)
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 14) {
                GradientButton(label: "Entrar", icon: nil, action: submit)
                    .padding(.horizontal, 20)

                HStack(spacing: 4) {
                    Text("Não tem conta?")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.muted)
                    Button(action: onSignup) {
                        Text("Criar conta")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.accentPink)
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.bottom, 20)
            .background(Color.clear)
        }
    }

    private func submit() {
        attempted = true
        error = nil
        guard emailOk && passwordOk else { return }
        vm.user.email = email
        onLogin()
    }
}

// MARK: – Cadastro

private struct SignupScreen: View {
    var onBack:    () -> Void
    var onSuccess: () -> Void

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""
    @State private var attempted = false

    @Environment(AppViewModel.self) private var vm

    private var nameOk:     Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    private var emailOk:    Bool { isValidEmail(email) }
    private var passwordOk: Bool { password.count >= 6 }
    private var confirmOk:  Bool { password == confirm }
    private var canSubmit:  Bool { nameOk && emailOk && passwordOk && confirmOk }

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glass(cornerRadius: 20)
                }
                .buttonStyle(TapScaleStyle())
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Heading
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Criar conta")
                            .font(.system(size: 32, weight: .black))
                            .tracking(-0.8)
                            .foregroundStyle(.white)
                        Text("Preencha seus dados para começar")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.muted)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 28)

                    // Fields
                    VStack(spacing: 10) {
                        fieldWithError(
                            AuthField(icon: "person.fill", placeholder: "Como quer ser chamado?", text: $name),
                            error: attempted && !nameOk ? "Informe seu nome" : nil
                        )
                        fieldWithError(
                            AuthField(icon: "envelope.fill", placeholder: "E-mail",
                                      text: $email, keyboardType: .emailAddress),
                            error: attempted && !emailOk ? "E-mail inválido" : nil
                        )
                        fieldWithError(
                            AuthField(icon: "lock.fill", placeholder: "Senha (mínimo 6 caracteres)",
                                      text: $password, isSecure: true),
                            error: attempted && !passwordOk ? "Mínimo 6 caracteres" : nil
                        )
                        fieldWithError(
                            AuthField(icon: "lock.shield.fill", placeholder: "Confirmar senha",
                                      text: $confirm, isSecure: true),
                            error: attempted && !confirmOk ? "As senhas não coincidem" : nil
                        )
                    }
                    .padding(.horizontal, 20)

                    // Terms
                    Text("Ao criar conta, você concorda com os **Termos de Uso** e a **Política de Privacidade**.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dim)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 20)

                    Spacer(minLength: 30)
                }
            }
            .scrollIndicators(.hidden)

            GradientButton(label: "Criar conta", icon: nil, action: submit)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }

    private func fieldWithError<F: View>(_ field: F, error: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            field
            if let err = error {
                ValidationMsg(err).padding(.horizontal, 4)
            }
        }
    }

    private func submit() {
        attempted = true
        guard canSubmit else { return }
        vm.user.name  = name.trimmingCharacters(in: .whitespaces)
        vm.user.email = email
        onSuccess()
    }
}

// MARK: – Esqueci senha

private struct ForgotPasswordScreen: View {
    var onBack: () -> Void

    @State private var email   = ""
    @State private var sent    = false
    @State private var loading = false

    private var emailOk: Bool { isValidEmail(email) }

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glass(cornerRadius: 20)
                }
                .buttonStyle(TapScaleStyle())
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            if sent {
                successState
            } else {
                formState
            }

            Spacer()
        }
    }

    // MARK: Form state

    private var formState: some View {
        VStack(spacing: 0) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentPink.opacity(0.20))
                    .frame(width: 130, height: 130)
                    .blur(radius: 24)

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(
                            colors: [.accentPink, .accentPurple],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.accentPink.opacity(0.40), radius: 20, y: 8)
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(width: 80, height: 80)
            }
            .padding(.bottom, 24)

            // Text
            VStack(spacing: 8) {
                Text("Esqueci a senha")
                    .font(.system(size: 26, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(.white)
                Text("Informe seu e-mail e enviaremos\num link para redefinir sua senha.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.bottom, 32)

            // Field
            AuthField(icon: "envelope.fill", placeholder: "E-mail",
                      text: $email, keyboardType: .emailAddress)
                .padding(.horizontal, 20)

            // Button
            GradientButton(label: "Enviar link", icon: "arrow.right", action: sendLink)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .disabled(!emailOk)
                .opacity(emailOk ? 1 : 0.5)
        }
    }

    // MARK: Success state

    private var successState: some View {
        VStack(spacing: 0) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.20))
                    .frame(width: 130, height: 130)
                    .blur(radius: 24)

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(
                            colors: [.successGreen, .accentBlue],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.successGreen.opacity(0.40), radius: 20, y: 8)
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 80, height: 80)
            }
            .padding(.bottom, 24)

            VStack(spacing: 8) {
                Text("Link enviado!")
                    .font(.system(size: 26, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(.white)
                Text("Verifique sua caixa de entrada em\n**\(email)**")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.bottom, 36)

            Button(action: onBack) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left").fontWeight(.semibold)
                    Text("Voltar ao login").fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(.white)
                .glass(cornerRadius: 18)
            }
            .buttonStyle(TapScaleStyle())
            .padding(.horizontal, 20)
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal:   .opacity
        ))
    }

    private func sendLink() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { sent = true }
    }
}

// MARK: – Shared auth components

struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure:    Bool = false
    var keyboardType: UIKeyboardType = .default

    @State private var showPassword = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.accentPink)
                .frame(width: 22)

            Group {
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                }
            }
            .font(.system(size: 15))
            .foregroundStyle(.white)
            .tint(Color.accentPink)

            if isSecure {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.muted)
                }
                .buttonStyle(TapScaleStyle())
            }
        }
        .padding(16)
        .glass(cornerRadius: 16)
    }
}

private struct ValidationMsg: View {
    let message: String
    init(_ message: String) { self.message = message }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 11))
            Text(message)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(Color.dangerRed)
    }
}

private struct ErrorBanner: View {
    let message: String
    init(_ message: String) { self.message = message }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
            Text(message)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(Color.dangerRed)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glass(cornerRadius: 14)
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.dangerRed.opacity(0.40), lineWidth: 0.5)
        }
    }
}

// Logo mark reutilizável (também usado no Splash)
struct AppLogoMark: View {
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.31, style: .continuous)
                .fill(LinearGradient(colors: [.accentPink, .accentPurple, .accentBlue],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
                .shadow(color: Color.accentPurple.opacity(0.55), radius: size * 0.35, y: size * 0.18)

            RoundedRectangle(cornerRadius: size * 0.19, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.19, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                }
                .frame(width: size * 0.66, height: size * 0.66)
                .overlay {
                    Text("R$")
                        .font(.system(size: size * 0.22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
        }
    }
}

// MARK: – Helpers

private func isValidEmail(_ email: String) -> Bool {
    let parts = email.split(separator: "@")
    return parts.count == 2 && parts[1].contains(".")
}

// MARK: – Preview

#Preview {
    ZStack {
        WallpaperView()
        AuthView()
            .environment(AppViewModel())
    }
    .preferredColorScheme(.dark)
}
