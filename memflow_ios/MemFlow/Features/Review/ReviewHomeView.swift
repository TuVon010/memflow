import SwiftUI
import SwiftData

/// 复习首页（默认 Tab）
///
/// 展示今日复习概览、连续打卡、复习进度和面试倒计时信息。
struct ReviewHomeView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var statsVM = StatsViewModel()
    @State private var reviewVM = ReviewViewModel()

    @State private var showReview = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 连续打卡
                    streakCard

                    // 今日复习概览
                    todayCard

                    // 面试倒计时
                    interviewBanner

                    // 开始复习按钮
                    Button {
                        showReview = true
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(reviewVM.totalCards > 0 ? "开始复习 (\(reviewVM.totalCards)张)" : "开始复习")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(reviewVM.totalCards == 0)

                    // 最近学习
                    recentStatsSection
                }
                .padding(16)
            }
            .navigationTitle("MemFlow")
            .navigationDestination(isPresented: $showReview) {
                CardReviewView()
            }
            .task {
                statsVM.loadStats(modelContext: modelContext)
                await reviewVM.generateQueue(modelContext: modelContext)
            }
            .refreshable {
                statsVM.loadStats(modelContext: modelContext)
                await reviewVM.generateQueue(modelContext: modelContext)
            }
        }
    }

    // MARK: - 子视图

    private var streakCard: some View {
        HStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                Text("连续打卡 \(statsVM.streakDays) 天")
                    .font(.headline)
                Text("记忆留存率 \(Int(statsVM.retentionRate * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日复习")
                .font(.headline)

            HStack(spacing: 24) {
                statItem(icon: "book.fill", label: "待复习", value: "\(reviewVM.totalCards)")
                statItem(icon: "plus.circle", label: "新卡片", value: "+\(reviewVM.queue.filter(\.isNewCard).count)")
                statItem(icon: "checkmark.circle", label: "已复习", value: "\(statsVM.todayReviewCount)")
            }
            .frame(maxWidth: .infinity)

            if reviewVM.totalCards > 0 {
                ProgressView(value: reviewVM.progress)
                    .tint(.blue)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var interviewBanner: some View {
        let descriptor = FetchDescriptor<UserSettings>()
        if let settings = try? modelContext.fetch(descriptor).first,
           settings.interviewModeEnabled,
           let date = settings.interviewDate,
           let days = settings.daysUntilInterview {
            HStack(spacing: 12) {
                Image(systemName: "timer")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text("距离面试还有 \(days) 天")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    ProgressView(value: 0.65)
                        .tint(.orange)
                }
            }
            .padding(16)
            .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var recentStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近学习")
                .font(.subheadline)
                .fontWeight(.bold)

            ForEach(statsVM.dailyReviewData.prefix(7), id: \.date) { item in
                HStack {
                    Text(String(item.date.suffix(5))) // MM-dd
                        .font(.caption)
                        .frame(width: 50, alignment: .leading)
                    ProgressView(value: Double(item.count) / 100.0)
                        .tint(.blue)
                    Text("\(item.count)张")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
