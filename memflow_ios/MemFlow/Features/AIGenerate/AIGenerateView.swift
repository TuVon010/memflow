import SwiftUI
import SwiftData

/// AI 生成卡片页面
///
/// 粘贴技术文本，调用 LLM 拆解为多张问答卡片预览。
/// 支持逐张编辑、删除，确认后存入指定卡组。
struct AIGenerateView: View {
    let deck: Deck
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AIGenerateViewModel()
    @State private var apiKey: String?
    @State private var settings: UserSettings?

    var body: some View {
        VStack(spacing: 0) {
            // 输入区（未生成时显示）
            if case .idle = viewModel.status {
                inputSection
            } else if case .error = viewModel.status {
                inputSection
            }

            // 结果区
            if case .success = viewModel.status {
                resultSection
            } else if case .loading = viewModel.status {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                    Text("正在生成卡片…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }

            // 错误提示
            if let error = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                    Spacer()
                    Button("重试") {
                        Task { await viewModel.generate() }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(12)
                .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("AI 生成卡片")
        .task {
            loadSettings()
            await loadApiKey()
        }
    }

    // MARK: - 输入区

    private var inputSection: some View {
        VStack(spacing: 16) {
            TextEditor(text: $viewModel.inputText)
                .frame(minHeight: 150)
                .padding(8)
                .overlay(alignment: .topLeading) {
                    if viewModel.inputText.isEmpty {
                        Text("粘贴面试题、技术文档、面经等内容…")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 16)
                            .padding(.leading, 12)
                            .allowsHitTesting(false)
                    }
                }
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                .padding(16)

            // API 状态提示
            HStack(spacing: 8) {
                Image(systemName: (apiKey != nil) ? "checkmark.circle.fill" : "info.circle.fill")
                    .foregroundStyle((apiKey != nil) ? .green : .orange)
                    .font(.caption)
                Text((apiKey != nil) ? "AI 服务已配置" : "请先在设置中配置 AI API Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)

            Button {
                viewModel.configure(
                    apiKey: apiKey,
                    baseURL: settings?.llmBaseURL ?? "https://api.openai.com/v1",
                    model: settings?.llmModel ?? "gpt-4o"
                )
                Task { await viewModel.generate() }
            } label: {
                if case .loading = viewModel.status {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("✨ 开始生成", systemImage: "sparkles")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - 结果区

    private var resultSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("生成结果 (\(viewModel.previewCards.count) 张)")
                    .font(.headline)
                Spacer()
                Button("重新生成") { viewModel.reset() }
                    .buttonStyle(.bordered)
            }
            .padding(16)

            List {
                ForEach(Array(viewModel.previewCards.enumerated()), id: \.element.id) { index, card in
                    previewCardRow(index: index, preview: card)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.removePreviewCard(at: index)
                    }
                }
            }

            Button {
                viewModel.saveAllToDeck(
                    deckId: deck.persistentModelID,
                    modelContext: modelContext
                )
                dismiss()
            } label: {
                Label("全部添加 (\(viewModel.previewCards.count))", systemImage: "checkmark")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(16)
            .disabled(viewModel.previewCards.isEmpty)
        }
    }

    private func previewCardRow(index: Int, preview: CardPreview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("#\(index + 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("**Q:** \(preview.question)")
                .font(.subheadline)
            Text("**A:** \(preview.answer)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if !preview.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(preview.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func loadSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        settings = try? modelContext.fetch(descriptor).first
    }

    private func loadApiKey() async {
        apiKey = await KeychainService.shared.getApiKey()
    }
}
