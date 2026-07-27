import SwiftUI

/// 评分按钮组件
///
/// 3个评分按钮：生疏(红色) / 犹豫(橙色) / 顺畅(绿色)。
struct RatingButtons: View {
    let onRated: (SM2Scheduler.Rating) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ratingButton(
                emoji: "😵",
                label: "生疏",
                color: .red,
                rating: .again
            )

            ratingButton(
                emoji: "🤔",
                label: "犹豫",
                color: .orange,
                rating: .hard
            )

            ratingButton(
                emoji: "😊",
                label: "顺畅",
                color: .green,
                rating: .good
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
        .background(.regularMaterial)
        .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
    }

    private func ratingButton(
        emoji: String,
        label: String,
        color: Color,
        rating: SM2Scheduler.Rating
    ) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onRated(rating)
        } label: {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.title2)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            }
        }
        .foregroundStyle(color)
    }
}
