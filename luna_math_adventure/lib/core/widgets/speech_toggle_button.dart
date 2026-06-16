import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../services/audio_service.dart';
import '../../services/speech_playback_controller.dart';

class SpeechToggleButton extends ConsumerWidget {
  const SpeechToggleButton({
    required this.clipKey,
    required this.text,
    required this.languageCode,
    this.voiceId,
    this.sessionId,
    this.clipId,
    this.label,
    this.tooltip,
    this.size = 30,
    this.filled = false,
    this.enabled = true,
    super.key,
  });

  final String clipKey;
  final String text;
  final String languageCode;
  final String? voiceId;
  final String? sessionId;
  final String? clipId;
  final String? label;
  final String? tooltip;
  final double size;
  final bool filled;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      speechPlaybackControllerProvider.select(
        (state) => state.isActive(clipKey),
      ),
    );
    final icon = Icon(
      isActive ? Symbols.stop_rounded : Symbols.volume_up_rounded,
      size: size,
    );
    final effectiveTooltip = tooltip ??
        (isActive
            ? languageCode == 'ca-ES'
                ? 'Aturar'
                : 'Parar'
            : languageCode == 'ca-ES'
                ? 'Escoltar'
                : 'Escuchar');
    final onPressed = enabled
        ? () => playTapAndRun(
              context,
              () => ref
                  .read(speechPlaybackControllerProvider.notifier)
                  .speakOrStop(
                    clipKey: clipKey,
                    text: text,
                    languageCode: languageCode,
                    voiceId: voiceId,
                    sessionId: sessionId,
                    clipId: clipId,
                  ),
              stopSpeech: false,
            )
        : null;

    if (filled && label != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(isActive ? _stopLabel(languageCode) : label!),
      );
    }

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        child: icon,
      );
    }

    return Tooltip(
      message: effectiveTooltip,
      child: Material(
        color: AppColors.skyBlue.withValues(alpha: isActive ? 0.26 : 0.18),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: AppColors.skyBlue.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: IconTheme(
              data: IconThemeData(
                color: HSLColor.fromColor(AppColors.skyBlue)
                    .withLightness(0.35)
                    .toColor(),
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  String _stopLabel(String languageCode) {
    return languageCode == 'ca-ES' ? 'Aturar' : 'Parar';
  }
}
