import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/reward_visual.dart';
import '../../core/widgets/safe_asset_image.dart';
import '../../core/widgets/speech_toggle_button.dart';
import '../../core/widgets/unicorn_avatar_image.dart';
import '../../core/widgets/responsive_action_grid.dart';
import '../../models/reward.dart';
import '../../models/unicorn_avatar.dart';
import '../../services/audio_service.dart';
import '../../services/content_repository.dart';
import '../../services/profile_controller.dart';
import '../../services/speech_playback_controller.dart';
import '../../services/speech_service.dart';
import '../../services/unicorn_avatar_asset_resolver.dart';
import 'game_session_controller.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({
    this.levelId,
    super.key,
  });

  final String? levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(
      gameSessionProvider(levelId ?? 'heart_forest_01'),
    );
    final languageCode =
        ref.watch(activeProfileProvider)?.language.ttsCode ?? 'es-ES';
    final currentSession = sessionState.valueOrNull;

    return MagicScaffold(
      title: currentSession?.level.title.get(languageCode) ?? 'Nivel',
      backgroundAssetPath: _levelBackgroundAssetPath(
        currentSession?.level.worldId ?? 'heart_forest',
      ),
      child: sessionState.when(
        data: (session) => _ExerciseView(
          session: session,
          levelId: levelId ?? 'heart_forest_01',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('No se pudo cargar el ejercicio.'),
        ),
      ),
    );
  }
}

String _levelBackgroundAssetPath(String worldId) {
  return 'assets/images/backgrounds/${worldId}_screen.webp';
}

class _ExerciseView extends ConsumerStatefulWidget {
  const _ExerciseView({
    required this.session,
    required this.levelId,
  });

  final GameSessionState session;
  final String levelId;

  @override
  ConsumerState<_ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends ConsumerState<_ExerciseView> {
  late String _speechSessionId;
  final _preparedClipKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _speechSessionId = _createSpeechSessionId(widget.levelId);
  }

