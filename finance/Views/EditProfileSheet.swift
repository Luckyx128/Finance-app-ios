import SwiftUI

struct EditProfileSheet: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss)        private var dismiss

    @State private var name:  String = ""
    @State private var email: String = ""
    @FocusState private var focused: Field?

    enum Field { case name, email }

    private var initials: String {
        name.components(separatedBy: " ")
            .prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            WallpaperView().ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle + nav
                VStack(spacing: 14) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 36, height: 4)

                    HStack {
                        Button("Cancelar") { dismiss() }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.muted)

                        Spacer()

                        Text("Editar Perfil")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)

                        Spacer()

                        Button("Salvar") { save() }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.accentPink)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 14)
                .padding(.bottom, 28)

                // Avatar preview
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.accentPink, .accentPurple, .accentBlue],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.accentPurple.opacity(0.4), radius: 20, y: 8)
                    Text(initials.isEmpty ? "?" : initials)
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 92, height: 92)
                .animation(.spring(response: 0.3), value: initials)

                // Fields
                VStack(spacing: 0) {
                    editField(icon: "person.fill",  placeholder: "Nome",   text: $name,  field: .name)
                    GlassDivider()
                    editField(icon: "envelope.fill", placeholder: "E-mail", text: $email, field: .email)
                }
                .glass(cornerRadius: 20)
                .padding(.horizontal, 16)
                .padding(.top, 24)

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .onAppear {
            name  = vm.user.name
            email = vm.user.email
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focused = .name
            }
        }
    }

    private func editField(icon: String, placeholder: String,
                            text: Binding<String>, field: Field) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.muted)
            }
            TextField(placeholder, text: text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .focused($focused, equals: field)
                .keyboardType(field == .email ? .emailAddress : .default)
                .autocorrectionDisabled(field == .email)
                .textInputAutocapitalization(field == .email ? .never : .words)
                .submitLabel(field == .name ? .next : .done)
                .onSubmit {
                    if field == .name { focused = .email } else { save() }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func save() {
        let trimName  = name.trimmingCharacters(in: .whitespaces)
        let trimEmail = email.trimmingCharacters(in: .whitespaces)
        if !trimName.isEmpty  { vm.user.name  = trimName  }
        if !trimEmail.isEmpty { vm.user.email = trimEmail }
        dismiss()
    }
}
