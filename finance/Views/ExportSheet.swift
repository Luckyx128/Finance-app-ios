import SwiftUI
import UIKit

// MARK: – Share sheet bridge

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        av.popoverPresentationController?.sourceView =
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first
        return av
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: – Export scope & format

enum ExportScope: String, CaseIterable {
    case month = "Mês atual"
    case all   = "Todos os dados"
}

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
    var icon: String { self == .csv ? "doc.text" : "doc.richtext" }
    var description: String {
        self == .csv
            ? "Planilha para Excel, Google Sheets"
            : "Relatório formatado para leitura"
    }
}

// MARK: – Sheet

struct ExportSheet: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss)        private var dismiss

    @State private var scope:       ExportScope  = .month
    @State private var format:      ExportFormat = .pdf
    @State private var isGenerating = false
    @State private var shareItems:  [Any]        = []
    @State private var showShare                 = false

    private var filteredBills: [Bill] {
        scope == .month
            ? vm.bills.filter { billInMonth($0, offset: vm.selectedMonthOffset) }
            : vm.bills
    }

    private var scopeTitle: String {
        scope == .month
            ? monthLabel(offset: vm.selectedMonthOffset)
                .components(separatedBy: " · ").first ?? "Mês"
            : "Todos os dados"
    }

    private var totalValue: Double { filteredBills.reduce(0) { $0 + $1.value } }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            WallpaperView().ignoresSafeArea()

            VStack(spacing: 0) {
                sheetHeader

                ScrollView {
                    VStack(spacing: 16) {
                        scopeCard
                        formatCard
                        previewCard
                        exportButton
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 44)
                }
                .scrollIndicators(.hidden)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .sheet(isPresented: $showShare) {
            ShareSheet(items: shareItems)
        }
    }

    // MARK: – Header

    private var sheetHeader: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)

            HStack {
                Text("Exportar")
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

    // MARK: – Scope card

    private var scopeCard: some View {
        GlassCard(padding: 18, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Text("ABRANGÊNCIA")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(Color.muted)

                HStack(spacing: 8) {
                    ForEach(ExportScope.allCases, id: \.self) { s in
                        Button {
                            withAnimation(.spring(response: 0.3)) { scope = s }
                        } label: {
                            Text(s.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .glass(cornerRadius: 12, strong: scope == s)
                                .overlay {
                                    if scope == s {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.accentPink.opacity(0.5), lineWidth: 1)
                                    }
                                }
                        }
                        .buttonStyle(TapScaleStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: – Format card

    private var formatCard: some View {
        GlassCard(padding: 18, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Text("FORMATO")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(Color.muted)

                HStack(spacing: 10) {
                    ForEach(ExportFormat.allCases, id: \.self) { f in
                        Button {
                            withAnimation(.spring(response: 0.3)) { format = f }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill((format == f ? Color.accentPink : Color.white).opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: f.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(format == f ? Color.accentPink : Color.muted)
                                }
                                Text(f.rawValue)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(f.description)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.muted)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glass(cornerRadius: 16, strong: format == f)
                            .overlay {
                                if format == f {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.accentPink.opacity(0.5), lineWidth: 1)
                                }
                            }
                        }
                        .buttonStyle(TapScaleStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: – Preview card

    private var previewCard: some View {
        GlassCard(padding: 16, cornerRadius: 20) {
            HStack(spacing: 0) {
                previewPill(label: "CONTAS", value: "\(filteredBills.count)")
                GlassDivider().frame(width: 1, height: 28)
                previewPill(label: "TOTAL",  value: fmtBRLshort(totalValue))
                GlassDivider().frame(width: 1, height: 28)
                previewPill(label: "ARQUIVO", value: format == .csv ? ".csv" : ".pdf")
            }
        }
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.3), value: scope)
        .animation(.spring(response: 0.3), value: format)
    }

    private func previewPill(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(Color.muted)
            Text(value)
                .font(.system(size: 14, weight: .bold).monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: – Export button

    private var exportButton: some View {
        GradientButton(
            label: isGenerating ? "Gerando…" : "Gerar \(format.rawValue) e Compartilhar",
            leadingIcon: isGenerating ? "ellipsis" : "square.and.arrow.up"
        ) {
            generate()
        }
        .padding(.horizontal, 16)
        .disabled(isGenerating || filteredBills.isEmpty)
        .opacity(filteredBills.isEmpty ? 0.5 : 1)
    }

    // MARK: – Generation

    private func generate() {
        isGenerating = true
        let bills    = filteredBills
        let user     = vm.user
        let title    = scopeTitle

        Task.detached(priority: .userInitiated) {
            let url: URL? = format == .csv
                ? ExportManager.generateCSV(bills: bills, title: title)
                : ExportManager.generatePDF(bills: bills, user: user, title: title)

            await MainActor.run {
                isGenerating = false
                if let url {
                    shareItems = [url]
                    showShare  = true
                }
            }
        }
    }
}
