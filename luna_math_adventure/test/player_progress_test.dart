import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/player_progress.dart';

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
  });

  test('keeps first heart forest level unlocked for empty progress', () {
    final progress = PlayerProgress.fromJson({
      'profileId': 'profile_1',
      'unlockedLevelIds': [],
    });

    expect(progress.unlockedLevelIds, ['heart_forest_01']);
  });
}
