import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/services/exercise_session_planner.dart';

void main() {
  test('avoids recently used operation keys while alternatives exist', () {
    final planner = ExerciseSessionPlanner(
      level: _level(
        exerciseTypes: const ['addition'],
        minNumber: 1,
        maxNumber: 5,
        maxResult: 5,
      ),
      random: Random(1),
    );

    final keys = [
      for (var index = 0; index < 6; index++) planner.next().key,
    ];

    expect(keys.toSet(), hasLength(keys.length));
  });

  test('balances mixed sessions across configured exercise types', () {
    final planner = ExerciseSessionPlanner(
      level: _level(
        exerciseTypes: const ['count', 'addition', 'subtraction'],
        minNumber: 1,
        maxNumber: 5,
        maxResult: 5,
      ),
      random: Random(1),
    );

    final types = [
      for (var index = 0; index < 6; index++) planner.next().type,
    ];

    expect(types.where((type) => type == 'count'), hasLength(2));
    expect(types.where((type) => type == 'addition'), hasLength(2));
    expect(types.where((type) => type == 'subtraction'), hasLength(2));
  });

  test('prefers non-zero answers while subtraction alternatives exist', () {
    final planner = ExerciseSessionPlanner(
      level: _level(
        exerciseTypes: const ['subtraction'],
        minNumber: 1,
        maxNumber: 5,
        maxResult: 5,
      ),
      random: Random(1),
    );

    final results = [
      for (var index = 0; index < 5; index++) planner.next().result,
    ];

    expect(results, isNot(contains(0)));
  });

  test('varies recent answers when alternatives exist', () {
    final planner = ExerciseSessionPlanner(
      level: _level(
        exerciseTypes: const ['subtraction'],
        minNumber: 1,
        maxNumber: 5,
        maxResult: 5,
      ),
      random: Random(1),
    );

    final results = [
      for (var index = 0; index < 4; index++) planner.next().result,
    ];

    expect(results.toSet(), hasLength(results.length));
  });

  test('throws a clear error when a level has no valid candidates', () {
    expect(
      () => ExerciseSessionPlanner(
        level: _level(
          exerciseTypes: const ['addition'],
          minNumber: 10,
          maxNumber: 20,
          maxResult: 5,
        ),
        random: Random(1),
      ),
      throwsStateError,
    );
  });
}

LevelConfig _level({
  required List<String> exerciseTypes,
  required int minNumber,
  required int maxNumber,
  int? maxResult,
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
    allowCarry: false,
    visualSupport: false,
    questionsToComplete: 5,
    starsToUnlockNext: 1,
    rewardId: null,
    visualItemIds: const ['heart_pink'],
    sortOrder: 1,
  );
}
