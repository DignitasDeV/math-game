import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/operation_candidate.dart';

void main() {
  test('addition metadata detects tens, crossing ten, and carry', () {
    const operation = OperationCandidate(
      left: 8,
      type: 'addition',
      right: 12,
      result: 20,
    );

    expect(operation.usesTens, isTrue);
    expect(operation.crossesTen, isTrue);
    expect(operation.requiresCarry, isTrue);
    expect(operation.strategyTags, contains(OperationStrategyTag.addition));
    expect(operation.strategyTags, contains(OperationStrategyTag.usesTens));
    expect(operation.strategyTags, contains(OperationStrategyTag.crossesTen));
    expect(operation.strategyTags, contains(OperationStrategyTag.requiresCarry));
    expect(operation.difficultyScore, greaterThan(3));
  });

  test('early addition metadata stays in the beginner range', () {
    const operation = OperationCandidate(
      left: 2,
      type: 'addition',
      right: 3,
      result: 5,
    );

    expect(operation.usesTens, isFalse);
    expect(operation.crossesTen, isFalse);
    expect(operation.requiresCarry, isFalse);
    expect(operation.strategyTags, contains(OperationStrategyTag.withinFive));
    expect(operation.strategyTags, contains(OperationStrategyTag.withinTen));
    expect(operation.difficultyScore, 1);
  });

  test('decomposition metadata marks tens and units work', () {
    const operation = OperationCandidate(
      left: 14,
      type: 'decomposition',
      right: 1,
      result: 4,
    );

    expect(operation.strategyTags, contains(OperationStrategyTag.decomposition));
    expect(operation.strategyTags, contains(OperationStrategyTag.tensAndUnits));
    expect(operation.strategyTags, contains(OperationStrategyTag.usesTens));
  });
}
