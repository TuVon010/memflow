import SwiftUI

/// AI 答疑底部抽屉
///
/// 用户在复习答案区选中文字后弹出，调用 LLM 解释选中内容。
struct AIExplainSheet: View {
    let selectedText: String
    let question: String
    let answer: String
    let apiKey: String?
    let baseURL: String
    let model: String

    @State private var explanation: String?
    @State private var isLoading = true
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // 选中文本引用
                VStack(alignment: .leading, spacing: 8) {
                    Label("AI 解答", systemImage: "sparkles")
                        .font(.headline)

                    Text("\"\(selectedText)\"")
                        .font(.caption)
                        .italic()
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)

                Divider()

                // 内容区域
                ScrollView {
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("正在生成解释…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else if let error = errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                            Button("重试") {
                                Task { await loadExplanation() }
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else if let text = explanation {
                        Text(text)
                            .font(.body)
                            .lineSpacing(6)
                            .textSelection(.enabled)
                            .padding(20)
                    }
                }

                // 底部操作
                if explanation != nil {
                    Divider()
                    HStack {
                        Button {
                            // TODO: 生成追问卡片
                        } label: {
                            Label("生成追问卡片", systemImage: "note.text.badge.plus")
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("关闭") { dismiss() }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding(16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            await loadExplanation()
        }
    }

    private func loadExplanation() async {
        guard let key = apiKey, !key.isEmpty else {
            errorMessage = "请先在设置中配置 AI API Key"
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        let service = AIService(apiKey: key, baseURL: baseURL, model: model)

        do {
            let result = try await service.explain(
                selectedText: selectedText,
                question: question,
                answer: answer
            )
            explanation = result
        } catch let error as AIServiceError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "答疑失败: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
