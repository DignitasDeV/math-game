import 'localized_text.dart';

class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.worldId,
    required this.title,
    required this.subtitle,
    required this.exerciseTypes,
    required this.minNumber,
    required this.maxNumber,
    required this.maxResult,
    required this.allowNegativeResults,
    required this.allowCarry,
    required this.visualSupport,
    required this.questionsToComplete,
    required this.starsToUnlockNext,
    required this.rewardId,
    required this.visualItemIds,
    required this.sortOrder,
  });

  final String id;
  final String worldId;
  final LocalizedText title;
  final LocalizedText subtitle;
  final List<String> exerciseTypes;
  final int minNumber;
  final int maxNumber;
  final int? maxResult;
  final bool allowNegativeResults;
  final bool allowCarry;
  final bool visualSupport;
  final int questionsToComplete;
  final int starsToUnlockNext;
  final String? rewardId;
  final List<String> visualItemIds;
  final int sortOrder;

  static LevelConfig fromJson(Map<String, Object?> json) {
    return LevelConfig(
      id: json['id'] as String? ?? '',
      worldId: json['worldId'] as String? ?? '',
      title: LocalizedText.fromJson(
        Map<String, Object?>.from(json['title'] as Map? ?? const {}),
      ),
      subtitle: LocalizedText.fromJson(
        Map<String, Object?>.from(json['subtitle'] as Map? ?? const {}),
      ),
      exerciseTypes: _readStringList(json['exerciseTypes']),
      minNumber: json['minNumber'] as int? ?? 0,
      maxNumber: json['maxNumber'] as int? ?? 0,
      maxResult: json['maxResult'] as int?,
      allowNegativeResults: json['allowNegativeResults'] as bool? ?? false,
      allowCarry: json['allowCarry'] as bool? ?? false,
      visualSupport: json['visualSupport'] as bool? ?? true,
      questionsToComplete: json['questionsToComplete'] as int? ?? 5,
      starsToUnlockNext: json['starsToUnlockNext'] as int? ?? 1,
      rewardId: json['rewardId'] as String?,
      visualItemIds: _readStringList(json['visualItemIds']),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}
