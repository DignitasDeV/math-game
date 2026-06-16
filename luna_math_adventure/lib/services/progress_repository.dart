import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';
import 'profile_controller.dart';

abstract class ProgressRepository {
  Future<PlayerProgress> loadProgress(String profileId);
  Future<void> saveProgress(PlayerProgress progress);
}

class SharedPreferencesProgressRepository implements ProgressRepository {
  static const _progressPrefix = 'player_progress_';

  @override
  Future<PlayerProgress> loadProgress(String profileId) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString('$_progressPrefix$profileId');
    if (value == null) {
      return PlayerProgress.initial(profileId);
    }

    final json = Map<String, Object?>.from(jsonDecode(value) as Map);
    final progress = PlayerProgress.fromJson(json);
    return progress.profileId.isEmpty
        ? PlayerProgress.initial(profileId)
        : progress;
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_progressPrefix${progress.profileId}',
      jsonEncode(progress.toJson()),
    );
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return SharedPreferencesProgressRepository();
});

final activeProgressProvider = FutureProvider<PlayerProgress?>((ref) async {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) {
    return null;
  }

  return ref
      .watch(progressRepositoryProvider)
      .loadProgress(activeProfile.id);
});
