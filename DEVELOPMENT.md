# MemFlow 开发构建环境文档

> MemFlow（记忆流）— AI 增强的离线记忆卡应用
> 
> Flutter 3.24+ | Dart 3.5+ | Isar 3.x | Riverpod 2.5+

---

## 1. 环境要求

### 1.1 核心运行时

| 软件 | 版本要求 | 用途 |
|------|---------|------|
| Flutter SDK | **3.24.0+** (stable) | 跨平台移动端框架 |
| Dart SDK | **3.5.0+** (包含在 Flutter SDK 中) | 编程语言 |
| Android Studio | 2024.1+ | Android SDK、模拟器 |
| Xcode | **15.2+** (仅 macOS) | iOS 开发、模拟器、签名 |
| Git | 2.40+ | 版本管理 |

### 1.2 推荐 IDE

**VS Code**（推荐）— 轻量高效，或 **Android Studio / IntelliJ IDEA**。

**VS Code 插件：**
- Flutter (官方)
- Dart (官方)
- Flutter Widget Snippets
- GitLens

### 1.3 环境校验

```bash
# 检查 Flutter 环境
flutter doctor -v

# 确认版本
flutter --version   # 应显示 3.24.0+
```

---

## 2. 项目初始化

### 2.1 克隆项目

```bash
git clone https://github.com/your-org/memflow.git
cd memflow
```

### 2.2 安装依赖

```bash
flutter pub get
```

### 2.3 生成 Isar 模型代码

MemFlow 使用 Isar 本地数据库，所有数据模型通过注解定义，需运行代码生成器：

```bash
dart run build_runner build --delete-conflicting-outputs
```

> **注意**：每次修改 `lib/data/models/` 下的模型文件（添加/删除字段）后，必须重新执行此命令。

### 2.4 验证项目结构

确认以下目录和文件已生成：

```
memflow/
├── android/                    # Android 工程
├── ios/                        # iOS 工程
├── lib/
│   ├── main.dart               # 应用入口
│   ├── app.dart                # MaterialApp 配置
│   ├── providers.dart          # Riverpod 全局 Provider
│   ├── core/                   # 核心配置
│   │   ├── theme.dart          # 浅色/深色主题
│   │   ├── constants.dart      # 全局常量、LLM 预设
│   │   └── utils.dart          # 工具函数
│   ├── data/                   # 数据层
│   │   ├── isar_service.dart   # Isar 实例管理
│   │   ├── models/             # Isar 数据模型（6个集合）
│   │   │   ├── deck.dart
│   │   │   ├── card.dart
│   │   │   ├── review_state.dart
│   │   │   ├── review_log_entry.dart
│   │   │   ├── ai_usage_log.dart
│   │   │   ├── user_settings.dart
│   │   │   └── review_session.dart
│   │   └── repositories/       # 数据仓库
│   │       ├── deck_repo.dart
│   │       ├── card_repo.dart
│   │       ├── review_repo.dart
│   │       └── settings_repo.dart
│   ├── engine/                 # 核心引擎
│   │   ├── scheduler.dart      # SM-2 调度算法
│   │   ├── queue_generator.dart # 每日队列生成
│   │   └── interview_planner.dart # 面试计划器
│   ├── services/               # 业务服务
│   │   ├── ai_service.dart     # AI API 调用
│   │   ├── export_service.dart # 卡组导入/导出
│   │   ├── notification_service.dart # 本地通知
│   │   └── secure_storage_service.dart # 安全存储
│   ├── features/               # 功能模块（Feature-first）
│   │   ├── review/             # 复习模块
│   │   ├── decks/              # 卡组模块
│   │   ├── ai_generate/        # AI 生成模块
│   │   ├── stats/              # 统计模块
│   │   └── settings/           # 设置模块
│   └── widgets/                # 公共组件
├── test/                       # 测试代码
│   ├── engine/
│   ├── services/
│   └── data/
├── pubspec.yaml                # 依赖配置
└── analysis_options.yaml       # 代码规范
```

---

## 3. 运行与调试

