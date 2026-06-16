import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'speech_playback_controller.dart';

enum AudioCue {
  tap('assets/audio/sfx/ui/tap_01.wav'),
  back('assets/audio/sfx/ui/back_01.wav'),
  correct('assets/audio/sfx/feedback/correct_01.wav'),
  wrongSoft('assets/audio/sfx/feedback/wrong_soft_01.wav'),
  hintOpen('assets/audio/sfx/feedback/hint_open_01.wav'),
  sparkle('assets/audio/sfx/rewards/sparkle_01.wav'),
  rewardUnlock('assets/audio/sfx/rewards/reward_unlock_01.wav'),
  levelComplete('assets/audio/sfx/rewards/level_complete_01.wav'),
  stickerCollected('assets/audio/sfx/rewards/sticker_collected_01.wav');

  const AudioCue(this.assetPath);

  final String assetPath;
}

abstract class AudioService {
  Future<void> playCue(AudioCue cue);
  Future<void> playTap();
  Future<void> playBack();
  Future<void> playCorrectSfx();
  Future<void> playWrongSoft();
  Future<void> playHintOpen();
  Future<void> playRewardUnlock();
  Future<void> stop();
}

class LocalAudioService implements AudioService {
  LocalAudioService(this._player);

  final AudioPlayer _player;
  Future<Set<String>>? _availableAssets;

  @override
  Future<void> playCue(AudioCue cue) async {
    try {
      await _player.stop();
      if (!await _assetExists(cue.assetPath)) {
        await _playFallbackClick();
        return;
      }

      await _player.setAsset(cue.assetPath);
      await _player.play();
    } catch (_) {
      await _playFallbackClick();
    }
  }

  @override
  Future<void> playTap() => playCue(AudioCue.tap);

  @override
  Future<void> playBack() => playCue(AudioCue.back);

  @override
  Future<void> playCorrectSfx() => playCue(AudioCue.correct);

  @override
  Future<void> playWrongSoft() => playCue(AudioCue.wrongSoft);

  @override
  Future<void> playHintOpen() => playCue(AudioCue.hintOpen);

  @override
  Future<void> playRewardUnlock() => playCue(AudioCue.rewardUnlock);

  @override
  Future<void> stop() => _player.stop();

  Future<bool> _assetExists(String assetPath) async {
    final assets = await (_availableAssets ??= _loadAvailableAssets());
    return assets.contains(assetPath);
  }

  Future<Set<String>> _loadAvailableAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().toSet();
    } catch (_) {
      return const <String>{};
    }
  }

  Future<void> _playFallbackClick() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Some platforms do not support system sounds; missing audio is non-fatal.
    }
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return LocalAudioService(player);
});

Future<void> playTapAndRun(
  BuildContext context,
  FutureOr<void> Function() action, {
  bool stopSpeech = true,
}) async {
  final container = ProviderScope.containerOf(context);
  if (stopSpeech) {
    await container.read(speechPlaybackControllerProvider.notifier).stop();
  }

  await container.read(audioServiceProvider).playTap();
  await action();
}

Future<void> playBackAndRun(
  BuildContext context,
  FutureOr<void> Function() action, {
  bool stopSpeech = true,
}) async {
  final container = ProviderScope.containerOf(context);
  if (stopSpeech) {
    await container.read(speechPlaybackControllerProvider.notifier).stop();
  }

  await container.read(audioServiceProvider).playBack();
  await action();
}
