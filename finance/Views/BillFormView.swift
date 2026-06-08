import SwiftUI

struct BillFormView: View {
    @Environment(AppViewModel.self) private var vm
    var editingId: String?
    var onDismiss: () -> Void

    private var initial: Bill? { editingId.flatMap { id in vm.bills.first { $0.id == id } } }
    private var isEdit: Bool { editingId != nil }

    @State private var name: String     = ""
    @State private var valueStr: String = ""
    @State private var dueDate: Date    = Date()
    @State private var category: String = "moradia"
    @State private var recurring: Bool  = true
    @State private var note: String     = ""

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && parseBRL(valueStr) > 0 }

    var body: some View {
        VStack(spacing: 0) {
            // Grabber
            Capsule()
                .fill(Color.white.opacity(0.30))
                .frame(width: 38, height: 5)
                .padding(.top, 10)

            // Header
            HStack {
                Button("Cancelar", action: onDismiss)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.muted)

                Spacer()

                Text(isEdit ? "Editar conta" : "Nova conta")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button("Salvar") { save() }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(canSave ? Color.accentPink : Color.white.opacity(0.30))
                    .disabled(!canSave)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 12) {
                    // Big value field
                    GlassCard(padding: 20, cornerRadius: 24) {
                        VStack(spacing: 6) {
                            Text("VALOR")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(0.6)
                                .foregroundStyle(Color.muted)
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("R$")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color.muted)
                                TextField("0,00", text: $valueStr)
                                    .font(.system(size: 44, weight: .black).monospacedDigit())
                                    .tracking(-1.4)
                                    .foregroundStyle(.white)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: valueStr) { _, v in
                                        valueStr = v.filter { "0123456789,.".contains($0) }
                                    }
                            }
                        }
                    }

                    // Nome
                    formRow(icon: "tag.fill") {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nome").font(.system(size: 11, weight: .semibold)).tracking(0.3).foregroundStyle(Color.muted)
                            TextField("ex: Aluguel, Netflix…", text: $name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }

                    // Vencimento
                    formRow(icon: "calendar") {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vencimento").font(.system(size: 11, weight: .semibold)).tracking(0.3).foregroundStyle(Color.muted)
                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(.accentPink)
                        }
                    }

                    // Repetir
                    formRow(icon: "clock.fill") {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Repetir todo mês").font(.system(size: 11, weight: .semibold)).tracking(0.3).foregroundStyle(Color.muted)
                            }
                            Spacer()
                            Toggle("", isOn: $recurring).labelsHidden().tint(.accentPink)
                        }
                    }

                    // Categoria
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CATEGORIA")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(Color.muted)
                            .padding(.horizontal, 8)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                            ForEach(allCategories) { cat in
                                let selected = category == cat.id
                                Button { category = cat.id } label: {
                                    VStack(spacing: 6) {
                                        CategoryIconView(categoryId: cat.id, size: 32)
                                        Text(cat.label)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(selected ? .white : Color.muted)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 4)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(selected ? cat.color.opacity(0.25) : Color.white.opacity(0.06))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(selected ? cat.color : Color.white.opacity(0.15), lineWidth: selected ? 1.5 : 0.5)
                                            }
                                            .shadow(color: selected ? cat.color.opacity(0.35) : .clear, radius: 8, y: 3)
                                    }
                                }
                                .buttonStyle(TapScaleStyle())
                            }
                        }
                    }

                    // Observação
                    VStack(alignment: .leading, spacing: 6) {
                        Text("OBSERVAÇÃO")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(Color.muted)
                            .padding(.horizontal, 8)
                        GlassCard(padding: 12, cornerRadius: 16) {
                            TextField("Notas opcionais…", text: $note, axis: .vertical)
                                .font(.system(size: 15))
                                .foregroundStyle(.white)
                                .lineLimit(3...6)
                        }
                    }

                    // Delete (edit only)
                    if isEdit {
                        Button {
                            if let id = editingId { vm.deleteBill(id); onDismiss() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill").font(.system(size: 14, weight: .semibold))
                                Text("Excluir conta").font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(Color.dangerRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.dangerRed.opacity(0.15))
                            }
                        }
                        .buttonStyle(TapScaleStyle())
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                }
                .ignoresSafeArea()
        }
        .onAppear { loadInitial() }
    }

    private func formRow<C: View>(icon: String, @ViewBuilder content: () -> C) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.80))
            }
            content()
        }
        .padding(12)
        .glass(cornerRadius: 16)
    }

    private func loadInitial() {
        guard let b = initial else { return }
        name       = b.name
        valueStr   = String(format: "%.2f", b.value).replacingOccurrences(of: ".", with: ",")
        category   = b.category
        recurring  = b.recurring
        note       = b.note
        let fmt    = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        dueDate    = fmt.date(from: b.due) ?? Date()
    }

    private func save() {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let bill = Bill(
            id:        editingId ?? UUID().uuidString,
            name:      name.trimmingCharacters(in: .whitespaces),
            value:     parseBRL(valueStr),
            due:       fmt.string(from: dueDate),
            category:  category,
            recurring: recurring,
            paid:      initial?.paid ?? false,
            note:      note
        )
        vm.saveBill(bill, editingId: editingId)
        onDismiss()
    }
}
