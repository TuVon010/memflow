# MemFlow for iOS

> AI 增强的间隔重复记忆工具 — 纯原生 SwiftUI 实现

MemFlow 是一款面向程序员面试准备的记忆卡应用。通过大模型自动将技术文本拆解为问答卡片，结合改良 SM-2 算法与划词 AI 答疑，实现科学的主动回忆。

## 技术栈

| 层 | 技术 |
|---|------|
| UI | SwiftUI 5 (iOS 17+) |
| 状态管理 | @Observable (iOS 17+ 原生) |
| 数据库 | SwiftData (Core Data 封装) |
| 图表 | Swift Charts |
| HTTP | URLSession |
| 安全存储 | Keychain (Security 框架) |
| 通知 | UserNotifications |

**零外部依赖** — 全部使用 Apple 系统框架。

## 快速开始

```bash
# 用 Xcode 打开
open Package.swift

# 或
open memflow_ios/
```

然后选择模拟器 (iPhone 15+)，按 ⌘R 运行。

## 项目结构

```
MemFlow/
├── App/MemFlowApp.swift         # 应用入口
├── Core/                        # 主题、常量、工具
├── Models/                      # SwiftData 数据模型
├── Engine/                      # SM-2 调度算法
├── Services/                    # AI、导出、通知、Keychain
├── ViewModels/                  # @Observable ViewModel
├── Features/                    # SwiftUI 页面
│   ├── Review/                  # 复习模块
│   ├── Decks/                   # 卡组模块
│   ├── AIGenerate/              # AI 生成
│   ├── Stats/                   # 统计图表 (Swift Charts)
│   └── Settings/                # 设置
└── Components/                  # 公共组件
```

## 性能特点

- App 包体 < 5MB (零外部依赖)
- 冷启动 < 0.3s
- 完全离线可用（除 AI 调用）
- API Key 存储在硬件加密 Keychain
- 原生 iOS HIG 设计, Dynamic Type 自适应

## 开发文档

详见 [DEVELOPMENT_iOS.md](./DEVELOPMENT_iOS.md)

## 数据互通

与 Flutter 版本共享 `.mfcard.json` 导出格式，可相互导入。

## 系统要求

- iOS 17.0+
- Xcode 15.2+
- macOS 14.0+
