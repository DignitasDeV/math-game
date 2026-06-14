class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.worldId,
    required this.minNumber,
    required this.maxNumber,
    required this.operations,
  });

  final String id;
  final String worldId;
  final int minNumber;
  final int maxNumber;
  final List<String> operations;
}
