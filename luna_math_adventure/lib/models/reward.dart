import 'localized_text.dart';

class Reward {
  const Reward({
    required this.id,
    required this.type,
    required this.name,
    required this.assetPath,
  });

  final String id;
  final String type;
  final LocalizedText name;
  final String assetPath;

  static Reward fromJson(Map<String, Object?> json) {
    return Reward(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'sticker',
      name: LocalizedText.fromJson(
        Map<String, Object?>.from(json['name'] as Map? ?? const {}),
      ),
      assetPath: json['assetPath'] as String? ?? '',
    );
  }
}
