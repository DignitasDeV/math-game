import '../models/level_config.dart';
import '../models/player_progress.dart';
import '../models/unicorn_avatar_stage.dart';

class UnicornEvolutionRule {
  const UnicornEvolutionRule({
    required this.stage,
    required this.requiredWorldId,
  });

  final UnicornAvatarStage stage;
  final String requiredWorldId;
}

const unicornEvolutionRules = [
  UnicornEvolutionRule(
    stage: UnicornAvatarStage.stage02,
    requiredWorldId: 'star_lake',
  ),
  UnicornEvolutionRule(
    stage: UnicornAvatarStage.stage03,
    requiredWorldId: 'rainbow_path',
  ),
  UnicornEvolutionRule(
    stage: UnicornAvatarStage.stage04,
    requiredWorldId: 'crystal_castle',
  ),
];

UnicornAvatarStage unlockedUnicornStageForProgress({
  required PlayerProgress progress,
  required List<LevelConfig> levels,
}) {
  var stage = progress.unlockedUnicornStage;
  final unlockedWorldIds = _unlockedWorldIds(progress, levels);

  for (final rule in unicornEvolutionRules) {
    if (unlockedWorldIds.contains(rule.requiredWorldId) &&
        rule.stage.index > stage.index) {
      stage = rule.stage;
    }
  }

  return stage;
}

UnicornAvatarStage? newlyUnlockedUnicornStage({
  required PlayerProgress previousProgress,
  required PlayerProgress nextProgress,
  required List<LevelConfig> levels,
}) {
  final previousStage = previousProgress.unlockedUnicornStage;
  final nextStage = unlockedUnicornStageForProgress(
    progress: nextProgress,
    levels: levels,
  );

  return nextStage.index > previousStage.index ? nextStage : null;
}

Set<String> _unlockedWorldIds(
  PlayerProgress progress,
  List<LevelConfig> levels,
) {
  final unlockedLevelIds = progress.unlockedLevelIds.toSet();
  return {
    for (final level in levels)
      if (unlockedLevelIds.contains(level.id)) level.worldId,
  };
}
