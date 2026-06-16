import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/exercise.dart';
import 'package:luna_math_adventure/models/exercise_template.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/models/operation_candidate.dart';
import 'package:luna_math_adventure/models/visual_item.dart';
import 'package:luna_math_adventure/services/exercise_generator.dart';
import 'package:luna_math_adventure/services/option_generator.dart';

void main() {
  test('uses plural article in count prompts', () {
    final exercise = _buildExercise(
      operation: const OperationCandidate(
        left: 3,
        type: 'count',
        right: 0,
        result: 3,
      ),
    );

    expect(exercise.visibleText, 'Cuenta las flores.');
    expect(exercise.spokenText, 'Cuenta las flores. ¿Cuántas hay?');
    expect(exercise.visualItemIds, ['flower_blue', 'flower_blue', 'flower_blue']);
  });

  test('uses singular and plural item names in addition prompts', () {
    final exercise = _buildExercise(
      operation: const OperationCandidate(
        left: 1,
        type: 'addition',
        right: 2,
        result: 3,
      ),
    );

    expect(
      exercise.visibleText,
      'Luna tiene 1 flor y recibe 2 flores más. ¿Cuántas tiene?',
    );
    expect(
      exercise.spokenText,
      'Luna tiene una flor y recibe dos flores más. ¿Cuántas tiene?',
    );
    expect(exercise.visualItemIds.length, 3);
  });

  test('uses masculine wording in addition prompts', () {
    final exercise = _buildExercise(
      visualItem: _heart,
      operation: const OperationCandidate(
        left: 1,
        type: 'addition',
        right: 2,
        result: 3,
      ),
    );

    expect(
      exercise.visibleText,
      'Luna tiene 1 corazón y recibe 2 corazones más. ¿Cuántos tiene?',
    );
    expect(exercise.visualItemIds.length, 3);
  });

  test('uses feminine cloud wording without misspelling', () {
    final exercise = _buildExercise(
      visualItem: _cloud,
      operation: const OperationCandidate(
        left: 7,
        type: 'addition',
        right: 2,
        result: 9,
      ),
    );

    expect(
      exercise.visibleText,
      'Luna tiene 7 nubes y recibe 2 nubes más. ¿Cuántas tiene?',
    );
    expect(exercise.visibleText, isNot(contains('nuve')));
    expect(exercise.visibleText, isNot(contains('nuves')));
    expect(exercise.visibleText, isNot(contains('Cuántos')));
  });

  test('uses feminine wording and remaining objects for subtraction prompts', () {
    final exercise = _buildExercise(
      operation: const OperationCandidate(
        left: 3,
        type: 'subtraction',
        right: 2,
        result: 1,
      ),
    );

    expect(
      exercise.visibleText,
      'Luna tiene 3 flores y entrega 2 flores. ¿Cuántas quedan?',
    );
    expect(
      exercise.visibleHint,
      'Empieza en 3 y retrocede 2 pasos.',
    );
    expect(exercise.answer, 1);
    expect(exercise.visualItemIds, ['flower_blue']);
  });

  test('uses strategy hints and hides advanced visual objects', () {
    final exercise = _buildExercise(
      level: _level(visualSupport: false),
      operation: const OperationCandidate(
        left: 17,
        type: 'addition',
        right: 8,
        result: 25,
      ),
    );

    expect(
      exercise.visibleHint,
      'Truco: completa la decena. De 17 a 20 faltan 3; después suma 5.',
    );
    expect(exercise.visualItemIds, isEmpty);
  });

  test('hides visual objects when level disables visual support', () {
    final exercise = _buildExercise(
      level: _level(visualSupport: false),
      operation: const OperationCandidate(
        left: 4,
        type: 'count',
        right: 0,
        result: 4,
      ),
    );

    expect(exercise.visualItemIds, isEmpty);
  });

  test('does not render large visual object counts', () {
    final exercise = _buildExercise(
      operation: const OperationCandidate(
        left: 6,
        type: 'addition',
        right: 5,
        result: 11,
      ),
    );

    expect(exercise.visualItemIds, isEmpty);
  });

  test('builds decomposition prompts with tens and units', () {
    final exercise = _buildExercise(
      level: _level(visualSupport: false),
      operation: const OperationCandidate(
        left: 14,
        type: 'decomposition',
        right: 1,
        result: 4,
      ),
    );

    expect(
      exercise.visibleText,
      '14 tiene 1 decena. ¿Cuántas unidades sueltas tiene?',
    );
    expect(exercise.answer, 4);
    expect(exercise.visualItemIds, isEmpty);
  });
}

Exercise _buildExercise({
  LevelConfig? level,
  VisualItem visualItem = _flower,
  required OperationCandidate operation,
}) {
  final testLevel = level ?? _level(visualItemIds: [visualItem.id]);

  return DynamicExerciseGenerator(
    random: Random(1),
    optionGenerator: const _FixedOptionGenerator(),
  ).buildExercise(
    level: testLevel,
    operation: operation,
    templates: _templates,
    visualItems: [visualItem],
    profile: null,
  );
}

