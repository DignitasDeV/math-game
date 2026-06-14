import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';

abstract class ExerciseGenerator {
  Exercise nextExercise(String levelId);
}

class BagExerciseGenerator implements ExerciseGenerator {
  @override
  Exercise nextExercise(String levelId) {
    return const Exercise(
      id: 'sample_2_plus_3',
      levelId: 'meadow_1',
      visibleText: 'Cuanto es 2 + 3?',
      spokenText: 'Cuanto es dos mas tres?',
      answer: 5,
      options: [4, 5, 6],
      visualItemIds: ['star'],
    );
  }
}

final exerciseGeneratorProvider = Provider<ExerciseGenerator>((ref) {
  return BagExerciseGenerator();
});

final sampleExerciseProvider = Provider<Exercise>((ref) {
  return ref.watch(exerciseGeneratorProvider).nextExercise('meadow_1');
});
