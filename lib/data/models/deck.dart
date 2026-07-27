/// MemFlow 卡组数据模型
import 'package:isar/isar.dart';

part 'deck.g.dart';

@collection
class Deck {
  Id id = Isar.autoIncrement;

  @Index()
  String name = '';

  String description = '';
  int color = 0xFF4A90D9;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isArchived = false;
  double priority = 0.0;
  List<String> tags = [];

  Deck({
    this.name = '',
    this.description = '',
    this.color = 0xFF4A90D9,
    this.isArchived = false,
    this.priority = 0.0,
    this.tags = const [],
  });
}
