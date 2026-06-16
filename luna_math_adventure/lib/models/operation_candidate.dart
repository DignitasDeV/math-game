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