### 3.1 Android

#### 模拟器

```bash
# 1. 打开 Android Studio → Virtual Device Manager → 创建虚拟设备
#    推荐 Pixel 系列，API 34+

# 2. 启动模拟器

# 3. 运行应用
flutter run
```

#### 真机

```bash
# 1. 手机开启开发者选项 → USB 调试
# 2. USB 连接电脑
# 3. 确认设备已识别
flutter devices

# 4. 运行
flutter run
```

### 3.2 iOS（仅限 macOS）

#### 模拟器

```bash
# 1. Xcode 中至少添加一个 iOS 模拟器
#    (Xcode → Settings → Platforms)

# 2. 启动模拟器
open -a Simulator

# 3. 运行
flutter run
```

#### 真机

```bash
# 1. Xcode 登录 Apple ID (Preferences → Accounts)
# 2. 连接 iPhone
# 3. 打开 ios/Runner.xcworkspace（注意不是 .xcodeproj）
# 4. 选择设备，点击 Run
# 5. iOS 上信任证书：设置 → 通用 → VPN与设备管理 → 信任开发者
```

> **注意**：免费开发者账号每 7 天签名过期，需重新构建。

### 3.3 指定设备运行

```bash
# 列出所有设备
flutter devices

# 指定设备
flutter run -d <device-id>
```

---

## 4. 依赖详解

### 4.1 完整依赖表

| 包名 | 版本约束 | 用途 |
|------|---------|------|
| `flutter_riverpod` | ^2.5.1 | 状态管理 |
| `isar` | ^3.1.0+1 | 本地 NoSQL 数据库 |
| `isar_flutter_libs` | ^3.1.0+1 | Isar Flutter 绑定 |
| `flutter_secure_storage` | ^9.2.2 | API Key 加密存储 |
| `dio` | ^5.4.3+1 | HTTP 客户端（AI API） |
| `flutter_markdown` | ^0.7.3+1 | Markdown 渲染 |
| `fl_chart` | ^0.68.0 | 统计图表 |
| `flutter_local_notifications` | ^17.2.2 | 本地复习提醒 |
| `path_provider` | ^2.1.4 | 获取应用目录 |
| `file_picker` | ^8.1.3 | 文件选择器 |
| `share_plus` | ^10.0.3 | 系统分享 |
| `intl` | ^0.19.0 | 国际化/日期格式化 |

### 4.2 开发依赖

| 包名 | 版本约束 | 用途 |
|------|---------|------|
| `build_runner` | ^2.4.11 | Dart 代码生成工具 |
| `isar_generator` | ^3.1.0+1 | Isar 模型代码生成 |
| `mocktail` | ^1.0.4 | Mock 测试框架 |
| `flutter_lints` | ^4.0.0 | Lint 规则集 |
| `riverpod_generator` | ^2.4.0 | Riverpod 代码生成（可选） |

---

## 5. 构建与发布

### 5.1 Android APK

```bash
# Debug APK（快速测试）
flutter build apk --debug

# Release APK（分发用）
flutter build apk --release

# App Bundle（Google Play 上架用）
flutter build appbundle --release
```

输出路径：`build/app/outputs/flutter-apk/app-release.apk`

### 5.2 Android 签名配置

```bash
# 生成签名密钥（仅需一次）
keytool -genkey -v -keystore ~/memflow-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias memflow

# 在项目根目录创建 android/key.properties
# 内容：
#   storeFile=<path-to-key.jks>
#   storePassword=<password>
#   keyAlias=memflow
#   keyPassword=<password>
```

### 5.3 iOS IPA

```bash
# Release 构建
flutter build ios --release

# 使用 Xcode Archive 生成 IPA
# 1. 打开 ios/Runner.xcworkspace
# 2. Product → Archive
# 3. Distribute App
```

---

## 6. 测试

### 6.1 单元测试

```bash
# 运行全部测试
flutter test

# 运行指定测试文件
flutter test test/engine/scheduler_test.dart

# 带覆盖率
flutter test --coverage
```

### 6.2 代码分析