  @override
  void didUpdateWidget(covariant _ExerciseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      final oldSessionId = _speechSessionId;
      _speechSessionId = _createSpeechSessionId(widget.levelId);
      _preparedClipKeys.clear();
      unawaited(ref.read(speechPlaybackControllerProvider.notifier).stop());
      unawaited(ref.read(speechServiceProvider).disposeSession(oldSessionId));
    }
  }

  @override
  void dispose() {
    unawaited(ref.read(speechPlaybackControllerProvider.notifier).stop());
    unawaited(ref.read(speechServiceProvider).disposeSession(_speechSessionId));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechService = ref.watch(speechServiceProvider);
    final audioService = ref.watch(audioServiceProvider);
    final speechPlayback =
        ref.read(speechPlaybackControllerProvider.notifier);
    final activeProfile = ref.watch(activeProfileProvider);
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';
    final voiceId = activeProfile?.ttsVoiceId;
    final unicornName = activeProfile?.unicornName ?? 'Luna';
    final unicornAvatar = activeProfile?.unicornAvatar ?? UnicornAvatar.avatar01;
    final session = widget.session;
    final levelId = widget.levelId;
    final controller = ref.read(gameSessionProvider(levelId).notifier);

    _prepareSpeechFor(session, languageCode, voiceId, speechService);

    if (session.isComplete) {
      return _LevelCompleteView(
        correctAnswers: session.correctAnswers,
        totalQuestions: session.questionsToComplete,
        starsEarned: session.starsEarned,
        newRewardId: session.newRewardId,
        languageCode: languageCode,
        nextLevelId: session.nextLevelId,
        unicornName: unicornName,
        unicornAvatar: unicornAvatar,
        onRepeatLevel: controller.repeatLevel,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 700;
        final sectionGap = isCompactHeight ? AppSpacing.sm : AppSpacing.md;
        final writtenOperation = _writtenOperationFor(session);
        final guideFlex = writtenOperation == null
            ? isCompactHeight
                ? 4
                : 5
            : isCompactHeight
                ? 5
                : 6;
        final answersFlex = isCompactHeight ? 3 : 4;
        final questionSpeech = _SpeechButtonData(
          clipKey: '$_speechSessionId:question:${session.exercise.id}',
          text: session.exercise.spokenText,
          languageCode: languageCode,
          voiceId: voiceId,
          sessionId: _speechSessionId,
          clipId: 'question:${session.exercise.id}',
        );
        final hintSpeech = _SpeechButtonData(
          clipKey: '$_speechSessionId:hint:${session.exercise.id}',
          text: session.exercise.spokenHint,
          languageCode: languageCode,
          voiceId: voiceId,
          sessionId: _speechSessionId,
          clipId: 'hint:${session.exercise.id}',
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProgressHeader(
              questionIndex: session.questionIndex,
              questionsToComplete: session.questionsToComplete,
              correctAnswers: session.correctAnswers,
              languageCode: languageCode,
            ),
            SizedBox(height: sectionGap),
            Expanded(
              flex: guideFlex,
              child: _UnicornGuide(
                title: _guideTitle(
                  languageCode: languageCode,
                  isCorrect: session.isCorrect,
                  hasAskedHint: session.hasAskedHint,
                ),
                avatar: unicornAvatar,
                emotion: _emotionForSession(
                  isCorrect: session.isCorrect,
                  hasAskedHint: session.hasAskedHint,
                ),
                message: _missionGuideMessage(
                  languageCode: languageCode,
                  worldId: session.level.worldId,
                  levelId: session.level.id,
                  isCorrect: session.isCorrect,
                  hasAskedHint: session.hasAskedHint,
                  hint: session.exercise.visibleHint,
                  unicornName: unicornName,
                ),
                writtenOperation: writtenOperation,
                speech: session.hasAskedHint && session.isCorrect == null
                    ? hintSpeech
                    : null,
              ),
            ),
            SizedBox(height: sectionGap),
            _QuestionCard(
              text: session.exercise.visibleText,
              speech: questionSpeech,
            ),
            if (_shouldShowVisualSupport(session)) ...[
              SizedBox(height: sectionGap),
              _VisualItemsPanel(
                itemIds: session.exercise.visualItemIds,
                assetPath: session.exercise.visualItemAssetPath,
              ),
            ],
            SizedBox(height: sectionGap),
            _HintButton(
              onPressed: () async {
                await speechPlayback.stop();
                controller.showHint();
                await audioService.playHintOpen();
              },
              languageCode: languageCode,
            ),
            SizedBox(height: sectionGap),
            Expanded(
              flex: answersFlex,
              child: ResponsiveActionGrid(
                minRows: 2,
                gap: isCompactHeight ? AppSpacing.sm : AppSpacing.md,
                children: [
                  for (final option in session.exercise.options)
                    _AnswerTile(
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
            _FeedbackBar(
              isCorrect: session.isCorrect,
              isAdvancing: session.isAdvancing,
              languageCode: languageCode,
              onNext: session.selectedAnswer == null
                  ? null
                  : controller.nextExercise,
            ),
          ],
        );
      },
    );
  }

  _WrittenOperationData? _writtenOperationFor(GameSessionState session) {
    if (session.level.sortOrder < 7) {
      return null;
    }
    if (session.exercise.type != 'addition' &&
        session.exercise.type != 'subtraction') {
      return null;
    }

    return _WrittenOperationData(
      left: session.exercise.left,
      right: session.exercise.right,
      symbol: session.exercise.type == 'addition' ? '+' : '-',
    );
  }

  bool _shouldShowVisualSupport(GameSessionState session) {
    if (session.exercise.visualItemIds.isEmpty) {
      return false;
    }

    return session.exercise.type == 'count' || session.hasAskedHint;
  }

  void _prepareSpeechFor(
    GameSessionState session,
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
          SpeechClip(
            id: 'hint:${session.exercise.id}',
            text: session.exercise.spokenHint,
          ),
        ],
      ),
    );
  }
}

String _createSpeechSessionId(String levelId) {
  return '$levelId-${DateTime.now().microsecondsSinceEpoch}';
}

enum _UnicornEmotion {
  idle,
  happy,
  thinking,
  encouraging,
  celebrating,
}

