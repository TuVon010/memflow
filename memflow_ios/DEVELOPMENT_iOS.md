# MemFlow iOS 开发构建环境文档

> 纯原生 SwiftUI 版本 — iOS 17+ | Swift 5.9+ | Xcode 15.2+

---

## 1. 技术栈对比

| 层 | Flutter 版本 | iOS 原生版本 |
|---|-------------|-------------|
| 框架 | Flutter 3.24+ | **SwiftUI 5** (iOS 17+) |
| 语言 | Dart 3.5+ | **Swift 5.9+** |
| 状态管理 | Riverpod 2.5+ | **@Observable** 宏 (内置) |
| 数据库 | Isar 3.x | **SwiftData** (Core Data 封装) |
| HTTP | Dio 5.4+ | **URLSession** (内置) |
| Markdown | flutter_markdown | 原生 `Text` + 自定义渲染 |
| 图表 | fl_chart 0.68+ | **Swift Charts** (内置) |
| 安全存储 | flutter_secure_storage | **Keychain** (Security 框架) |
| 通知 | flutter_local_notifications | **UserNotifications** (内置) |
| 文件导入 | file_picker | **AppStorage / DocumentGroup** |

**关键优势：**
- **零外部依赖** — 全部使用 Apple 系统框架，应用包体积极小
- **原生性能** — SwiftUI 编译为原生代码，启动快、渲染流畅
- **HIG 一致** — 自动适配 iOS 设计规范、无障碍、深色模式、Dynamic Type
- **硬件加速加密** — Keychain 使用 Secure Enclave，App Sandbox 隔离

---

## 2. 环境要求

| 软件 | 版本要求 | 用途 |
|------|---------|------|
| **Xcode** | 15.2+ | IDE、iOS SDK、模拟器、签名 |
| **macOS** | 14.0+ (Sonoma) | 运行 Xcode 所需 |
| **iOS 部署目标** | 17.0+ | @Observable、SwiftData、Swift Charts |
| **Swift** | 5.9+ | 宏系统 (@Model, @Observable) |

### 2.1 环境校验

```bash
# 检查 Xcode 版本
xcodebuild -version

# 检查 Swift 版本
swift --version

# 列出可用模拟器
xcrun simctl list devices available
```

---

## 3. 项目结构

```
memflow_ios/
├── Package.swift                         # Swift Package 配置（零外部依赖）
├── DEVELOPMENT_iOS.md                    # 本文档
├── MemFlow/
│   ├── App/
│   │   └── MemFlowApp.swift              # @main 入口 + Tab 导航
│   ├── Core/
│   │   ├── Theme.swift                   # 颜色定义
│   │   ├── Constants.swift               # 常量与预设
│   │   └── Utilities.swift               # 工具函数
│   ├── Models/                           # SwiftData 模型（7个）
│   │   ├── Deck.swift
│   │   ├── Card.swift
│   │   ├── ReviewState.swift
│   │   ├── ReviewLogEntry.swift
│   │   ├── AIUsageLog.swift
│   │   ├── UserSettings.swift
│   │   └── ReviewSession.swift
│   ├── Engine/                           # 核心算法
│   │   ├── Scheduler.swift               # SM-2 调度算法
│   │   ├── QueueGenerator.swift          # 队列生成器
│   │   └── InterviewPlanner.swift        # 面试计划器
│   ├── Services/                         # 业务服务
│   │   ├── AIService.swift               # AI API 调用 (URLSession)
│   │   ├── ExportService.swift           # JSON 导入/导出
│   │   ├── NotificationService.swift     # 本地通知
│   │   └── KeychainService.swift         # Keychain 安全存储
│   ├── ViewModels/                       # 响应式 ViewModel (@Observable)
│   │   ├── ReviewViewModel.swift         # 复习队列、评分、统计
│   │   ├── DeckViewModel.swift           # 卡组 CRUD
│   │   ├── AIGenerateViewModel.swift     # AI 制卡状态
│   │   ├── StatsViewModel.swift          # 统计数据
│   │   └── SettingsViewModel.swift       # 设置读写
│   ├── Features/                         # SwiftUI 页面
│   │   ├── Review/
│   │   │   ├── ReviewHomeView.swift      # 复习首页 (Tab 1)
│   │   │   ├── CardReviewView.swift      # 沉浸式卡片复习
│   │   │   ├── CardWidget.swift          # 卡片显示组件
│   │   │   ├── RatingButtons.swift       # 评分按钮组
│   │   │   └── AIExplainSheet.swift      # AI 答疑底部抽屉
│   │   ├── Decks/
│   │   │   └── DeckListView.swift        # 卡组列表+详情+编辑 (Tab 2)
│   │   ├── AIGenerate/
│   │   │   └── AIGenerateView.swift      # AI 拆卡生成
│   │   ├── Stats/
│   │   │   └── StatsView.swift           # 统计图表 (Tab 3)
│   │   └── Settings/
│   │       └── SettingsView.swift        # 全部设置 (Tab 4)
│   ├── Components/                       # 公共组件
│   │   ├── EmptyStateView.swift          # 空状态占位
│   │   └── LoadingShimmer.swift          # 骨架屏加载
│   └── Resources/
│       └── Info.plist                    # 应用配置
```

