import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/player_progress.dart';
import 'package:luna_math_adventure/models/unicorn_avatar_stage.dart';

void main() {
  test('normalizes legacy level ids without duplicates', () {
    final progress = PlayerProgress.fromJson({
      'profileId': 'profile_1',
      'unlockedLevelIds': [
        'meadow_1',
        'heart_forest_01',
        'meadow_2',
        '',
      ],
      'completedLevelIds': [
        'meadow_1',
        'heart_forest_01',
        'heart_forest_03',
      ],
      'starsByLevel': {
        'meadow_1': 2,
        'heart_forest_03': '3',
        '': 1,
      },
      'lastLevelId': 'meadow_2',
      'earnedRewardIds': ['sticker_heart'],
    });

    expect(progress.unlockedLevelIds, ['heart_forest_01', 'heart_forest_03']);
    expect(progress.completedLevelIds, ['heart_forest_01', 'heart_forest_03']);
    expect(progress.starsByLevel, {
      'heart_forest_01': 2,
      'heart_forest_03': 3,
    });
    expect(progress.lastLevelId, 'heart_forest_03');
    expect(progress.unlockedUnicornStage, UnicornAvatarStage.stage01);
  });

  test('keeps first heart forest level unlocked for empty progress', () {
    final progress = PlayerProgress.fromJson({
      'profileId': 'profile_1',
      'unlockedLevelIds': [],
    });

    expect(progress.unlockedLevelIds, ['heart_forest_01']);
  });

  test('initial progress starts with unicorn stage 01', () {
    final progress = PlayerProgress.initial('profile_1');

    expect(progress.unlockedUnicornStageId, 'stage_01');
    expect(progress.unlockedUnicornStage, UnicornAvatarStage.stage01);
  });

  test('persists unlocked unicorn stage id', () {
    final progress = PlayerProgress.initial('profile_1').copyWith(
      unlockedUnicornStageId: UnicornAvatarStage.stage03.id,
    );

    final restored = PlayerProgress.fromJson(progress.toJson());

    expect(restored.unlockedUnicornStage, UnicornAvatarStage.stage03);
  });

  test('old progress without unicorn stage migrates to stage 01', () {
    final progress = PlayerProgress.fromJson({
      'profileId': 'profile_1',
      'unlockedLevelIds': ['heart_forest_01'],
    });

    expect(progress.unlockedUnicornStage, UnicornAvatarStage.stage01);
  });
}
