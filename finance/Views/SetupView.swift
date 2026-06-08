import SwiftUI

// MARK: – Container

struct SetupView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var step        = 0
    @State private var goForward   = true
    @State private var name        = ""
    @State private var incomeCents = 0                              // cents (500000 = R$ 5.000,00)
    @State private var selectedCats: Set<String> = Set(allCategories.map(\.id))

    var body: some View {
        ZStack {
            currentStep
                .transition(slide)
                .id(step)
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: step)
        .onAppear {
            name        = vm.user.name
            incomeCents = Int(vm.user.income * 100)
        }
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 0:  StepName(name: $name, onNext: advance)
        case 1:  StepIncome(cents: $incomeCents, onBack: back, onNext: advance)
        default: StepCategories(selected: $selectedCats, onBack: back, onDone: finish)
        }
    }

    private var slide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goForward ? .trailing : .leading).combined(with: .opacity),
            removal:   .move(edge: goForward ? .leading  : .trailing).combined(with: .opacity)
        )
    }

    private func advance() {
        if step == 0 {
            let t = name.trimmingCharacters(in: .whitespaces)
            if !t.isEmpty { vm.user.name = t }
        } else if step == 1, incomeCents > 0 {
            vm.user.income = Double(incomeCents) / 100
        }
        goForward = true
        step += 1
    }

    private func back() { goForward = false; step -= 1 }

    private func finish() { vm.appFlow = .app }
}

// MARK: – Progress dots

private struct StepDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i <= current
                          ? AnyShapeStyle(LinearGradient(
                              colors: [.accentPink, .accentPurple],
                              startPoint: .leading, endPoint: .trailing))
                          : AnyShapeStyle(Color.white.opacity(0.20)))
                    .frame(width: i == current ? 28 : 8, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: current)
            }
        }
    }
}

// MARK: – Nav bar helper

private struct SetupNav: View {
    let step: Int
    var onBack: (() -> Void)?
    var trailing: AnyView? = nil

    var body: some View {
        HStack {
            if let back = onBack {
                Button(action: back) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glass(cornerRadius: 20)
                }
                .buttonStyle(TapScaleStyle())
            } else {
                Color.clear.frame(width: 40, height: 40)
            }

            Spacer()
            StepDots(current: step, total: 3)
            Spacer()

            if let t = trailing { t.frame(width: 52) }
            else { Color.clear.frame(width: 40) }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

// MARK: – Step 1: Nome

private struct StepName: View {
    @Binding var name: String
    var onNext: () -> Void

    private var initials: String {
        name.trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    private var canContinue: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            SetupNav(step: 0)

            Spacer()

            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.accentPink, .accentPurple],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.accentPink.opacity(0.40), radius: 20, y: 8)
                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 28)

            // Heading
            VStack(spacing: 8) {
                Text("Como quer ser\nchamado?")
                    .font(.system(size: 30, weight: .black))
                    .tracking(-0.8)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Usamos seu nome para personalizar\nsua experiência.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.bottom, 32)

            AuthField(icon: "person.fill", placeholder: "Seu nome", text: $name)
                .padding(.horizontal, 20)
                .submitLabel(.continue)
                .onSubmit { if canContinue { onNext() } }

            Spacer()

            GradientButton(label: "Próximo", icon: "chevron.right", action: onNext)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.45)
        }
    }
}

// MARK: – Step 2: Renda

private struct StepIncome: View {
    @Binding var cents: Int
    var onBack: () -> Void
    var onNext: () -> Void

    @FocusState private var focused: Bool
    @State private var incomeStr = ""   // whole reais, digits only (e.g. "5000")

    private var displayText: String {
        if let v = Double(incomeStr), v > 0 { return fmtBRL(v) }
        return "R$ —"
    }

