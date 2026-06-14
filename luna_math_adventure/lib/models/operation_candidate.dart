class OperationCandidate {
  const OperationCandidate({
    required this.left,
    required this.operator,
    required this.right,
    required this.result,
  });

  final int left;
  final String operator;
  final int right;
  final int result;
}
