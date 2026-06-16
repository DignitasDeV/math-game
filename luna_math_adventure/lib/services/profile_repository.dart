import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/dev_options.dart';
import '../models/app_language.dart';
import '../models/family_profiles.dart';
import '../models/player_profile.dart';
import '../models/tts_voice_option.dart';
import '../models/unicorn_avatar.dart';

abstract class ProfileRepository {
  Future<FamilyProfiles> loadFamily();
  Future<void> saveFamily(FamilyProfiles family);
  Future<void> clearFamily();
}

class SharedPreferencesProfileRepository implements ProfileRepository {
  static const _familyProfilesKey = 'family_profiles';
  static const _legacyProfileKey = 'player_profile';

  @override
  Future<FamilyProfiles> loadFamily() async {
    final preferences = await SharedPreferences.getInstance();

    if (AppDevOptions.resetOnFreshStart) {
      await preferences.clear();
    }

    final value = preferences.getString(_familyProfilesKey);
    if (value != null) {
      final json = Map<String, Object?>.from(jsonDecode(value) as Map);
      final family = FamilyProfiles.fromJson(json);
      if (AppDevOptions.skipOnboarding && !family.hasProfiles) {
        return _devFamily();
      }

      return family;
    }

    final legacyValue = preferences.getString(_legacyProfileKey);
    if (legacyValue == null) {
      if (AppDevOptions.skipOnboarding) {
        return _devFamily();
      }

      return FamilyProfiles.empty;
    }

    final legacyJson = Map<String, Object?>.from(jsonDecode(legacyValue) as Map);
    final legacyProfile = PlayerProfile.fromJson(legacyJson).copyWith(
      id: legacyJson['id'] as String? ?? _createProfileId(),
    );
    final migratedFamily = FamilyProfiles(
      profiles: [legacyProfile],
      activeProfileId: legacyProfile.id,
    );
    await saveFamily(migratedFamily);
    await preferences.remove(_legacyProfileKey);
    return migratedFamily;
  }

  @override
  Future<void> saveFamily(FamilyProfiles family) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_familyProfilesKey, jsonEncode(family.toJson()));
  }

  @override
  Future<void> clearFamily() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_familyProfilesKey);
  }
}

FamilyProfiles _devFamily() {
  return const FamilyProfiles(
    profiles: [
      PlayerProfile(
        id: AppDevOptions.devProfileId,
        childName: 'Pruebas',
        unicornName: 'Luna',
        language: AppLanguage.spanish,
        unicornAvatar: UnicornAvatar.avatar01,
        ttsVoiceId: TtsVoiceOptions.defaultSpanishVoiceId,
      ),
    ],
    activeProfileId: AppDevOptions.devProfileId,
  );
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SharedPreferencesProfileRepository();
});

final onboardingDraftProvider =
    StateNotifierProvider<OnboardingDraftController, PlayerProfile>((ref) {
  return OnboardingDraftController();
});

class OnboardingDraftController extends StateNotifier<PlayerProfile> {
  OnboardingDraftController()
      : super(
          const PlayerProfile(
            id: '',
            childName: '',
            unicornName: '',
            language: AppLanguage.spanish,
            unicornAvatar: UnicornAvatar.avatar01,
            ttsVoiceId: TtsVoiceOptions.defaultSpanishVoiceId,
          ),
        );

  void setLanguage(AppLanguage language) {
    state = state.copyWith(
      language: language,
      ttsVoiceId: TtsVoiceOptions.defaultVoiceIdFor(language),
    );
  }

  void setChildName(String childName) {
    state = state.copyWith(childName: childName.trim());
  }

  void setUnicornAvatar(UnicornAvatar avatar) {
    state = state.copyWith(
      unicornAvatar: avatar,
    );
  }

  void setUnicornName(String unicornName) {
    state = state.copyWith(unicornName: unicornName.trim());
  }

  void reset() {
    state = const PlayerProfile(
      id: '',
      childName: '',
      unicornName: '',
      language: AppLanguage.spanish,
      unicornAvatar: UnicornAvatar.avatar01,
      ttsVoiceId: TtsVoiceOptions.defaultSpanishVoiceId,
    );
  }

  PlayerProfile buildProfile() {
    return state.copyWith(id: state.id.isEmpty ? _createProfileId() : state.id);
  }
}

String _createProfileId() {
  return 'child_${DateTime.now().microsecondsSinceEpoch}';
}
