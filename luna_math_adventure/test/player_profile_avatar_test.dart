import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/app_language.dart';
import 'package:luna_math_adventure/models/player_profile.dart';
import 'package:luna_math_adventure/models/tts_voice_option.dart';
import 'package:luna_math_adventure/models/unicorn_avatar.dart';

void main() {
  test('serializes new profiles with unicornAvatarId', () {
    const profile = PlayerProfile(
      id: 'child_1',
      childName: 'Ada',
      unicornName: 'Iris',
      language: AppLanguage.spanish,
      unicornAvatar: UnicornAvatar.avatar03,
      ttsVoiceId: TtsVoiceOptions.defaultSpanishVoiceId,
    );

    expect(profile.toJson(), containsPair('unicornAvatarId', 'avatar_03'));
    expect(
      profile.toJson(),
      containsPair('ttsVoiceId', TtsVoiceOptions.defaultSpanishVoiceId),
    );
    expect(profile.toJson().containsKey('unicornVariant'), isFalse);
  });

  test('migrates legacy unicornia variant to avatar 1', () {
    final profile = PlayerProfile.fromJson({
      'id': 'child_1',
      'childName': 'Ada',
      'unicornName': 'Luna',
      'language': 'es-ES',
      'unicornVariant': 'unicornia',
    });

    expect(profile.unicornAvatar, UnicornAvatar.avatar01);
    expect(profile.ttsVoiceId, TtsVoiceOptions.defaultSpanishVoiceId);
  });

  test('migrates legacy unicorn variant to avatar 2', () {
    final profile = PlayerProfile.fromJson({
      'id': 'child_1',
      'childName': 'Ada',
      'unicornName': 'Luno',
      'language': 'es-ES',
      'unicornVariant': 'unicorn',
    });

    expect(profile.unicornAvatar, UnicornAvatar.avatar02);
  });

  test('migrates legacy catalan profiles to default catalan voice', () {
    final profile = PlayerProfile.fromJson({
      'id': 'child_1',
      'childName': 'Ada',
      'unicornName': 'Luna',
      'language': 'ca-ES',
      'unicornAvatarId': 'aurora',
    });

    expect(profile.ttsVoiceId, TtsVoiceOptions.defaultCatalanVoiceId);
  });

  test('migrates legacy rainbow avatar id to avatar 3', () {
    final profile = PlayerProfile.fromJson({
      'id': 'child_1',
      'childName': 'Ada',
      'unicornName': 'Iris',
      'language': 'es-ES',
      'unicornAvatarId': 'rainbow',
    });

    expect(profile.unicornAvatar, UnicornAvatar.avatar03);
  });
}
