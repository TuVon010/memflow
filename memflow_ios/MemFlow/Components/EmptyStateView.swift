import SwiftUI

/// 空状态占位组件
///
/// 用于列表/页面无数据时的引导展示。
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionLabel: String?
    let action: (() -> Void)?

    init(
        icon: String = "tray",
        title: String = "暂无数据",
        subtitle: String? = nil,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionLabel = actionLabel
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text(title)
                .font(.headline)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let label = actionLabel, let action {
                Button(action: action) {
                    Text(label)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