class _SpeechButtonData {
  const _SpeechButtonData({
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

_UnicornEmotion _emotionForSession({
  required bool? isCorrect,
  required bool hasAskedHint,
}) {
  if (isCorrect == null) {
    if (hasAskedHint) {
      return _UnicornEmotion.thinking;
    }

    return _UnicornEmotion.idle;
  }

  return isCorrect ? _UnicornEmotion.happy : _UnicornEmotion.encouraging;
}

String _guideTitle({
  required String languageCode,
  required bool? isCorrect,
  required bool hasAskedHint,
}) {
  if (languageCode == 'ca-ES') {
    if (isCorrect == true) {
      return 'Molt bé';
    }
    if (isCorrect == false) {
      return 'Ho mirem juntes';
    }
    if (hasAskedHint) {
      return 'Pista màgica';
    }

    return 'Missió';
  }

  if (isCorrect == true) {
    return 'Muy bien';
  }
  if (isCorrect == false) {
    return 'Lo miramos juntos';
  }
  if (hasAskedHint) {
    return 'Pista mágica';
  }

  return 'Misión';
}

String _missionGuideMessage({
  required String languageCode,
  required String worldId,
  required String levelId,
  required bool? isCorrect,
  required bool hasAskedHint,
  required String hint,
  required String unicornName,
}) {
  if (languageCode == 'ca-ES') {
    if (isCorrect == true) {
      return 'Has ajudat $unicornName a encendre més màgia del bosc.';
    }
    if (isCorrect == false) {
      return 'No passa res. $unicornName ho prova amb tu, a poc a poc.';
    }
    if (hasAskedHint) {
      return hint;
    }

    return _levelMissionCa(levelId, worldId, unicornName);
  }

  if (isCorrect == true) {
    return 'Has ayudado a $unicornName a encender más magia del bosque.';
  }
  if (isCorrect == false) {
    return 'No pasa nada. $unicornName lo prueba contigo, paso a paso.';
  }
  if (hasAskedHint) {
    return hint;
  }

  return _levelMissionEs(levelId, worldId, unicornName);
}

String _levelMissionEs(String levelId, String worldId, String unicornName) {
  return switch (levelId) {
    'heart_forest_01' =>
      'Ayuda a $unicornName a encontrar los primeros corazones mágicos.',
    'heart_forest_02' =>
      'Ayuda a $unicornName a llenar el sendero con más corazones.',
    'heart_forest_03' =>
      'Junta pequeños grupos para abrir una puerta del bosque.',
    'heart_forest_04' =>
      'Suma los regalos del bosque para que $unicornName avance.',
    'heart_forest_05' =>
      'Reparte los objetos con cuidado para dejar el bosque ordenado.',
    'heart_forest_boss' =>
      'Resuelve el reto final para iluminar el Bosque de Corazones.',
    _ => switch (worldId) {
        'heart_forest' =>
          'Ayuda a $unicornName a encontrar los corazones mágicos del bosque.',
        _ => 'Ayuda a $unicornName a avanzar por el mundo mágico.',
      },
  };
}

String _levelMissionCa(String levelId, String worldId, String unicornName) {
  return switch (levelId) {
    'heart_forest_01' =>
      'Ajuda $unicornName a trobar els primers cors màgics.',
    'heart_forest_02' =>
      'Ajuda $unicornName a omplir el camí amb més cors.',
    'heart_forest_03' =>
      'Ajunta grups petits per obrir una porta del bosc.',
    'heart_forest_04' =>
      'Suma els regals del bosc perquè $unicornName avanci.',
    'heart_forest_05' =>
      'Reparteix els objectes amb calma per deixar el bosc endreçat.',
    'heart_forest_boss' =>
      'Resol el repte final per il·luminar el Bosc de Cors.',
    _ => switch (worldId) {
        'heart_forest' =>
          'Ajuda $unicornName a trobar els cors màgics del bosc.',
        _ => 'Ajuda $unicornName a avançar pel món màgic.',
      },
  };
}

class _UnicornGuide extends StatelessWidget {
  const _UnicornGuide({
    required this.title,
    required this.avatar,
    required this.emotion,
    required this.message,
    required this.writtenOperation,
    required this.speech,
  });

  final String title;
  final UnicornAvatar avatar;
  final _UnicornEmotion emotion;
  final String message;
  final _WrittenOperationData? writtenOperation;
  final _SpeechButtonData? speech;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final hasOperation = writtenOperation != null;
        final availableHeight = constraints.maxHeight;
        final padding = AppSpacing.md * 2;
        final portraitSize = (availableHeight - padding).clamp(
          hasOperation ? 124.0 : 104.0,
          hasOperation ? 260.0 : 230.0,
        ).toDouble();
        final useCompactText = isCompact || availableHeight < 210;

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
            child: Row(
              children: [
                _UnicornPortrait(
                  avatar: avatar,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                            _GuideSpeakButton(speech: speech!),
                          ],
                        ],
                      ),
                      if (writtenOperation case final operation?) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _WrittenOperation(
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

class _WrittenOperationData {
  const _WrittenOperationData({
    required this.left,
    required this.right,
    required this.symbol,
  });

  final int left;
  final int right;
  final String symbol;

  bool get isVertical => left >= 10 || right >= 10;
}

class _WrittenOperation extends StatelessWidget {
  const _WrittenOperation({
    required this.operation,
    required this.compact,
  });

  final _WrittenOperationData operation;
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
              ? _VerticalWrittenOperation(
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
                      .copyWith(
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}

class _VerticalWrittenOperation extends StatelessWidget {
  const _VerticalWrittenOperation({
    required this.operation,
    required this.color,
    required this.compact,
  });

  final _WrittenOperationData operation;
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
          .copyWith(
        color: color,
      ),
    );
  }
}

class _GuideSpeakButton extends StatelessWidget {
  const _GuideSpeakButton({required this.speech});

  final _SpeechButtonData speech;

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

class _UnicornPortrait extends StatelessWidget {
  const _UnicornPortrait({
    required this.avatar,
    required this.emotion,
    required this.size,
  });

  final UnicornAvatar avatar;
  final _UnicornEmotion emotion;
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
          key: ValueKey('${avatar.id}:${emotion.name}'),
          avatar: avatar,
          emotion: _avatarEmotionFor(emotion),
          fallback: _UnicornFallback(size: size),
        ),
      ),
    );
  }
}

class _UnicornFallback extends StatelessWidget {
  const _UnicornFallback({required this.size});

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

UnicornAvatarEmotion _avatarEmotionFor(_UnicornEmotion emotion) {
  return switch (emotion) {
    _UnicornEmotion.idle => UnicornAvatarEmotion.idle,
    _UnicornEmotion.happy => UnicornAvatarEmotion.happy,
    _UnicornEmotion.thinking => UnicornAvatarEmotion.thinking,
    _UnicornEmotion.encouraging => UnicornAvatarEmotion.encouraging,
    _UnicornEmotion.celebrating => UnicornAvatarEmotion.celebrating,
  };
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.questionIndex,
    required this.questionsToComplete,
    required this.correctAnswers,
    required this.languageCode,
  });

  final int questionIndex;
  final int questionsToComplete;
  final int correctAnswers;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final progressText = '$questionIndex/$questionsToComplete';
    final correctText = languageCode == 'ca-ES'
        ? '$correctAnswers encerts'
        : '$correctAnswers aciertos';

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
                  value: questionIndex / questionsToComplete,
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.text,
    required this.speech,
  });

  final String text;
  final _SpeechButtonData speech;

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

