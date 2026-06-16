import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/exercise.dart';
import '../../models/exercise_template.dart';
import '../../models/level_config.dart';
import '../../models/operation_candidate.dart';
import '../../models/visual_item.dart';
import '../../services/content_repository.dart';
import '../../services/exercise_generator.dart';
import '../../services/exercise_pool_generator.dart';
import '../../services/profile_controller.dart';
import '../../services/progress_repository.dart';

class GameSessionState {
  const GameSessionState({
    required this.level,
    required this.exercise,
    required this.questionIndex,
    required this.correctAnswers,
    this.selectedAnswer,
    this.isCorrect,
    this.isComplete = false,
    this.hasAskedHint = false,
    this.isAdvancing = false,
    this.starsEarned = 0,
    this.newRewardId,
    this.nextLevelId,
  });

  final LevelConfig level;
  final Exercise exercise;
  final int questionIndex;
  final int correctAnswers;
  final int? selectedAnswer;
  final bool? isCorrect;
  final bool isComplete;
  final bool hasAskedHint;
  final bool isAdvancing;
  final int starsEarned;
  final String? newRewardId;
  final String? nextLevelId;

  int get questionsToComplete => level.questionsToComplete;

  GameSessionState copyWith({
    Exercise? exercise,
    int? questionIndex,
    int? correctAnswers,
    int? selectedAnswer,
    bool? isCorrect,
    bool clearAnswer = false,
    bool? isComplete,
    bool? hasAskedHint,
    bool? isAdvancing,
    int? starsEarned,
    String? newRewardId,
    String? nextLevelId,
  }) {
    return GameSessionState(
      level: level,
      exercise: exercise ?? this.exercise,
      questionIndex: questionIndex ?? this.questionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      selectedAnswer: clearAnswer ? null : selectedAnswer ?? this.selectedAnswer,
      isCorrect: clearAnswer ? null : isCorrect ?? this.isCorrect,
      isComplete: isComplete ?? this.isComplete,
      hasAskedHint: clearAnswer ? false : hasAskedHint ?? this.hasAskedHint,
      isAdvancing: isAdvancing ?? this.isAdvancing,
      starsEarned: starsEarned ?? this.starsEarned,
      newRewardId: newRewardId ?? this.newRewardId,
      nextLevelId: nextLevelId ?? this.nextLevelId,
    );
  }
}

final gameSessionProvider = StateNotifierProvider.family<
    GameSessionController,
    AsyncValue<GameSessionState>,
    String>((ref, levelId) {
  final controller = GameSessionController(ref, levelId);
  controller.load();
  return controller;
});

class GameSessionController extends StateNotifier<AsyncValue<GameSessionState>> {
  GameSessionController(this._ref, this._levelId)
      : super(const AsyncValue.loading());

  final Ref _ref;
  final String _levelId;
  final _random = Random();
  final _poolGenerator = const ExercisePoolGenerator();
  final _recentKeys = <String>[];

  late LevelConfig _level;
  late List<ExerciseTemplate> _templates;
  late List<VisualItem> _visualItems;
  late List<OperationCandidate> _pool;

