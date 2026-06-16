enum AppLanguage {
  spanish('es-ES', 'Español'),
  catalan('ca-ES', 'Català');

  const AppLanguage(this.ttsCode, this.label);

  final String ttsCode;
  final String label;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (language) => language.ttsCode == code,
      orElse: () => AppLanguage.spanish,
    );
  }
}
