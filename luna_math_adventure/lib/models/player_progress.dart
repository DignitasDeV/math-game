class PlayerProgress {
  const PlayerProgress({
    required this.unlockedLevelIds,
    required this.lastLevelId,
    required this.earnedRewardIds,
  });

  final List<String> unlockedLevelIds;
  final String lastLevelId;
  final List<String> earnedRewardIds;
}
