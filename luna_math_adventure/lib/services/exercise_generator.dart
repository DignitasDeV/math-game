import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../models/exercise_template.dart';
import '../models/level_config.dart';
import '../models/operation_candidate.dart';
import '../models/player_profile.dart';
import '../models/visual_item.dart';
import 'exercise_hint_generator.dart';
import 'localized_grammar.dart';
import 'option_generator.dart';

abstract class ExerciseGenerator {
  Exercise buildExercise({
    required LevelConfig level,
    required OperationCandidate operation,
    required List<ExerciseTemplate> templates,
    required List<VisualItem> visualItems,
    required PlayerProfile? profile,
  });
}

class DynamicExerciseGenerator implements ExerciseGenerator {
  DynamicExerciseGenerator({
    Random? random,
    OptionGenerator? optionGenerator,
    ExerciseHintGenerator? hintGenerator,
  })  : _random = random ?? Random(),
        _optionGenerator = optionGenerator ?? NearbyOptionGenerator(),
        _hintGenerator = hintGenerator ?? const StrategyExerciseHintGenerator();

  final Random _random;
  final OptionGenerator _optionGenerator;
  final ExerciseHintGenerator _hintGenerator;

  @override
  Exercise buildExercise({
    required LevelConfig level,
    required OperationCandidate operation,
    required List<ExerciseTemplate> templates,
    required List<VisualItem> visualItems,
    required PlayerProfile? profile,
  }) {
    final languageCode = profile?.language.ttsCode ?? 'es-ES';
    final template = _templateFor(operation.type, templates);
    final visualItem = _visualItemFor(level, visualItems);
    final replacements = _replacements(
      operation: operation,
      visualItem: visualItem,
      profile: profile,
      languageCode: languageCode,
    );
    final hints = _hintGenerator.hintsFor(
      operation: operation,
      visualItem: visualItem,
      languageCode: languageCode,
    );
    final maxOption = max(
      level.maxResult ?? level.maxNumber,
      operation.result + 2,
    );

    return Exercise(
      id: '${level.id}_${operation.key}_${DateTime.now().microsecondsSinceEpoch}',
      levelId: level.id,
      type: operation.type,
      left: operation.left,
      right: operation.right,
      visibleText: _apply(
        template.visiblePattern.get(languageCode),
        replacements,
      ),
      spokenText: _apply(
        template.spokenPattern.get(languageCode),
        replacements,
      ),
      visibleHint: hints.visibleHint,
      spokenHint: hints.spokenHint,
      hintSteps: hints.steps,
      answer: operation.result,
      options: _optionGenerator.optionsFor(
        answer: operation.result,
        min: 0,
        max: maxOption,
        operation: operation,
      )..shuffle(_random),
      visualItemId: visualItem.id,
      visualItemAssetPath: visualItem.assetPath,
      visualItemIds: List.filled(
        _visualItemCountFor(level, operation),
        visualItem.id,
      ),
    );
  }

  ExerciseTemplate _templateFor(
    String type,
    List<ExerciseTemplate> templates,
  ) {
    final matching = templates
        .where((template) => template.type == type)
        .toList(growable: false);
    if (matching.isEmpty) {
      return templates.first;
    }

    return matching[_random.nextInt(matching.length)];
  }

  VisualItem _visualItemFor(LevelConfig level, List<VisualItem> visualItems) {
    final allowed = visualItems
        .where((item) => level.visualItemIds.contains(item.id))
        .toList(growable: false);
    final candidates = allowed.isEmpty ? visualItems : allowed;
    return candidates[_random.nextInt(candidates.length)];
  }

  Map<String, String> _replacements({
    required OperationCandidate operation,
    required VisualItem visualItem,
    required PlayerProfile? profile,
    required String languageCode,
  }) {
    return {
      'characterName': profile?.unicornName ?? 'Luna',
      'a': '${operation.left}',
      'b': '${operation.right}',
      'tens': '${operation.right}',
      'units': '${operation.result}',
      'aWords': LocalizedGrammar.numberWord(operation.left, languageCode),
      'bWords': LocalizedGrammar.numberWord(operation.right, languageCode),
      'tensWords': LocalizedGrammar.numberWord(
        operation.right,
        languageCode,
        feminine: true,
      ),
      'unitsWords': LocalizedGrammar.numberWord(
        operation.result,
        languageCode,
        feminine: true,
      ),
      'tensLabel': LocalizedGrammar.tensLabel(operation.right, languageCode),
      'itemSingular': visualItem.singularLabel.get(languageCode),
      'itemPlural': visualItem.pluralLabel.get(languageCode),
      'itemPluralWithArticle':
          visualItem.pluralWithArticleLabel.get(languageCode),
      'aItemLabel': LocalizedGrammar.itemLabel(
        operation.left,
        visualItem,
        languageCode,
      ),
      'bItemLabel': LocalizedGrammar.itemLabel(
        operation.right,
        visualItem,
        languageCode,
      ),
      'countQuestion': LocalizedGrammar.countQuestion(
        visualItem,
        languageCode,
      ),
      'totalQuestion': LocalizedGrammar.totalQuestion(
        visualItem,
        languageCode,
      ),
      'remainingQuestion': LocalizedGrammar.remainingQuestion(
        visualItem,
        languageCode,
      ),
      'remainingItemsPronoun': LocalizedGrammar.remainingItemsPronoun(
        visualItem,
        languageCode,
      ),
      'aSpokenItemCount': LocalizedGrammar.itemCountPhrase(
        operation.left,
        visualItem,
        languageCode,
      ),
      'bSpokenItemCount': LocalizedGrammar.itemCountPhrase(
        operation.right,
        visualItem,
        languageCode,
      ),
    };
  }

  int _visualItemCountFor(LevelConfig level, OperationCandidate operation) {
    if (operation.type != 'count') {
      return 0;
    }

    if (!level.visualSupport) {
      return 0;
    }

    if (!_allowsConcreteVisualSupport(level)) {
      return 0;
    }

    if (operation.result > 10) {
      return 0;
    }

    return operation.result;
  }

  bool _allowsConcreteVisualSupport(LevelConfig level) {
    return level.worldId == 'heart_forest' || level.worldId == 'practice';
  }

  String _apply(String pattern, Map<String, String> replacements) {
    var value = pattern;
    for (final entry in replacements.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }

    return value;
  }
}

final exerciseGeneratorProvider = Provider<ExerciseGenerator>((ref) {
  return DynamicExerciseGenerator();
});
