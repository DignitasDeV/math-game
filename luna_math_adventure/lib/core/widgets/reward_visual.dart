import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../models/reward.dart';
import 'safe_asset_image.dart';

class RewardVisual extends StatelessWidget {
  const RewardVisual({
    required this.reward,
    this.fit = BoxFit.contain,
    super.key,
  });

  final Reward reward;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final color = rewardColor(reward);
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();

    return SafeAssetImage(
      assetPath: reward.assetPath,
      fit: fit,
      placeholder: CodeRewardVisual(
        reward: reward,
        color: color,
        iconColor: iconColor,
      ),
    );
  }
}

class CodeRewardVisual extends StatelessWidget {
  const CodeRewardVisual({
    required this.reward,
    required this.color,
    required this.iconColor,
    super.key,
  });

  final Reward reward;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        shape: reward.type == 'badge' ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: reward.type == 'badge' ? BorderRadius.circular(18) : null,
        border: Border.all(
          color: color.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          rewardIcon(reward),
          color: iconColor,
          size: 44,
        ),
      ),
    );
  }
}

IconData rewardIcon(Reward reward) {
  return switch (reward.id) {
    'magic_wand' => Icons.auto_fix_high_rounded,
    'necklace_star' => Icons.diamond_rounded,
    'wings_rainbow' => Icons.air_rounded,
    'badge_10_correct' => Icons.looks_one_rounded,
    'badge_level_complete' => Icons.verified_rounded,
    'sticker_rainbow' => Icons.filter_vintage_rounded,
    'sticker_unicorn' => Icons.auto_awesome_rounded,
    _ => switch (reward.type) {
        'badge' => Icons.workspace_premium_rounded,
        'accessory' => Icons.diamond_rounded,
        _ => Icons.star_rounded,
      },
  };
}

Color rewardColor(Reward reward) {
  return switch (reward.type) {
    'badge' => AppColors.starGold,
    'accessory' => AppColors.softLilac,
    _ => switch (reward.id) {
        String id when id.contains('heart') => AppColors.magicPink,
        String id when id.contains('rainbow') => AppColors.skyBlue,
        String id when id.contains('crystal') => AppColors.softLilac,
        _ => AppColors.softMint,
      },
  };
}
