import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/dev_options.dart';
import '../models/family_profiles.dart';
import '../models/player_profile.dart';
import '../models/tts_voice_option.dart';
import 'profile_repository.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, FamilyProfiles>(
  ProfileController.new,
);

final activeProfileProvider = Provider<PlayerProfile?>((ref) {
  return ref.watch(profileControllerProvider).valueOrNull?.activeProfile;
});

const maxFamilyProfiles = 8;

class ProfileController extends AsyncNotifier<FamilyProfiles> {
  @override
  Future<FamilyProfiles> build() {
    return ref.read(profileRepositoryProvider).loadFamily();
  }

  Future<bool> addProfile(PlayerProfile profile) async {
    final currentFamily = state.valueOrNull ?? await build();
    final isExistingProfile = currentFamily.profiles.any(
      (item) => item.id == profile.id,
    );
    if (!isExistingProfile &&
        currentFamily.profiles.length >= maxFamilyProfiles) {
      return false;
    }

    final profiles = [
      ...currentFamily.profiles.where((item) => item.id != profile.id),
      profile,
    ];
    final nextFamily = FamilyProfiles(
      profiles: profiles,
      activeProfileId: profile.id,
    );
    await _saveFamily(nextFamily);
    return true;
  }

  Future<void> selectProfile(String profileId) async {
    final currentFamily = state.valueOrNull ?? await build();
    if (!currentFamily.profiles.any((profile) => profile.id == profileId)) {
      return;
    }

    await _saveFamily(
      FamilyProfiles(
        profiles: currentFamily.profiles,
        activeProfileId: profileId,
      ),
    );
  }

  Future<void> updateProfile(PlayerProfile updatedProfile) async {
    final currentFamily = state.valueOrNull ?? await build();
    if (!currentFamily.profiles.any(
      (profile) => profile.id == updatedProfile.id,
    )) {
      return;
    }

    final profiles = [
      for (final profile in currentFamily.profiles)
        if (profile.id == updatedProfile.id) updatedProfile else profile,
    ];

    await _saveFamily(
      FamilyProfiles(
        profiles: profiles,
        activeProfileId: currentFamily.activeProfileId,
      ),
    );
  }

  Future<void> deleteProfile(String profileId) async {
    final currentFamily = state.valueOrNull ?? await build();
    if (!currentFamily.profiles.any((profile) => profile.id == profileId)) {
      return;
    }

    final profiles = [
      for (final profile in currentFamily.profiles)
        if (profile.id != profileId) profile,
    ];
    final activeProfileId = currentFamily.activeProfileId == profileId
        ? profiles.isEmpty
            ? null
            : profiles.first.id
        : currentFamily.activeProfileId;

    await _saveFamily(
      FamilyProfiles(
        profiles: profiles,
        activeProfileId: activeProfileId,
      ),
    );
  }

  Future<void> updateActiveProfileVoice(String voiceId) async {
    final currentFamily = state.valueOrNull ?? await build();
    final activeProfile = currentFamily.activeProfile;
    final voice = TtsVoiceOptions.byId(voiceId);
    if (activeProfile == null ||
        voice == null ||
        voice.languageCode != activeProfile.language.ttsCode) {
      return;
    }

    final profiles = [
      for (final profile in currentFamily.profiles)
        if (profile.id == activeProfile.id)
          profile.copyWith(ttsVoiceId: voice.id)
        else
          profile,
    ];

    await _saveFamily(
      FamilyProfiles(
        profiles: profiles,
        activeProfileId: currentFamily.activeProfileId,
      ),
    );
  }

  Future<void> updateActiveProfileSoundEffects(bool isEnabled) async {
    final currentFamily = state.valueOrNull ?? await build();
    final activeProfile = currentFamily.activeProfile;
    if (activeProfile == null) {
      return;
    }

    final profiles = [
      for (final profile in currentFamily.profiles)
        if (profile.id == activeProfile.id)
          profile.copyWith(soundEffectsEnabled: isEnabled)
        else
          profile,
    ];

    await _saveFamily(
      FamilyProfiles(
        profiles: profiles,
        activeProfileId: currentFamily.activeProfileId,
      ),
    );
  }

  Future<void> clearFamily() async {
    state = const AsyncLoading();
    await ref.read(profileRepositoryProvider).clearFamily();
    state = AsyncData(
      AppDevOptions.skipOnboarding ? await build() : FamilyProfiles.empty,
    );
  }

  Future<void> _saveFamily(FamilyProfiles family) async {
    state = const AsyncLoading();
    await ref.read(profileRepositoryProvider).saveFamily(family);
    state = AsyncData(family);
  }
}
