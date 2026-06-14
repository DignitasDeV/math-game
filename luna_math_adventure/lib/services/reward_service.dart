abstract class RewardService {
  Future<String?> rewardForLevel(String levelId);
}

class SimpleRewardService implements RewardService {
  @override
  Future<String?> rewardForLevel(String levelId) async => 'star_badge';
}
