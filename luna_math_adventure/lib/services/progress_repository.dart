import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_progress.dart';

abstract class ProgressRepository {
  Future<PlayerProgress> loadProgress();
  Future<void> saveProgress(PlayerProgress progress);
}

class InMemoryProgressRepository implements ProgressRepository {
  PlayerProgress _progress = const PlayerProgress(
    unlockedLevelIds: ['meadow_1'],
    lastLevelId: 'meadow_1',
    earnedRewardIds: [],
  );

  @override
  Future<PlayerProgress> loadProgress() async => _progress;

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    _progress = progress;
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return InMemoryProgressRepository();
});
