/// MemFlow 卡片数据模型
import 'package:isar/isar.dart';

part 'card.g.dart';

@collection
class Card {
  Id id = Isar.autoIncrement;

  /// 所属卡组 ID
  @Index()
  int deckId = 0;

  String question = '';
  String answer = '';
  @Index()
  String cardType = 'basic';
  String sourceUrl = '';
  double difficulty = 0.5;
  List<String> tags = [];
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Card({
    this.deckId = 0,
    this.question = '',
    this.answer = '',
    this.cardType = 'basic',
    this.sourceUrl = '',
    this.difficulty = 0.5,
    this.tags = const [],
  });
}
