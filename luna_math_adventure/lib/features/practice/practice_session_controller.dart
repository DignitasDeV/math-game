import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/exercise.dart';
import '../../models/exercise_template.dart';
import '../../models/level_config.dart';
import '../../models/localized_text.dart';
import '../../models/operation_candidate.dart';
import '../../models/visual_item.dart';
import '../../services/content_repository.dart';
import '../../services/exercise_generator.dart';
import '../../services/exercise_pool_generator.dart';
import '../../services/profile_controller.dart';

enum PracticeTopic {
  count,
  addition,
  subtraction,
  mixed;

  List<String> get exerciseTypes {
    return switch (this) {
      PracticeTopic.count => const ['count'],
      PracticeTopic.addition => const ['addition'],
      PracticeTopic.subtraction => const ['subtraction'],
      PracticeTopic.mixed => const ['count', 'addition', 'subtraction'],
    };
  }

  String title(String languageCode) {
    if (languageCode == 'ca-ES') {
      return switch (this) {
        PracticeTopic.count => 'Comptar',
        PracticeTopic.addition => 'Sumar',
        PracticeTopic.subtraction => 'Restar',
        PracticeTopic.mixed => 'Barreja',
      };
    }

    return switch (this) {
      PracticeTopic.count => 'Contar',
      PracticeTopic.addition => 'Sumar',
      PracticeTopic.subtraction => 'Restar',
      PracticeTopic.mixed => 'Mezcla',
    };
  }
}

enum PracticeDifficulty {
  upTo5(5, 4),
  upTo10(10, 7),
  upTo20(20, 13);

  const PracticeDifficulty(this.maxNumber, this.practiceSortOrder);

  final int maxNumber;
  final int practiceSortOrder;

  String label(String languageCode) {
    return languageCode == 'ca-ES'
        ? '1-$maxNumber'
        : '1-$maxNumber';
  }
}

class PracticeSessionConfig {
  const PracticeSessionConfig({
    required this.topic,
    required this.difficulty,
  });

  final PracticeTopic topic;
  final PracticeDifficulty difficulty;
}

class PracticeSessionState {
  const PracticeSessionState({
    required this.config,
    required this.exercise,
    required this.questionIndex,
    required this.correctAnswers,
    this.selectedAnswer,
    this.isCorrect,
    this.hasAskedHint = false,
    this.isComplete = false,
  });

  final PracticeSessionConfig config;
  final Exercise exercise;
  final int questionIndex;
  final int correctAnswers;
  final int? selectedAnswer;
  final bool? isCorrect;
  final bool hasAskedHint;
  final bool isComplete;

  int get questionsToComplete => practiceQuestionsToComplete;

  PracticeSessionState copyWith({
    Exercise? exercise,
    int? questionIndex,
    int? correctAnswers,
    int? selectedAnswer,
    bool? isCorrect,
    bool? hasAskedHint,
    bool? isComplete,
    bool clearAnswer = false,
  }) {
    return PracticeSessionState(
      config: config,
      exercise: exercise ?? this.exercise,
      questionIndex: questionIndex ?? this.questionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      selectedAnswer: clearAnswer ? null : selectedAnswer ?? this.selectedAnswer,
      isCorrect: clearAnswer ? null : isCorrect ?? this.isCorrect,
      hasAskedHint: clearAnswer ? false : hasAskedHint ?? this.hasAskedHint,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

const practiceQuestionsToComplete = 8;

final practiceSessionProvider = StateNotifierProvider.autoDispose<
    PracticeSessionController, AsyncValue<PracticeSessionState?>>((ref) {
  return PracticeSessionController(ref);
});

class PracticeSessionController
    extends StateNotifier<AsyncValue<PracticeSessionState?>> {
  PracticeSessionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  final _random = Random();
  final _poolGenerator = const ExercisePoolGenerator();
  final _recentKeys = <String>[];

  late PracticeSessionConfig _config;
  late LevelConfig _level;
  late List<ExerciseTemplate> _templates;
  late List<VisualItem> _visualItems;
  late List<OperationCandidate> _pool;

  Future<void> start(PracticeSessionConfig config) async {
    state = const AsyncValue.loading();
    _config = config;
    _level = buildPracticeLevel(config);
    _recentKeys.clear();

    try {
      final content = _ref.read(contentRepositoryProvider);
      _templates = await content.loadExerciseTemplates();
      _visualItems = await content.loadVisualItems();
      _pool = _createShuffledPool();

      state = AsyncValue.data(
        PracticeSessionState(
          config: _config,
          exercise: _nextExercise(),
          questionIndex: 1,
          correctAnswers: 0,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> repeat() async {
    final config = state.valueOrNull?.config;
    if (config == null) {
      return;
    }

    await start(config);
  }

  void changePractice() {
    state = const AsyncValue.data(null);
  }

  void submitAnswer(int answer) {
    final current = state.valueOrNull;
    if (current == null ||
        current.selectedAnswer != null ||
        current.isComplete) {
      return;
    }

    final isCorrect = answer == current.exercise.answer;
    state = AsyncValue.data(
      current.copyWith(
        selectedAnswer: answer,
        isCorrect: isCorrect,
        correctAnswers:
            isCorrect ? current.correctAnswers + 1 : current.correctAnswers,
      ),
    );
  }

  void showHint() {
    final current = state.valueOrNull;
    if (current == null ||
        current.isComplete ||
        current.selectedAnswer != null) {
      return;
    }

    state = AsyncValue.data(current.copyWith(hasAskedHint: true));
  }

  void nextExercise() {
    final current = state.valueOrNull;
    if (current == null ||
        current.isComplete ||
        current.selectedAnswer == null) {
      return;
    }

    if (current.questionIndex >= current.questionsToComplete) {
      state = AsyncValue.data(current.copyWith(isComplete: true));
      return;
    }

    state = AsyncValue.data(
      current.copyWith(
        exercise: _nextExercise(),
        questionIndex: current.questionIndex + 1,
        clearAnswer: true,
      ),
    );
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
}

LevelConfig buildPracticeLevel(PracticeSessionConfig config) {
  final maxNumber = config.difficulty.maxNumber;
  return LevelConfig(
    id: 'practice_${config.topic.name}_${maxNumber}',
    worldId: 'practice',
    title: LocalizedText(
      es: config.topic.title('es-ES'),
      ca: config.topic.title('ca-ES'),
    ),
    subtitle: LocalizedText(
      es: 'Práctica libre 1-$maxNumber',
      ca: 'Pràctica lliure 1-$maxNumber',
    ),
    exerciseTypes: config.topic.exerciseTypes,
    minNumber: 1,
    maxNumber: maxNumber,
    maxResult: maxNumber,
    allowNegativeResults: false,
    allowCarry: maxNumber > 10,
    visualSupport: true,
    questionsToComplete: practiceQuestionsToComplete,
    starsToUnlockNext: 1,
    rewardId: null,
    visualItemIds: const [
      'heart_pink',
      'star_yellow',
      'flower_blue',
      'cupcake_pink',
      'cloud_white',
      'gem_purple',
    ],
    sortOrder: config.difficulty.practiceSortOrder,
  );
}
