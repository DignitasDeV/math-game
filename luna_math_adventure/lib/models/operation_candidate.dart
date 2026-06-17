enum OperationStrategyTag {
  count,
  addition,
  subtraction,
  decomposition,
  withinFive,
  withinTen,
  usesTens,
  crossesTen,
  requiresCarry,
  nearDouble,
  tensAndUnits,
}

class OperationCandidate {
  const OperationCandidate({
    required this.left,
    required this.type,
    required this.right,
    required this.result,
  });

  final int left;
  final String type;
  final int right;
  final int result;

  Set<OperationStrategyTag> get strategyTags {
    final tags = <OperationStrategyTag>{};

    switch (type) {
      case 'count':
        tags.add(OperationStrategyTag.count);
        break;
      case 'addition':
        tags.add(OperationStrategyTag.addition);
        break;
      case 'subtraction':
        tags.add(OperationStrategyTag.subtraction);
        break;
      case 'decomposition':
        tags.add(OperationStrategyTag.decomposition);
        tags.add(OperationStrategyTag.tensAndUnits);
        break;
    }

    if (highestValue <= 5) {
      tags.add(OperationStrategyTag.withinFive);
    }
    if (highestValue <= 10) {
      tags.add(OperationStrategyTag.withinTen);
    }
    if (usesTens) {
      tags.add(OperationStrategyTag.usesTens);
    }
    if (crossesTen) {
      tags.add(OperationStrategyTag.crossesTen);
    }
    if (requiresCarry) {
      tags.add(OperationStrategyTag.requiresCarry);
    }
    if (isNearDouble) {
      tags.add(OperationStrategyTag.nearDouble);
    }

    return tags;
  }

  int get highestValue => [left, right, result].reduce((a, b) => a > b ? a : b);

  bool get usesTens => highestValue >= 10;

  bool get crossesTen {
    if (type != 'addition') {
      return false;
    }

    return left < 10 && result > 10 || right < 10 && result > 10;
  }

  bool get requiresCarry {
    if (type != 'addition') {
      return false;
    }

    final hasTens = left >= 10 || right >= 10;
    return hasTens && (left % 10) + (right % 10) >= 10;
  }

  bool get isNearDouble {
    if (type != 'addition') {
      return false;
    }

    return (left - right).abs() <= 1;
  }

  int get difficultyScore {
    var score = 1;

    if (!strategyTags.contains(OperationStrategyTag.withinFive)) {
      score++;
    }
    if (!strategyTags.contains(OperationStrategyTag.withinTen)) {
      score++;
    }
    if (usesTens) {
      score++;
    }
    if (crossesTen) {
      score++;
    }
    if (requiresCarry) {
      score++;
    }
    if (type == 'decomposition') {
      score++;
    }

    return score;
  }

  String get key {
    if (type == 'addition') {
      final values = [left, right]..sort();
      return '${values[0]}+${values[1]}';
    }

    if (type == 'count') {
      return 'count:$result';
    }

    if (type == 'decomposition') {
      return 'decompose:$left';
    }

    return '$left-$right';
  }
}
