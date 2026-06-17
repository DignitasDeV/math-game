import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/reward_visual.dart';
import '../../models/level_config.dart';
import '../../models/reward.dart';
import '../../services/audio_service.dart';
import '../../services/content_repository.dart';
import '../../services/profile_controller.dart';
import '../../services/progress_repository.dart';
import '../../services/ui_copy.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsState = ref.watch(rewardsProvider);
    final levelsState = ref.watch(levelsProvider);
    final progress = ref.watch(activeProgressProvider).valueOrNull;
    final languageCode =
        ref.watch(activeProfileProvider)?.language.ttsCode ?? 'es-ES';
    final earnedRewardIds = progress?.earnedRewardIds.toSet() ?? <String>{};

    return MagicScaffold(
      title: 'Recompensas',
      backgroundAssetPath:
          'assets/images/backgrounds/crystal_castle_screen.webp',
      child: rewardsState.when(
        data: (rewards) => levelsState.when(
          data: (levels) => _RewardsContent(
            rewards: rewards,
            levels: levels,
            earnedRewardIds: earnedRewardIds,
            languageCode: languageCode,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('No se pudieron cargar los niveles.'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('No se pudieron cargar las recompensas.'),
        ),
      ),
    );
  }
}

class _RewardsContent extends StatelessWidget {
  const _RewardsContent({
    required this.rewards,
    required this.levels,
    required this.earnedRewardIds,
    required this.languageCode,
  });

  final List<Reward> rewards;
  final List<LevelConfig> levels;
  final Set<String> earnedRewardIds;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final earnedCount =
        rewards.where((reward) => earnedRewardIds.contains(reward.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppScreenHeader(
          icon: Icons.emoji_events_rounded,
          title: languageCode == 'ca-ES' ? 'Recompenses' : 'Recompensas',
          subtitle: languageCode == 'ca-ES'
              ? '$earnedCount de ${rewards.length} desbloquejades'
              : '$earnedCount de ${rewards.length} desbloqueadas',
        ),
        const SizedBox(height: AppSpacing.lg),
        _RewardSummary(
          earnedCount: earnedCount,
          totalCount: rewards.length,
          languageCode: languageCode,
        ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: rewards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columnCount(context),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: _childAspectRatio(context),
            ),
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final earned = earnedRewardIds.contains(reward.id);
              final unlockLevel = _levelForReward(reward.id);

              return _RewardTile(
                reward: reward,
                earned: earned,
                unlockLevel: unlockLevel,
                languageCode: languageCode,
              ).animate(delay: (35 * index).ms).fadeIn(duration: 240.ms).scale(
                    begin: const Offset(0.94, 0.94),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => playTapAndRun(context, () => context.go('/home')),
            icon: const Icon(Icons.home_rounded),
            label: Text(languageCode == 'ca-ES' ? 'Inici' : 'Inicio'),
          ),
        ),
      ],
    );
  }

  int _columnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 700) {
      return 4;
    }
    if (width >= 460) {
      return 3;
    }
    if (width < 380) {
      return 1;
    }
    return 2;
  }

  double _childAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 380) {
      return 1.35;
    }

    return 0.92;
  }

  LevelConfig? _levelForReward(String rewardId) {
    for (final level in levels) {
      if (level.rewardId == rewardId) {
        return level;
      }
    }

    return null;
  }
}

class _RewardSummary extends StatelessWidget {
  const _RewardSummary({
    required this.earnedCount,
    required this.totalCount,
    required this.languageCode,
  });

