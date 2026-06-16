import 'player_profile.dart';

class FamilyProfiles {
  const FamilyProfiles({
    required this.profiles,
    required this.activeProfileId,
  });

  final List<PlayerProfile> profiles;
  final String? activeProfileId;

  PlayerProfile? get activeProfile {
    if (activeProfileId == null) {
      return null;
    }

    for (final profile in profiles) {
      if (profile.id == activeProfileId) {
        return profile;
      }
    }

    return null;
  }

  bool get hasProfiles => profiles.isNotEmpty;

  FamilyProfiles copyWith({
    List<PlayerProfile>? profiles,
    String? activeProfileId,
  }) {
    return FamilyProfiles(
      profiles: profiles ?? this.profiles,
      activeProfileId: activeProfileId ?? this.activeProfileId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'profiles': profiles.map((profile) => profile.toJson()).toList(),
      'activeProfileId': activeProfileId,
    };
  }

  static FamilyProfiles fromJson(Map<String, Object?> json) {
    final rawProfiles = json['profiles'] as List? ?? const [];
    final profiles = rawProfiles
        .map(
          (value) => PlayerProfile.fromJson(
            Map<String, Object?>.from(value as Map),
          ),
        )
        .where((profile) => profile.id.isNotEmpty)
        .toList();

    final activeProfileId = json['activeProfileId'] as String?;
    final fallbackProfileId = profiles.isEmpty ? null : profiles.first.id;
    return FamilyProfiles(
      profiles: profiles,
      activeProfileId: profiles.any((profile) => profile.id == activeProfileId)
          ? activeProfileId
          : fallbackProfileId,
    );
  }

  static const empty = FamilyProfiles(
    profiles: [],
    activeProfileId: null,
  );
}