  Future<void> load() async {
    try {
      final content = _ref.read(contentRepositoryProvider);
      final level = await content.loadLevel(_levelId);
      if (level == null) {
        throw StateError('Level not found: $_levelId');
      }

      _level = level;
      _templates = await content.loadExerciseTemplates();
      _visualItems = await content.loadVisualItems();
      _pool = _createShuffledPool();

      state = AsyncValue.data(
        GameSessionState(
          level: _level,
          exercise: _nextExercise(),
          questionIndex: 1,
          correctAnswers: 0,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> repeatLevel() async {
    _recentKeys.clear();
    state = const AsyncValue.loading();
    await load();
  }

  void submitAnswer(int answer) {
    final current = state.valueOrNull;
    if (current == null || current.selectedAnswer != null || current.isComplete) {
      return;
    }

    final isCorrect = answer == current.exercise.answer;
    state = AsyncValue.data(
      current.copyWith(
        selectedAnswer: answer,
        isCorrect: isCorrect,
        correctAnswers: isCorrect
            ? current.correctAnswers + 1
            : current.correctAnswers,
      ),
    );
  }

  void showHint() {
    final current = state.valueOrNull;
    if (current == null ||
        current.isComplete ||
        current.selectedAnswer != null ||
        current.isAdvancing) {
      return;
    }

    state = AsyncValue.data(current.copyWith(hasAskedHint: true));
  }

  Future<void> nextExercise() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isAdvancing ||
        current.isComplete ||
        current.selectedAnswer == null) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isAdvancing: true));

    try {
      if (current.questionIndex >= current.questionsToComplete) {
        final result = await _completeLevel(current);
        state = AsyncValue.data(
          current.copyWith(
            isComplete: true,
            isAdvancing: false,
            starsEarned: result.starsEarned,
            newRewardId: result.newRewardId,
            nextLevelId: result.nextLevelId,
          ),
        );
        return;
      }

      state = AsyncValue.data(
        current.copyWith(
          exercise: _nextExercise(),
          questionIndex: current.questionIndex + 1,
          clearAnswer: true,
          isAdvancing: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<OperationCandidate> _createShuffledPool() {
    final pool = _poolGenerator.generate(_level);
    pool.shuffle(_random);
    return pool;
  }

  Exercise _nextExercise() {
    if (_pool.isEmpty) {
      _pool = _createShuffledPool();
    }

    var candidateIndex = _pool.indexWhere(
      (candidate) => !_recentKeys.contains(candidate.key),
    );
    if (candidateIndex == -1) {
      _recentKeys.clear();
      candidateIndex = 0;
    }

    final candidate = _pool.removeAt(candidateIndex);
    _markRecent(candidate);

    return _ref.read(exerciseGeneratorProvider).buildExercise(
          level: _level,
          operation: candidate,
          templates: _templates,
          visualItems: _visualItems,
          profile: _ref.read(activeProfileProvider),
        );
  }

  void _markRecent(OperationCandidate candidate) {
    _recentKeys.add(candidate.key);
    if (_recentKeys.length > 10) {
      _recentKeys.removeAt(0);
    }
  }

  Future<_LevelCompletionResult> _completeLevel(GameSessionState current) async {
    final profile = _ref.read(activeProfileProvider);
    if (profile == null) {
      return _LevelCompletionResult(
        starsEarned: _starsFor(
          current.correctAnswers,
          current.questionsToComplete,
        ),
      );
    }

    final content = _ref.read(contentRepositoryProvider);
    final levels = await content.loadLevels();
    final nextLevel = _nextLevelInAdventure(levels);
    final stars = _starsFor(
      current.correctAnswers,
      current.questionsToComplete,
    );

    final repository = _ref.read(progressRepositoryProvider);
    final progress = await repository.loadProgress(profile.id);
    final unlockedLevelIds = {
      ...progress.unlockedLevelIds,
      _level.id,
    };
    final completedLevelIds = {
      ...progress.completedLevelIds,
      _level.id,
    };
    final alreadyEarnedRewardIds = progress.earnedRewardIds.toSet();
    final newRewardId = switch (_level.rewardId) {
      final rewardId? when !alreadyEarnedRewardIds.contains(rewardId) =>
        rewardId,
      _ => null,
    };
    final earnedRewardIds = {
      ...alreadyEarnedRewardIds,
      if (_level.rewardId case final rewardId?) rewardId,
    };
    final starsByLevel = {
      ...progress.starsByLevel,
      _level.id: max(progress.starsByLevel[_level.id] ?? 0, stars),
    };

    String? unlockedNextLevelId;
    if (nextLevel != null && stars >= _level.starsToUnlockNext) {
      unlockedLevelIds.add(nextLevel.id);
      unlockedNextLevelId = nextLevel.id;
    }

    final nextProgress = progress.copyWith(
      unlockedLevelIds: unlockedLevelIds.toList(growable: false),
      completedLevelIds: completedLevelIds.toList(growable: false),
      starsByLevel: starsByLevel,
      lastLevelId: unlockedNextLevelId ?? _level.id,
      earnedRewardIds: earnedRewardIds.toList(growable: false),
    );

    await repository.saveProgress(nextProgress);
    _ref.invalidate(activeProgressProvider);
    return _LevelCompletionResult(
      starsEarned: stars,
      newRewardId: newRewardId,
      nextLevelId: unlockedNextLevelId,
    );
  }

  LevelConfig? _nextLevelInAdventure(List<LevelConfig> levels) {
    final adventureLevels = levels.toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final level in adventureLevels) {
      if (level.sortOrder > _level.sortOrder) {
        return level;
      }
    }

    return null;
  }

  int _starsFor(int correctAnswers, int totalQuestions) {
    if (totalQuestions <= 0) {
      return 1;
    }

    final ratio = correctAnswers / totalQuestions;
    if (ratio >= 0.9) {
      return 3;
    }
    if (ratio >= 0.6) {
      return 2;
    }

    return 1;
  }
}

class _LevelCompletionResult {
  const _LevelCompletionResult({
    required this.starsEarned,
    this.newRewardId,
    this.nextLevelId,
  });

  final int starsEarned;
  final String? newRewardId;
  final String? nextLevelId;
}
