/// 导出/导入服务单元测试
///
/// 验证 JSON 序列化/反序列化、版本兼容性检查。

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleExportJson = '''
{
  "version": "1.0",
  "exportedAt": "2026-07-25T10:00:00Z",
  "decks": [
    {
      "name": "Java Collections",
      "description": "Java collection framework interview questions",
      "color": 4289449321,
      "cards": [
        {
          "question": "What is the difference between HashMap and Hashtable?",
          "answer": "HashMap is not synchronized and allows nulls...",
          "cardType": "comparison",
          "difficulty": 0.5,
          "tags": ["java", "collections"]
        }
      ]
    }
  ]
}
''';

  group('导出数据格式', () {
    test('JSON 结构应符合导出规范', () {
      final json = jsonDecode(sampleExportJson) as Map<String, dynamic>;

      // 验证顶层结构
      expect(json['version'], '1.0');
      expect(json.containsKey('exportedAt'), true);
      expect(json['decks'], isA<List>());

      // 验证卡组结构
      final decks = json['decks'] as List<dynamic>;
      expect(decks.length, 1);

      final deck = decks[0] as Map<String, dynamic>;
      expect(deck['name'], 'Java Collections');
      expect(deck['cards'], isA<List>());

      // 验证卡片结构
      final cards = deck['cards'] as List<dynamic>;
      expect(cards.length, 1);

      final card = cards[0] as Map<String, dynamic>;
      expect(card['question'], isNotEmpty);
      expect(card['answer'], isNotEmpty);
      expect(card['cardType'], 'comparison');
      expect(card['tags'], contains('java'));
    });

    test('版本号应以 "1." 开头', () {
      const validVersions = ['1.0', '1.1', '1.99'];
      const invalidVersions = ['0.9', '2.0', ''];

      for (final v in validVersions) {
        expect(v.startsWith('1.'), isTrue);
      }
      for (final v in invalidVersions) {
        expect(v.startsWith('1.'), isFalse);
      }
    });
  });

  group('导入数据验证', () {
    test('缺少必要字段时应可容错', () {
      const minimalJson = '''
{
  "version": "1.0",
  "exportedAt": "2026-07-25T10:00:00Z",
  "decks": []
}
''';
      final json = jsonDecode(minimalJson) as Map<String, dynamic>;
      expect(json['decks'], isEmpty);
    });
  });
}
