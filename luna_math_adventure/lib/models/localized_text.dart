class LocalizedText {
  const LocalizedText({
    required this.es,
    required this.ca,
  });

  final String es;
  final String ca;

  String get(String languageCode) {
    return languageCode == 'ca-ES' ? ca : es;
  }

  static LocalizedText fromJson(Map<String, Object?> json) {
    return LocalizedText(
      es: json['es'] as String? ?? json['es-ES'] as String? ?? '',
      ca: json['ca'] as String? ?? json['ca-ES'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'es': es,
      'ca': ca,
    };
  }
}
