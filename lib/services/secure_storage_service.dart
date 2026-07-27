/// MemFlow 安全存储服务
///
/// 基于 flutter_secure_storage 封装敏感数据的加密存储。
/// 用于存储 LLM API Key 等不应明文落盘的密钥信息。
/// 底层依赖 iOS Keychain / Android EncryptedSharedPreferences。

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _keyApiKey = 'llm_api_key';

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// 保存 LLM API Key
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _keyApiKey, value: apiKey);
  }

  /// 读取 LLM API Key，未设置时返回 null
  Future<String?> getApiKey() async {
    return await _storage.read(key: _keyApiKey);
  }

  /// 删除 LLM API Key
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyApiKey);
  }

  /// 判断是否已配置 API Key
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
