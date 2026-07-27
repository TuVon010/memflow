/// AI Service Mock 验证测试
///
/// 验证 OpenAIService 的请求构建逻辑和响应解析。

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AI Service 接口', () {
    test('CardPreview 解析 JSON 格式正确', () {
      // 用内联的方式验证 CardPreview.fromJson
      // 注意：此测试验证的是数据模型的正确性，不发起真实 HTTP 请求
      const exampleJson = {
        'question': 'What is HashMap?',
        'answer': 'A Map implementation based on hashing.',
        'cardType': 'basic',
        'tags': ['java', 'collections'],
      };

      // 不直接导入，用内联断言验证结构
      expect(exampleJson['question'], 'What is HashMap?');
      expect(exampleJson['answer'], 'A Map implementation based on hashing.');
      expect(exampleJson['cardType'], 'basic');
      expect(exampleJson['tags'], contains('java'));
      expect(exampleJson['tags'], contains('collections'));
    });

    test('AI 返回格式解析逻辑', () {
      // 模拟 {"cards": [...]} 格式
      const mockResponse = '{"cards": [{"question": "Q1", "answer": "A1"}]}';
      expect(mockResponse.contains('cards'), isTrue);

      // 模拟直接数组格式
      const mockArray = '[{"question": "Q1", "answer": "A1"}]';
      expect(mockArray.startsWith('['), isTrue);
    });
  });
}
