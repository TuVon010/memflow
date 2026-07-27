/// MemFlow 全局 Riverpod Providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/isar_service.dart';
import 'data/repositories/deck_repo.dart';
import 'data/repositories/card_repo.dart';
import 'data/repositories/review_repo.dart';
import 'data/repositories/settings_repo.dart';
import 'data/models/deck.dart';
import 'data/models/card.dart';
import 'data/models/review_state.dart';
import 'data/models/user_settings.dart';
import 'engine/scheduler.dart';
import 'engine/queue_generator.dart';
import 'engine/interview_planner.dart';
import 'services/ai_service.dart';
import 'services/secure_storage_service.dart';
import 'services/notification_service.dart';
import 'services/export_service.dart';

// ============================================================
// 基础设施 Providers
// ============================================================

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('IsarService 必须在 main.dart 中通过 override 注入');
});

final schedulerProvider = Provider<Scheduler>((ref) => SM2Scheduler());
final queueGeneratorProvider = Provider<QueueGenerator>((ref) => QueueGenerator());
final interviewPlannerProvider = Provider<InterviewPlanner>((ref) => InterviewPlanner());
final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());
final importServiceProvider = Provider<ImportService>((ref) => ImportService());

// ============================================================
// Repository Providers
// ============================================================

final deckRepoProvider = Provider<DeckRepo>((ref) {
  return DeckRepo(ref.watch(isarServiceProvider));
});

final cardRepoProvider = Provider<CardRepo>((ref) {
  return CardRepo(ref.watch(isarServiceProvider));
});

final reviewRepoProvider = Provider<ReviewRepo>((ref) {
  return ReviewRepo(ref.watch(isarServiceProvider));
});

final settingsRepoProvider = Provider<SettingsRepo>((ref) {
  return SettingsRepo(ref.watch(isarServiceProvider));
});

// ============================================================
// AI Service Provider
// ============================================================

final aiServiceProvider = Provider<AIService?>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null) return null;

  final apiKey = ref.watch(apiKeyProvider).valueOrNull;
  if (apiKey == null || apiKey.isEmpty) return null;

  return OpenAIService(
    apiKey: apiKey,
    baseUrl: settings.llmBaseURL,
    model: settings.llmModel,
  );
});

final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.getApiKey();
});

// ============================================================
// Settings Provider
// ============================================================

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final repo = ref.watch(settingsRepoProvider);
    return await repo.get();
  }

  Future<void> saveSettings(UserSettings settings) async {
    final repo = ref.watch(settingsRepoProvider);
    await repo.update(settings);
    state = AsyncData(settings);
  }

  Future<void> updateAIConfig({
    required String provider,
    required String baseUrl,
    required String model,
  }) async {
    final repo = ref.watch(settingsRepoProvider);
    await repo.setAIConfig(provider: provider, baseUrl: baseUrl, model: model);
    state = AsyncData(await repo.get());
  }

  Future<void> setInterviewMode({
    required bool enabled,
    DateTime? interviewDate,
  }) async {
    final repo = ref.watch(settingsRepoProvider);
    await repo.setInterviewMode(enabled: enabled, interviewDate: interviewDate);
    state = AsyncData(await repo.get());
  }
}

// ============================================================
// Deck Providers
// ============================================================

final deckListProvider = AsyncNotifierProvider<DeckListNotifier, List<Deck>>(
  DeckListNotifier.new,
);

class DeckListNotifier extends AsyncNotifier<List<Deck>> {
  @override
  Future<List<Deck>> build() async {
    final repo = ref.watch(deckRepoProvider);
    return await repo.getAll();
  }

  Future<void> refresh() async {
    final repo = ref.watch(deckRepoProvider);
    state = AsyncData(await repo.getAll());
  }

  Future<void> createDeck(Deck deck) async {
    final repo = ref.watch(deckRepoProvider);
    await repo.createDeck(deck);
    await refresh();
  }

  Future<void> deleteDeck(int deckId) async {
    final repo = ref.watch(deckRepoProvider);
    await repo.deleteDeck(deckId);
    await refresh();
  }

  Future<void> toggleArchive(int deckId, bool archive) async {
    final repo = ref.watch(deckRepoProvider);
    await repo.toggleArchive(deckId, archive);
    await refresh();
  }
}

// ============================================================
// Card Providers
// ============================================================

final cardsOfDeckProvider =
    FutureProvider.family<List<Card>, int>((ref, deckId) async {
  final repo = ref.watch(cardRepoProvider);
  return await repo.getByDeck(deckId);
});

// ============================================================
// Review Providers
// ============================================================

class ReviewQueueState {
  final List<ReviewItem> queue;
  final int currentIndex;
  final bool isCompleted;
  final int totalCards;
  final int reviewedCount;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final Duration elapsedTime;

