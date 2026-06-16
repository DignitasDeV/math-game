import 'localized_text.dart';

class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.category,
    required this.sortOrder,
    required this.title,
    required this.summary,
    required this.body,
    required this.spokenText,
    required this.examples,
    required this.exampleType,
  });

  final String id;
  final LocalizedText category;
  final int sortOrder;
  final LocalizedText title;
  final LocalizedText summary;
  final LocalizedText body;
  final LocalizedText spokenText;
  final List<LocalizedText> examples;
  final String exampleType;

  static HelpTopic fromJson(Map<String, Object?> json) {
    return HelpTopic(
      id: json['id'] as String? ?? '',
      category: LocalizedText.fromJson(
        Map<String, Object?>.from(json['category'] as Map? ?? const {}),
      ),
      sortOrder: json['sortOrder'] as int? ?? 0,
      title: LocalizedText.fromJson(
        Map<String, Object?>.from(json['title'] as Map? ?? const {}),
      ),
      summary: LocalizedText.fromJson(
        Map<String, Object?>.from(json['summary'] as Map? ?? const {}),
      ),
      body: LocalizedText.fromJson(
        Map<String, Object?>.from(json['body'] as Map? ?? const {}),
      ),
      spokenText: LocalizedText.fromJson(
        Map<String, Object?>.from(json['spokenText'] as Map? ?? const {}),
      ),
      examples: _localizedListFromJson(json['examples']),
      exampleType: json['exampleType'] as String? ?? 'counting',
    );
  }

  static List<LocalizedText> _localizedListFromJson(Object? value) {
    final items = value is List ? value : const [];
    return [
      for (final item in items)
        LocalizedText.fromJson(
          Map<String, Object?>.from(item as Map? ?? const {}),
        ),
    ];
  }
}