    var body: some View {
        VStack(spacing: 0) {
            SetupNav(step: 1, onBack: onBack)

            Spacer()

            // Big number
            VStack(spacing: 6) {
                Text("RENDA MENSAL")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(Color.muted)

                ZStack {
                    Text(displayText)
                        .font(.system(size: 44, weight: .black).monospacedDigit())
                        .tracking(-1.4)
                        .foregroundStyle(.white)
                        .allowsHitTesting(false)

                    TextField("", text: $incomeStr)
                        .keyboardType(.numberPad)
                        .focused($focused)
                        .opacity(0.001)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .onChange(of: incomeStr) { _, new in
                            let digits = new.filter { $0.isNumber }
                            let capped = String(digits.prefix(8))
                            if capped != incomeStr { incomeStr = capped }
                            cents = (Int(capped) ?? 0) * 100
                        }
                }
                .onTapGesture { focused = true }

                Text("Toque no valor para editar")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.dim)
                    .opacity(focused ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: focused)
            }

            // Preset chips
            VStack(alignment: .leading, spacing: 10) {
                Text("Sugestões")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.muted)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach([2000, 3500, 5000, 7500, 12000], id: \.self) { v in
                            presetChip(v)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 28)

            Spacer()

            GradientButton(label: "Próximo", icon: "chevron.right", action: onNext)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
        .onAppear {
            if cents > 0 { incomeStr = String(cents / 100) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { focused = true }
        }
    }

    private func presetChip(_ v: Int) -> some View {
        let active = cents == v * 100
        return Button {
            withAnimation(.spring(response: 0.3)) {
                incomeStr = String(v)
                focused = false
            }
        } label: {
            Text(fmtBRLshort(Double(v)))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(active ? Color.accentPink : Color.muted)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .glass(cornerRadius: 999)
                .overlay {
                    if active {
                        Capsule().stroke(Color.accentPink.opacity(0.60), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Step 3: Categorias

private struct StepCategories: View {
    @Binding var selected: Set<String>
    var onBack: () -> Void
    var onDone: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    private var allOn: Bool { selected.count == allCategories.count }

    var body: some View {
        VStack(spacing: 0) {
            SetupNav(
                step: 2,
                onBack: onBack,
                trailing: AnyView(
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selected = allOn ? [] : Set(allCategories.map(\.id))
                        }
                    } label: {
                        Text(allOn ? "Limpar" : "Todas")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.accentPink)
                    }
                )
            )

            VStack(spacing: 6) {
                Text("Quais categorias\nvocê usa?")
                    .font(.system(size: 28, weight: .black))
                    .tracking(-0.8)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Selecione para organizar seus gastos.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.muted)
            }
            .padding(.vertical, 18)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(allCategories) { cat in
                        CategoryToggleCard(
                            cat: cat,
                            isSelected: selected.contains(cat.id)
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.70)) {
                                if selected.contains(cat.id) { selected.remove(cat.id) }
                                else                         { selected.insert(cat.id) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)

            GradientButton(label: "Começar agora", icon: "sparkles", action: onDone)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .disabled(selected.isEmpty)
                .opacity(selected.isEmpty ? 0.45 : 1)
        }
    }
}

// MARK: – Category toggle card

private struct CategoryToggleCard: View {
    let cat: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(cat.color.opacity(isSelected ? 0.25 : 0.10))
                        .frame(width: 54, height: 54)
                    Image(systemName: cat.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? cat.color : cat.color.opacity(0.50))
                }
                Text(cat.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 8)
            .glass(cornerRadius: 20)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(cat.color.opacity(isSelected ? 0.65 : 0), lineWidth: 1.5)
            }
            .shadow(color: isSelected ? cat.color.opacity(0.22) : .clear, radius: 10, y: 3)
        }
        .buttonStyle(TapScaleStyle())
    }
}

// MARK: – Preview

#Preview {
    ZStack {
        WallpaperView()
        SetupView()
            .environment(AppViewModel())
    }
    .preferredColorScheme(.dark)
}
