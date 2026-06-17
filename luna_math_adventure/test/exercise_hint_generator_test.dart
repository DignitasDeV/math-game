import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/models/operation_candidate.dart';
import 'package:luna_math_adventure/models/visual_item.dart';
import 'package:luna_math_adventure/services/exercise_hint_generator.dart';

void main() {
  const generator = StrategyExerciseHintGenerator();

  test('addition hint completes the next ten when that strategy fits', () {
    final hints = generator.hintsFor(
      operation: const OperationCandidate(
        left: 17,
        type: 'addition',
        right: 8,
        result: 25,
      ),
      visualItem: _flower,
      languageCode: 'es-ES',
    );

    expect(
      hints.visibleHint,
      'Completa la decena: de 17 a 20 faltan 3; después suma 5.',
    );
    expect(hints.spokenHint, hints.visibleHint);
    expect(hints.steps, hasLength(2));
    expect(hints.steps.first.visibleText, 'Completa la decena.');
    expect(hints.steps.first.spokenText, hints.steps.first.visibleText);
    expect(hints.steps.last.visibleText, hints.visibleHint);
    expect(hints.steps.last.spokenText, hints.visibleHint);
  });

  test('decomposition hint names both digits explicitly', () {
    final hints = generator.hintsFor(
      operation: const OperationCandidate(
        left: 14,
        type: 'decomposition',
        right: 1,
        result: 4,
      ),
      visualItem: _flower,
      languageCode: 'es-ES',
    );

    expect(
      hints.visibleHint,
      'Mira 14: el 1 marca las decenas y el 4 marca las unidades.',
    );
    expect(hints.spokenHint, hints.visibleHint);
    expect(hints.steps, hasLength(2));
    expect(hints.steps.first.visibleText, 'Mira el número 14.');
    expect(hints.steps.first.spokenText, hints.steps.first.visibleText);
    expect(hints.steps.last.visibleText, hints.visibleHint);
    expect(hints.steps.last.spokenText, hints.visibleHint);
  });

  test('Catalan hints keep spoken text aligned with visible text', () {
    final hints = generator.hintsFor(
      operation: const OperationCandidate(
        left: 3,
        type: 'subtraction',
        right: 2,
        result: 1,
      ),
      visualItem: _flower,
      languageCode: 'ca-ES',
    );

    expect(hints.visibleHint, 'Comença en 3 i retrocedeix dos passos.');
    expect(hints.spokenHint, hints.visibleHint);
    expect(hints.steps, hasLength(2));
    expect(hints.steps.last.spokenText, hints.steps.last.visibleText);
  });

  test('Catalan hints use singular step wording', () {
    final hints = generator.hintsFor(
      operation: const OperationCandidate(
        left: 3,
        type: 'addition',
        right: 1,
        result: 4,
      ),
      visualItem: _flower,
      languageCode: 'ca-ES',
    );

    expect(hints.visibleHint, 'Comença en 3 i avança un pas.');
    expect(hints.spokenHint, hints.visibleHint);
  });

  test('Catalan hints agree missing amounts with one and many', () {
    final oneMissing = generator.hintsFor(
      operation: const OperationCandidate(
        left: 19,
        type: 'addition',
        right: 4,
        result: 23,
      ),
      visualItem: _flower,
      languageCode: 'ca-ES',
    );
    final manyMissing = generator.hintsFor(
      operation: const OperationCandidate(
        left: 17,
        type: 'addition',
        right: 8,
        result: 25,
      ),
      visualItem: _flower,
      languageCode: 'ca-ES',
    );

    expect(
      oneMissing.visibleHint,
      'Completa la desena: de 19 a 20 falta 1; després suma 3.',
    );
    expect(
      manyMissing.visibleHint,
      'Completa la desena: de 17 a 20 falten 3; després suma 5.',
    );
  });
}

const _flower = VisualItem(
  id: 'flower_blue',
  assetPath: 'assets/images/items/flower_blue.webp',
  singularLabel: LocalizedText(es: 'flor', ca: 'flor'),
  pluralLabel: LocalizedText(es: 'flores', ca: 'flors'),
  pluralWithArticleLabel: LocalizedText(es: 'las flores', ca: 'les flors'),
  oneWithArticleLabel: LocalizedText(es: 'una flor', ca: 'una flor'),
  gender: LocalizedText(es: 'feminine', ca: 'feminine'),
);