---

## 4. 编译与运行

### 4.1 用 Xcode 打开（推荐）

```bash
# 方法 1：直接打开 Package.swift（支持 SPM 项目）
open memflow_ios/Package.swift

# 方法 2：在 Xcode 中创建新 iOS App 项目后，拖入 MemFlow 目录

# 方法 3：用 xcodebuild 命令行编译
cd memflow_ios
xcodebuild -scheme MemFlow -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### 4.2 选择目标设备

在 Xcode 顶部 Scheme 菜单中选择：
- **iPhone 15 / 15 Pro 模拟器**（推荐）
- **真机**（需 USB 连接并配置签名）

### 4.3 运行

```
Xcode → 选择设备 → ⌘R (Run)
```

或命令行：
```bash
xcodebuild -scheme MemFlow \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
xcrun simctl boot "iPhone 15"
```

---

## 5. 框架依赖说明

本项目**零外部依赖**，全部使用 Apple 系统框架：

### 5.1 iOS 17+ 新特性使用

| 特性 | 用途 |
|------|------|
| `@Observable` 宏 | 替代 @ObservableObject / @Published，自动追踪属性变更 |
| `@Model` 宏 | SwiftData 模型定义，替代 Core Data Entity |
| `Swift Charts` | 统计图表（柱状图等） |
| `#Predicate` | 类型安全的 SwiftData 查询条件 |
| `@Environment(\.modelContext)` | SwiftUI 环境中注入 SwiftData 上下文 |

### 5.2 传统框架使用

| 框架 | 用途 |
|------|------|
| `Security` | Keychain API Key 存储 |
| `UserNotifications` | 本地复习提醒 |
| `UniformTypeIdentifiers` | 文件导入导出 MIME 类型 |

---

## 6. 项目配置清单

### 6.1 Info.plist 必要配置

| Key | Value | 说明 |
|-----|-------|------|
| `CFBundleName` | MemFlow | 应用名称 |
| `CFBundleIdentifier` | com.memflow.app | Bundle ID |
| `ITSAppUsesNonExemptEncryption` | false | 无加密，加速审核 |
| `NSLocalNetworkUsageDescription` | MemFlow 需要访问网络以调用 AI API | 网络权限说明 |
| `MinimumOSVersion` | 17.0 | 最低 iOS 版本 |

### 6.2 Xcode 项目设置

| 设置 | 值 |
|------|---|
| Deployment Target | iOS 17.0 |
| Swift Language Version | Swift 5.9 |
| Development Team | 需设置（真机调试需要） |
| Signing & Capabilities | 真机需选 "Automatically manage signing" |

---

## 7. AI 配置

用户在设置中可选择以下预设（也可自定义）：

| 提供商 | Base URL | 默认模型 |
|--------|----------|---------|
| OpenAI | `https://api.openai.com/v1` | `gpt-4o` |
| DeepSeek | `https://api.deepseek.com/v1` | `deepseek-chat` |
| Ollama | `http://localhost:11434/v1` | `llama3` |

> API Key 存储于 iOS Keychain（硬件安全隔区级别），App Sandbox 隔离。

---

## 8. 常见问题

### Q1: Swift Package 无法解析
```bash
# 重置缓存
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Q2: 模拟器启动失败
```bash
# 重置模拟器
xcrun simctl shutdown all
xcrun simctl erase all
```

### Q3: 真机运行时签名错误
- Xcode → Signing & Capabilities → 选择你的 Apple ID
- 免费账号可调试，但每 7 天需重新签名

### Q4: SwiftData @Model 报错
- 确保所有 @Model 类属性是 SwiftData 支持的类型
- 不支持 `[String]`，需用逗号分隔字符串替代（已在模型中实现）

### Q5: Keychain 存储后读取为空
- 检查 `kSecAttrAccessible` 设置（当前: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`）
- 首次安装后需解锁设备才能读取

---

## 9. 与 Flutter 版本的关系

| 特性 | Flutter | iOS 原生 |
|------|---------|---------|
| 代码量 | ~5000 行 | ~3500 行 |
| 外部依赖 | 12 个包 | 0 个 |
| App 包体 | ~40MB (基础) | ~4MB (基础) |
| 启动时间 | ~1.5s (冷启动) | ~0.3s |
| 开发环境 | VS Code + Flutter SDK | Xcode 15.2+ |
| 跨平台 | iOS + Android | 仅 iOS |
| 原生体验 | 模拟 Material/Cupertino | 原生 iOS HIG |

**建议**：
- iOS 体验优先 → 使用原生版本
- 双端快速覆盖 → 使用 Flutter 版本
- 两者可共享 JSON 导出格式（`.mfcard.json`），数据互通

---

## 10. 快速开始（5 分钟）

```bash
# 1. 在 Xcode 中打开项目
#    File → Open → 选择 memflow_ios 目录

# 2. 等待 Indexing 完成（首次约 1-2 分钟）

# 3. 选择模拟器（如 iPhone 15 Pro）

# 4. 按 ⌘R 运行

# 5. 在设置 Tab 中配置 AI API Key

# 6. 在卡组 Tab 中创建卡组并开始学习
```

零外部依赖、编译即跑、热重载 (⌘⇧.) 秒级生效。
