/// MemFlow 导出/导入服务
///
/// 支持将卡组及其卡片序列化为 .mfcard.json 格式文件，
/// 以及从 JSON 文件导入卡组（深度复制，重新生成 ID，复习状态不导入）。

import 'dart:convert';
import '../data/models/deck.dart';
import '../data/models/card.dart' as model;

/// 导出数据格式
class ExportData {
  final String version;
  final String exportedAt;
  final List<ExportDeck> decks;

  ExportData({
    this.version = '1.0',
    String? exportedAt,
    this.decks = const [],
  }) : exportedAt = exportedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt,
        'decks': decks.map((d) => d.toJson()).toList(),
      };

  factory ExportData.fromJson(Map<String, dynamic> json) => ExportData(
        version: json['version'] as String? ?? '1.0',
        exportedAt: json['exportedAt'] as String?,
        decks: (json['decks'] as List<dynamic>?)
                ?.map(
                    (e) => ExportDeck.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

/// 导出的卡组数据
class ExportDeck {
  final String name;
  final String description;
  final int color;
  final List<ExportCard> cards;

  ExportDeck({
    required this.name,
    this.description = '',
    this.color = 0xFF4A90D9,
    this.cards = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'color': color,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory ExportDeck.fromJson(Map<String, dynamic> json) => ExportDeck(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        color: json['color'] as int? ?? 0xFF4A90D9,
        cards: (json['cards'] as List<dynamic>?)
                ?.map((e) =>
                    ExportCard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

/// 导出的卡片数据
class ExportCard {
  final String question;
  final String answer;
  final String cardType;
  final double difficulty;
  final List<String> tags;

  ExportCard({
    required this.question,
    required this.answer,
    this.cardType = 'basic',
    this.difficulty = 0.5,
    List<String>? tags,
  }) : tags = tags ?? [];

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'cardType': cardType,
        'difficulty': difficulty,
        'tags': tags,
      };

  factory ExportCard.fromJson(Map<String, dynamic> json) => ExportCard(
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        cardType: json['cardType'] as String? ?? 'basic',
        difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

/// 导入结果
class ImportResult {
  final int decksImported;
  final int cardsImported;
  final List<String> warnings;

  ImportResult({
    this.decksImported = 0,
    this.cardsImported = 0,
    List<String>? warnings,
  }) : warnings = warnings ?? [];
}

/// 导出服务—将卡组序列化为 JSON 字符串
class ExportService {
  /// 将卡组及其卡片导出为 .mfcard.json 格式字符串
  String exportToJson(Map<Deck, List<model.Card>> deckCardsMap) {
    final exportDecks = deckCardsMap.entries.map((entry) {
      final deck = entry.key;
      final cards = entry.value.map((card) => ExportCard(
            question: card.question,
            answer: card.answer,
            cardType: card.cardType,
            difficulty: card.difficulty,
            tags: card.tags,
          )).toList();

      return ExportDeck(
        name: deck.name,
        description: deck.description,
        color: deck.color,
        cards: cards,
      );
    }).toList();

    final data = ExportData(decks: exportDecks);
    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }

}

/// 导入服务—解析 JSON 并返回可供插入的数据结构
class ImportService {
  /// 解析 JSON 字符串为导出数据
  ExportData parseJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ExportData.fromJson(json);
  }

  /// 验证导入数据的版本兼容性
  bool isVersionCompatible(String version) {
    // MVP 阶段仅支持 1.x 版本
    return version.startsWith('1.');
  }
}
