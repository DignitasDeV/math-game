enum AppLanguage {
  spanish('es-ES', 'Espanol'),
  catalan('ca-ES', 'Catala');

  const AppLanguage(this.ttsCode, this.label);

  final String ttsCode;
  final String label;
}