  ReviewQueueState({
    this.queue = const [],
    this.currentIndex = 0,
    this.isCompleted = false,
    this.totalCards = 0,
    this.reviewedCount = 0,
    this.againCount = 0,
    this.hardCount = 0,
    this.goodCount = 0,
    this.elapsedTime = Duration.zero,
  });

  ReviewItem? get currentCard =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  double get progress =>
      totalCards > 0 ? reviewedCount / totalCards : 0.0;

  double get retentionRate =>
      reviewedCount > 0 ? (goodCount + hardCount) / reviewedCount : 0.0;

  ReviewQueueState copyWith({
    List<ReviewItem>? queue,
    int? currentIndex,
    bool? isCompleted,
    int? totalCards,
    int? reviewedCount,
    int? againCount,
    int? hardCount,
    int? goodCount,
    Duration? elapsedTime,
  }) {
    return ReviewQueueState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      totalCards: totalCards ?? this.totalCards,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      againCount: againCount ?? this.againCount,
      hardCount: hardCount ?? this.hardCount,
      goodCount: goodCount ?? this.goodCount,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }
}

final reviewQueueProvider =
    StateNotifierProvider<ReviewQueueNotifier, ReviewQueueState>(
  ReviewQueueNotifier.new,
);

class ReviewQueueNotifier extends StateNotifier<ReviewQueueState> {
  final Ref _ref;
  DateTime? _sessionStart;

  ReviewQueueNotifier(this._ref) : super(ReviewQueueState());

  /// 使用自定义队列（卡片选择模式）
  void setCustomQueue(ReviewQueueState qs) => state = qs;

  Future<void> generateQueue() async {
    state = ReviewQueueState();
    _sessionStart = DateTime.now();

    final cardRepo = _ref.read(cardRepoProvider);
    final reviewRepo = _ref.read(reviewRepoProvider);
    final settings = await _ref.read(settingsRepoProvider).get();

    final dueStates = await reviewRepo.getDueStates();
    final dueCardIds = dueStates.map((s) => s.cardId).toList();
    final dueCards = <Card>[];
    for (final id in dueCardIds) {
      final card = await cardRepo.getById(id);
      if (card != null) dueCards.add(card);
    }

    // 拉取所有卡组的所有卡片
    final allCards = <Card>[];
    final decks = await _ref.read(deckRepoProvider).getAll();
    for (final deck in decks) {
      if (!deck.isArchived) {
        allCards.addAll(await cardRepo.getByDeck(deck.id));
      }
    }

    // 筛选新卡片（从未学过的）
    final newCardIds = dueStates.map((s) => s.cardId).toSet();
    final newCards = allCards.where((c) => !newCardIds.contains(c.id)).toList();

    final generator = _ref.read(queueGeneratorProvider);
    var queue = generator.generate(
      dueCards: dueCards,
      dueStates: dueStates,
      newCards: newCards,
      settings: settings,
    );

    // 自由复习：无到期卡片时，把所有卡片都放进队列
    if (queue.isEmpty && allCards.isNotEmpty) {
      queue = allCards.map((c) => ReviewItem(card: c)).toList();
    }

    state = state.copyWith(
      queue: queue,
      totalCards: queue.length,
    );
  }

  Future<void> submitRating(Rating rating, {int elapsedMs = 0}) async {
    final current = state.currentCard;
    if (current == null || state.isCompleted) return;

    final reviewRepo = _ref.read(reviewRepoProvider);
    final scheduler = _ref.read(schedulerProvider);
    final settings = await _ref.read(settingsRepoProvider).get();

    ReviewState? reviewState = current.reviewState;
    reviewState ??= await reviewRepo.getByCardId(current.card.id);

    // 新卡片没有 ReviewState，创建一个
    if (reviewState == null) {
      reviewState = ReviewState(cardId: current.card.id);
      reviewState.due = DateTime.now().subtract(const Duration(days: 1));
    }

    // SM-2 调度
    final result = scheduler.schedule(
      ef: reviewState.difficultyFactor,
      interval: reviewState.stability.round(),
      repetitions: reviewState.reps,
      rating: rating,
      interviewMode: settings.interviewModeEnabled,
      cardPriority: settings.interviewModeEnabled ? current.card.difficulty : 0.0,
    );

    reviewState.difficultyFactor = result.difficultyFactor;
    reviewState.stability = result.interval.toDouble();
    reviewState.reps = result.repetitions;
    reviewState.due = result.due;
    if (rating == Rating.again) reviewState.lapses++;

    await reviewRepo.updateAfterReview(reviewState, rating: rating.ratingIndex, elapsedMs: elapsedMs);

    // 一次 copyWith 搞定所有变更（之前分两次调用导致 currentIndex 被覆盖）
    final newAgain = state.againCount + (rating == Rating.again ? 1 : 0);
    final newHard = state.hardCount + (rating == Rating.hard ? 1 : 0);
    final newGood = state.goodCount + (rating == Rating.good ? 1 : 0);
    final newIdx = state.currentIndex + 1;

    state = state.copyWith(
      currentIndex: newIdx,
      reviewedCount: state.reviewedCount + 1,
      againCount: newAgain,
      hardCount: newHard,
      goodCount: newGood,
      elapsedTime: _sessionStart != null
          ? DateTime.now().difference(_sessionStart!)
          : Duration.zero,
      isCompleted: newIdx >= state.queue.length,
    );
  }
}

