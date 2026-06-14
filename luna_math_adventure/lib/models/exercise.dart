class Exercise {
  const Exercise({
    required this.id,
    required this.levelId,
    required this.visibleText,
    required this.spokenText,
    required this.answer,
    required this.options,
    required this.visualItemIds,
  });

  final String id;
  final String levelId;
  final String visibleText;
  final String spokenText;
  final int answer;
  final List<int> options;
  final List<String> visualItemIds;
}