  final int earnedCount;
  final int totalCount;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : earnedCount / totalCount;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softLilac.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const _SparkleMedal(),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageCode == 'ca-ES'
                        ? 'Col.leccio magica'
                        : 'Coleccion magica',
                    style: AppTypography.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      color: AppColors.pinkAccent,
                      backgroundColor:
                          AppColors.softLilac.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleMedal extends StatelessWidget {
  const _SparkleMedal();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.starGold.withValues(alpha: 0.32),
              shape: BoxShape.circle,
            ),
            child: const SizedBox.expand(),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                duration: 1600.ms,
                color: Colors.white.withValues(alpha: 0.65),
              ),
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.purpleText,
            size: 34,
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.reward,
    required this.earned,
    required this.unlockLevel,
    required this.languageCode,
  });

  final Reward reward;
  final bool earned;
  final LevelConfig? unlockLevel;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final color = _rewardColor(reward);

    return Material(
      color: earned
          ? Colors.white.withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.66),
      borderRadius: BorderRadius.circular(20),
      elevation: earned ? 3 : 0,
      shadowColor: color.withValues(alpha: 0.22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showRewardDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: Opacity(
                  opacity: earned ? 1 : 0.34,
                  child: RewardVisual(reward: reward),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                reward.name.get(languageCode),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color:
                      earned ? AppColors.purpleText : AppColors.purpleTextLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Icon(
                earned ? Icons.check_circle_rounded : Icons.lock_rounded,
                color:
                    earned ? AppColors.successGreen : AppColors.purpleTextLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRewardDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      animationStyle: AppMotion.dialog,
      builder: (context) => _RewardDetailsDialog(
        reward: reward,
        earned: earned,
        unlockLevel: unlockLevel,
        languageCode: languageCode,
      ),
    );
  }
}

Color _rewardColor(Reward reward) {
  return rewardColor(reward);
}

class _RewardDetailsDialog extends StatelessWidget {
  const _RewardDetailsDialog({
    required this.reward,
    required this.earned,
    required this.unlockLevel,
    required this.languageCode,
  });

  final Reward reward;
  final bool earned;
  final LevelConfig? unlockLevel;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 136,
                  child: RewardVisual(reward: reward),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  reward.name.get(languageCode),
                  textAlign: TextAlign.center,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                _RewardStatusPill(
                  earned: earned,
                  languageCode: languageCode,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _statusText(),
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.md),
                _RewardHowToUnlock(
                  reward: reward,
                  unlockLevel: unlockLevel,
                  languageCode: languageCode,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(UiCopy.ok(languageCode)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusText() {
    if (languageCode == 'ca-ES') {
      return earned
          ? 'Ja la tens a la teva col·lecció.'
          : 'Encara no està desbloquejada.';
    }

    return earned
        ? 'Ya la tienes en tu coleccion.'
        : 'Todavia no esta desbloqueada.';
  }
}

class _RewardStatusPill extends StatelessWidget {
  const _RewardStatusPill({
    required this.earned,
    required this.languageCode,
  });

  final bool earned;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final color = earned ? AppColors.successGreen : AppColors.softLilac;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              earned ? Icons.check_circle_rounded : Icons.lock_rounded,
              color: HSLColor.fromColor(color).withLightness(0.35).toColor(),
              size: 18,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _statusLabel(),
              style: AppTypography.chip,
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    if (languageCode == 'ca-ES') {
      return earned ? 'Desbloquejada' : 'Bloquejada';
    }

    return earned ? 'Desbloqueada' : 'Bloqueada';
  }
}

class _RewardHowToUnlock extends StatelessWidget {
  const _RewardHowToUnlock({
    required this.reward,
    required this.unlockLevel,
    required this.languageCode,
  });

  final Reward reward;
  final LevelConfig? unlockLevel;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softLilac.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.softLilac.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              _rewardTypeLabel(reward.type, languageCode),
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(
                color: AppColors.purpleTextLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _unlockText(),
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong,
            ),
          ],
        ),
      ),
    );
  }

  String _unlockText() {
    final level = unlockLevel;
    if (level == null) {
      return languageCode == 'ca-ES'
          ? 'Aquesta recompensa especial encara no està assignada a un nivell.'
          : 'Esta recompensa especial aun no esta asignada a un nivel.';
    }

    final levelTitle = level.title.get(languageCode);
    return languageCode == 'ca-ES'
        ? "S'aconsegueix completant el nivell: $levelTitle."
        : 'Se consigue completando el nivel: $levelTitle.';
  }

  String _rewardTypeLabel(String type, String languageCode) {
    if (languageCode == 'ca-ES') {
      return switch (type) {
        'badge' => 'Insignia',
        'accessory' => 'Accessori',
        _ => 'Enganxina',
      };
    }

    return switch (type) {
      'badge' => 'Insignia',
      'accessory' => 'Accesorio',
      _ => 'Pegatina',
    };
  }
}
