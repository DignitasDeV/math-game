import 'localized_text.dart';

class VisualItem {
  const VisualItem({
    required this.id,
    required this.assetPath,
    required this.singularLabel,
    required this.pluralLabel,
    required this.pluralWithArticleLabel,
    required this.oneWithArticleLabel,
    required this.gender,
  });

  final String id;
  final String assetPath;
  final LocalizedText singularLabel;
  final LocalizedText pluralLabel;
  final LocalizedText pluralWithArticleLabel;
  final LocalizedText oneWithArticleLabel;
  final LocalizedText gender;

  static VisualItem fromJson(Map<String, Object?> json) {
    final labels =
        Map<String, Object?>.from(json['labels'] as Map? ?? const {});
    final es = Map<String, Object?>.from(labels['es'] as Map? ?? const {});
    final ca = Map<String, Object?>.from(labels['ca'] as Map? ?? const {});

    return VisualItem(
      id: json['id'] as String? ?? '',
      assetPath: json['assetPath'] as String? ?? '',
      singularLabel: LocalizedText(
        es: es['singular'] as String? ?? '',
        ca: ca['singular'] as String? ?? '',
      ),
      pluralLabel: LocalizedText(
        es: es['plural'] as String? ?? '',
        ca: ca['plural'] as String? ?? '',
      ),
      pluralWithArticleLabel: LocalizedText(
        es: es['pluralWithArticle'] as String? ?? es['plural'] as String? ?? '',
        ca: ca['pluralWithArticle'] as String? ?? ca['plural'] as String? ?? '',
      ),
      oneWithArticleLabel: LocalizedText(
        es: es['oneWithArticle'] as String? ?? es['singular'] as String? ?? '',
        ca: ca['oneWithArticle'] as String? ?? ca['singular'] as String? ?? '',
      ),
      gender: LocalizedText(
        es: es['gender'] as String? ?? 'masculine',
        ca: ca['gender'] as String? ?? 'masculine',
      ),
    );
  }
}