class _VisualItemsPanel extends StatelessWidget {
  const _VisualItemsPanel({
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
                    _VisualItemIcon(
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

class _VisualItemIcon extends StatelessWidget {
  const _VisualItemIcon({
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
        placeholder: _VisualItemFallback(
          itemId: itemId,
          size: size,
        ),
      ),
    );
  }
}

class _VisualItemFallback extends StatelessWidget {
  const _VisualItemFallback({
    required this.itemId,
    required this.size,
  });

  final String itemId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _itemColor(itemId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(math.max(8.0, size * 0.3)),
      ),
      child: Icon(
        _itemIcon(itemId),
        color: HSLColor.fromColor(color).withLightness(0.35).toColor(),
        size: size * 0.65,
      ),
    );
  }
}

IconData _itemIcon(String itemId) {
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

Color _itemColor(String itemId) {
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

class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.onPressed,
    required this.languageCode,
  });

  final VoidCallback onPressed;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Symbols.lightbulb_rounded),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _hintButtonLabel(languageCode),
            style: AppTypography.button,
          ),
        ),
      ),
    );
  }
}

String _hintButtonLabel(String languageCode) {
  return languageCode == 'ca-ES' ? 'Pista' : 'Pista';
}

class _AnswerTile extends StatefulWidget {
  const _AnswerTile({
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
  State<_AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<_AnswerTile> {
  bool _isPressed = false;

  @override
  void didUpdateWidget(covariant _AnswerTile oldWidget) {
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
        ? AppColors.successGreen.withValues(alpha: 0.34)
        : isSelected
            ? AppColors.gentleError.withValues(alpha: 0.34)
            : Colors.white.withValues(alpha: 0.94);
    final borderColor = isAnswered && isCorrect
        ? AppColors.successGreen.withValues(alpha: 0.92)
        : isSelected
            ? AppColors.gentleError.withValues(alpha: 0.92)
            : AppColors.lilacAccent.withValues(alpha: 0.58);
    final textColor = isAnswered && isCorrect
        ? HSLColor.fromColor(AppColors.successGreen).withLightness(0.28).toColor()
        : isSelected
            ? HSLColor.fromColor(AppColors.gentleError).withLightness(0.30).toColor()
            : AppColors.purpleText;
    final scale = _isPressed
        ? 0.95
        : isSelected
            ? 1.04
            : 1.0;
    final shadowOpacity = isSelected || (isAnswered && isCorrect) ? 0.24 : 0.14;
    final showFeedbackBadge = isAnswered && (isSelected || isCorrect);

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

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
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
          child: _NextImageButton(
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

class _NextImageButton extends StatelessWidget {
  const _NextImageButton({
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

class _StarsEarnedRow extends StatelessWidget {
  const _StarsEarnedRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.starGold.withValues(alpha: 0.42),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purpleText.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 1; index <= 3; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    index <= stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index <= stars
                        ? AppColors.starGold
                        : AppColors.purpleTextLight.withValues(alpha: 0.58),
                    size: 34,
                    shadows: [
                      Shadow(
                        color: AppColors.purpleText.withValues(alpha: 0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCompleteView extends ConsumerStatefulWidget {
  const _LevelCompleteView({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.starsEarned,
    required this.newRewardId,
    required this.languageCode,
    required this.nextLevelId,
    required this.unicornName,
    required this.unicornAvatar,
    required this.onRepeatLevel,
  });

  final int correctAnswers;
  final int totalQuestions;
  final int starsEarned;
  final String? newRewardId;
  final String languageCode;
  final String? nextLevelId;
  final String unicornName;
  final UnicornAvatar unicornAvatar;
  final FutureOr<void> Function() onRepeatLevel;

  @override
  ConsumerState<_LevelCompleteView> createState() => _LevelCompleteViewState();
}

class _LevelCompleteViewState extends ConsumerState<_LevelCompleteView> {
  var _showRewardModal = true;

  @override
  void initState() {
    super.initState();
    _playRewardSoundIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _LevelCompleteView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.newRewardId != widget.newRewardId) {
      _showRewardModal = true;
      _playRewardSoundIfNeeded();
    }
  }

  void _playRewardSoundIfNeeded() {
    if (widget.newRewardId == null) {
      return;
    }

    unawaited(ref.read(audioServiceProvider).playRewardUnlock());
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowRewardModal =
        widget.newRewardId != null && _showRewardModal;
    final rewardsState = shouldShowRewardModal
        ? ref.watch(rewardsProvider)
        : const AsyncValue<List<Reward>>.data([]);
    final correctAnswers = widget.correctAnswers;
    final totalQuestions = widget.totalQuestions;
    final starsEarned = widget.starsEarned;
    final rewardId = widget.newRewardId;
    final languageCode = widget.languageCode;
    final nextLevelId = widget.nextLevelId;
    final unicornName = widget.unicornName;
    final unicornAvatar = widget.unicornAvatar;
    final canRepeatLevel = correctAnswers < totalQuestions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxUnicornSize = math.min(
          constraints.maxHeight * 0.40,
          constraints.maxWidth * 0.72,
        );
        final unicornSize = maxUnicornSize.clamp(190.0, 360.0).toDouble();

        final completeContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            _UnicornPortrait(
              avatar: unicornAvatar,
              emotion: _UnicornEmotion.celebrating,
              size: unicornSize,
            )
                .animate()
                .fadeIn(duration: 260.ms)
                .scale(
                  begin: const Offset(0.88, 0.88),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              languageCode == 'ca-ES' ? 'Nivell completat' : 'Nivel completado',
              textAlign: TextAlign.center,
              style: AppTypography.heading,
            ).animate(delay: 120.ms).fadeIn(duration: 240.ms).slideY(
                  begin: 0.12,
                  end: 0,
                ),
            const SizedBox(height: AppSpacing.md),
            Text(
              languageCode == 'ca-ES'
                  ? '$correctAnswers de $totalQuestions correctes'
                  : '$correctAnswers de $totalQuestions correctas',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            _StarsEarnedRow(stars: starsEarned)
                .animate(delay: 180.ms)
                .fadeIn(duration: 240.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                )
                .shimmer(
                  delay: 420.ms,
                  duration: 900.ms,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
            if (rewardId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                languageCode == 'ca-ES'
                    ? 'Recompensa desbloquejada'
                    : 'Recompensa desbloqueada',
                textAlign: TextAlign.center,
                style:
                    AppTypography.caption.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              languageCode == 'ca-ES'
                  ? '$unicornName ha avançat una mica més.'
                  : '$unicornName ha avanzado un poquito más.',
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle,
            ),
            const Spacer(),
            if (nextLevelId != null) ...[
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => playTapAndRun(
                    context,
                    () => context.go('/game/$nextLevelId'),
                  ),
                  icon: const Icon(Symbols.arrow_forward_rounded),
                  label: Text(
                    languageCode == 'ca-ES'
                        ? 'Següent nivell'
                        : 'Siguiente nivel',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (canRepeatLevel) ...[
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => playTapAndRun(
                    context,
                    widget.onRepeatLevel,
                  ),
                  icon: const Icon(Symbols.replay_rounded),
                  label: Text(
                    languageCode == 'ca-ES'
                        ? 'Repetir nivell'
                        : 'Repetir nivel',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () =>
                    playTapAndRun(context, () => context.go('/map')),
                icon: const Icon(Symbols.map_rounded),
                label: Text(
                  languageCode == 'ca-ES' ? 'Tornar al mapa' : 'Volver al mapa',
                ),
              ),
            ),
          ],
        );

        return Stack(
          children: [
            completeContent,
            if (shouldShowRewardModal)
              Positioned.fill(
                child: _RewardUnlockOverlay(
                  reward: _rewardFromState(rewardsState, rewardId!),
                  isLoading: rewardsState.isLoading,
                  languageCode: languageCode,
                  onClose: () => setState(() => _showRewardModal = false),
                  onOpenCollection: () => playTapAndRun(
                    context,
                    () => context.go('/rewards'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Reward? _rewardFromState(
    AsyncValue<List<Reward>> rewardsState,
    String rewardId,
  ) {
    return rewardsState.valueOrNull
        ?.where((reward) => reward.id == rewardId)
        .firstOrNull;
  }
}

class _RewardUnlockOverlay extends StatelessWidget {
  const _RewardUnlockOverlay({
    required this.reward,
    required this.isLoading,
    required this.languageCode,
    required this.onClose,
    required this.onOpenCollection,
  });

  final Reward? reward;
  final bool isLoading;
  final String languageCode;
  final VoidCallback onClose;
  final VoidCallback onOpenCollection;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          color: AppColors.purpleText.withValues(alpha: 0.32),
          dismissible: false,
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.starGold.withValues(alpha: 0.8),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purpleText.withValues(alpha: 0.24),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.auto_awesome_rounded,
                          color: AppColors.hintOrange,
                          size: 42,
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              duration: 1200.ms,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          languageCode == 'ca-ES'
                              ? 'Has guanyat una recompensa!'
                              : 'Has ganado una recompensa!',
                          textAlign: TextAlign.center,
                          style: AppTypography.pageTitle,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox.square(
                          dimension: 150,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _RewardUnlockVisual(reward: reward),
                        )
                            .animate()
                            .fadeIn(duration: 220.ms)
                            .scale(
                              begin: const Offset(0.78, 0.78),
                              end: const Offset(1, 1),
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          reward?.name.get(languageCode) ??
                              (languageCode == 'ca-ES'
                                  ? 'Recompensa màgica'
                                  : 'Recompensa mágica'),
                          textAlign: TextAlign.center,
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: onOpenCollection,
                                icon: const Icon(
                                  Symbols.collections_bookmark_rounded,
                                ),
                                label: Text(
                                  languageCode == 'ca-ES'
                                      ? 'Veure col·lecció'
                                      : 'Ver colección',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: onClose,
                                child: Text(
                                  languageCode == 'ca-ES' ? 'Genial' : 'Genial',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 180.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardUnlockVisual extends StatelessWidget {
  const _RewardUnlockVisual({required this.reward});

  final Reward? reward;

  @override
  Widget build(BuildContext context) {
    if (reward case final reward?) {
      return RewardVisual(reward: reward);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.starGold.withValues(alpha: 0.26),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.starGold.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      child: const Icon(
        Symbols.workspace_premium_rounded,
        color: AppColors.purpleText,
        size: 62,
      ),
    );
  }
}
