/// MemFlow 卡组仓库
import 'package:isar/isar.dart';
import '../isar_service.dart';
import '../models/deck.dart';
import '../models/card.dart';
import '../models/review_state.dart';

class DeckRepo {
  final IsarService _isarService;
  Isar get _isar => _isarService.isar;

  DeckRepo(this._isarService);

  Future<int> createDeck(Deck deck) async {
    return await _isar.writeTxn(() async {
      return await _isar.decks.put(deck);
    });
  }

  Future<void> updateDeck(Deck deck) async {
    deck.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.decks.put(deck);
    });
  }

  Future<void> deleteDeck(int deckId) async {
    await _isar.writeTxn(() async {
      // 级联删除卡片和复习状态
      final cards = await _isar.cards
          .filter().deckIdEqualTo(deckId).findAll();
      for (final card in cards) {
        final state = await _isar.reviewStates
            .filter().cardIdEqualTo(card.id).findFirst();
        if (state != null) await _isar.reviewStates.delete(state.id);
      }
      await _isar.cards.filter().deckIdEqualTo(deckId).deleteAll();
      await _isar.decks.delete(deckId);
    });
  }

  Future<List<Deck>> getAll({bool includeArchived = false}) async {
    if (includeArchived) {
      return await _isar.decks.where().sortByCreatedAt().findAll();
    }
    return await _isar.decks
        .filter().isArchivedEqualTo(false).sortByCreatedAt().findAll();
  }

  Future<Deck?> getById(int id) async {
    return await _isar.decks.get(id);
  }

  Future<void> toggleArchive(int deckId, bool archive) async {
    await _isar.writeTxn(() async {
      final deck = await _isar.decks.get(deckId);
      if (deck != null) {
        deck.isArchived = archive;
        deck.updatedAt = DateTime.now();
        await _isar.decks.put(deck);
      }
    });
  }

  /// 获取某个卡组的卡片数量
  Future<int> getCardCount(int deckId) async {
    return await _isar.cards.filter().deckIdEqualTo(deckId).count();
  }
}
