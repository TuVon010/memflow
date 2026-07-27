import SwiftUI

/// 复习卡片组件
///
/// 展示卡片的问答内容，支持文本选中和代码块渲染。
/// 显示答案后可长按选中文字呼出 AI 答疑。
struct CardWidget: View {
    let card: Card
    let isAnswerShown: Bool
    let isNewCard: Bool
    var onTextSelected: ((String) -> Void)?

    @State private var selectedText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标签区域
            headerView

            Divider()

            // 内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 问题
                    contentSection(title: "问题", content: card.question, isCode: card.cardType == "code")

                    // 答案
                    if isAnswerShown {
                        Divider()
                        contentSection(title: "答案", content: card.answer, isCode: card.cardType == "code", isAnswer: true)
                    }
                }
                .padding(20)
            }

            // 未显示答案时的提示
            if !isAnswerShown {
                Text("点击卡片显示答案")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(16)
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(16)
    }

    // MARK: - 子视图

    private var headerView: some View {
        HStack(spacing: 6) {
            if isNewCard {
                tagLabel("🆕 新卡片")
            }

            if card.cardType != "basic" {
                tagLabel(card.cardType)
            }

            ForEach(card.tags, id: \.self) { tag in
                tagLabel(tag, color: .blue.opacity(0.15))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func tagLabel(_ text: String, color: Color = .blue.opacity(0.1)) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }

    private func contentSection(title: String, content: String, isCode: Bool, isAnswer: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            if isCode {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.12))
                    .foregroundStyle(Color(white: 0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(content)
                    .font(.body)
                    .lineSpacing(6)
                    .textSelection(.enabled)
                    .contextMenu {
                        Button {
                            // 复制
                            UIPasteboard.general.string = content
                        } label: {
                            Label("复制", systemImage: "doc.on.doc")
                        }

                        if isAnswer {
                            Button {
                                // 获取选中文本，触发 AI 答疑
                                onTextSelected?(selectedText.isEmpty ? content : selectedText)
                            } label: {
                                Label("问 AI", systemImage: "sparkles")
                            }
                        }
                    }
            }
        }
    }
}
