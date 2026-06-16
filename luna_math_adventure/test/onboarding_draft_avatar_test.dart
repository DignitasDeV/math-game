import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/app_language.dart';
import 'package:luna_math_adventure/models/tts_voice_option.dart';
import 'package:luna_math_adventure/models/unicorn_avatar.dart';
import 'package:luna_math_adventure/services/profile_repository.dart';

void main() {
  test('defaults to avatar 1 without a suggested name', () {
    final controller = OnboardingDraftController();

    expect(controller.state.unicornAvatar, UnicornAvatar.avatar01);
    expect(controller.state.unicornName, isEmpty);
    expect(controller.state.ttsVoiceId, TtsVoiceOptions.defaultSpanishVoiceId);
  });

  test('selecting avatar keeps the name empty', () {
    final controller = OnboardingDraftController();

    controller.setUnicornAvatar(UnicornAvatar.avatar04);

    expect(controller.state.unicornAvatar, UnicornAvatar.avatar04);
    expect(controller.state.unicornName, isEmpty);
  });

  test('selecting catalan updates the default voice', () {
    final controller = OnboardingDraftController();

    controller.setLanguage(AppLanguage.catalan);

    expect(controller.state.ttsVoiceId, TtsVoiceOptions.defaultCatalanVoiceId);
  });
}
