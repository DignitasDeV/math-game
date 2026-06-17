class UiCopy {
  const UiCopy._();

  static bool isCatalan(String languageCode) => languageCode == 'ca-ES';

  static String text(
    String languageCode, {
    required String es,
    required String ca,
  }) {
    return isCatalan(languageCode) ? ca : es;
  }

  static String back(String languageCode) {
    return text(languageCode, es: 'Volver', ca: 'Tornar');
  }

  static String home(String languageCode) {
    return text(languageCode, es: 'Inicio', ca: 'Inici');
  }

  static String map(String languageCode) {
    return text(languageCode, es: 'Mapa', ca: 'Mapa');
  }

  static String help(String languageCode) {
    return text(languageCode, es: 'Ayuda', ca: 'Ajuda');
  }

  static String settings(String languageCode) {
    return text(languageCode, es: 'Ajustes', ca: 'Ajustos');
  }

  static String rewards(String languageCode) {
    return text(languageCode, es: 'Recompensas', ca: 'Recompenses');
  }

  static String retry(String languageCode) {
    return text(languageCode, es: 'Reintentar', ca: 'Torna-ho a provar');
  }

  static String next(String languageCode) {
    return text(languageCode, es: 'Siguiente', ca: 'Següent');
  }

  static String start(String languageCode) {
    return text(languageCode, es: 'Empezar', ca: 'Començar');
  }

  static String ok(String languageCode) {
    return text(languageCode, es: 'Vale', ca: "D'acord");
  }
}
