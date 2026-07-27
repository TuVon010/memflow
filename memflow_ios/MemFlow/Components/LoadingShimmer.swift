import SwiftUI

/// 骨架屏加载组件
///
/// AI 调用等耗时操作时展示加载占位，减轻等待焦虑。
struct LoadingShimmer: View {
    let itemCount: Int

    init(itemCount: Int = 3) {
        self.itemCount = itemCount
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<itemCount, id: \.self) { _ in
                shimmerCard
            }
        }
        .padding(16)
    }

    private var shimmerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题占位
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary)
                .frame(height: 16)

            // 内容行 1
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary.opacity(0.6))
                .frame(height: 12)

            // 内容行 2
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary.opacity(0.6))
                .frame(width: 200, height: 12)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
