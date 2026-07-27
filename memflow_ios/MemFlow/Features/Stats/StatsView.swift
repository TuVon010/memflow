import SwiftUI
import SwiftData
import Charts

/// 学习统计页面
///
/// "统计" Tab，使用 Swift Charts 展示学习日历、记忆留存率、各卡组掌握度等。
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 打卡天数
                    streakCard

                    // 记忆留存率
                    retentionCard

                    // 过去 7 天复习柱状图 (Swift Charts)
                    dailyChart

                    // 卡组概览
                    deckSummarySection
                }
                .padding(16)
            }
            .navigationTitle("统计")
            .task {
                viewModel.loadStats(modelContext: modelContext)
            }
            .refreshable {
                viewModel.loadStats(modelContext: modelContext)
            }
        }
    }

    // MARK: - 打卡天数

    private var streakCard: some View {
        HStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 44))
            VStack(alignment: .leading, spacing: 4) {
                Text("连续打卡 \(viewModel.streakDays) 天")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("今日已复习 \(viewModel.todayReviewCount) 张")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 记忆留存率

    private var retentionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("记忆留存率")
                .font(.subheadline)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.quaternary)
                            .frame(height: 20)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.blue.gradient)
                            .frame(
                                width: geometry.size.width * viewModel.retentionRate,
                                height: 20
                            )
                    }
                }
                .frame(height: 20)

                Text("\(Int(viewModel.retentionRate * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 每日复习图表 (Swift Charts)

    private var dailyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("过去 7 天复习量")
                .font(.subheadline)
                .fontWeight(.bold)

            Chart {
                ForEach(viewModel.dailyReviewData.prefix(7).reversed(), id: \.date) { item in
                    BarMark(
                        x: .value("日期", String(item.date.suffix(5))),
                        y: .value("复习量", item.count)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(4)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 160)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 卡组概览

    private var deckSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("卡组概览")
                .font(.subheadline)
                .fontWeight(.bold)

            ForEach(viewModel.deckSummaries, id: \.deck.persistentModelID) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(rgb: item.deck.color))
                        .frame(width: 10, height: 10)

                    Text(item.deck.name)
                        .font(.subheadline)

                    Spacer()

                    Text("\(item.cardCount) 张")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if viewModel.deckSummaries.isEmpty {
                Text("暂无卡组数据")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Color 辅助

extension Color {
    init(rgb: Int) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
