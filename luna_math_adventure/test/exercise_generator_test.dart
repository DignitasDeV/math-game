import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/app_language.dart';
import 'package:luna_math_adventure/models/exercise.dart';
import 'package:luna_math_adventure/models/exercise_template.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/models/operation_candidate.dart';
import 'package:luna_math_adventure/models/player_profile.dart';
import 'package:luna_math_adventure/models/unicorn_avatar.dart';
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
    expect(
        exercise.visualItemIds, ['flower_blue', 'flower_blue', 'flower_blue']);
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
    expect(exercise.visualItemIds, isEmpty);
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
    expect(exercise.visualItemIds, isEmpty);
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

  test('uses feminine wording and remaining objects for subtraction prompts',
      () {
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
    expect(exercise.visualItemIds, isEmpty);
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
      'Completa la decena: de 17 a 20 faltan 3; después suma 5.',
    );
    expect(exercise.spokenHint, exercise.visibleHint);
    expect(exercise.hintSteps, hasLength(2));
    expect(exercise.hintSteps.first.visibleText, 'Completa la decena.');
    expect(exercise.hintSteps.first.spokenText, 'Completa la decena.');
    expect(exercise.hintSteps.last.visibleText, exercise.visibleHint);
    expect(exercise.hintSteps.last.spokenText, exercise.spokenHint);
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

  test('hides concrete visual objects outside the first adventure world', () {
    final exercise = _buildExercise(
      level: _level(
        worldId: 'star_lake',
        visualSupport: true,
      ),
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
    expect(
      exercise.visibleHint,
      'Mira 14: el 1 marca las decenas y el 4 marca las unidades.',
    );
    expect(exercise.spokenHint, exercise.visibleHint);
    expect(exercise.hintSteps, hasLength(2));
    expect(exercise.hintSteps.first.visibleText, 'Mira el número 14.');
    expect(exercise.hintSteps.first.spokenText, 'Mira el número 14.');
    expect(exercise.hintSteps.last.visibleText, exercise.visibleHint);
    expect(exercise.hintSteps.last.spokenText, exercise.spokenHint);
    expect(exercise.answer, 4);
    expect(exercise.visualItemIds, isEmpty);
  });

  test('builds Catalan count prompts with gendered question', () {
    final exercise = _buildExercise(
      profile: _catalanProfile,
      operation: const OperationCandidate(
        left: 2,
        type: 'count',
        right: 0,
        result: 2,
      ),
    );

    expect(exercise.visibleText, 'Compta les flors.');
    expect(exercise.spokenText, "Compta les flors. Quantes n'hi ha?");
  });

  test('builds Catalan feminine item count phrases', () {
    final exercise = _buildExercise(
      profile: _catalanProfile,
      operation: const OperationCandidate(
        left: 1,
        type: 'addition',
        right: 2,
        result: 3,
      ),
    );

    expect(
      exercise.visibleText,
      'Luna té 1 flor i rep 2 flors més. Quantes en té?',
    );
    expect(
      exercise.spokenText,
      'Luna té una flor i rep dues flors més. Quantes en té?',
    );
  });

  test('builds Catalan masculine item count phrases', () {
    final exercise = _buildExercise(
      profile: _catalanProfile,
      visualItem: _cloud,
      operation: const OperationCandidate(
        left: 1,
        type: 'addition',
        right: 2,
        result: 3,
      ),
    );

    expect(
      exercise.visibleText,
      'Luna té 1 núvol i rep 2 núvols més. Quants en té?',
    );
    expect(
      exercise.spokenText,
      'Luna té un núvol i rep dos núvols més. Quants en té?',
    );
  });

  test('builds Catalan subtraction with feminine remaining question', () {
    final exercise = _buildExercise(
      profile: _catalanProfile,
      visualItem: _gem,
      operation: const OperationCandidate(
        left: 3,
        type: 'subtraction',
        right: 2,
        result: 1,
      ),
    );

    expect(
      exercise.spokenText,
      'Luna té tres gemmes i dona dues gemmes. Quantes en queden?',
    );
  });

  test('builds Catalan decomposition with feminine tens wording', () {
    final exercise = _buildExercise(
      profile: _catalanProfile,
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
      '14 té 1 desena. Quantes unitats soltes té?',
    );
    expect(
      exercise.spokenText,
      'catorze té una desena. Quantes unitats soltes té?',
    );
  });
}

Exercise _buildExercise({
  LevelConfig? level,
  VisualItem visualItem = _flower,
  PlayerProfile? profile,
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
    profile: profile,
  );
}

LevelConfig _level({
  String worldId = 'heart_forest',
  bool visualSupport = true,
  List<String> visualItemIds = const ['flower_blue'],
}) {
  return LevelConfig(
    id: 'heart_forest_test',
    worldId: worldId,
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

const _gem = VisualItem(
  id: 'gem_purple',
  assetPath: 'assets/images/items/gem_purple.webp',
  singularLabel: LocalizedText(es: 'gema', ca: 'gemma'),
  pluralLabel: LocalizedText(es: 'gemas', ca: 'gemmes'),
  pluralWithArticleLabel: LocalizedText(es: 'las gemas', ca: 'les gemmes'),
  oneWithArticleLabel: LocalizedText(es: 'una gema', ca: 'una gemma'),
  gender: LocalizedText(es: 'feminine', ca: 'feminine'),
);

const _catalanProfile = PlayerProfile(
  id: 'profile_ca',
  childName: 'Nora',
  unicornName: 'Luna',
  language: AppLanguage.catalan,
  unicornAvatar: UnicornAvatar.avatar01,
  ttsVoiceId: 'ca_ES-upc_ona-medium',
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
      es: '{characterName} tiene {a} {aItemLabel} y recibe {b} {bItemLabel} más. {totalQuestion}',
      ca: '{characterName} té {a} {aItemLabel} i rep {b} {bItemLabel} més. {totalQuestion}',
    ),
    spokenPattern: LocalizedText(
      es: '{characterName} tiene {aSpokenItemCount} y recibe {bSpokenItemCount} más. {totalQuestion}',
      ca: '{characterName} té {aSpokenItemCount} i rep {bSpokenItemCount} més. {totalQuestion}',
    ),
    hintPattern: LocalizedText(es: '{additionHint}', ca: '{additionHint}'),
    spokenHintPattern: LocalizedText(
      es: '{additionHint}',
      ca: '{additionHint}',
    ),
  ),
  ExerciseTemplate(
    id: 'character_gives_away_items',
    type: 'subtraction',
    visiblePattern: LocalizedText(
      es: '{characterName} tiene {a} {aItemLabel} y entrega {b} {bItemLabel}. {remainingQuestion}',
      ca: '{characterName} té {a} {aItemLabel} i dona {b} {bItemLabel}. {remainingQuestion}',
    ),
    spokenPattern: LocalizedText(
      es: '{characterName} tiene {aSpokenItemCount} y entrega {bSpokenItemCount}. {remainingQuestion}',
      ca: '{characterName} té {aSpokenItemCount} i dona {bSpokenItemCount}. {remainingQuestion}',
    ),
    hintPattern: LocalizedText(
      es: '{subtractionHint}',
      ca: '{subtractionHint}',
    ),
    spokenHintPattern: LocalizedText(
      es: '{subtractionHint}',
      ca: '{subtractionHint}',
    ),
  ),
  ExerciseTemplate(
    id: 'number_decomposition_units',
    type: 'decomposition',
    visiblePattern: LocalizedText(
      es: '{a} tiene {tens} {tensLabel}. ¿Cuántas unidades sueltas tiene?',
      ca: '{a} té {tens} {tensLabel}. Quantes unitats soltes té?',
    ),
    spokenPattern: LocalizedText(
      es: '{aWords} tiene {tensWords} {tensLabel}. ¿Cuántas unidades sueltas tiene?',
      ca: '{aWords} té {tensWords} {tensLabel}. Quantes unitats soltes té?',
    ),
    hintPattern: LocalizedText(
      es: 'Mira {a}: el {tens} marca las decenas y el {units} marca las unidades.',
      ca: 'Mira {a}: el {tens} marca les desenes i el {units} marca les unitats.',
    ),
    spokenHintPattern: LocalizedText(
      es: 'Mira {a}: el {tens} marca las decenas y el {units} marca las unidades.',
      ca: 'Mira {a}: el {tens} marca les desenes i el {units} marca les unitats.',
    ),
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
    OperationCandidate? operation,
  }) {
    return [answer, answer + 1, answer + 2, answer + 3];
  }
}
