import '../models/operation_candidate.dart';

abstract class OptionGenerator {
  List<int> optionsFor({
    required int answer,
    required int min,
    required int max,
    int count = 4,
    OperationCandidate? operation,
  });
}

class NearbyOptionGenerator implements OptionGenerator {
  @override
  List<int> optionsFor({
    required int answer,
    required int min,
    required int max,
    int count = 4,
    OperationCandidate? operation,
  }) {
    final values = <int>{answer};
    for (final distractor in _contextualDistractors(operation)) {
      _addIfValid(values, distractor, min: min, max: max);
      if (values.length >= count) {
        break;
      }
    }

    var distance = 1;

    while (values.length < count && distance <= max - min + count) {
      final lower = answer - distance;
      _addIfValid(values, lower, min: min, max: max);

      if (values.length >= count) {
        break;
      }

      final upper = answer + distance;
      _addIfValid(values, upper, min: min, max: max);

      distance++;
    }

    var fallback = min;
    while (values.length < count && fallback <= max) {
      _addIfValid(values, fallback, min: min, max: max);
      fallback++;
    }

    return values.toList()..sort();
  }

  Iterable<int> _contextualDistractors(OperationCandidate? operation) sync* {
    if (operation == null) {
      return;
    }

    switch (operation.type) {
      case 'addition':
        yield operation.left + (operation.right % 10);
        yield (operation.left % 10) + operation.right;
        if (operation.requiresCarry) {
          yield operation.result - 10;
        }
        if (operation.usesTens) {
          yield operation.result + 10;
          yield operation.result - 10;
        }
        if (operation.isNearDouble) {
          yield operation.left * 2;
          yield operation.right * 2;
        }
        break;
      case 'subtraction':
        yield operation.left + operation.right;
        yield operation.left - (operation.right % 10);
        yield operation.right - operation.left;
        if (operation.usesTens) {
          yield operation.result + 10;
          yield operation.result - 10;
        }
        break;
      case 'decomposition':
        yield operation.right;
        yield operation.result + 10;
        yield operation.left;
        break;
      case 'count':
        yield operation.result - 1;
        yield operation.result + 1;
        yield operation.result + 2;
        break;
    }
  }

  void _addIfValid(
    Set<int> values,
    int value, {
    required int min,
    required int max,
  }) {
    if (value < min || value > max) {
      return;
    }

    values.add(value);
  }
}
