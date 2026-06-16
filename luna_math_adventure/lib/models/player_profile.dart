import 'app_language.dart';
import 'tts_voice_option.dart';
import 'unicorn_avatar.dart';

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.childName,
    required this.unicornName,
    required this.language,
    required this.unicornAvatar,
    required this.ttsVoiceId,
  });

  final String id;
  final String childName;
  final String unicornName;
  final AppLanguage language;
  final UnicornAvatar unicornAvatar;
  final String ttsVoiceId;

  PlayerProfile copyWith({
    String? id,
    String? childName,
    String? unicornName,
    AppLanguage? language,
    UnicornAvatar? unicornAvatar,
    String? ttsVoiceId,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      unicornName: unicornName ?? this.unicornName,
      language: language ?? this.language,
      unicornAvatar: unicornAvatar ?? this.unicornAvatar,
      ttsVoiceId: ttsVoiceId ?? this.ttsVoiceId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'childName': childName,
      'unicornName': unicornName,
      'language': language.ttsCode,
      'unicornAvatarId': unicornAvatar.id,
      'ttsVoiceId': ttsVoiceId,
    };
  }

  static PlayerProfile fromJson(Map<String, Object?> json) {
    final language = AppLanguage.fromCode(json['language'] as String? ?? '');
    return PlayerProfile(
      id: json['id'] as String? ?? '',
      childName: json['childName'] as String? ?? '',
      unicornName: json['unicornName'] as String? ?? '',
      language: language,
      unicornAvatar: UnicornAvatar.fromProfileJson(json),
      ttsVoiceId: TtsVoiceOptions.normalizedVoiceId(
        language: language,
        voiceId: json['ttsVoiceId'] as String?,
      ),
    );
  }
}
