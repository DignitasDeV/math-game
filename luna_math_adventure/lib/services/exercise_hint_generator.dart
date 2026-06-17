import '../models/exercise_hint_step.dart';
import '../models/operation_candidate.dart';
import '../models/visual_item.dart';
import 'localized_grammar.dart';

class ExerciseHints {
  const ExerciseHints({
    required this.visibleHint,
    required this.spokenHint,
    this.steps = const [],
  });

  final String visibleHint;
  final String spokenHint;
  final List<ExerciseHintStep> steps;
}

abstract class ExerciseHintGenerator {
  ExerciseHints hintsFor({
    required OperationCandidate operation,
    required VisualItem visualItem,
    required String languageCode,
  });
}

class StrategyExerciseHintGenerator implements ExerciseHintGenerator {
  const StrategyExerciseHintGenerator();

  @override
  ExerciseHints hintsFor({
    required OperationCandidate operation,
    required VisualItem visualItem,
    required String languageCode,
  }) {
    final steps = _stepsFor(
      operation: operation,
      visualItem: visualItem,
      languageCode: languageCode,
    );
    final visibleHint = steps.last.visibleText;

    return ExerciseHints(
      visibleHint: visibleHint,
      spokenHint: visibleHint,
      steps: steps,
    );
  }

  List<ExerciseHintStep> _stepsFor({
    required OperationCandidate operation,
    required VisualItem visualItem,
    required String languageCode,
  }) {
    return switch (operation.type) {
      'count' => _countSteps(
          visualItem: visualItem,
          languageCode: languageCode,
        ),
      'addition' => _additionSteps(
          operation: operation,
          languageCode: languageCode,
        ),
      'subtraction' => _subtractionSteps(
          operation: operation,
          languageCode: languageCode,
        ),
      'decomposition' => _decompositionSteps(
          operation: operation,
          languageCode: languageCode,
        ),
      _ => [
          _same(
            languageCode == 'ca-ES'
                ? 'Mira els números amb calma.'
                : 'Mira los números con calma.',
          ),
        ],
    };
  }

  List<ExerciseHintStep> _countSteps({
    required VisualItem visualItem,
    required String languageCode,
  }) {
    final item = visualItem.singularLabel.get(languageCode);
    return [
      _same(
        languageCode == 'ca-ES'
            ? 'Mira cada $item una vegada.'
            : 'Mira cada $item una vez.',
      ),
      _same(
        languageCode == 'ca-ES'
            ? 'Mira cada $item una vegada i compta a poc a poc.'
            : 'Mira cada $item una vez y cuenta despacito.',
      ),
    ];
  }

  List<ExerciseHintStep> _additionSteps({
    required OperationCandidate operation,
    required String languageCode,
  }) {
    final left = operation.left;
    final right = operation.right;
    final result = operation.result;
    final stepPhrase = LocalizedGrammar.stepCountPhrase(right, languageCode);

    if (result <= 10) {
      return [
        _same(
          languageCode == 'ca-ES' ? 'Comença en $left.' : 'Empieza en $left.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? 'Comença en $left i avança $stepPhrase.'
              : 'Empieza en $left y avanza $stepPhrase.',
        ),
      ];
    }

    final nextTen = ((left ~/ 10) + 1) * 10;
    final toNextTen = nextTen - left;
    if (right < 10 && toNextTen > 0 && toNextTen < right) {
      final remaining = right - toNextTen;
      return [
        _same(
          languageCode == 'ca-ES'
              ? 'Completa la desena.'
              : 'Completa la decena.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? 'Completa la desena: de $left a $nextTen ${LocalizedGrammar.missingPhrase(toNextTen, languageCode)}; després suma $remaining.'
              : 'Completa la decena: de $left a $nextTen ${LocalizedGrammar.missingPhrase(toNextTen, languageCode)}; después suma $remaining.',
        ),
      ];
    }

    if (operation.requiresCarry) {
      final leftUnits = left % 10;
      final rightUnits = right % 10;
      return [
        _same(
          languageCode == 'ca-ES'
              ? 'Suma primer les unitats.'
              : 'Suma primero las unidades.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? '$leftUnits + $rightUnits passa de 9 i forma una desena nova.'
              : '$leftUnits + $rightUnits pasa de 9 y forma una decena nueva.',
        ),
      ];
    }

    if (right >= 10) {
      final tensPart = (right ~/ 10) * 10;
      final unitsPart = right % 10;
      if (unitsPart == 0) {
        return [
          _same(
            languageCode == 'ca-ES'
                ? 'Suma primer $tensPart.'
                : 'Suma primero $tensPart.',
          ),
          _same(
            languageCode == 'ca-ES'
                ? 'Suma primer $tensPart i després revisa el resultat.'
                : 'Suma primero $tensPart y después revisa el resultado.',
          ),
        ];
      }

      return [
        _same(
          languageCode == 'ca-ES'
              ? 'Separa $right en $tensPart i $unitsPart.'
              : 'Separa $right en $tensPart y $unitsPart.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? 'Separa $right en $tensPart i $unitsPart. Suma primer $tensPart i després $unitsPart.'
              : 'Separa $right en $tensPart y $unitsPart. Suma primero $tensPart y después $unitsPart.',
        ),
      ];
    }

    return [
      _same(
        languageCode == 'ca-ES'
            ? 'Suma les unitats a poc a poc i comprova el total.'
            : 'Suma las unidades poco a poco y comprueba el total.',
      ),
    ];
  }

