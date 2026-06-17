import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/speech_toggle_button.dart';
import '../../models/player_profile.dart';
import '../../models/tts_voice_option.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
import '../../services/profile_repository.dart';
import '../../services/ui_copy.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';

    return MagicScaffold(
      title: UiCopy.settings(languageCode),
      backgroundAssetPath:
          'assets/images/backgrounds/home_background_screen.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppScreenHeader(
                    icon: Symbols.tune_rounded,
                    title: UiCopy.settings(languageCode),
                    subtitle: activeProfile == null
                        ? UiCopy.text(
                            languageCode,
                            es: 'No hay perfil activo.',
                            ca: 'No hi ha cap perfil actiu.',
                          )
                        : UiCopy.text(
                            languageCode,
                            es: 'Perfil activo: ${activeProfile.childName}',
                            ca: 'Perfil actiu: ${activeProfile.childName}',
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SettingsCard(
                    icon: Symbols.group_rounded,
                    label: UiCopy.text(
                      languageCode,
                      es: 'Cambiar perfil',
                      ca: 'Canviar perfil',
                    ),
                    subtitle: UiCopy.text(
                      languageCode,
                      es: 'Elige otro jugador de la familia',
                      ca: 'Tria un altre jugador de la família',
                    ),
                    color: AppColors.softLilac,
                    onPressed: () => context.go('/profiles'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsCard(
                    icon: Symbols.person_add_rounded,
                    label: UiCopy.text(
                      languageCode,
                      es: 'Crear otro perfil',
                      ca: 'Crear un altre perfil',
                    ),
                    subtitle: UiCopy.text(
                      languageCode,
                      es: 'Añade un nuevo jugador',
                      ca: 'Afegeix un jugador nou',
                    ),
                    color: AppColors.skyBlue,
                    onPressed: () {
                      ref.read(onboardingDraftProvider.notifier).reset();
                      context.go('/language');
                    },
                  ),
                  if (activeProfile != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _SoundEffectsSettingsCard(profile: activeProfile),
                    const SizedBox(height: AppSpacing.md),
                    _VoiceSettingsPanel(profile: activeProfile),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () =>
                  playTapAndRun(context, () => context.go('/home')),
              icon: const Icon(Symbols.home_rounded),
              label: Text(UiCopy.text(
                languageCode,
                es: 'Volver al inicio',
                ca: "Tornar a l'inici",
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundEffectsSettingsCard extends ConsumerWidget {
  const _SoundEffectsSettingsCard({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = profile.language.ttsCode;
    const color = AppColors.softMint;
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowWidth;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? AppSpacing.md : AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              width: isNarrow ? 44 : 48,
              height: isNarrow ? 44 : 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                profile.soundEffectsEnabled
                    ? Symbols.volume_up_rounded
                    : Symbols.volume_off_rounded,
                color: iconColor,
              ),
            ),
            SizedBox(width: isNarrow ? AppSpacing.md : AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UiCopy.text(
                      languageCode,
                      es: 'Efectos sonoros',
                      ca: 'Efectes sonors',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(
                      color: iconColor,
                    ),
                  ),
                  Text(
                    UiCopy.text(
                      languageCode,
                      es: 'Activa o desactiva toques, aciertos y premios',
                      ca: 'Activa o desactiva tocs, encerts i premis',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Switch(
              value: profile.soundEffectsEnabled,
              onChanged: (value) {
                ref
                    .read(profileControllerProvider.notifier)
                    .updateActiveProfileSoundEffects(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceSettingsPanel extends ConsumerWidget {
  const _VoiceSettingsPanel({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voices = TtsVoiceOptions.forLanguage(profile.language);
    final selectedVoice = TtsVoiceOptions.byId(profile.ttsVoiceId) ??
        voices.firstWhere((voice) => voice.isDefault);
    final iconColor =
        HSLColor.fromColor(AppColors.starGold).withLightness(0.35).toColor();
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowWidth;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.starGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.starGold.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: isNarrow ? 44 : 48,
                  height: isNarrow ? 44 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Symbols.record_voice_over_rounded,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    UiCopy.text(
                      profile.language.ttsCode,
                      es: 'Voz',
                      ca: 'Veu',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final voice in voices)
                  ChoiceChip(
                    selected: voice.id == profile.ttsVoiceId,
                    label: Text('${voice.toneLabel} · ${voice.label}'),
                    onSelected: (_) {
                      playTapAndRun(
                        context,
                        () => ref
                            .read(profileControllerProvider.notifier)
                            .updateActiveProfileVoice(voice.id),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 52,
              child: SpeechToggleButton(
                clipKey:
                    'settings:${profile.id}:voice-sample:${selectedVoice.id}',
                text: selectedVoice.sampleText,
                languageCode: profile.language.ttsCode,
                voiceId: selectedVoice.id,
                sessionId: 'settings-${profile.id}',
                clipId: 'voice-sample:${selectedVoice.id}',
                filled: true,
                label: UiCopy.text(
                  profile.language.ttsCode,
                  es: 'Probar voz',
                  ca: 'Provar veu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowWidth;
    final horizontalPadding = isNarrow ? AppSpacing.md : AppSpacing.xl;
    final gap = isNarrow ? AppSpacing.md : AppSpacing.lg;

    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onPressed),
        splashColor: color.withValues(alpha: 0.3),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: isNarrow ? 44 : 48,
                height: isNarrow ? 44 : 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        color: iconColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isNarrow ? AppSpacing.sm : AppSpacing.md),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: iconColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
