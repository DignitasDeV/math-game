class Exercise {
  const Exercise({
    required this.id,
    required this.levelId,
    required this.type,
    required this.left,
    required this.right,
    required this.visibleText,
    required this.spokenText,
    required this.visibleHint,
    required this.spokenHint,
    required this.answer,
    required this.options,
    required this.visualItemId,
    required this.visualItemAssetPath,
    required this.visualItemIds,
  });

  final String id;
  final String levelId;
  final String type;
  final int left;
  final int right;
  final String visibleText;
  final String spokenText;
  final String visibleHint;
  final String spokenHint;
  final int answer;
  final List<int> options;
  final String visualItemId;
  final String visualItemAssetPath;
  final List<String> visualItemIds;
}
