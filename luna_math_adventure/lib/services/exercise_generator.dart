import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../models/exercise_template.dart';
import '../models/level_config.dart';
import '../models/operation_candidate.dart';
import '../models/player_profile.dart';
import '../models/visual_item.dart';
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
  })  : _random = random ?? Random(),
        _optionGenerator = optionGenerator ?? NearbyOptionGenerator();

  final Random _random;
  final OptionGenerator _optionGenerator;

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
      visibleHint: _apply(
        template.hintPattern.get(languageCode),
        replacements,
      ),
      spokenHint: _apply(
        template.spokenHintPattern.get(languageCode),
        replacements,
      ),
      answer: operation.result,
      options: _optionGenerator.optionsFor(
        answer: operation.result,
        min: 0,
        max: maxOption,
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
      'aWords': _numberWord(operation.left, languageCode),
      'bWords': _numberWord(operation.right, languageCode),
      'tensWords': _numberWord(operation.right, languageCode),
      'unitsWords': _numberWord(operation.result, languageCode),
      'tensLabel': _tensLabel(operation.right, languageCode),
      'itemSingular': visualItem.singularLabel.get(languageCode),
      'itemPlural': visualItem.pluralLabel.get(languageCode),
      'itemPluralWithArticle':
          visualItem.pluralWithArticleLabel.get(languageCode),
      'aItemLabel': _itemLabel(operation.left, visualItem, languageCode),
      'bItemLabel': _itemLabel(operation.right, visualItem, languageCode),
      'countQuestion': _countQuestion(visualItem, languageCode),
      'totalQuestion': _totalQuestion(visualItem, languageCode),
      'additionHint': _additionHint(operation, languageCode),
      'subtractionHint': _subtractionHint(operation, languageCode),
      'remainingQuestion': _remainingQuestion(visualItem, languageCode),
      'remainingItemsPronoun': _remainingItemsPronoun(
        visualItem,
        languageCode,
      ),
      'aSpokenItemCount': _spokenItemCountPhrase(
        operation.left,
        visualItem,
        languageCode,
      ),
      'bSpokenItemCount': _spokenItemCountPhrase(
        operation.right,
        visualItem,
        languageCode,
      ),
    };
  }

  int _visualItemCountFor(LevelConfig level, OperationCandidate operation) {
    if (!level.visualSupport) {
      return 0;
    }

    if (operation.result > 10) {
      return 0;
    }

    return operation.result;
  }

  String _itemLabel(
    int count,
    VisualItem visualItem,
    String languageCode,
  ) {
    if (count == 1) {
      return visualItem.singularLabel.get(languageCode);
    }

    return visualItem.pluralLabel.get(languageCode);
  }

  String _tensLabel(int count, String languageCode) {
    if (languageCode == 'ca-ES') {
      return count == 1 ? 'desena' : 'desenes';
    }

    return count == 1 ? 'decena' : 'decenas';
  }

  String _additionHint(OperationCandidate operation, String languageCode) {
    final left = operation.left;
    final right = operation.right;
    final result = operation.result;

    if (result <= 10) {
      return languageCode == 'ca-ES'
          ? 'Comença en $left i avança $right passos.'
          : 'Empieza en $left y avanza $right pasos.';
    }

    if (right >= 10) {
      final tensPart = (right ~/ 10) * 10;
      final unitsPart = right % 10;
      if (unitsPart == 0) {
        return languageCode == 'ca-ES'
            ? 'Truc: suma primer $tensPart. Després revisa el resultat.'
            : 'Truco: suma primero $tensPart. Después revisa el resultado.';
      }

      return languageCode == 'ca-ES'
          ? 'Truc: separa $right en $tensPart i $unitsPart. Suma primer $tensPart i després $unitsPart.'
          : 'Truco: separa $right en $tensPart y $unitsPart. Suma primero $tensPart y después $unitsPart.';
    }

    final nextTen = ((left ~/ 10) + 1) * 10;
    final toNextTen = nextTen - left;
    if (toNextTen > 0 && toNextTen < right) {
      final remaining = right - toNextTen;
      return languageCode == 'ca-ES'
          ? 'Truc: completa la desena. De $left a $nextTen falten $toNextTen; després suma $remaining.'
          : 'Truco: completa la decena. De $left a $nextTen faltan $toNextTen; después suma $remaining.';
    }

    return languageCode == 'ca-ES'
        ? 'Truc: suma les unitats a poc a poc i comprova el total.'
        : 'Truco: suma las unidades poco a poco y comprueba el total.';
  }

  String _subtractionHint(OperationCandidate operation, String languageCode) {
    final left = operation.left;
    final right = operation.right;

    if (left <= 10) {
      return languageCode == 'ca-ES'
          ? 'Comença en $left i retrocedeix $right passos.'
          : 'Empieza en $left y retrocede $right pasos.';
    }

    if (right >= 10) {
      final tensPart = (right ~/ 10) * 10;
      final unitsPart = right % 10;
      if (unitsPart == 0) {
        return languageCode == 'ca-ES'
            ? 'Truc: treu primer $tensPart. Després revisa el resultat.'
            : 'Truco: quita primero $tensPart. Después revisa el resultado.';
      }

      return languageCode == 'ca-ES'
          ? 'Truc: separa $right en $tensPart i $unitsPart. Treu primer $tensPart i després $unitsPart.'
          : 'Truco: separa $right en $tensPart y $unitsPart. Quita primero $tensPart y después $unitsPart.';
    }

    final previousTen = (left ~/ 10) * 10;
    final toPreviousTen = left - previousTen;
    if (toPreviousTen > 0 && toPreviousTen < right) {
      final remaining = right - toPreviousTen;
      return languageCode == 'ca-ES'
          ? 'Truc: baixa fins a la desena. De $left a $previousTen treus $toPreviousTen; després treus $remaining.'
          : 'Truco: baja hasta la decena. De $left a $previousTen quitas $toPreviousTen; después quitas $remaining.';
    }

    return languageCode == 'ca-ES'
        ? 'Truc: treu les unitats a poc a poc i comprova el resultat.'
        : 'Truco: quita las unidades poco a poco y comprueba el resultado.';
  }

  String _countQuestion(VisualItem visualItem, String languageCode) {
    final gender = visualItem.gender.get(languageCode);
    if (languageCode == 'ca-ES') {
      return gender == 'feminine' ? "Quantes n'hi ha?" : "Quants n'hi ha?";
    }

    return gender == 'feminine' ? '¿Cuántas hay?' : '¿Cuántos hay?';
  }

  String _totalQuestion(VisualItem visualItem, String languageCode) {
    final gender = visualItem.gender.get(languageCode);
    if (languageCode == 'ca-ES') {
      return gender == 'feminine' ? 'Quantes en té?' : 'Quants en té?';
    }

    return gender == 'feminine' ? '¿Cuántas tiene?' : '¿Cuántos tiene?';
  }

  String _remainingQuestion(VisualItem visualItem, String languageCode) {
    final gender = visualItem.gender.get(languageCode);
    if (languageCode == 'ca-ES') {
      return gender == 'feminine' ? 'Quantes en queden?' : 'Quants en queden?';
    }

    return gender == 'feminine' ? '¿Cuántas quedan?' : '¿Cuántos quedan?';
  }

  String _remainingItemsPronoun(VisualItem visualItem, String languageCode) {
    final gender = visualItem.gender.get(languageCode);
    if (languageCode == 'ca-ES') {
      return gender == 'feminine' ? 'les que queden' : 'els que queden';
    }

    return gender == 'feminine' ? 'las que quedan' : 'los que quedan';
  }

  String _spokenItemCountPhrase(
    int count,
    VisualItem visualItem,
    String languageCode,
  ) {
    if (count == 1) {
      return visualItem.oneWithArticleLabel.get(languageCode);
    }

    return '${_numberWord(count, languageCode)} '
        '${visualItem.pluralLabel.get(languageCode)}';
  }

  String _apply(String pattern, Map<String, String> replacements) {
    var value = pattern;
    for (final entry in replacements.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }

    return value;
  }

  String _numberWord(int value, String languageCode) {
    final words = languageCode == 'ca-ES' ? _caNumbers : _esNumbers;
    return words[value] ?? '$value';
  }
}

const _esNumbers = {
  0: 'cero',
  1: 'uno',
  2: 'dos',
  3: 'tres',
  4: 'cuatro',
  5: 'cinco',
  6: 'seis',
  7: 'siete',
  8: 'ocho',
  9: 'nueve',
  10: 'diez',
  11: 'once',
  12: 'doce',
  13: 'trece',
  14: 'catorce',
  15: 'quince',
  16: 'dieciséis',
  17: 'diecisiete',
  18: 'dieciocho',
  19: 'diecinueve',
  20: 'veinte',
};

const _caNumbers = {
  0: 'zero',
  1: 'un',
  2: 'dos',
  3: 'tres',
  4: 'quatre',
  5: 'cinc',
  6: 'sis',
  7: 'set',
  8: 'vuit',
  9: 'nou',
  10: 'deu',
  11: 'onze',
  12: 'dotze',
  13: 'tretze',
  14: 'catorze',
  15: 'quinze',
  16: 'setze',
  17: 'disset',
  18: 'divuit',
  19: 'dinou',
  20: 'vint',
};

final exerciseGeneratorProvider = Provider<ExerciseGenerator>((ref) {
  return DynamicExerciseGenerator();
});