  List<ExerciseHintStep> _subtractionSteps({
    required OperationCandidate operation,
    required String languageCode,
  }) {
    final left = operation.left;
    final right = operation.right;
    final stepPhrase = LocalizedGrammar.stepCountPhrase(right, languageCode);

    if (left <= 10) {
      return [
        _same(
          languageCode == 'ca-ES' ? 'Comença en $left.' : 'Empieza en $left.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? 'Comença en $left i retrocedeix $stepPhrase.'
              : 'Empieza en $left y retrocede $stepPhrase.',
        ),
      ];
    }

    if (right >= 10) {
      final tensPart = (right ~/ 10) * 10;
      final unitsPart = right % 10;
      if (unitsPart == 0) {
        return [
          _same(
            languageCode == 'ca-ES'
                ? 'Treu primer $tensPart.'
                : 'Quita primero $tensPart.',
          ),
          _same(
            languageCode == 'ca-ES'
                ? 'Treu primer $tensPart i després revisa el resultat.'
                : 'Quita primero $tensPart y después revisa el resultado.',
          ),
        ];
      }

      return [
        _same(
          languageCode == 'ca-ES'
              ? 'Separa $right en $tensPart i $unitsPart.'
              : 'Separa $right en $tensPart y $unitsPart.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? 'Separa $right en $tensPart i $unitsPart. Treu primer $tensPart i després $unitsPart.'
              : 'Separa $right en $tensPart y $unitsPart. Quita primero $tensPart y después $unitsPart.',
        ),
      ];
    }

    final previousTen = (left ~/ 10) * 10;
    final toPreviousTen = left - previousTen;
    if (toPreviousTen > 0 && toPreviousTen < right) {
      final remaining = right - toPreviousTen;
      return [
        _same(
          languageCode == 'ca-ES'
              ? 'Baixa fins a la desena.'
              : 'Baja hasta la decena.',
        ),
        _same(
          languageCode == 'ca-ES'
              ? 'Baixa fins a la desena: de $left a $previousTen treus $toPreviousTen; després treus $remaining.'
              : 'Baja hasta la decena: de $left a $previousTen quitas $toPreviousTen; después quitas $remaining.',
        ),
      ];
    }

    return [
      _same(
        languageCode == 'ca-ES'
            ? 'Treu les unitats a poc a poc i comprova el resultat.'
            : 'Quita las unidades poco a poco y comprueba el resultado.',
      ),
    ];
  }

  List<ExerciseHintStep> _decompositionSteps({
    required OperationCandidate operation,
    required String languageCode,
  }) {
    final value = operation.left;
    final tens = operation.right;
    final units = operation.result;

    return [
      _same(
        languageCode == 'ca-ES'
            ? 'Mira el nombre $value.'
            : 'Mira el número $value.',
      ),
      _same(
        languageCode == 'ca-ES'
            ? 'Mira $value: el $tens marca les desenes i el $units marca les unitats.'
            : 'Mira $value: el $tens marca las decenas y el $units marca las unidades.',
      ),
    ];
  }

  ExerciseHintStep _same(String text) {
    return ExerciseHintStep(
      visibleText: text,
      spokenText: text,
    );
  }
}
