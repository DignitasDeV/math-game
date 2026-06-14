import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_typography.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../services/audio_service.dart';
import '../../services/exercise_generator.dart';
import '../../services/speech_service.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(sampleExerciseProvider);
    final speechService = ref.watch(speechServiceProvider);
    final audioService = ref.watch(audioServiceProvider);

    return MagicScaffold(
      title: 'Juego',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(exercise.visibleText, style: AppTypography.title),
          const SizedBox(height: 16),
          Text(
            'Toca el altavoz para escucharlo. Luego elige una respuesta.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 24),
          IconButton.filledTonal(
            iconSize: 40,
            onPressed: () => speechService.speak(exercise.spokenText),
            icon: const Icon(Icons.volume_up),
            tooltip: 'Leer en voz alta',
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => audioService.playCorrectSfx(),
            icon: const Icon(Icons.favorite),
            label: Text('${exercise.answer}'),
          ),
        ],
      ),
    );
  }
}
