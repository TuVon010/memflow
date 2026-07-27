/// MemFlow 每日复习队列生成器

import 'dart:math';
import '../data/models/card.dart';
import '../data/models/review_state.dart';
import '../data/models/user_settings.dart';

class ReviewItem {
  final Card card;
  final ReviewState? reviewState;

  bool get isNewCard => reviewState == null;

  ReviewItem({required this.card, this.reviewState});
}

class QueueGenerator {
  static const int defaultInterleaveRatio = 3;
  static const int interviewMaxNewCards = 50;

  List<ReviewItem> generate({
    required List<Card> dueCards,
    required List<ReviewState> dueStates,
    required List<Card> newCards,
    required UserSettings settings,
    Map<int, double> deckPriorities = const {},
    int? daysUntilInterview,
  }) {
    final stateMap = <int, ReviewState>{};
    for (final state in dueStates) {
      stateMap[state.cardId] = state;
    }

    final dueItems = <ReviewItem>[];
    for (final card in dueCards) {
      final state = stateMap[card.id];
      if (state != null) {
        dueItems.add(ReviewItem(card: card, reviewState: state));
      }
    }
    dueItems.sort((a, b) {
      final aDue = a.reviewState?.due ?? DateTime.now();
      final bDue = b.reviewState?.due ?? DateTime.now();
      return aDue.compareTo(bDue);
    });

    List<Card> sortedNewCards;
    if (settings.interviewModeEnabled) {
      sortedNewCards = List<Card>.from(newCards);
      sortedNewCards.sort((a, b) {
        final aScore = a.difficulty * 0.6;
        final bScore = b.difficulty * 0.6;
        final scoreCmp = bScore.compareTo(aScore);
        if (scoreCmp != 0) return scoreCmp;
        return a.createdAt.compareTo(b.createdAt);
      });
    } else {
      sortedNewCards = List<Card>.from(newCards)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    int newCardLimit = settings.dailyNewCardLimit;
    if (settings.interviewModeEnabled && daysUntilInterview != null && daysUntilInterview > 0) {
      final neededPerDay = (sortedNewCards.length / daysUntilInterview).ceil();
      newCardLimit = min(max(newCardLimit, neededPerDay), interviewMaxNewCards);
    }

    final todayNewCards = sortedNewCards.take(newCardLimit).toList();
    return _interleave(dueItems, todayNewCards, defaultInterleaveRatio);
  }

  List<ReviewItem> _interleave(
    List<ReviewItem> dueItems,
    List<Card> newCards,
    int ratio,
  ) {
    final result = <ReviewItem>[];
    int dueIndex = 0;
    int newIndex = 0;

    while (dueIndex < dueItems.length || newIndex < newCards.length) {
      for (int i = 0; i < ratio && dueIndex < dueItems.length; i++) {
        result.add(dueItems[dueIndex]);
        dueIndex++;
      }
      if (newIndex < newCards.length) {
        result.add(ReviewItem(card: newCards[newIndex]));
        newIndex++;
      }
    }

    return result;
  }
}
