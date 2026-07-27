import SwiftUI
import SwiftData

/// 沉浸式卡片复习页面
///
/// 全屏复习界面：显示问题 → 点击展示答案 → 评分 → 下一张。
/// 复习完成自动跳转至统计完成页。
struct CardReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ReviewViewModel()
    @State private var isAnswerShown = false
    @State private var showAIExplain = false
    @State private var aiSelectedText = ""
    @State private var settings: UserSettings?

    // API Key 相关
    @State private var apiKey: String?

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("加载复习队列…")
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(error))
            } else if viewModel.isCompleted {
                ReviewCompletionView(viewModel: viewModel)
            } else if let card = viewModel.currentCard {
                reviewContent(card: card)
            } else {
                ContentUnavailableView("今日无待复习卡片", systemImage: "checkmark.circle", description: Text("你已经完成了所有复习，真棒！"))
            }
        }
        .task {
            await viewModel.generateQueue(modelContext: modelContext)
            loadSettings()
            await loadApiKey()
        }
    }

    // MARK: - 复习内容

    private func reviewContent(card: ReviewItem) -> some View {
        VStack(spacing: 0) {
            // 进度条
            ProgressView(value: viewModel.progress)
                .tint(.blue)

            // 卡片
            CardWidget(
                card: card.card,
                isAnswerShown: isAnswerShown,
                isNewCard: card.isNewCard,
                onTextSelected: { text in
                    aiSelectedText = text
                    showAIExplain = true
                }
            )
            .onTapGesture {
                if !isAnswerShown {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnswerShown = true
                    }
                    viewModel.markQuestionShown()
                }
            }

            // 评分按钮
            if isAnswerShown {
                RatingButtons { rating in
                    viewModel.submitRating(rating, modelContext: modelContext)
                    withAnimation {
                        isAnswerShown = false
                    }
                }
            }
        }
        .navigationTitle("\(viewModel.currentIndex + 1) / \(viewModel.totalCards)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("退出") { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                Text("\(viewModel.currentIndex + 1) / \(viewModel.totalCards)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showAIExplain) {
            AIExplainSheet(
                selectedText: aiSelectedText,
                question: card.card.question,
                answer: card.card.answer,
                apiKey: apiKey,
                baseURL: settings?.llmBaseURL ?? "https://api.openai.com/v1",
                model: settings?.llmModel ?? "gpt-4o"
            )
        }
    }

    // MARK: - 数据加载

    private func loadSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        settings = try? modelContext.fetch(descriptor).first
    }

    private func loadApiKey() async {
        apiKey = await KeychainService.shared.getApiKey()
    }
}

// MARK: - 复习完成页

struct ReviewCompletionView: View {
    let viewModel: ReviewViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🎉")
                .font(.system(size: 64))

            Text("今日复习完成！")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                statRow("复习卡片", "\(viewModel.reviewedCount) 张")
                statRow("顺畅", "\(viewModel.goodCount) 张")
                statRow("犹豫", "\(viewModel.hardCount) 张")
                statRow("生疏", "\(viewModel.againCount) 张")

                Divider()
                    .padding(.vertical, 4)

                statRow("记忆留存率", "\(Int(viewModel.retentionRate * 100))%")
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

            Button {
                dismiss()
            } label: {
                Text("返回首页")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Spacer()
        }
        .navigationBarBackButtonHidden()
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
        .font(.callout)
    }
}
