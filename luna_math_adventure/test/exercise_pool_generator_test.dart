import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/services/exercise_pool_generator.dart';

void main() {
  test('decomposition only creates candidates from 10 upwards', () {
    final candidates = const ExercisePoolGenerator().generate(
      _level(
        exerciseTypes: const ['decomposition'],
        minNumber: 1,
        maxNumber: 20,
        maxResult: 9,
      ),
    );

    expect(candidates, isNotEmpty);
    expect(candidates.every((candidate) => candidate.left >= 10), isTrue);
    expect(candidates.firstWhere((candidate) => candidate.left == 14).right, 1);
    expect(
      candidates.firstWhere((candidate) => candidate.left == 14).result,
      4,
    );
    expect(
      candidates.firstWhere((candidate) => candidate.left == 14).key,
      'decompose:14',
    );
  });

  test('addition respects max result and carry flag', () {
    final candidates = const ExercisePoolGenerator().generate(
      _level(
        exerciseTypes: const ['addition'],
        minNumber: 10,
        maxNumber: 20,
        maxResult: 30,
        allowCarry: false,
      ),
    );

    expect(candidates, isNotEmpty);
    expect(candidates.every((candidate) => candidate.result <= 30), isTrue);
    expect(
      candidates.every(
        (candidate) =>
            (candidate.left % 10) + (candidate.right % 10) < 10,
      ),
      isTrue,
    );
  });
}

LevelConfig _level({
  required List<String> exerciseTypes,
  required int minNumber,
  required int maxNumber,
  int? maxResult,
  bool allowCarry = false,
}) {
  return LevelConfig(
    id: 'test_level',
    worldId: 'test_world',
    title: const LocalizedText(es: 'Test', ca: 'Test'),
    subtitle: const LocalizedText(es: 'Test', ca: 'Test'),
    exerciseTypes: exerciseTypes,
    minNumber: minNumber,
    maxNumber: maxNumber,
    maxResult: maxResult,
    allowNegativeResults: false,
    allowCarry: allowCarry,
    visualSupport: false,
    questionsToComplete: 5,
    starsToUnlockNext: 1,
    rewardId: null,
    visualItemIds: const ['heart_pink'],
    sortOrder: 1,
  );
}
