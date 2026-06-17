import '../models/visual_item.dart';

class LocalizedGrammar {
  const LocalizedGrammar._();

  static bool isCatalan(String languageCode) => languageCode == 'ca-ES';

  static bool isFeminine(VisualItem visualItem, String languageCode) {
    return visualItem.gender.get(languageCode) == 'feminine';
  }

  static String numberWord(
    int value,
    String languageCode, {
    bool feminine = false,
  }) {
    if (isCatalan(languageCode)) {
      if (feminine) {
        return _caFeminineNumbers[value] ?? _caNumbers[value] ?? '$value';
      }

      return _caNumbers[value] ?? '$value';
    }

    if (feminine) {
      return _esFeminineNumbers[value] ?? _esNumbers[value] ?? '$value';
    }

    return _esNumbers[value] ?? '$value';
  }

  static String itemLabel(
    int count,
    VisualItem visualItem,
    String languageCode,
  ) {
    if (count == 1) {
      return visualItem.singularLabel.get(languageCode);
    }

    return visualItem.pluralLabel.get(languageCode);
  }

  static String itemCountPhrase(
    int count,
    VisualItem visualItem,
    String languageCode,
  ) {
    if (count == 1) {
      return visualItem.oneWithArticleLabel.get(languageCode);
    }

    final feminine = isFeminine(visualItem, languageCode);
    return '${numberWord(count, languageCode, feminine: feminine)} '
        '${visualItem.pluralLabel.get(languageCode)}';
  }

  static String tensLabel(int count, String languageCode) {
    if (isCatalan(languageCode)) {
      return count == 1 ? 'desena' : 'desenes';
    }

    return count == 1 ? 'decena' : 'decenas';
  }

  static String countQuestion(VisualItem visualItem, String languageCode) {
    final feminine = isFeminine(visualItem, languageCode);
    if (isCatalan(languageCode)) {
      return feminine ? "Quantes n'hi ha?" : "Quants n'hi ha?";
    }

    return feminine ? '¿Cuántas hay?' : '¿Cuántos hay?';
  }

  static String totalQuestion(VisualItem visualItem, String languageCode) {
    final feminine = isFeminine(visualItem, languageCode);
    if (isCatalan(languageCode)) {
      return feminine ? 'Quantes en té?' : 'Quants en té?';
    }

    return feminine ? '¿Cuántas tiene?' : '¿Cuántos tiene?';
  }

  static String remainingQuestion(VisualItem visualItem, String languageCode) {
    final feminine = isFeminine(visualItem, languageCode);
    if (isCatalan(languageCode)) {
      return feminine ? 'Quantes en queden?' : 'Quants en queden?';
    }

    return feminine ? '¿Cuántas quedan?' : '¿Cuántos quedan?';
  }

  static String remainingItemsPronoun(
    VisualItem visualItem,
    String languageCode,
  ) {
    final feminine = isFeminine(visualItem, languageCode);
    if (isCatalan(languageCode)) {
      return feminine ? 'les que queden' : 'els que queden';
    }

    return feminine ? 'las que quedan' : 'los que quedan';
  }

  static String stepCountPhrase(int count, String languageCode) {
    if (isCatalan(languageCode)) {
      final label = count == 1 ? 'pas' : 'passos';
      return '${numberWord(count, languageCode)} $label';
    }

    return count == 1 ? '1 paso' : '$count pasos';
  }

  static String missingPhrase(int count, String languageCode) {
    if (isCatalan(languageCode)) {
      return count == 1 ? 'falta 1' : 'falten $count';
    }

    return count == 1 ? 'falta 1' : 'faltan $count';
  }
}

const _esNumbers = {
  0: 'cero',
  1: 'uno',
  2: 'dos',
  3: 'tres',
  4: 'cuatro',
  5: 'cinco',
  6: 'seis',
  7: 'siete',
  8: 'ocho',
  9: 'nueve',
  10: 'diez',
  11: 'once',
  12: 'doce',
  13: 'trece',
  14: 'catorce',
  15: 'quince',
  16: 'dieciséis',
  17: 'diecisiete',
  18: 'dieciocho',
  19: 'diecinueve',
  20: 'veinte',
  21: 'veintiuno',
  22: 'veintidós',
  23: 'veintitrés',
  24: 'veinticuatro',
  25: 'veinticinco',
  26: 'veintiséis',
  27: 'veintisiete',
  28: 'veintiocho',
  29: 'veintinueve',
  30: 'treinta',
  31: 'treinta y uno',
  32: 'treinta y dos',
  33: 'treinta y tres',
  34: 'treinta y cuatro',
  35: 'treinta y cinco',
  36: 'treinta y seis',
  37: 'treinta y siete',
  38: 'treinta y ocho',
  39: 'treinta y nueve',
  40: 'cuarenta',
};

const _esFeminineNumbers = {
  1: 'una',
};

const _caNumbers = {
  0: 'zero',
  1: 'un',
  2: 'dos',
  3: 'tres',
  4: 'quatre',
  5: 'cinc',
  6: 'sis',
  7: 'set',
  8: 'vuit',
  9: 'nou',
  10: 'deu',
  11: 'onze',
  12: 'dotze',
  13: 'tretze',
  14: 'catorze',
  15: 'quinze',
  16: 'setze',
  17: 'disset',
  18: 'divuit',
  19: 'dinou',
  20: 'vint',
  21: 'vint-i-un',
  22: 'vint-i-dos',
  23: 'vint-i-tres',
  24: 'vint-i-quatre',
  25: 'vint-i-cinc',
  26: 'vint-i-sis',
  27: 'vint-i-set',
  28: 'vint-i-vuit',
  29: 'vint-i-nou',
  30: 'trenta',
  31: 'trenta-un',
  32: 'trenta-dos',
  33: 'trenta-tres',
  34: 'trenta-quatre',
  35: 'trenta-cinc',
  36: 'trenta-sis',
  37: 'trenta-set',
  38: 'trenta-vuit',
  39: 'trenta-nou',
  40: 'quaranta',
};

const _caFeminineNumbers = {
  1: 'una',
  2: 'dues',
  21: 'vint-i-una',
  22: 'vint-i-dues',
  31: 'trenta-una',
  32: 'trenta-dues',
};
