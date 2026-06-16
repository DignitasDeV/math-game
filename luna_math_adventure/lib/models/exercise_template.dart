import 'localized_text.dart';

class ExerciseTemplate {
  const ExerciseTemplate({
    required this.id,
    required this.type,
    required this.visiblePattern,
    required this.spokenPattern,
    required this.hintPattern,
    required this.spokenHintPattern,
  });

  final String id;
  final String type;
  final LocalizedText visiblePattern;
  final LocalizedText spokenPattern;
  final LocalizedText hintPattern;
  final LocalizedText spokenHintPattern;

  static ExerciseTemplate fromJson(Map<String, Object?> json) {
    final texts = Map<String, Object?>.from(json['texts'] as Map? ?? const {});
    final es = Map<String, Object?>.from(texts['es'] as Map? ?? const {});
    final ca = Map<String, Object?>.from(texts['ca'] as Map? ?? const {});

    return ExerciseTemplate(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      visiblePattern: LocalizedText(
        es: es['visible'] as String? ?? '',
        ca: ca['visible'] as String? ?? '',
      ),
      spokenPattern: LocalizedText(
        es: es['spoken'] as String? ?? '',
        ca: ca['spoken'] as String? ?? '',
      ),
      hintPattern: LocalizedText(
        es: es['hint'] as String? ?? '',
        ca: ca['hint'] as String? ?? '',
      ),
      spokenHintPattern: LocalizedText(
        es: es['spokenHint'] as String? ?? '',
        ca: ca['spokenHint'] as String? ?? '',
      ),
    );
  }
}