```bash
# 静态分析
flutter analyze

# 格式化检查
dart format --set-exit-if-changed lib/
```

### 6.3 已有测试覆盖

| 测试文件 | 覆盖内容 |
|---------|---------|
| `test/engine/scheduler_test.dart` | SM-2 评分映射、EF 更新、间隔计算、面试模式、EF 下限保护 |
| `test/engine/queue_generator_test.dart` | 交错比例、新卡上限、ReviewItem 模型 |
| `test/services/ai_service_test.dart` | CardPreview JSON 解析、AI 响应格式验证 |
| `test/data/export_service_test.dart` | JSON 导入导出格式、版本兼容性 |

---

## 7. 常用命令速查

```bash
# 环境检查
flutter doctor -v

# 依赖管理
flutter pub get           # 安装依赖
flutter pub upgrade       # 升级依赖
flutter pub outdated      # 查看过时依赖

# 代码生成
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs  # 监听模式

# 开发运行
flutter run               # 默认设备运行
flutter run -d <device>   # 指定设备

# 调试
flutter run --debug       # Debug 模式（默认）
flutter run --profile     # Profile 模式（性能分析）
flutter run --release     # Release 模式

# 热重载 / 热重启
r                         # 热重载（保持状态）
R                         # 热重启（重置状态）

# 测试与分析
flutter test              # 运行测试
flutter analyze           # 静态检查
dart format lib/          # 格式化代码

# 清理
flutter clean             # 清理构建缓存
flutter pub cache repair  # 修复 pub 缓存
```

---

## 8. AI 配置预设

用户在设置中可选择以下预设提供商（也可自定义）：

| 提供商 | Base URL | 默认模型 |
|--------|----------|---------|
| OpenAI | `https://api.openai.com/v1` | `gpt-4o` |
| DeepSeek | `https://api.deepseek.com/v1` | `deepseek-chat` |
| Ollama | `http://localhost:11434/v1` | `llama3` |
| 自定义 | 用户自行输入 | 用户自行输入 |

> 所有 AI 调用直接由客户端发起，API Key 存储在系统钥匙串（iOS Keychain / Android EncryptedSharedPreferences），不经过任何第三方服务器。

---

## 9. 常见问题 FAQ

### Q1: `flutter pub get` 报网络错误
- 设置国内镜像：
  ```bash
  export PUB_HOSTED_URL=https://pub.flutter-io.cn
  export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
  ```

### Q2: `build_runner` 生成失败
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Q3: Android 模拟器无法启动
- 确保 BIOS 中已开启虚拟化（Intel VT-x / AMD-V）
- 检查 SDK Manager 中 Android SDK Platform 已安装

### Q4: iOS 模拟器卡在启动页
```bash
flutter clean
cd ios && pod install && cd ..
flutter run
```

### Q5: 真机运行时提示"不受信任的开发者"
- iOS：设置 → 通用 → VPN与设备管理 → 信任证书
- Android：允许安装未知来源应用

### Q6: Isar 模型修改后运行报错
- 每次修改模型文件后必须重新生成：
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

### Q7: 如何调试 AI 调用？
- 使用抓包工具（如 Charles / Proxyman）查看 HTTP 请求
- 或在代码中临时打印 `dio` 拦截器日志

---

## 10. 版本兼容矩阵

| 组件 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.24+ | 使用 Material 3 特性 |
| Android minSdk | 29 (Android 10) | 满足主流设备覆盖 |
| iOS Deployment Target | 15.0 | 覆盖 iOS 15+ 设备 |
| Isar | 3.1.x | 稳定的本地数据库版本 |
| Riverpod | 2.5.x | 编译安全的响应式状态管理 |

---

## 11. 下一步

1. **运行 `flutter pub get`** 安装依赖
2. **运行 `dart run build_runner build --delete-conflicting-outputs`** 生成 Isar 模型代码
3. **运行 `flutter run`** 启动应用
4. **运行 `flutter test`** 验证测试通过

如需进一步了解项目架构，请阅读 `开发方案/` 目录下的设计文档。
