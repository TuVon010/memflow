// swift-tools-version: 5.9
//
// MemFlow iOS — Swift Package 配置
//
// 纯 SwiftUI 项目，无外部依赖。
// SwiftData、Swift Charts、UserNotifications、Keychain 均为系统框架。

import PackageDescription

let package = Package(
    name: "MemFlow",
    platforms: [
        .iOS(.v17),  // 基于 SwiftData / @Observable / Swift Charts 的最低版本
    ],
    products: [
        .executable(
            name: "MemFlow",
            targets: ["MemFlow"]
        ),
    ],
    dependencies: [
        // 无外部依赖——全部使用 Apple 原生框架
    ],
    targets: [
        .executableTarget(
            name: "MemFlow",
            path: "MemFlow",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
