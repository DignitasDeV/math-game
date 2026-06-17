import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/models/player_progress.dart';
import 'package:luna_math_adventure/models/unicorn_avatar_stage.dart';
import 'package:luna_math_adventure/services/unicorn_evolution_rules.dart';

void main() {
  test('keeps stage 01 before world 2 is unlocked', () {
    final progress = PlayerProgress.initial('profile_1');

    expect(
      unlockedUnicornStageForProgress(
        progress: progress,
        levels: _levels,
      ),
      UnicornAvatarStage.stage01,
    );
  });

  test('unlocks stage 02 when star lake is unlocked', () {
    final progress = PlayerProgress.initial('profile_1').copyWith(
      unlockedLevelIds: ['heart_forest_01', 'star_lake_01'],
    );

    expect(
      unlockedUnicornStageForProgress(
        progress: progress,
        levels: _levels,
      ),
      UnicornAvatarStage.stage02,
    );
  });

  test('unlocks stage 03 when rainbow path is unlocked', () {
    final progress = PlayerProgress.initial('profile_1').copyWith(
      unlockedLevelIds: ['heart_forest_01', 'rainbow_path_01'],
    );

    expect(
      unlockedUnicornStageForProgress(
        progress: progress,
        levels: _levels,
      ),
      UnicornAvatarStage.stage03,
    );
  });

  test('unlocks stage 04 when crystal castle is unlocked', () {
    final progress = PlayerProgress.initial('profile_1').copyWith(
      unlockedLevelIds: ['heart_forest_01', 'crystal_castle_01'],
    );

    expect(
      unlockedUnicornStageForProgress(
        progress: progress,
        levels: _levels,
      ),
      UnicornAvatarStage.stage04,
    );
  });

  test('does not downgrade an already unlocked stage', () {
    final progress = PlayerProgress.initial('profile_1').copyWith(
      unlockedLevelIds: ['heart_forest_01', 'star_lake_01'],
      unlockedUnicornStageId: UnicornAvatarStage.stage03.id,
    );

    expect(
      unlockedUnicornStageForProgress(
        progress: progress,
        levels: _levels,
      ),
      UnicornAvatarStage.stage03,
    );
  });

  test('reports stage 02 when completing a level opens star lake', () {
    final previousProgress = PlayerProgress.initial('profile_1').copyWith(
      unlockedLevelIds: ['heart_forest_01'],
    );
    final nextProgress = previousProgress.copyWith(
      unlockedLevelIds: ['heart_forest_01', 'star_lake_01'],
    );

    expect(
      newlyUnlockedUnicornStage(
        previousProgress: previousProgress,
        nextProgress: nextProgress,
        levels: _levels,
      ),
      UnicornAvatarStage.stage02,
    );
  });

  test('does not report an evolution again when replaying', () {
    final previousProgress = PlayerProgress.initial('profile_1').copyWith(
      unlockedLevelIds: ['heart_forest_01', 'star_lake_01'],
      unlockedUnicornStageId: UnicornAvatarStage.stage02.id,
    );
    final nextProgress = previousProgress.copyWith(
      completedLevelIds: ['heart_forest_boss'],
    );

    expect(
      newlyUnlockedUnicornStage(
        previousProgress: previousProgress,
        nextProgress: nextProgress,
        levels: _levels,
      ),
      isNull,
    );
  });
}

final _levels = [
  _level('heart_forest_01', 'heart_forest', 1),
  _level('star_lake_01', 'star_lake', 2),
  _level('rainbow_path_01', 'rainbow_path', 3),
  _level('crystal_castle_01', 'crystal_castle', 4),
];

LevelConfig _level(String id, String worldId, int sortOrder) {
  return LevelConfig(
    id: id,
    worldId: worldId,
    title: const LocalizedText(es: 'Nivel', ca: 'Nivell'),
    subtitle: const LocalizedText(es: 'Subtitulo', ca: 'Subtitol'),
    exerciseTypes: const ['count'],
    minNumber: 1,
    maxNumber: 10,
    maxResult: 10,
    allowNegativeResults: false,
    allowCarry: false,
    visualSupport: true,
    questionsToComplete: 5,
    starsToUnlockNext: 1,
    rewardId: null,
    visualItemIds: const [],
    sortOrder: sortOrder,
  );
}
