import '../models/level_config.dart';
import '../models/operation_candidate.dart';

class ExercisePoolGenerator {
  const ExercisePoolGenerator();

  List<OperationCandidate> generate(LevelConfig level) {
    final candidates = <OperationCandidate>[];

    for (final type in level.exerciseTypes) {
      switch (type) {
        case 'count':
          candidates.addAll(_generateCount(level));
          break;
        case 'addition':
          candidates.addAll(_generateAddition(level));
          break;
        case 'subtraction':
          candidates.addAll(_generateSubtraction(level));
          break;
        case 'decomposition':
          candidates.addAll(_generateDecomposition(level));
          break;
      }
    }

    return candidates;
  }

  Iterable<OperationCandidate> _generateCount(LevelConfig level) sync* {
    for (var value = level.minNumber; value <= level.maxNumber; value++) {
      if (level.maxResult != null && value > level.maxResult!) {
        continue;
      }

      yield OperationCandidate(
        left: value,
        type: 'count',
        right: 0,
        result: value,
      );
    }
  }

  Iterable<OperationCandidate> _generateAddition(LevelConfig level) sync* {
    for (var left = level.minNumber; left <= level.maxNumber; left++) {
      for (var right = level.minNumber; right <= level.maxNumber; right++) {
        final result = left + right;
        if (level.maxResult != null && result > level.maxResult!) {
          continue;
        }
        if (!level.allowCarry && _requiresCarry(left, right)) {
          continue;
        }

        yield OperationCandidate(
          left: left,
          type: 'addition',
          right: right,
          result: result,
        );
      }
    }
  }

  bool _requiresCarry(int left, int right) {
    final hasTens = left >= 10 || right >= 10;
    return hasTens && (left % 10) + (right % 10) >= 10;
  }

  Iterable<OperationCandidate> _generateSubtraction(LevelConfig level) sync* {
    for (var left = level.minNumber; left <= level.maxNumber; left++) {
      for (var right = level.minNumber; right <= level.maxNumber; right++) {
        final result = left - right;
        if (!level.allowNegativeResults && result < 0) {
          continue;
        }
        if (level.maxResult != null && result > level.maxResult!) {
          continue;
        }

        yield OperationCandidate(
          left: left,
          type: 'subtraction',
          right: right,
          result: result,
        );
      }
    }
  }

  Iterable<OperationCandidate> _generateDecomposition(LevelConfig level) sync* {
    for (var value = level.minNumber; value <= level.maxNumber; value++) {
      if (value < 10) {
        continue;
      }

      final tens = value ~/ 10;
      final units = value % 10;
      if (level.maxResult != null && units > level.maxResult!) {
        continue;
      }

      yield OperationCandidate(
        left: value,
        type: 'decomposition',
        right: tens,
        result: units,
      );
    }
  }
}
