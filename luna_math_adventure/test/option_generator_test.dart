import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/operation_candidate.dart';
import 'package:luna_math_adventure/services/option_generator.dart';

void main() {
  test('nearby options returns exactly four answers when range allows it', () {
    final options = NearbyOptionGenerator().optionsFor(
      answer: 7,
      min: 0,
      max: 20,
    );

    expect(options, hasLength(4));
    expect(options, contains(7));
  });

  test('nearby options does not exceed requested count near boundaries', () {
    final options = NearbyOptionGenerator().optionsFor(
      answer: 1,
      min: 0,
      max: 20,
    );

    expect(options, hasLength(4));
    expect(options, contains(1));
  });

  test('nearby options include carry-aware distractors for addition', () {
    final options = NearbyOptionGenerator().optionsFor(
      answer: 20,
      min: 0,
      max: 22,
      operation: const OperationCandidate(
        left: 12,
        type: 'addition',
        right: 8,
        result: 20,
      ),
    );

    expect(options, hasLength(4));
    expect(options, containsAll([10, 20]));
    expect(options.toSet(), hasLength(options.length));
  });

  test('nearby options include operation-confusion distractor for subtraction', () {
    final options = NearbyOptionGenerator().optionsFor(
      answer: 4,
      min: 0,
      max: 20,
      operation: const OperationCandidate(
        left: 12,
        type: 'subtraction',
        right: 8,
        result: 4,
      ),
    );

    expect(options, hasLength(4));
    expect(options, containsAll([4, 20]));
    expect(options.toSet(), hasLength(options.length));
  });

  test('nearby options include tens-count distractor for decomposition', () {
    final options = NearbyOptionGenerator().optionsFor(
      answer: 4,
      min: 0,
      max: 9,
      operation: const OperationCandidate(
        left: 14,
        type: 'decomposition',
        right: 1,
        result: 4,
      ),
    );

    expect(options, hasLength(4));
    expect(options, containsAll([1, 4]));
    expect(options.toSet(), hasLength(options.length));
  });
}
