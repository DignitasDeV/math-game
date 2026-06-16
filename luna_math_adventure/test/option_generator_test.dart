import 'package:flutter_test/flutter_test.dart';
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
}
