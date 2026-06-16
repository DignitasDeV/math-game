class PlayerProgress {
  const PlayerProgress({
    required this.profileId,
    required this.unlockedLevelIds,
    required this.completedLevelIds,
    required this.starsByLevel,
    required this.lastLevelId,
    required this.earnedRewardIds,
  });

  final String profileId;
  final List<String> unlockedLevelIds;
  final List<String> completedLevelIds;
  final Map<String, int> starsByLevel;
  final String lastLevelId;
  final List<String> earnedRewardIds;

  PlayerProgress copyWith({
    List<String>? unlockedLevelIds,
    List<String>? completedLevelIds,
    Map<String, int>? starsByLevel,
    String? lastLevelId,
    List<String>? earnedRewardIds,
  }) {
    return PlayerProgress(
      profileId: profileId,
      unlockedLevelIds: unlockedLevelIds ?? this.unlockedLevelIds,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      starsByLevel: starsByLevel ?? this.starsByLevel,
      lastLevelId: lastLevelId ?? this.lastLevelId,
      earnedRewardIds: earnedRewardIds ?? this.earnedRewardIds,
    );
  }

  static PlayerProgress initial(String profileId) {
    return PlayerProgress(
      profileId: profileId,
      unlockedLevelIds: const ['heart_forest_01'],
      completedLevelIds: const [],
      starsByLevel: const {},
      lastLevelId: 'heart_forest_01',
      earnedRewardIds: const [],
    );
  }

  Map<String, Object?> toJson() {
    return {
      'profileId': profileId,
      'unlockedLevelIds': unlockedLevelIds,
      'completedLevelIds': completedLevelIds,
      'starsByLevel': starsByLevel,
      'lastLevelId': lastLevelId,
      'earnedRewardIds': earnedRewardIds,
    };
  }

  static PlayerProgress fromJson(Map<String, Object?> json) {
    final profileId = json['profileId'] as String? ?? '';
    return PlayerProgress(
      profileId: profileId,
      unlockedLevelIds: _normalizeUnlockedLevels(
        _readStringList(json['unlockedLevelIds']),
      ),
      completedLevelIds: _normalizeLevelIds(
        _readStringList(json['completedLevelIds']),
      ),
      starsByLevel: _readStarsByLevel(json['starsByLevel']),
      lastLevelId: _normalizeLevelId(
        json['lastLevelId'] as String? ?? 'heart_forest_01',
      ),
      earnedRewardIds: _readStringList(json['earnedRewardIds']),
    );
  }
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}

Map<String, int> _readStarsByLevel(Object? value) {
  if (value is! Map) {
    return const {};
  }

  return Map.fromEntries(
    value.entries
        .map(
          (entry) => MapEntry(
            _normalizeLevelId(entry.key.toString()),
            entry.value is int
                ? entry.value as int
                : int.tryParse(entry.value.toString()) ?? 0,
          ),
        )
        .where((entry) => entry.key.isNotEmpty),
  );
}

List<String> _normalizeUnlockedLevels(List<String> levelIds) {
  if (levelIds.isEmpty) {
    return const ['heart_forest_01'];
  }

  final normalized = _normalizeLevelIds(levelIds);
  if (normalized.isEmpty) {
    return const ['heart_forest_01'];
  }

  return normalized;
}

List<String> _normalizeLevelIds(List<String> levelIds) {
  return levelIds
      .map(_normalizeLevelId)
      .where((levelId) => levelId.isNotEmpty)
      .toSet()
      .toList(growable: false);
}

String _normalizeLevelId(String levelId) {
  return switch (levelId) {
    'meadow_1' => 'heart_forest_01',
    'meadow_2' => 'heart_forest_03',
    _ => levelId,
  };
}
