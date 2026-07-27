# MemFlow（记忆流）

> AI 增强的离线间隔重复记忆工具 — 面向程序员面试准备

MemFlow 是一款纯移动端的记忆卡应用，帮助程序员高效记忆技术面试八股文。通过大模型自动将笔记拆解为问答卡片，结合改良的 SM-2 算法与划词 AI 答疑，将"背八股"变为科学的主动回忆。

## 核心特性

- **AI 自动制卡** — 粘贴一段技术文本，AI 自动拆解为问答卡片
- **科学记忆引擎** — 基于改良 SM-2 算法的间隔重复
- **划词 AI 答疑** — 复习时选中任何文字，即时追问大模型
- **面试倒计时** — 设置面试日期，自动调整复习节奏
- **完全离线** — 所有数据本地存储，无需账号、无需联网（除 AI 调用外）
- **数据可控** — API Key 由用户自己提供，成本透明

## 平台支持

- iOS 15+
- Android 10+

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Flutter 3.24+ |
| 语言 | Dart 3.5+ |
| 状态管理 | Riverpod 2.5+ |
| 本地数据库 | Isar 3.x |
| AI 接口 | OpenAI-compatible API（OpenAI / DeepSeek / Ollama） |

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/your-org/memflow.git
cd memflow

# 2. 安装依赖
flutter pub get

# 3. 生成 Isar 模型代码
dart run build_runner build --delete-conflicting-outputs

# 4. 运行
flutter run
```

详细开发环境搭建指南见 [DEVELOPMENT.md](./DEVELOPMENT.md)。

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── app.dart               # MaterialApp 与导航
├── providers.dart         # 全部 Riverpod Provider
├── core/                  # 主题、常量、工具
├── data/                  # Isar 模型 + Repository
├── engine/                # SM-2 调度、队列生成、面试计划
├── services/              # AI、导出导入、通知、安全存储
├── features/              # 功能模块
│   ├── review/            # 复习页面 + 卡片组件
│   ├── decks/             # 卡组列表 + 详情
│   ├── ai_generate/       # AI 拆卡生成
│   ├── stats/             # 学习统计
│   └── settings/          # AI 配置、面试计划、提醒
└── widgets/               # 公共组件
```

## 文档

- [PRD 产品需求文档](./开发方案/prd.md)
- [数据库设计](./开发方案/数据库设计.md)
- [核心算法说明](./开发方案/核心算法.md)
- [API 接口设计](./开发方案/api接口设计(AI).md)
- [技术选型与架构](./开发方案/技术选型与说明.md)
- [用户流程与原型](./开发方案/用户流程与原型图.md)
- [编码规范](./开发方案/编码规范与命名约定.md)
- [开发环境搭建](./DEVELOPMENT.md)

## 版本规划

- **v0.5 (内部测试)** — 手动卡组创建、基本复习、SM-2 算法、本地存储
- **v0.8 (Alpha)** — AI 制卡、划词答疑、面试倒计时、数据导入导出
- **v1.0 (MVP)** — 完善 UI、引导流程、统计图表、本地通知，上架应用商店

## License

MIT