LevelConfig _level({
  bool visualSupport = true,
  List<String> visualItemIds = const ['flower_blue'],
}) {
  return LevelConfig(
    id: 'heart_forest_test',
    worldId: 'heart_forest',
    title: const LocalizedText(es: 'Test', ca: 'Test'),
    subtitle: const LocalizedText(es: 'Test', ca: 'Test'),
    exerciseTypes: const ['count', 'addition', 'subtraction'],
    minNumber: 1,
    maxNumber: 5,
    maxResult: 5,
    allowNegativeResults: false,
    allowCarry: false,
    visualSupport: visualSupport,
    questionsToComplete: 5,
    starsToUnlockNext: 1,
    rewardId: null,
    visualItemIds: visualItemIds,
    sortOrder: 1,
  );
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

const _heart = VisualItem(
  id: 'heart_pink',
  assetPath: 'assets/images/items/heart_pink.webp',
  singularLabel: LocalizedText(es: 'corazón', ca: 'cor'),
  pluralLabel: LocalizedText(es: 'corazones', ca: 'cors'),
  pluralWithArticleLabel: LocalizedText(es: 'los corazones', ca: 'els cors'),
  oneWithArticleLabel: LocalizedText(es: 'un corazón', ca: 'un cor'),
  gender: LocalizedText(es: 'masculine', ca: 'masculine'),
);

const _cloud = VisualItem(
  id: 'cloud_white',
  assetPath: 'assets/images/items/cloud_white.webp',
  singularLabel: LocalizedText(es: 'nube', ca: 'núvol'),
  pluralLabel: LocalizedText(es: 'nubes', ca: 'núvols'),
  pluralWithArticleLabel: LocalizedText(es: 'las nubes', ca: 'els núvols'),
  oneWithArticleLabel: LocalizedText(es: 'una nube', ca: 'un núvol'),
  gender: LocalizedText(es: 'feminine', ca: 'masculine'),
);

const _templates = [
  ExerciseTemplate(
    id: 'count_items_basic',
    type: 'count',
    visiblePattern: LocalizedText(
      es: 'Cuenta {itemPluralWithArticle}.',
      ca: 'Compta {itemPluralWithArticle}.',
    ),
    spokenPattern: LocalizedText(
      es: 'Cuenta {itemPluralWithArticle}. {countQuestion}',
      ca: 'Compta {itemPluralWithArticle}.',
    ),
    hintPattern: LocalizedText(
      es: 'Mira cada {itemSingular}.',
      ca: 'Mira cada {itemSingular}.',
    ),
    spokenHintPattern: LocalizedText(
      es: 'Mira cada {itemSingular}.',
      ca: 'Mira cada {itemSingular}.',
    ),
  ),
  ExerciseTemplate(
    id: 'character_gets_more_items',
    type: 'addition',
    visiblePattern: LocalizedText(
      es:
          '{characterName} tiene {a} {aItemLabel} y recibe {b} {bItemLabel} más. {totalQuestion}',
      ca: '',
    ),
    spokenPattern: LocalizedText(
      es:
          '{characterName} tiene {aSpokenItemCount} y recibe {bSpokenItemCount} más. {totalQuestion}',
      ca: '',
    ),
    hintPattern: LocalizedText(es: '{additionHint}', ca: ''),
    spokenHintPattern: LocalizedText(es: '{additionHint}', ca: ''),
  ),
  ExerciseTemplate(
    id: 'character_gives_away_items',
    type: 'subtraction',
    visiblePattern: LocalizedText(
      es:
          '{characterName} tiene {a} {aItemLabel} y entrega {b} {bItemLabel}. {remainingQuestion}',
      ca: '',
    ),
    spokenPattern: LocalizedText(
      es:
          '{characterName} tiene {aSpokenItemCount} y entrega {bSpokenItemCount}. {remainingQuestion}',
      ca: '',
    ),
    hintPattern: LocalizedText(
      es: '{subtractionHint}',
      ca: '',
    ),
    spokenHintPattern: LocalizedText(es: '{subtractionHint}', ca: ''),
  ),
  ExerciseTemplate(
    id: 'number_decomposition_units',
    type: 'decomposition',
    visiblePattern: LocalizedText(
      es: '{a} tiene {tens} {tensLabel}. ¿Cuántas unidades sueltas tiene?',
      ca: '',
    ),
    spokenPattern: LocalizedText(es: '', ca: ''),
    hintPattern: LocalizedText(es: '', ca: ''),
    spokenHintPattern: LocalizedText(es: '', ca: ''),
  ),
];

class _FixedOptionGenerator implements OptionGenerator {
  const _FixedOptionGenerator();

  @override
  List<int> optionsFor({
    required int answer,
    required int min,
    required int max,
    int count = 4,
  }) {
    return [answer, answer + 1, answer + 2, answer + 3];
  }
}
