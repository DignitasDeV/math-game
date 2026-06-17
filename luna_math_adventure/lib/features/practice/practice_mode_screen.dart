import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/responsive_action_grid.dart';
import '../../core/widgets/safe_asset_image.dart';
import '../../core/widgets/speech_toggle_button.dart';
import '../../core/widgets/unicorn_avatar_image.dart';
import '../../models/unicorn_avatar.dart';
import '../../models/unicorn_avatar_stage.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
import '../../services/progress_repository.dart';
import '../../services/speech_playback_controller.dart';
import '../../services/speech_service.dart';
import '../../services/unicorn_avatar_asset_resolver.dart';
import 'practice_session_controller.dart';

class PracticeModeScreen extends ConsumerStatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  ConsumerState<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends ConsumerState<PracticeModeScreen> {
  var _topic = PracticeTopic.count;
  var _difficulty = PracticeDifficulty.upTo10;
  var _isChoosingDifficulty = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(practiceSessionProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final progress = ref.watch(activeProgressProvider).valueOrNull;
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';
    final unicornStage =
        progress?.unlockedUnicornStage ?? UnicornAvatarStage.stage01;

    return MagicScaffold(
      title: languageCode == 'ca-ES' ? 'Pràctica lliure' : 'Práctica libre',
      backgroundAssetPath: 'assets/images/backgrounds/star_lake_screen.webp',
      child: sessionState.when(
        data: (session) {
          if (session == null) {
            return _PracticeSelector(
              topic: _topic,
              difficulty: _difficulty,
              isChoosingDifficulty: _isChoosingDifficulty,
              languageCode: languageCode,
              onTopicChanged: (topic) => setState(() {
                _topic = topic;
                _isChoosingDifficulty = true;
              }),
              onDifficultyChanged: (difficulty) =>
                  setState(() => _difficulty = difficulty),
              onBackToTopics: () => setState(() {
                _isChoosingDifficulty = false;
              }),
              onStart: () => ref.read(practiceSessionProvider.notifier).start(
                    PracticeSessionConfig(
                      topic: _topic,
                      difficulty: _difficulty,
                    ),
                  ),
            );
          }

          if (session.isComplete) {
            return _PracticeSummary(
              session: session,
              languageCode: languageCode,
              avatar: activeProfile?.unicornAvatar ?? UnicornAvatar.avatar01,
              stage: unicornStage,
              characterName: activeProfile?.unicornName ?? 'Luna',
              onRepeat: ref.read(practiceSessionProvider.notifier).repeat,
              onChangePractice:
                  ref.read(practiceSessionProvider.notifier).changePractice,
            );
          }

          return _PracticeExerciseView(
            session: session,
            languageCode: languageCode,
            avatar: activeProfile?.unicornAvatar ?? UnicornAvatar.avatar01,
            stage: unicornStage,
            characterName: activeProfile?.unicornName ?? 'Luna',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.read(practiceSessionProvider.notifier).start(
                  PracticeSessionConfig(
                    topic: _topic,
                    difficulty: _difficulty,
                  ),
                ),
            icon: const Icon(Symbols.refresh_rounded),
            label: Text(
              languageCode == 'ca-ES' ? 'Torna-ho a provar' : 'Reintentar',
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeSelector extends StatelessWidget {
  const _PracticeSelector({
    required this.topic,
    required this.difficulty,
    required this.isChoosingDifficulty,
    required this.languageCode,
    required this.onTopicChanged,
    required this.onDifficultyChanged,
    required this.onBackToTopics,
    required this.onStart,
  });

  final PracticeTopic topic;
  final PracticeDifficulty difficulty;
  final bool isChoosingDifficulty;
  final String languageCode;
  final ValueChanged<PracticeTopic> onTopicChanged;
  final ValueChanged<PracticeDifficulty> onDifficultyChanged;
  final VoidCallback onBackToTopics;
  final FutureOr<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    return _PracticeReadablePanel(
      child: isChoosingDifficulty
          ? _DifficultyStep(
              topic: topic,
              difficulty: difficulty,
              languageCode: languageCode,
              onChanged: onDifficultyChanged,
              onBack: onBackToTopics,
              onStart: onStart,
            )
          : _TopicStep(
              languageCode: languageCode,
              onTopicChanged: onTopicChanged,
            ),
    );
  }
}

class _PracticeReadablePanel extends StatelessWidget {
  const _PracticeReadablePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softLilac.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleText.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _TopicStep extends StatelessWidget {
  const _TopicStep({
    required this.languageCode,
    required this.onTopicChanged,
  });

  final String languageCode;
  final ValueChanged<PracticeTopic> onTopicChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppScreenHeader(
          icon: Symbols.fitness_center_rounded,
          title: languageCode == 'ca-ES'
              ? 'Que vols practicar?'
              : 'Que quieres practicar?',
          subtitle: languageCode == 'ca-ES'
              ? 'Primer tria el tema.'
              : 'Primero elige el tema.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppBreakpoints.narrowWidth;

              return ResponsiveActionGrid(
                columns: isNarrow ? 1 : 2,
                minRows: isNarrow ? _PracticeTopicViewData.values.length : 2,
                gap: isNarrow ? AppSpacing.sm : AppSpacing.md,
                children: [
                  for (final item in _PracticeTopicViewData.values)
                    _PracticeTopicTile(
                      data: item,
                      languageCode: languageCode,
                      isSelected: false,
                      compact: isNarrow,
                      onTap: () => onTopicChanged(item.topic),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DifficultyStep extends StatelessWidget {
  const _DifficultyStep({
    required this.topic,
    required this.difficulty,
    required this.languageCode,
    required this.onChanged,
    required this.onBack,
    required this.onStart,
  });

  final PracticeTopic topic;
  final PracticeDifficulty difficulty;
  final String languageCode;
  final ValueChanged<PracticeDifficulty> onChanged;
  final VoidCallback onBack;
  final FutureOr<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShort = constraints.maxHeight < 560;
        final gap = isShort ? AppSpacing.sm : AppSpacing.md;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppScreenHeader(
              icon: Symbols.tune_rounded,
              title: languageCode == 'ca-ES'
                  ? 'Tria els números'
                  : 'Elige los números',
              subtitle: topic.title(languageCode),
            ),
            SizedBox(height: isShort ? AppSpacing.sm : AppSpacing.md),
            Expanded(
              child: _DifficultyOptionsGrid(
                gap: gap,
                topic: topic,
                difficulty: difficulty,
                languageCode: languageCode,
                onChanged: onChanged,
              ),
            ),
            SizedBox(height: isShort ? AppSpacing.sm : AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => playTapAndRun(context, onBack),
                      icon: const Icon(Symbols.arrow_back_rounded),
                      label: Text(languageCode == 'ca-ES' ? 'Tema' : 'Tema'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => playTapAndRun(context, onStart),
                      icon: const Icon(Symbols.play_arrow_rounded),
                      label: Text(
                        languageCode == 'ca-ES' ? 'Començar' : 'Empezar',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DifficultyOptionsGrid extends StatelessWidget {
  const _DifficultyOptionsGrid({
    required this.gap,
    required this.topic,
    required this.difficulty,
    required this.languageCode,
    required this.onChanged,
  });

  final double gap;
  final PracticeTopic topic;
  final PracticeDifficulty difficulty;
  final String languageCode;
  final ValueChanged<PracticeDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const targetHeight = 336.0;
        final gridHeight = math.min(constraints.maxHeight, targetHeight);

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: gridHeight,
            child: ResponsiveActionGrid(
              columns: 1,
              gap: gap,
              children: [
                for (final item in _PracticeDifficultyViewData.values)
                  _DifficultyTile(
                    data: item,
                    topic: topic,
                    languageCode: languageCode,
                    isSelected: item.difficulty == difficulty,
                    onTap: () => onChanged(item.difficulty),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PracticeTopicViewData {
  const _PracticeTopicViewData({
    required this.topic,
    required this.icon,
    required this.color,
  });

  final PracticeTopic topic;
  final IconData icon;
  final Color color;

  static const values = [
    _PracticeTopicViewData(
      topic: PracticeTopic.count,
      icon: Symbols.counter_1_rounded,
      color: AppColors.skyBlue,
    ),
    _PracticeTopicViewData(
      topic: PracticeTopic.addition,
      icon: Symbols.add_rounded,
      color: AppColors.softMint,
    ),
    _PracticeTopicViewData(
      topic: PracticeTopic.subtraction,
      icon: Symbols.remove_rounded,
      color: AppColors.magicPink,
    ),
    _PracticeTopicViewData(
      topic: PracticeTopic.mixed,
      icon: Symbols.shuffle_rounded,
      color: AppColors.starGold,
    ),
  ];
}

class _PracticeDifficultyViewData {
  const _PracticeDifficultyViewData({
    required this.difficulty,
    required this.icon,
    required this.color,
    required this.previewNumbers,
  });

  final PracticeDifficulty difficulty;
  final IconData icon;
  final Color color;
  final List<int> previewNumbers;

  String title(String languageCode) {
    if (languageCode == 'ca-ES') {
      return switch (difficulty) {
        PracticeDifficulty.upTo5 => 'Primer pas',
        PracticeDifficulty.upTo10 => 'Amb més ritme',
        PracticeDifficulty.upTo20 => 'Repte de desenes',
      };
    }

    return switch (difficulty) {
      PracticeDifficulty.upTo5 => 'Primer paso',
      PracticeDifficulty.upTo10 => 'Con más ritmo',
      PracticeDifficulty.upTo20 => 'Reto de decenas',
    };
  }

  String helper(PracticeTopic topic, String languageCode) {
    if (languageCode == 'ca-ES') {
      return switch ((topic, difficulty)) {
        (PracticeTopic.count, PracticeDifficulty.upTo5) => 'Comptar poquets',
        (PracticeTopic.count, PracticeDifficulty.upTo10) =>
          'Comptar fins a deu',
        (PracticeTopic.count, PracticeDifficulty.upTo20) =>
          'Comptar i comparar',
        (PracticeTopic.addition, PracticeDifficulty.upTo5) =>
          'Sumes molt curtes',
        (PracticeTopic.addition, PracticeDifficulty.upTo10) =>
          'Sumes fins a deu',
        (PracticeTopic.addition, PracticeDifficulty.upTo20) =>
          'Salts amb desenes',
        (PracticeTopic.subtraction, PracticeDifficulty.upTo5) =>
          'Treure poquets',
        (PracticeTopic.subtraction, PracticeDifficulty.upTo10) =>
          'Restes fins a deu',
        (PracticeTopic.subtraction, PracticeDifficulty.upTo20) =>
          'Baixar per desenes',
        (PracticeTopic.mixed, PracticeDifficulty.upTo5) => 'Una barreja suau',
        (PracticeTopic.mixed, PracticeDifficulty.upTo10) =>
          'Barreja equilibrada',
        (PracticeTopic.mixed, PracticeDifficulty.upTo20) => 'Barreja amb repte',
      };
    }

    return switch ((topic, difficulty)) {
      (PracticeTopic.count, PracticeDifficulty.upTo5) => 'Contar poquitos',
      (PracticeTopic.count, PracticeDifficulty.upTo10) => 'Contar hasta diez',
      (PracticeTopic.count, PracticeDifficulty.upTo20) => 'Contar y comparar',
      (PracticeTopic.addition, PracticeDifficulty.upTo5) => 'Sumas muy cortas',
      (PracticeTopic.addition, PracticeDifficulty.upTo10) => 'Sumas hasta diez',
      (PracticeTopic.addition, PracticeDifficulty.upTo20) =>
        'Saltos con decenas',
      (PracticeTopic.subtraction, PracticeDifficulty.upTo5) =>
        'Quitar poquitos',
      (PracticeTopic.subtraction, PracticeDifficulty.upTo10) =>
        'Restas hasta diez',
      (PracticeTopic.subtraction, PracticeDifficulty.upTo20) =>
        'Bajar por decenas',
      (PracticeTopic.mixed, PracticeDifficulty.upTo5) => 'Una mezcla suave',
      (PracticeTopic.mixed, PracticeDifficulty.upTo10) => 'Mezcla equilibrada',
      (PracticeTopic.mixed, PracticeDifficulty.upTo20) => 'Mezcla con reto',
    };
  }

  static const values = [
    _PracticeDifficultyViewData(
      difficulty: PracticeDifficulty.upTo5,
      icon: Symbols.looks_one_rounded,
      color: AppColors.softMint,
      previewNumbers: [1, 2, 3, 4, 5],
    ),
    _PracticeDifficultyViewData(
      difficulty: PracticeDifficulty.upTo10,
      icon: Symbols.exposure_plus_1_rounded,
      color: AppColors.skyBlue,
      previewNumbers: [1, 3, 5, 8, 10],
    ),
    _PracticeDifficultyViewData(
      difficulty: PracticeDifficulty.upTo20,
      icon: Symbols.view_timeline_rounded,
      color: AppColors.softLilac,
      previewNumbers: [1, 5, 10, 15, 20],
    ),
  ];
}

class _PracticeTopicTile extends StatelessWidget {
  const _PracticeTopicTile({
    required this.data,
    required this.languageCode,
    required this.isSelected,
    required this.compact,
    required this.onTap,
  });

  final _PracticeTopicViewData data;
  final String languageCode;
  final bool isSelected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = data.color;
    final foreground = HSLColor.fromColor(color).withLightness(0.35).toColor();

    return Material(
      color: color.withValues(alpha: isSelected ? 0.28 : 0.17),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onTap),
        splashColor: color.withValues(alpha: 0.28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.78)
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: compact
                ? Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.74),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(data.icon, size: 36, color: foreground),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          data.topic.title(languageCode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.cardTitle.copyWith(
                            color: foreground,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Symbols.check_circle_rounded
                            : Symbols.circle_rounded,
                        color:
                            isSelected ? foreground : AppColors.purpleTextLight,
                        size: 28,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.74),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(data.icon, size: 48, color: foreground),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          data.topic.title(languageCode),
                          maxLines: 1,
                          style: AppTypography.cardTitle.copyWith(
                            color: foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({
    required this.data,
    required this.topic,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final _PracticeDifficultyViewData data;
  final PracticeTopic topic;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = data.color;
    final foreground = HSLColor.fromColor(color).withLightness(0.34).toColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        final showPreview = constraints.maxWidth >= 540;

        return Material(
          color: color.withValues(alpha: isSelected ? 0.34 : 0.16),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => playTapAndRun(context, onTap),
            splashColor: color.withValues(alpha: 0.28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.pinkAccent
                      : color.withValues(alpha: 0.24),
                  width: isSelected ? 3 : 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _content(
                  color: color,
                  foreground: foreground,
                  showPreview: showPreview,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content({
    required Color color,
    required Color foreground,
    required bool showPreview,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DifficultyIcon(data: data, color: color, foreground: foreground),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.difficulty.label(languageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sectionTitle.copyWith(
                  color: foreground,
                  fontSize: 31,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                data.helper(topic, languageCode),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: AppTypography.bodyStrong.copyWith(
                  color: foreground,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        if (showPreview) ...[
          const SizedBox(width: AppSpacing.lg),
          SizedBox(
            width: 168,
            child: _DifficultyNumberPreview(
              numbers: data.previewNumbers,
              color: color,
              foreground: foreground,
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.md),
        _DifficultyCheck(isSelected: isSelected),
      ],
    );
  }
}

class _DifficultyIcon extends StatelessWidget {
  const _DifficultyIcon({
    required this.data,
    required this.color,
    required this.foreground,
  });

  final _PracticeDifficultyViewData data;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Icon(data.icon, color: foreground, size: 36),
    );
  }
}

class _DifficultyCheck extends StatelessWidget {
  const _DifficultyCheck({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isSelected ? 1 : 0.32,
      duration: const Duration(milliseconds: 160),
      child: Icon(
        isSelected ? Symbols.check_circle_rounded : Symbols.circle_rounded,
        color: isSelected ? AppColors.pinkAccent : AppColors.purpleTextLight,
        size: 28,
      ),
    );
  }
}

class _DifficultyNumberPreview extends StatelessWidget {
  const _DifficultyNumberPreview({
    required this.numbers,
    required this.color,
    required this.foreground,
  });

  final List<int> numbers;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final number in numbers) ...[
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.28)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  '$number',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppTypography.label.copyWith(color: foreground),
                ),
              ),
            ),
          ),
          if (number != numbers.last) const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _PracticeExerciseView extends ConsumerStatefulWidget {
  const _PracticeExerciseView({
    required this.session,
    required this.languageCode,
    required this.avatar,
    required this.stage,
    required this.characterName,
  });

  final PracticeSessionState session;
  final String languageCode;
  final UnicornAvatar avatar;
  final UnicornAvatarStage stage;
  final String characterName;

  @override
  ConsumerState<_PracticeExerciseView> createState() =>
      _PracticeExerciseViewState();
}

class _PracticeExerciseViewState extends ConsumerState<_PracticeExerciseView> {
  late String _speechSessionId;
  final _preparedClipKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _speechSessionId = _createPracticeSpeechSessionId();
  }

  @override
  void dispose() {
    unawaited(ref.read(speechPlaybackControllerProvider.notifier).stop());
    unawaited(ref.read(speechServiceProvider).disposeSession(_speechSessionId));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final languageCode = widget.languageCode;
    final avatar = widget.avatar;
    final stage = widget.stage;
    final characterName = widget.characterName;
    final controller = ref.read(practiceSessionProvider.notifier);
    final speechService = ref.watch(speechServiceProvider);
    final speechPlayback = ref.read(speechPlaybackControllerProvider.notifier);
    final audioService = ref.watch(audioServiceProvider);
    final voiceId = ref.watch(activeProfileProvider)?.ttsVoiceId;
    final contentWidth =
        MediaQuery.sizeOf(context).width - AppSpacing.screenPadding.horizontal;
    final isNarrow = contentWidth < AppBreakpoints.narrowWidth;
    final isCompactHeight = MediaQuery.sizeOf(context).height < 720;
    final sectionGap = isCompactHeight ? AppSpacing.sm : AppSpacing.md;
    final writtenOperation = _writtenOperationFor(session);
    final guideFlex = isNarrow
        ? writtenOperation == null
            ? 4
            : 5
        : writtenOperation == null
            ? isCompactHeight
                ? 4
                : 5
            : isCompactHeight
                ? 5
                : 6;
    final answersFlex = isNarrow
        ? 5
        : isCompactHeight
            ? 3
            : 4;
    final showVisualSupport = _shouldShowVisualSupport(session);
    final activeHintIndex = _activeHintStepIndex(session);
    final activeVisibleHint = _activeVisibleHint(session);
    final activeSpokenHint = _activeSpokenHint(session);
    final canRequestHint = _canRequestHint(session);
    final questionSpeech = _PracticeSpeechButtonData(
      clipKey: '$_speechSessionId:question:${session.exercise.id}',
      text: session.exercise.spokenText,
      languageCode: languageCode,
      voiceId: voiceId,
      sessionId: _speechSessionId,
      clipId: 'question:${session.exercise.id}',
    );
    final hintSpeech = _PracticeSpeechButtonData(
      clipKey: '$_speechSessionId:hint:${session.exercise.id}:$activeHintIndex',
      text: activeSpokenHint,
      languageCode: languageCode,
      voiceId: voiceId,
      sessionId: _speechSessionId,
      clipId: _practiceHintClipId(session.exercise.id, activeHintIndex),
    );

    _prepareSpeechFor(session, languageCode, voiceId, speechService);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PracticeProgressHeader(
          session: session,
          languageCode: languageCode,
        ),
        SizedBox(height: sectionGap),
        Expanded(
          flex: guideFlex,
          child: _PracticeGuide(
            avatar: avatar,
            stage: stage,
            writtenOperation: writtenOperation,
            message: _guideMessage(
              languageCode: languageCode,
              session: session,
              characterName: characterName,
              hint: activeVisibleHint,
            ),
            title: _guideTitle(languageCode, session),
            emotion: _emotionFor(session),
            speech: session.hasAskedHint && session.isCorrect == null
                ? hintSpeech
                : null,
          ),
        ),
        SizedBox(height: sectionGap),
        _PracticeQuestionCard(
          text: session.exercise.visibleText,
          speech: questionSpeech,
        ),
        if (showVisualSupport) ...[
          SizedBox(height: sectionGap),
          _PracticeVisualItems(
            itemIds: session.exercise.visualItemIds,
            assetPath: session.exercise.visualItemAssetPath,
          ),
        ],
        SizedBox(height: sectionGap),
        _PracticeHintButton(
          languageCode: languageCode,
          isFollowUp: session.hasAskedHint,
          onPressed: canRequestHint
              ? () async {
                  await speechPlayback.stop();
                  controller.showHint();
                  await audioService.playHintOpen();
                }
              : null,
        ),
        SizedBox(height: sectionGap),
        Expanded(
          flex: answersFlex,
          child: ResponsiveActionGrid(
            columns: isNarrow ? 1 : 2,
            minRows: isNarrow ? 4 : 2,
            gap: isCompactHeight ? AppSpacing.sm : AppSpacing.md,
            children: [
              for (final option in session.exercise.options)
                _PracticeAnswerTile(
                  value: option,
                  selectedAnswer: session.selectedAnswer,
                  correctAnswer: session.exercise.answer,
                  onTap: () async {
                    await speechPlayback.stop();
                    controller.submitAnswer(option);
                    if (option == session.exercise.answer) {
                      unawaited(audioService.playCorrectSfx());
                    } else {
                      unawaited(audioService.playWrongSoft());
                    }
                  },
                ),
            ],
          ),
        ),
        SizedBox(height: sectionGap),
        _PracticeFeedbackBar(
          isCorrect: session.isCorrect,
          isAdvancing: false,
          languageCode: languageCode,
          onNext:
              session.selectedAnswer == null ? null : controller.nextExercise,
        ),
      ],
    );
  }

  void _prepareSpeechFor(
    PracticeSessionState session,
    String languageCode,
    String? voiceId,
    SpeechService speechService,
  ) {
    if (session.isComplete) {
      return;
    }

    final key = '$languageCode:${voiceId ?? 'default'}:${session.exercise.id}';
    if (!_preparedClipKeys.add(key)) {
      return;
    }

    unawaited(
      speechService.prepareSession(
        sessionId: _speechSessionId,
        languageCode: languageCode,
        voiceId: voiceId ?? '',
        clips: [
          SpeechClip(
            id: 'question:${session.exercise.id}',
            text: session.exercise.spokenText,
          ),
          ..._hintSpeechClips(session),
        ],
      ),
    );
  }

  List<SpeechClip> _hintSpeechClips(PracticeSessionState session) {
    final steps = session.exercise.hintSteps;
    if (steps.isEmpty) {
      return [
        SpeechClip(
          id: _practiceHintClipId(session.exercise.id, 0),
          text: session.exercise.spokenHint,
        ),
      ];
    }

    return [
      for (var index = 0; index < steps.length; index++)
        SpeechClip(
          id: _practiceHintClipId(session.exercise.id, index),
          text: steps[index].spokenText,
        ),
    ];
  }
}

String _createPracticeSpeechSessionId() {
  return 'practice-${DateTime.now().microsecondsSinceEpoch}';
}

String _practiceHintClipId(String exerciseId, int hintStepIndex) {
  return 'hint:$exerciseId:$hintStepIndex';
}

class _PracticeSpeechButtonData {
  const _PracticeSpeechButtonData({
    required this.clipKey,
    required this.text,
    required this.languageCode,
    this.voiceId,
    this.sessionId,
    this.clipId,
  });

  final String clipKey;
  final String text;
  final String languageCode;
  final String? voiceId;
  final String? sessionId;
  final String? clipId;
}

class _PracticeProgressHeader extends StatelessWidget {
  const _PracticeProgressHeader({
    required this.session,
    required this.languageCode,
  });

  final PracticeSessionState session;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final progressText =
        '${session.questionIndex}/${session.questionsToComplete}';
    final correctText = languageCode == 'ca-ES'
        ? '${session.correctAnswers} encerts'
        : '${session.correctAnswers} aciertos';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.softLilac.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: session.questionIndex / session.questionsToComplete,
                  backgroundColor: AppColors.softLilac.withValues(alpha: 0.22),
                  color: AppColors.pinkAccent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              progressText,
              style: AppTypography.label,
            ),
            const SizedBox(width: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.starGold.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Text(correctText, style: AppTypography.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeGuide extends StatelessWidget {
  const _PracticeGuide({
    required this.avatar,
    required this.stage,
    required this.writtenOperation,
    required this.title,
    required this.message,
    required this.emotion,
    required this.speech,
  });

  final UnicornAvatar avatar;
  final UnicornAvatarStage stage;
  final _PracticeWrittenOperationData? writtenOperation;
  final String title;
  final String message;
  final UnicornAvatarEmotion emotion;
  final _PracticeSpeechButtonData? speech;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.narrowWidth;
        final isCompact = constraints.maxWidth < 420;
        final hasOperation = writtenOperation != null;
        final availableHeight = constraints.maxHeight;
        const padding = AppSpacing.md * 2;
        final portraitSize = isNarrow
            ? math
                .min(availableHeight * 0.42, constraints.maxWidth * 0.42)
                .clamp(96.0, 170.0)
                .toDouble()
            : (availableHeight - padding)
                .clamp(
                  hasOperation ? 180.0 : 160.0,
                  hasOperation ? 300.0 : 280.0,
                )
                .toDouble();
        final useCompactText = isNarrow || isCompact || availableHeight < 210;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.softLilac.withValues(alpha: 0.24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: isNarrow
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: _PracticeUnicornPortrait(
                          avatar: avatar,
                          stage: stage,
                          emotion: emotion,
                          size: portraitSize,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.guideTitleCompact,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  message,
                                  maxLines: hasOperation ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.guideBodyCompact,
                                ),
                              ],
                            ),
                          ),
                          if (speech != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _PracticeGuideSpeakButton(speech: speech!),
                          ],
                        ],
                      ),
                      if (writtenOperation case final operation?) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _PracticeWrittenOperation(
                          operation: operation,
                          compact: true,
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      _PracticeUnicornPortrait(
                        avatar: avatar,
                        stage: stage,
                        emotion: emotion,
                        size: portraitSize,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: useCompactText
                                            ? AppTypography.guideTitleCompact
                                            : AppTypography.guideTitle,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        message,
                                        maxLines: hasOperation
                                            ? isCompact
                                                ? 2
                                                : 3
                                            : isCompact
                                                ? 3
                                                : 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: useCompactText
                                            ? AppTypography.guideBodyCompact
                                            : AppTypography.guideBody,
                                      ),
                                    ],
                                  ),
                                ),
                                if (speech != null) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  _PracticeGuideSpeakButton(speech: speech!),
                                ],
                              ],
                            ),
                            if (writtenOperation case final operation?) ...[
                              const SizedBox(height: AppSpacing.sm),
                              _PracticeWrittenOperation(
                                operation: operation,
                                compact: useCompactText,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _PracticeGuideSpeakButton extends StatelessWidget {
  const _PracticeGuideSpeakButton({required this.speech});

  final _PracticeSpeechButtonData speech;

  @override
  Widget build(BuildContext context) {
    return SpeechToggleButton(
      clipKey: speech.clipKey,
      text: speech.text,
      languageCode: speech.languageCode,
      voiceId: speech.voiceId,
      sessionId: speech.sessionId,
      clipId: speech.clipId,
      size: 28,
    );
  }
}

class _PracticeUnicornPortrait extends StatelessWidget {
  const _PracticeUnicornPortrait({
    required this.avatar,
    required this.stage,
    required this.emotion,
    required this.size,
  });

  final UnicornAvatar avatar;
  final UnicornAvatarStage stage;
  final UnicornAvatarEmotion emotion;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: UnicornAvatarImage(
          key: ValueKey('${avatar.id}:${stage.id}:${emotion.name}'),
          avatar: avatar,
          stage: stage,
          emotion: emotion,
          fallback: _PracticeUnicornFallback(size: size),
        ),
      ),
    );
  }
}

class _PracticeUnicornFallback extends StatelessWidget {
  const _PracticeUnicornFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softLilac.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Symbols.auto_awesome_rounded,
        color: AppColors.lilacAccent,
        size: size * 0.48,
      ),
    );
  }
}

class _PracticeWrittenOperationData {
  const _PracticeWrittenOperationData({
    required this.left,
    required this.right,
    required this.symbol,
  });

  final int left;
  final int right;
  final String symbol;

  bool get isVertical => left >= 10 || right >= 10;
}

class _PracticeWrittenOperation extends StatelessWidget {
  const _PracticeWrittenOperation({
    required this.operation,
    required this.compact,
  });

  final _PracticeWrittenOperationData operation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color =
        HSLColor.fromColor(AppColors.hintOrange).withLightness(0.32).toColor();

    return Align(
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.hintOrange.withValues(alpha: 0.28),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.md : AppSpacing.lg,
            vertical: compact ? AppSpacing.xs : AppSpacing.sm,
          ),
          child: operation.isVertical
              ? _PracticeVerticalWrittenOperation(
                  operation: operation,
                  color: color,
                  compact: compact,
                )
              : Text(
                  '${operation.left} ${operation.symbol} ${operation.right} = ?',
                  textAlign: TextAlign.center,
                  style: (compact
                          ? AppTypography.mathHorizontalCompact
                          : AppTypography.mathHorizontal)
                      .copyWith(color: color),
                ),
        ),
      ),
    );
  }
}

class _PracticeVerticalWrittenOperation extends StatelessWidget {
  const _PracticeVerticalWrittenOperation({
    required this.operation,
    required this.color,
    required this.compact,
  });

  final _PracticeWrittenOperationData operation;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final maxDigits = math.max(
      '${operation.left}'.length,
      '${operation.right}'.length,
    );
    final width = maxDigits + 2;
    final right = '${operation.right}'.padLeft(maxDigits);
    final top = '${operation.left}'.padLeft(width);
    final bottom = '${operation.symbol} $right';
    final line = ''.padLeft(width, '-');
    final result = '?'.padLeft(width);

    return Text(
      '$top\n$bottom\n$line\n$result',
      textAlign: TextAlign.right,
      style: (compact
              ? AppTypography.mathVerticalCompact
              : AppTypography.mathVertical)
          .copyWith(color: color),
    );
  }
}

class _PracticeQuestionCard extends StatelessWidget {
  const _PracticeQuestionCard({
    required this.text,
    required this.speech,
  });

  final String text;
  final _PracticeSpeechButtonData speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.softLilac.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTypography.question,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SpeechToggleButton(
            clipKey: speech.clipKey,
            text: speech.text,
            languageCode: speech.languageCode,
            voiceId: speech.voiceId,
            sessionId: speech.sessionId,
            clipId: speech.clipId,
          ),
        ],
      ),
    );
  }
}

class _PracticeVisualItems extends StatelessWidget {
  const _PracticeVisualItems({
    required this.itemIds,
    required this.assetPath,
  });

  final List<String> itemIds;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 146),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.softLilac.withValues(alpha: 0.28),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = _visualIconSize(
              itemCount: itemIds.length,
              maxWidth: constraints.maxWidth,
            );

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final itemId in itemIds)
                    _PracticeVisualItemIcon(
                      itemId: itemId,
                      assetPath: assetPath,
                      size: iconSize,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double _visualIconSize({
    required int itemCount,
    required double maxWidth,
  }) {
    const maxIconSize = 46.0;
    const minIconSize = 24.0;
    const panelPadding = AppSpacing.md * 2;
    const spacing = AppSpacing.sm;
    const maxRows = 3;

    if (itemCount <= 0) {
      return maxIconSize;
    }

    final rows = math.min(maxRows, math.max(1, (itemCount / 5).ceil())).toInt();
    final columns = (itemCount / rows).ceil();
    final availableWidth = math.max(0.0, maxWidth - panelPadding);
    final totalSpacing = spacing * math.max(0, columns - 1);
    final sizeByWidth = (availableWidth - totalSpacing) / columns;

    return sizeByWidth.clamp(minIconSize, maxIconSize).toDouble();
  }
}

class _PracticeVisualItemIcon extends StatelessWidget {
  const _PracticeVisualItemIcon({
    required this.itemId,
    required this.assetPath,
    required this.size,
  });

