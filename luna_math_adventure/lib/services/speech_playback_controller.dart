import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'speech_service.dart';

class SpeechPlaybackState {
  const SpeechPlaybackState({
    this.activeClipKey,
    this.isPlaying = false,
  });

  final String? activeClipKey;
  final bool isPlaying;

  bool isActive(String clipKey) => isPlaying && activeClipKey == clipKey;
}

class SpeechPlaybackController extends StateNotifier<SpeechPlaybackState> {
  SpeechPlaybackController(this._speechService)
      : super(const SpeechPlaybackState());

  final SpeechService _speechService;
  int _playbackToken = 0;

  Future<void> speakOrStop({
    required String clipKey,
    required String text,
    required String languageCode,
    String? voiceId,
    String? sessionId,
    String? clipId,
  }) async {
    if (state.isActive(clipKey)) {
      await stop();
      return;
    }

    final token = ++_playbackToken;
    await _speechService.stop();
    if (token != _playbackToken) {
      return;
    }

    state = SpeechPlaybackState(
      activeClipKey: clipKey,
      isPlaying: true,
    );

    try {
      await _speechService.speak(
        text,
        languageCode: languageCode,
        voiceId: voiceId,
        sessionId: sessionId,
        clipId: clipId,
      );
    } finally {
      if (mounted && token == _playbackToken) {
        state = const SpeechPlaybackState();
      }
    }
  }

  Future<void> stop() async {
    _playbackToken++;
    state = const SpeechPlaybackState();
    await _speechService.stop();
  }
}

final speechPlaybackControllerProvider =
    StateNotifierProvider<SpeechPlaybackController, SpeechPlaybackState>((ref) {
  return SpeechPlaybackController(ref.watch(speechServiceProvider));
});
