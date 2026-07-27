/// MemFlow 卡片仓库
import 'package:isar/isar.dart';
import '../isar_service.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/review_state.dart';

class CardRepo {
  final IsarService _isarService;
  Isar get _isar => _isarService.isar;

  CardRepo(this._isarService);

  /// 创建新卡片并写入 deckId
  Future<int> createCard(Card card) async {
    return await _isar.writeTxn(() async {
      final cardId = await _isar.cards.put(card);
      final reviewState = ReviewState(cardId: cardId);
      reviewState.due = DateTime.now().subtract(const Duration(days: 1));
      await _isar.reviewStates.put(reviewState);
      return cardId;
    });
  }

  /// 批量创建卡片到指定卡组
  Future<void> createCardsToDeck(List<Card> cards, int deckId) async {
    await _isar.writeTxn(() async {
      // 先确认卡组存在
      final deck = await _isar.decks.get(deckId);
      if (deck == null) throw Exception('卡组不存在 (id=$deckId)');

      for (final card in cards) {
        card.deckId = deckId;
        final cardId = await _isar.cards.put(card);

        final reviewState = ReviewState(cardId: cardId);
        reviewState.due = DateTime.now().subtract(const Duration(days: 1));
        await _isar.reviewStates.put(reviewState);
      }
    });
  }

  Future<void> updateCard(Card card) async {
    card.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.cards.put(card);
    });
  }

  Future<void> deleteCard(int cardId) async {
    await _isar.writeTxn(() async {
      final state = await _isar.reviewStates
          .filter().cardIdEqualTo(cardId).findFirst();
      if (state != null) {
        await _isar.reviewStates.delete(state.id);
      }
      await _isar.cards.delete(cardId);
    });
  }

  Future<void> deleteCards(List<int> cardIds) async {
    await _isar.writeTxn(() async {
      for (final id in cardIds) {
        final state = await _isar.reviewStates
            .filter().cardIdEqualTo(id).findFirst();
        if (state != null) await _isar.reviewStates.delete(state.id);
        await _isar.cards.delete(id);
      }
    });
  }

  /// 获取指定卡组的所有卡片
  Future<List<Card>> getByDeck(int deckId) async {
    return await _isar.cards
        .filter()
        .deckIdEqualTo(deckId)
        .sortByCreatedAt()
        .findAll();
  }

  Future<Card?> getById(int id) async {
    return await _isar.cards.get(id);
  }

  /// 获取卡片总数
  Future<int> getCount({int? deckId}) async {
    final q = _isar.cards.filter();
    if (deckId != null) {
      return await q.deckIdEqualTo(deckId).count();
    }
    return await _isar.cards.count();
  }
}
