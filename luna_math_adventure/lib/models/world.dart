import 'localized_text.dart';

class World {
  const World({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundAssetPath,
    required this.levelIds,
    required this.sortOrder,
    required this.isImplemented,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final String backgroundAssetPath;
  final List<String> levelIds;
  final int sortOrder;
  final bool isImplemented;

  static World fromJson(Map<String, Object?> json) {
    return World(
      id: json['id'] as String? ?? '',
      name: LocalizedText.fromJson(
        Map<String, Object?>.from(json['name'] as Map? ?? const {}),
      ),
      description: LocalizedText.fromJson(
        Map<String, Object?>.from(json['description'] as Map? ?? const {}),
      ),
      backgroundAssetPath: json['backgroundAssetPath'] as String? ?? '',
      levelIds: _readStringList(json['levelIds']),
      sortOrder: json['sortOrder'] as int? ?? 0,
      isImplemented: json['isImplemented'] as bool? ?? false,
    );
  }
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}
