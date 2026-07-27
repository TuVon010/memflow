import Foundation
import Security

/// iOS Keychain 安全存储服务
///
/// 将 LLM API Key 存储于系统 Keychain（硬件加密级别）。
/// 比 UserDefaults / SwiftData 更安全，即使设备备份也不会暴露密钥。
actor KeychainService {
    static let shared = KeychainService()

    private let serviceName = "com.memflow.apikey"
    private let accountName = "llm_api_key"

    /// 保存 API Key 到 Keychain
    func saveApiKey(_ key: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }

        // 先尝试删除旧条目
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // 创建新条目
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// 从 Keychain 读取 API Key
    func getApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// 删除 API Key
    func deleteApiKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 检查是否已配置 API Key
    func hasApiKey() -> Bool {
        return getApiKey() != nil
    }
}
