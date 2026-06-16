import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../models/tts_voice_option.dart';

class SpeechClip {
  const SpeechClip({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;
}

abstract class SpeechService {
  Future<void> prepareSession({
    required String sessionId,
    required String languageCode,
    required String voiceId,
    required Iterable<SpeechClip> clips,
  });

  Future<void> speak(
    String text, {
    String languageCode,
    String? voiceId,
    String? sessionId,
    String? clipId,
  });

  Future<void> disposeSession(String sessionId);
  Future<void> stop();
}

class HybridSpeechService implements SpeechService {
  HybridSpeechService({
    required FlutterTts tts,
    required AudioPlayer player,
    http.Client? client,
    String serverUrl = _defaultServerUrl,
    bool useGeneratedSpeech = _defaultUseGeneratedSpeech,
  })  : _tts = tts,
        _player = player,
        _client = client ?? http.Client(),
        _serverUri = Uri.parse(serverUrl),
        _useGeneratedSpeech = useGeneratedSpeech;

  static const _defaultServerUrl = String.fromEnvironment(
    'LUNA_TTS_SERVER_URL',
    defaultValue: 'http://127.0.0.1:8765',
  );
  static const _defaultUseGeneratedSpeech = bool.fromEnvironment(
    'LUNA_USE_PIPER_TTS',
    defaultValue: true,
  );

  final FlutterTts _tts;
  final AudioPlayer _player;
  final http.Client _client;
  final Uri _serverUri;
  final bool _useGeneratedSpeech;
  final _generatedUrls = <String, String>{};

  @override
  Future<void> prepareSession({
    required String sessionId,
    required String languageCode,
    required String voiceId,
    required Iterable<SpeechClip> clips,
  }) async {
    if (!_useGeneratedSpeech || TtsVoiceOptions.isSystemVoice(voiceId)) {
      return;
    }

    final uniqueClips = <String, SpeechClip>{};
    for (final clip in clips) {
      final text = _speechTextFor(clip.text.trim(), languageCode);
      if (text.isEmpty) {
        continue;
      }

      uniqueClips[_cacheKey(sessionId, languageCode, voiceId, text)] =
          SpeechClip(
        id: clip.id,
        text: text,
      );
    }

    if (uniqueClips.isEmpty) {
      return;
    }

    try {
      final response = await _postJson(
        '/api/tts/prepare',
        {
          'sessionId': sessionId,
          'languageCode': languageCode,
          'voiceId': _piperVoiceIdFor(voiceId),
          'speakerId': _speakerIdFor(voiceId),
          'clips': [
            for (final clip in uniqueClips.values)
              {
                'id': clip.id,
                'text': clip.text,
              },
          ],
        },
      );
      final prepared = response['clips'];
      if (prepared is! List) {
        return;
      }

      for (final item in prepared) {
        if (item is! Map) {
          continue;
        }

        final text = item['text'] as String?;
        final url = item['url'] as String?;
        if (text == null || url == null) {
          continue;
        }

        _generatedUrls[_cacheKey(sessionId, languageCode, voiceId, text)] = url;
      }
    } catch (_) {
      // Piper is optional. If the local server is unavailable, flutter_tts
      // remains the fallback.
    }
  }

  @override
  Future<void> speak(
    String text, {
    String languageCode = 'es-ES',
    String? voiceId,
    String? sessionId,
    String? clipId,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return;
    }
    final speechText = _speechTextFor(cleanText, languageCode);

    if (_useGeneratedSpeech &&
        sessionId != null &&
        !TtsVoiceOptions.isSystemVoice(voiceId)) {
      final played = await _speakGenerated(
        text: speechText,
        languageCode: languageCode,
        voiceId: voiceId,
        sessionId: sessionId,
        clipId: clipId,
      );
      if (played) {
        return;
      }
    }

    await _speakWithFlutterTts(
      speechText,
      languageCode,
      useSystemSettings: TtsVoiceOptions.isSystemVoice(voiceId),
    );
  }

  @override
  Future<void> disposeSession(String sessionId) async {
    _generatedUrls.removeWhere((key, _) => key.startsWith('$sessionId|'));
    if (!_useGeneratedSpeech) {
      return;
    }

    try {
      await _client
          .delete(_serverUri.resolve('/api/tts/session/$sessionId'))
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {
      // Best-effort cleanup; the local server can also be restarted to clear
      // its temp directory.
    }
  }

  @override
  Future<void> stop() async {
    await Future.wait([
      _tts.stop(),
      _player.stop(),
    ]);
  }

  void dispose() {
    _client.close();
    unawaited(_player.dispose());
  }

  Future<bool> _speakGenerated({
    required String text,
    required String languageCode,
    required String? voiceId,
    required String sessionId,
    String? clipId,
  }) async {
    try {
      final key = _cacheKey(sessionId, languageCode, voiceId, text);
      final url = _generatedUrls[key] ??
          await _synthesizeOne(
            sessionId: sessionId,
            languageCode: languageCode,
            voiceId: voiceId,
            clipId: clipId ?? 'spoken',
            text: text,
          );
      if (url == null) {
        return false;
      }

      _generatedUrls[key] = url;
      await _tts.stop();
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _synthesizeOne({
    required String sessionId,
    required String languageCode,
    required String? voiceId,
    required String clipId,
    required String text,
  }) async {
    final response = await _postJson(
      '/api/tts/synthesize',
      {
        'sessionId': sessionId,
        'languageCode': languageCode,
        'voiceId': _piperVoiceIdFor(voiceId),
        'speakerId': _speakerIdFor(voiceId),
        'id': clipId,
        'text': text,
      },
    );
    return response['url'] as String?;
  }

  Future<void> _speakWithFlutterTts(
    String text,
    String languageCode, {
    bool useSystemSettings = false,
  }) async {
    await _player.stop();
    await _tts.setLanguage(languageCode);
    await _tts.awaitSpeakCompletion(true);
    if (!useSystemSettings) {
      await _tts.setSpeechRate(0.45);
    }
    await _tts.speak(text);
  }

  Future<Map<String, Object?>> _postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client
        .post(
          _serverUri.resolve(path),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('TTS server returned HTTP ${response.statusCode}.');
    }

    return Map<String, Object?>.from(jsonDecode(response.body) as Map);
  }

  String _cacheKey(
    String sessionId,
    String languageCode,
    String? voiceId,
    String text,
  ) {
    return '$sessionId|$languageCode|${voiceId ?? 'default'}|$text';
  }

  String? _piperVoiceIdFor(String? voiceId) {
    if (voiceId == null || voiceId.isEmpty) {
      return voiceId;
    }

    return TtsVoiceOptions.byId(voiceId)?.piperVoiceId ?? voiceId;
  }

  int? _speakerIdFor(String? voiceId) {
    if (voiceId == null || voiceId.isEmpty) {
      return null;
    }

    return TtsVoiceOptions.byId(voiceId)?.speakerId;
  }

  String _speechTextFor(String text, String languageCode) {
    final isCatalan = languageCode == 'ca-ES';
    final plus = isCatalan ? ' mes ' : ' mas ';
    final minus = isCatalan ? ' menys ' : ' menos ';
    final equals = isCatalan ? ' igual a ' : ' igual a ';
    final divided = isCatalan ? ' dividit entre ' : ' dividido entre ';

    var value = text
        .replaceAll(RegExp(r'(?<=\d)\s*\+\s*(?=\d)'), plus)
        .replaceAll(RegExp(r'(?<=\d)\s*-\s*(?=\d)'), minus)
        .replaceAll(RegExp(r'(?<=\d)\s*=\s*(?=\d|\?)'), equals)
        .replaceAll(RegExp(r'(?<=\d)\s*/\s*(?=\d)'), divided)
        .replaceAll('...', '. ');

    value = value.replaceAllMapped(
      RegExp(r'\b\d{1,2}\b'),
      (match) => _numberWordForSpeech(
        int.parse(match.group(0)!),
        languageCode,
      ),
    );

    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _numberWordForSpeech(int value, String languageCode) {
    final words = languageCode == 'ca-ES'
        ? _catalanSpeechNumbers
        : _spanishSpeechNumbers;
    return words[value] ?? '$value';
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = HybridSpeechService(
    tts: FlutterTts(),
    player: AudioPlayer(),
  );
  ref.onDispose(service.dispose);
  return service;
});

const _spanishSpeechNumbers = {
  0: 'cero',
  1: 'uno',
  2: 'dos',
  3: 'tres',
  4: 'cuatro',
  5: 'cinco',
  6: 'seis',
  7: 'siete',
  8: 'ocho',
  9: 'nueve',
  10: 'diez',
  11: 'once',
  12: 'doce',
  13: 'trece',
  14: 'catorce',
  15: 'quince',
  16: 'dieciseis',
  17: 'diecisiete',
  18: 'dieciocho',
  19: 'diecinueve',
  20: 'veinte',
  21: 'veintiuno',
  22: 'veintidos',
  23: 'veintitres',
  24: 'veinticuatro',
  25: 'veinticinco',
  26: 'veintiseis',
  27: 'veintisiete',
  28: 'veintiocho',
  29: 'veintinueve',
  30: 'treinta',
  31: 'treinta y uno',
  32: 'treinta y dos',
  33: 'treinta y tres',
  34: 'treinta y cuatro',
  35: 'treinta y cinco',
  36: 'treinta y seis',
  37: 'treinta y siete',
  38: 'treinta y ocho',
  39: 'treinta y nueve',
  40: 'cuarenta',
};

const _catalanSpeechNumbers = {
  0: 'zero',
  1: 'un',
  2: 'dos',
  3: 'tres',
  4: 'quatre',
  5: 'cinc',
  6: 'sis',
  7: 'set',
  8: 'vuit',
  9: 'nou',
  10: 'deu',
  11: 'onze',
  12: 'dotze',
  13: 'tretze',
  14: 'catorze',
  15: 'quinze',
  16: 'setze',
  17: 'disset',
  18: 'divuit',
  19: 'dinou',
  20: 'vint',
  21: 'vint-i-un',
  22: 'vint-i-dos',
  23: 'vint-i-tres',
  24: 'vint-i-quatre',
  25: 'vint-i-cinc',
  26: 'vint-i-sis',
  27: 'vint-i-set',
  28: 'vint-i-vuit',
  29: 'vint-i-nou',
  30: 'trenta',
  31: 'trenta-un',
  32: 'trenta-dos',
  33: 'trenta-tres',
  34: 'trenta-quatre',
  35: 'trenta-cinc',
  36: 'trenta-sis',
  37: 'trenta-set',
  38: 'trenta-vuit',
  39: 'trenta-nou',
  40: 'quaranta',
};
