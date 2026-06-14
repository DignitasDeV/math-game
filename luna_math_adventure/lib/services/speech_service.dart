import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class SpeechService {
  Future<void> speak(String text, {String languageCode});
  Future<void> stop();
}

class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService(this._tts);

  final FlutterTts _tts;

  @override
  Future<void> speak(String text, {String languageCode = 'es-ES'}) async {
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  return FlutterTtsSpeechService(FlutterTts());
});