// ============================================================
// AI Generate Providers
// ============================================================

enum AIGenerateStatus { idle, loading, success, error }

class AIGenerateState {
  final AIGenerateStatus status;
  final String inputText;
  final List<CardPreview> previewCards;
  final String? errorMessage;

  AIGenerateState({
    this.status = AIGenerateStatus.idle,
    this.inputText = '',
    this.previewCards = const [],
    this.errorMessage,
  });

  AIGenerateState copyWith({
    AIGenerateStatus? status,
    String? inputText,
    List<CardPreview>? previewCards,
    String? errorMessage,
  }) {
    return AIGenerateState(
      status: status ?? this.status,
      inputText: inputText ?? this.inputText,
      previewCards: previewCards ?? this.previewCards,
      errorMessage: errorMessage,
    );
  }
}

final aiGenerateProvider =
    StateNotifierProvider<AIGenerateNotifier, AIGenerateState>(
  AIGenerateNotifier.new,
);

class AIGenerateNotifier extends StateNotifier<AIGenerateState> {
  final Ref _ref;

  AIGenerateNotifier(this._ref) : super(AIGenerateState());

  void setInputText(String text) {
    state = state.copyWith(inputText: text);
  }

  Future<void> generate() async {
    final aiService = _ref.read(aiServiceProvider);
    if (aiService == null) {
      state = state.copyWith(
        status: AIGenerateStatus.error,
        errorMessage: '请先在设置中配置 AI API Key',
      );
      return;
    }

    if (state.inputText.trim().isEmpty) {
      state = state.copyWith(
        status: AIGenerateStatus.error,
        errorMessage: '请输入要生成卡片的文本',
      );
      return;
    }

    state = state.copyWith(status: AIGenerateStatus.loading);

    try {
      final cards = await aiService.generateCards(state.inputText);
      state = state.copyWith(
        status: AIGenerateStatus.success,
        previewCards: cards,
      );
    } on AIServiceException catch (e) {
      state = state.copyWith(
        status: AIGenerateStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AIGenerateStatus.error,
        errorMessage: '生成失败: ${e.toString()}',
      );
    }
  }

  void removePreviewCard(int index) {
    final cards = List<CardPreview>.from(state.previewCards);
    if (index < cards.length) {
      cards.removeAt(index);
      state = state.copyWith(previewCards: cards);
    }
  }

  void reset() {
    state = AIGenerateState();
  }
}

// ============================================================
// Stats Provider
// ============================================================

class LearningStats {
  final int todayReviewCount;
  final int streakDays;
  final double retentionRate;
  final Map<String, int> dailyReviewCounts;

  LearningStats({
    this.todayReviewCount = 0,
    this.streakDays = 0,
    this.retentionRate = 0.0,
    this.dailyReviewCounts = const {},
  });
}

final statsProvider = FutureProvider<LearningStats>((ref) async {
  final reviewRepo = ref.watch(reviewRepoProvider);

  final todayCount = await reviewRepo.getTodayReviewedCount();
  final streak = await reviewRepo.getStreakDays();
  final retention = await reviewRepo.getEstimatedRetention();
  final dailyCounts = await reviewRepo.getDailyReviewCounts(30);

  return LearningStats(
    todayReviewCount: todayCount,
    streakDays: streak,
    retentionRate: retention,
    dailyReviewCounts: dailyCounts,
  );
});

// ============================================================
// AI Explain Provider
// ============================================================

class AIExplainState {
  final bool isLoading;
  final String? explanation;
  final String? errorMessage;

  AIExplainState({this.isLoading = false, this.explanation, this.errorMessage});
}

final aiExplainProvider =
    StateNotifierProvider<AIExplainNotifier, AIExplainState>(
  AIExplainNotifier.new,
);

class AIExplainNotifier extends StateNotifier<AIExplainState> {
  final Ref _ref;

  AIExplainNotifier(this._ref) : super(AIExplainState());

  Future<void> explain({
    required String selectedText,
    required String question,
    required String answer,
  }) async {
    final aiService = _ref.read(aiServiceProvider);
    if (aiService == null) {
      state = AIExplainState(errorMessage: '请先在设置中配置 AI API Key');
      return;
    }

    state = AIExplainState(isLoading: true);

    try {
      final result = await aiService.explain(selectedText, question, answer);
      state = AIExplainState(explanation: result);
    } on AIServiceException catch (e) {
      state = AIExplainState(errorMessage: e.message);
    } catch (e) {
      state = AIExplainState(errorMessage: '答疑失败: ${e.toString()}');
    }
  }

  void reset() {
    state = AIExplainState();
  }
}