  final String itemId;
  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SafeAssetImage(
        assetPath: assetPath,
        fit: BoxFit.contain,
        placeholder: _PracticeVisualItemFallback(
          itemId: itemId,
          size: size,
        ),
      ),
    );
  }
}

class _PracticeVisualItemFallback extends StatelessWidget {
  const _PracticeVisualItemFallback({
    required this.itemId,
    required this.size,
  });

  final String itemId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _practiceItemColor(itemId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(math.max(8.0, size * 0.3)),
      ),
      child: Icon(
        _practiceItemIcon(itemId),
        color: HSLColor.fromColor(color).withLightness(0.35).toColor(),
        size: size * 0.65,
      ),
    );
  }
}

IconData _practiceItemIcon(String itemId) {
  return switch (itemId) {
    'heart_pink' => Icons.favorite_rounded,
    'star_yellow' => Icons.star_rounded,
    'flower_blue' => Icons.local_florist_rounded,
    'cloud_white' => Icons.cloud_rounded,
    'cupcake_pink' => Icons.cake_rounded,
    'gem_purple' => Icons.diamond_rounded,
    'ten_block' => Icons.grid_view_rounded,
    'unit_cube' => Icons.crop_square_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}

Color _practiceItemColor(String itemId) {
  return switch (itemId) {
    'heart_pink' => AppColors.magicPink,
    'star_yellow' => AppColors.starGold,
    'flower_blue' => AppColors.skyBlue,
    'cloud_white' => AppColors.softLilac,
    'cupcake_pink' => AppColors.magicPink,
    'gem_purple' => AppColors.softLilac,
    'ten_block' => AppColors.hintOrange,
    'unit_cube' => AppColors.softMint,
    _ => AppColors.softMint,
  };
}

class _PracticeHintButton extends StatelessWidget {
  const _PracticeHintButton({
    required this.languageCode,
    required this.isFollowUp,
    required this.onPressed,
  });

  final String languageCode;
  final bool isFollowUp;
  final FutureOr<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = enabled
        ? AppColors.purpleText
        : AppColors.purpleText.withValues(alpha: 0.42);
    final bulbColor = enabled
        ? AppColors.starGold
        : AppColors.starGold.withValues(alpha: 0.45);

    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.white.withValues(alpha: enabled ? 0.76 : 0.42),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () => playTapAndRun(context, onPressed!),
          splashColor: AppColors.starGold.withValues(alpha: 0.24),
          highlightColor: AppColors.starGold.withValues(alpha: 0.14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    AppColors.starGold.withValues(alpha: enabled ? 0.62 : 0.28),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleText.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: bulbColor.withValues(alpha: 0.30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Symbols.lightbulb_rounded,
                      color: HSLColor.fromColor(bulbColor)
                          .withLightness(enabled ? 0.42 : 0.62)
                          .toColor(),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _practiceHintButtonLabel(languageCode, isFollowUp),
                        style: AppTypography.button.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _practiceHintButtonLabel(String languageCode, bool isFollowUp) {
  if (!isFollowUp) {
    return 'Pista';
  }

  return languageCode == 'ca-ES' ? 'Una altra pista' : 'Otra pista';
}

class _PracticeAnswerTile extends StatefulWidget {
  const _PracticeAnswerTile({
    required this.value,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.onTap,
  });

  final int value;
  final int? selectedAnswer;
  final int correctAnswer;
  final VoidCallback onTap;

  @override
  State<_PracticeAnswerTile> createState() => _PracticeAnswerTileState();
}

class _PracticeAnswerTileState extends State<_PracticeAnswerTile> {
  bool _isPressed = false;

  @override
  void didUpdateWidget(covariant _PracticeAnswerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != null && _isPressed) {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnswered = widget.selectedAnswer != null;
    final isSelected = widget.selectedAnswer == widget.value;
    final isCorrect = widget.correctAnswer == widget.value;
    final accentColor = isAnswered && isCorrect
        ? AppColors.successGreen
        : isSelected
            ? AppColors.gentleError
            : AppColors.softLilac;
    final fillColor = isAnswered && isCorrect
        ? AppColors.successGreen.withValues(alpha: 0.28)
        : isSelected
            ? AppColors.gentleError.withValues(alpha: 0.28)
            : AppColors.softLilac.withValues(alpha: 0.18);
    final borderColor = isAnswered && isCorrect
        ? AppColors.successGreen.withValues(alpha: 0.92)
        : isSelected
            ? AppColors.gentleError.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.64);
    final textColor = isAnswered && isCorrect
        ? HSLColor.fromColor(AppColors.successGreen)
            .withLightness(0.28)
            .toColor()
        : isSelected
            ? HSLColor.fromColor(AppColors.gentleError)
                .withLightness(0.30)
                .toColor()
            : AppColors.purpleText;
    final scale = _isPressed
        ? 0.95
        : isSelected
            ? 1.04
            : 1.0;
    final shadowOpacity = isSelected || (isAnswered && isCorrect) ? 0.24 : 0.14;
    final showFeedbackBadge = isAnswered && (isSelected || isCorrect);
    final numberChipBorderColor = isAnswered && (isSelected || isCorrect)
        ? accentColor.withValues(alpha: 0.36)
        : Colors.white.withValues(alpha: 0.82);

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.92,
        heightFactor: 0.84,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: showFeedbackBadge ? 3 : 2.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: shadowOpacity),
                  blurRadius: showFeedbackBadge ? 18 : 14,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.purpleText.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isAnswered ? null : widget.onTap,
                onTapDown: isAnswered
                    ? null
                    : (_) => setState(() => _isPressed = true),
                onTapUp: isAnswered
                    ? null
                    : (_) => setState(() => _isPressed = false),
                onTapCancel: isAnswered
                    ? null
                    : () => setState(() => _isPressed = false),
                splashColor: accentColor.withValues(alpha: 0.3),
                highlightColor: accentColor.withValues(alpha: 0.16),
                hoverColor: AppColors.softLilac.withValues(alpha: 0.14),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOut,
                            constraints: const BoxConstraints(
                              minWidth: 74,
                              minHeight: 68,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 26 : 24,
                              vertical: isSelected ? 13 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: numberChipBorderColor,
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.14),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 140),
                              curve: Curves.easeOut,
                              style: AppTypography.answerNumber.copyWith(
                                color: textColor,
                                fontSize: isSelected ? 46 : 42,
                              ),
                              child: Text('${widget.value}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: AnimatedScale(
                        scale: showFeedbackBadge ? 1 : 0,
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutBack,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isCorrect
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeFeedbackBar extends StatelessWidget {
  const _PracticeFeedbackBar({
    required this.isCorrect,
    required this.isAdvancing,
    required this.languageCode,
    required this.onNext,
  });

  final bool? isCorrect;
  final bool isAdvancing;
  final String languageCode;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final message = _feedbackMessage(languageCode, isCorrect);

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.softLilac.withValues(alpha: 0.24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sectionTitle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          height: 84,
          width: 84,
          child: _PracticeNextImageButton(
            isAdvancing: isAdvancing,
            tooltip: languageCode == 'ca-ES' ? 'Següent' : 'Siguiente',
            onPressed: onNext,
          ),
        ),
      ],
    );
  }

  String _feedbackMessage(String languageCode, bool? isCorrect) {
    if (languageCode == 'ca-ES') {
      if (isCorrect == null) {
        return 'Tria una resposta.';
      }

      return isCorrect ? 'Molt bé!' : 'Gairebé. Ho provem?';
    }

    if (isCorrect == null) {
      return 'Elige una respuesta.';
    }

    return isCorrect ? '¡Muy bien!' : 'Casi. ¿Probamos otra?';
  }
}

class _PracticeNextImageButton extends StatelessWidget {
  const _PracticeNextImageButton({
    required this.isAdvancing,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isAdvancing;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = !isAdvancing && onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () => playTapAndRun(
                      context,
                      onPressed!,
                    )
                : null,
            customBorder: const CircleBorder(),
            child: isAdvancing
                ? const Icon(Symbols.hourglass_top_rounded, size: 34)
                : const SafeAssetImage(
                    assetPath: 'assets/images/ui/buttons/next.webp',
                    fit: BoxFit.contain,
                    placeholder: Icon(
                      Symbols.arrow_forward_rounded,
                      size: 40,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PracticeSummary extends StatelessWidget {
  const _PracticeSummary({
    required this.session,
    required this.languageCode,
    required this.avatar,
    required this.stage,
    required this.characterName,
    required this.onRepeat,
    required this.onChangePractice,
  });

  final PracticeSessionState session;
  final String languageCode;
  final UnicornAvatar avatar;
  final UnicornAvatarStage stage;
  final String characterName;
  final FutureOr<void> Function() onRepeat;
  final VoidCallback onChangePractice;

  @override
  Widget build(BuildContext context) {
    return _PracticeReadablePanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avatarSize = math
              .min(constraints.maxHeight * 0.34, constraints.maxWidth * 0.72)
              .clamp(170.0, 330.0)
              .toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              SizedBox.square(
                dimension: avatarSize,
                child: UnicornAvatarImage(
                  avatar: avatar,
                  stage: stage,
                  emotion: UnicornAvatarEmotion.celebrating,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                languageCode == 'ca-ES'
                    ? 'Pràctica acabada'
                    : 'Práctica terminada',
                textAlign: TextAlign.center,
                style: AppTypography.heading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                languageCode == 'ca-ES'
                    ? '${session.correctAnswers} de ${session.questionsToComplete} correctes'
                    : '${session.correctAnswers} de ${session.questionsToComplete} correctas',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStrong,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                languageCode == 'ca-ES'
                    ? '$characterName ha practicat amb tu sense pressa.'
                    : '$characterName ha practicado contigo sin presion.',
                textAlign: TextAlign.center,
                style: AppTypography.cardTitle,
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => playTapAndRun(context, onRepeat),
                  icon: const Icon(Symbols.replay_rounded),
                  label: Text(languageCode == 'ca-ES' ? 'Repetir' : 'Repetir'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => playTapAndRun(context, onChangePractice),
                  icon: const Icon(Symbols.tune_rounded),
                  label: Text(
                    languageCode == 'ca-ES'
                        ? 'Canviar practica'
                        : 'Cambiar practica',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 56,
                child: TextButton.icon(
                  onPressed: () =>
                      playTapAndRun(context, () => context.go('/home')),
                  icon: const Icon(Symbols.home_rounded),
                  label: Text(languageCode == 'ca-ES' ? 'Inici' : 'Inicio'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _guideTitle(String languageCode, PracticeSessionState session) {
  if (languageCode == 'ca-ES') {
    if (session.isCorrect == true) {
      return 'Molt bé';
    }
    if (session.isCorrect == false) {
      return 'Ho mirem junts';
    }
    if (session.hasAskedHint) {
      return 'Pista màgica';
    }
    return 'Practiquem';
  }

  if (session.isCorrect == true) {
    return 'Muy bien';
  }
  if (session.isCorrect == false) {
    return 'Lo miramos juntos';
  }
  if (session.hasAskedHint) {
    return 'Pista mágica';
  }
  return 'Practicamos';
}

_PracticeWrittenOperationData? _writtenOperationFor(
  PracticeSessionState session,
) {
  if (session.config.difficulty == PracticeDifficulty.upTo5) {
    return null;
  }
  if (session.exercise.type != 'addition' &&
      session.exercise.type != 'subtraction') {
    return null;
  }

  return _PracticeWrittenOperationData(
    left: session.exercise.left,
    right: session.exercise.right,
    symbol: session.exercise.type == 'addition' ? '+' : '-',
  );
}

bool _shouldShowVisualSupport(PracticeSessionState session) {
  if (session.exercise.visualItemIds.isEmpty) {
    return false;
  }

  return session.exercise.type == 'count';
}

String _guideMessage({
  required String languageCode,
  required PracticeSessionState session,
  required String characterName,
  required String hint,
}) {
  if (session.hasAskedHint && session.isCorrect == null) {
    return hint;
  }

  if (languageCode == 'ca-ES') {
    if (session.isCorrect == true) {
      return '$characterName somriu. Has trobat la resposta!';
    }
    if (session.isCorrect == false) {
      return 'No passa res. $characterName ho torna a provar amb tu.';
    }
    return '$characterName està preparat per practicar amb tu.';
  }

  if (session.isCorrect == true) {
    return '$characterName sonríe. ¡Has encontrado la respuesta!';
  }
  if (session.isCorrect == false) {
    return 'No pasa nada. $characterName lo vuelve a probar contigo.';
  }
  return '$characterName está listo para practicar contigo.';
}

String _activeVisibleHint(PracticeSessionState session) {
  final steps = session.exercise.hintSteps;
  if (steps.isEmpty) {
    return session.exercise.visibleHint;
  }

  return steps[_activeHintStepIndex(session)].visibleText;
}

String _activeSpokenHint(PracticeSessionState session) {
  final steps = session.exercise.hintSteps;
  if (steps.isEmpty) {
    return session.exercise.spokenHint;
  }

  return steps[_activeHintStepIndex(session)].spokenText;
}

int _activeHintStepIndex(PracticeSessionState session) {
  final stepCount = session.exercise.hintSteps.length;
  if (stepCount == 0 || session.hintStepIndex < 0) {
    return 0;
  }

  return session.hintStepIndex >= stepCount
      ? stepCount - 1
      : session.hintStepIndex;
}

bool _canRequestHint(PracticeSessionState session) {
  if (session.selectedAnswer != null || session.isComplete) {
    return false;
  }
  if (!session.hasAskedHint) {
    return true;
  }

  final stepCount = session.exercise.hintSteps.length;
  return stepCount > 0 && session.hintStepIndex < stepCount - 1;
}

UnicornAvatarEmotion _emotionFor(PracticeSessionState session) {
  if (session.isCorrect == true) {
    return UnicornAvatarEmotion.happy;
  }
  if (session.isCorrect == false) {
    return UnicornAvatarEmotion.encouraging;
  }
  if (session.hasAskedHint) {
    return UnicornAvatarEmotion.thinking;
  }
  return UnicornAvatarEmotion.idle;
}
