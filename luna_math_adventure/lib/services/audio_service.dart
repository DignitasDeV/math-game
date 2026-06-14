import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioService {
  Future<void> playCorrectSfx();
  Future<void> stop();
}

class LocalAudioService implements AudioService {
  LocalAudioService(this._player);

  final AudioPlayer _player;

  @override
  Future<void> playCorrectSfx() async {
    try {
      await _player.setAsset('assets/audio/sfx/correct.mp3');
      await _player.play();
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  Future<void> stop() => _player.stop();
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return LocalAudioService(player);
});
