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
import '../../core/widgets/unicorn_avatar_image.dart';
import '../../models/unicorn_avatar.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
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
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';

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
              onContinue: () => setState(() {
                _isChoosingDifficulty = true;
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
            label: Text(languageCode == 'ca-ES' ? 'Reintentar' : 'Reintentar'),
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
    required this.onContinue,
    required this.onStart,
  });

  final PracticeTopic topic;
  final PracticeDifficulty difficulty;
  final bool isChoosingDifficulty;
  final String languageCode;
  final ValueChanged<PracticeTopic> onTopicChanged;
  final ValueChanged<PracticeDifficulty> onDifficultyChanged;
  final VoidCallback onBackToTopics;
  final VoidCallback onContinue;
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
              topic: topic,
              languageCode: languageCode,
              onTopicChanged: onTopicChanged,
              onContinue: onContinue,
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
    required this.topic,
    required this.languageCode,
    required this.onTopicChanged,
    required this.onContinue,
  });

  final PracticeTopic topic;
  final String languageCode;
  final ValueChanged<PracticeTopic> onTopicChanged;
  final VoidCallback onContinue;

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
          child: ResponsiveActionGrid(
            children: [
              for (final item in _PracticeTopicViewData.values)
                _PracticeTopicTile(
                  data: item,
                  languageCode: languageCode,
                  isSelected: item.topic == topic,
                  onTap: () => onTopicChanged(item.topic),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: () => playTapAndRun(context, onContinue),
            icon: const Icon(Symbols.arrow_forward_rounded),
            label: Text(languageCode == 'ca-ES' ? 'Seguent' : 'Siguiente'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppScreenHeader(
          icon: Symbols.tune_rounded,
          title: languageCode == 'ca-ES' ? 'Tria el nivell' : 'Elige el nivel',
          subtitle: topic.title(languageCode),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 3 : 1;

              return ResponsiveActionGrid(
                columns: columns,
                children: [
                  for (final item in PracticeDifficulty.values)
                    _DifficultyTile(
                      difficulty: item,
                      languageCode: languageCode,
                      isSelected: item == difficulty,
                      onTap: () => onChanged(item),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
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
                  label: Text(languageCode == 'ca-ES' ? 'Comencar' : 'Empezar'),
                ),
              ),
            ),
          ],
        ),
      ],
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

class _PracticeTopicTile extends StatelessWidget {
  const _PracticeTopicTile({
    required this.data,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final _PracticeTopicViewData data;
  final String languageCode;
  final bool isSelected;
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
              color: isSelected ? AppColors.pinkAccent : Colors.transparent,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
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
    required this.difficulty,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final PracticeDifficulty difficulty;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      PracticeDifficulty.upTo5 => AppColors.softMint,
      PracticeDifficulty.upTo10 => AppColors.skyBlue,
      PracticeDifficulty.upTo20 => AppColors.softLilac,
    };
    final foreground = HSLColor.fromColor(color).withLightness(0.34).toColor();

    return Material(
      color: color.withValues(alpha: isSelected ? 0.3 : 0.17),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onTap),
        splashColor: color.withValues(alpha: 0.28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.pinkAccent : Colors.transparent,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  difficulty.label(languageCode),
                  textAlign: TextAlign.center,
                  style: AppTypography.heading.copyWith(color: foreground),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  languageCode == 'ca-ES' ? 'nombres' : 'números',
                  textAlign: TextAlign.center,
                  style: AppTypography.cardTitle.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeExerciseView extends ConsumerWidget {
  const _PracticeExerciseView({
    required this.session,
    required this.languageCode,
    required this.avatar,
    required this.characterName,
  });

  final PracticeSessionState session;
  final String languageCode;
  final UnicornAvatar avatar;
  final String characterName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(practiceSessionProvider.notifier);
    final audioService = ref.watch(audioServiceProvider);
    final isCompactHeight = MediaQuery.sizeOf(context).height < 720;
    final writtenOperation = _writtenOperationFor(session);
    final showVisualSupport = _shouldShowVisualSupport(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PracticeProgressHeader(
          session: session,
          languageCode: languageCode,
        ),
        SizedBox(height: isCompactHeight ? AppSpacing.sm : AppSpacing.md),
        Expanded(
          flex: 5,
          child: _PracticeGuide(
            avatar: avatar,
            writtenOperation: writtenOperation,
            message: _guideMessage(
              languageCode: languageCode,
              session: session,
              characterName: characterName,
            ),
            title: _guideTitle(languageCode, session),
            emotion: _emotionFor(session),
          ),
        ),
        SizedBox(height: isCompactHeight ? AppSpacing.sm : AppSpacing.md),
        _PracticeQuestionCard(text: session.exercise.visibleText),
        if (showVisualSupport) ...[
          SizedBox(height: isCompactHeight ? AppSpacing.sm : AppSpacing.md),
          _PracticeVisualItems(
            itemIds: session.exercise.visualItemIds,
            assetPath: session.exercise.visualItemAssetPath,
          ),
        ],
        SizedBox(height: isCompactHeight ? AppSpacing.sm : AppSpacing.md),
        _PracticeHintButton(
          languageCode: languageCode,
          onPressed: () async {
            controller.showHint();
            await audioService.playHintOpen();
          },
        ),
        SizedBox(height: isCompactHeight ? AppSpacing.sm : AppSpacing.md),
        Expanded(
          flex: 4,
          child: ResponsiveActionGrid(
            minRows: 2,
            gap: isCompactHeight ? AppSpacing.sm : AppSpacing.md,
            children: [
              for (final option in session.exercise.options)
                _PracticeAnswerTile(
                  value: option,
                  selectedAnswer: session.selectedAnswer,
                  correctAnswer: session.exercise.answer,
                  onTap: () {
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
        SizedBox(height: isCompactHeight ? AppSpacing.sm : AppSpacing.md),
        _PracticeFeedbackBar(
          isCorrect: session.isCorrect,
          languageCode: languageCode,
          onNext: session.selectedAnswer == null ? null : controller.nextExercise,
        ),
      ],
    );
  }
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
    final progressText = languageCode == 'ca-ES'
        ? 'Pregunta ${session.questionIndex} de ${session.questionsToComplete}'
        : 'Pregunta ${session.questionIndex} de ${session.questionsToComplete}';
    final correctText = languageCode == 'ca-ES'
        ? '${session.correctAnswers} correctes'
        : '${session.correctAnswers} correctas';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                progressText,
                style: AppTypography.sectionTitle,
              ),
            ),
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
    required this.writtenOperation,
    required this.title,
    required this.message,
    required this.emotion,
  });

  final UnicornAvatar avatar;
  final _PracticeWrittenOperationData? writtenOperation;
  final String title;
  final String message;
  final UnicornAvatarEmotion emotion;

  @override
  Widget build(BuildContext context) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasOperation = writtenOperation != null;
            final isCompact = constraints.maxWidth < 420;
            final availableHeight = constraints.maxHeight;
            final padding = AppSpacing.md * 2;
            final portraitSize = (availableHeight - padding).clamp(
              hasOperation ? 124.0 : 104.0,
              hasOperation ? 260.0 : 230.0,
            ).toDouble();
            final useCompactText = isCompact || availableHeight < 210;

            return Row(
              children: [
                SizedBox.square(
                  dimension: portraitSize,
                  child: UnicornAvatarImage(
                    avatar: avatar,
                    emotion: emotion,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: useCompactText
                            ? AppTypography.guideTitleCompact
                            : AppTypography.guideTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
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
            );
          },
        ),
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
  const _PracticeQuestionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.question,
        ),
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
    final itemCount = itemIds.length.clamp(0, 10);

    return SizedBox(
      height: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (var index = 0; index < itemCount; index++)
                SizedBox.square(
                  dimension: 42,
                  child: SafeAssetImage(
                    assetPath: assetPath,
                    placeholder: const Icon(Symbols.favorite_rounded),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeHintButton extends StatelessWidget {
  const _PracticeHintButton({
    required this.languageCode,
    required this.onPressed,
  });

  final String languageCode;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => playTapAndRun(context, onPressed),
        icon: const Icon(Symbols.lightbulb_rounded),
        label: Text(languageCode == 'ca-ES' ? 'Pista' : 'Pista'),
      ),
    );
  }
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
    final color = isAnswered && isCorrect
        ? AppColors.successGreen
        : isSelected
            ? AppColors.gentleError
            : AppColors.softLilac;
    final textColor = HSLColor.fromColor(color).withLightness(0.32).toColor();
    final scale = _isPressed
        ? 0.95
        : isSelected
            ? 1.04
            : 1.0;
    final shadowOpacity = isSelected ? 0.22 : 0.08;

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
              color: color.withValues(alpha: isAnswered ? 0.25 : 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: isAnswered ? 0.66 : 0.34),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: shadowOpacity),
                  blurRadius: isSelected ? 18 : 10,
                  offset: const Offset(0, 7),
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
                splashColor: color.withValues(alpha: 0.3),
                highlightColor: color.withValues(alpha: 0.16),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    style: AppTypography.answerNumber.copyWith(
                      color: textColor,
                    ),
                    child: Text('${widget.value}'),
                  ),
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
    required this.languageCode,
    required this.onNext,
  });

  final bool? isCorrect;
  final String languageCode;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _feedbackText(),
                style: AppTypography.sectionTitle,
              ),
            ),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: onNext == null
                    ? null
                    : () => playTapAndRun(context, onNext!),
                icon: const Icon(Symbols.arrow_forward_rounded),
                label: Text(languageCode == 'ca-ES' ? 'Seguent' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _feedbackText() {
    if (languageCode == 'ca-ES') {
      if (isCorrect == null) {
        return 'Tria una resposta.';
      }
      return isCorrect! ? 'Molt be!' : 'Gairebe. Ho provem?';
    }

    if (isCorrect == null) {
      return 'Elige una respuesta.';
    }
    return isCorrect! ? 'Muy bien!' : 'Casi. Probamos otra?';
  }
}

class _PracticeSummary extends StatelessWidget {
  const _PracticeSummary({
    required this.session,
    required this.languageCode,
    required this.avatar,
    required this.characterName,
    required this.onRepeat,
    required this.onChangePractice,
  });

  final PracticeSessionState session;
  final String languageCode;
  final UnicornAvatar avatar;
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
                  emotion: UnicornAvatarEmotion.celebrating,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                languageCode == 'ca-ES'
                    ? 'Practica acabada'
                    : 'Practica terminada',
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
      return 'Ho mirem juntes';
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
  if (session.config.difficulty == PracticeDifficulty.upTo5) {
    return true;
  }

  return session.exercise.type == 'count' || session.hasAskedHint;
}

String _guideMessage({
  required String languageCode,
  required PracticeSessionState session,
  required String characterName,
}) {
  if (session.hasAskedHint && session.isCorrect == null) {
    return session.exercise.visibleHint;
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
