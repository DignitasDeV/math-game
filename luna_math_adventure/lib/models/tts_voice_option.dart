import 'app_language.dart';

class TtsVoiceOption {
  const TtsVoiceOption({
    required this.id,
    required this.piperVoiceId,
    required this.languageCode,
    required this.label,
    required this.sampleText,
    required this.toneLabel,
    this.useSystemVoice = false,
    this.speakerId,
    this.isDefault = false,
  });

  final String id;
  final String piperVoiceId;
  final String languageCode;
  final String label;
  final String sampleText;
  final String toneLabel;
  final bool useSystemVoice;
  final int? speakerId;
  final bool isDefault;
}

class TtsVoiceOptions {
  const TtsVoiceOptions._();

  static const defaultSpanishVoiceId = 'es_ES-sharvard-medium';
  static const defaultCatalanVoiceId = 'ca_ES-upc_ona-medium';
  static const systemSpanishVoiceId = 'system-es-ES';
  static const systemCatalanVoiceId = 'system-ca-ES';

  static const all = <TtsVoiceOption>[
    TtsVoiceOption(
      id: systemSpanishVoiceId,
      piperVoiceId: '',
      languageCode: 'es-ES',
      label: 'Sistema',
      sampleText: 'Hola, que tal estas?',
      toneLabel: 'Voz del dispositivo',
      useSystemVoice: true,
    ),
    TtsVoiceOption(
      id: defaultSpanishVoiceId,
      piperVoiceId: defaultSpanishVoiceId,
      languageCode: 'es-ES',
      label: 'Sharvard',
      sampleText: 'Hola, que tal estas?',
      toneLabel: 'Voz femenina',
      speakerId: 1,
      isDefault: true,
    ),
    TtsVoiceOption(
      id: 'es_ES-davefx-medium',
      piperVoiceId: 'es_ES-davefx-medium',
      languageCode: 'es-ES',
      label: 'DaveFX',
      sampleText: 'Hola, que tal estas?',
      toneLabel: 'Voz masculina',
    ),
    TtsVoiceOption(
      id: systemCatalanVoiceId,
      piperVoiceId: '',
      languageCode: 'ca-ES',
      label: 'Sistema',
      sampleText: 'Hola, com estas?',
      toneLabel: 'Voz del dispositivo',
      useSystemVoice: true,
    ),
    TtsVoiceOption(
      id: defaultCatalanVoiceId,
      piperVoiceId: defaultCatalanVoiceId,
      languageCode: 'ca-ES',
      label: 'UPC Ona',
      sampleText: 'Hola, com estas?',
      toneLabel: 'Voz femenina',
      isDefault: true,
    ),
    TtsVoiceOption(
      id: 'ca_ES-upc_pau-x_low',
      piperVoiceId: 'ca_ES-upc_pau-x_low',
      languageCode: 'ca-ES',
      label: 'UPC Pau',
      sampleText: 'Hola, com estas?',
      toneLabel: 'Voz masculina',
    ),
  ];

  static List<TtsVoiceOption> forLanguage(AppLanguage language) {
    return forLanguageCode(language.ttsCode);
  }

  static List<TtsVoiceOption> forLanguageCode(String languageCode) {
    return [
      for (final option in all)
        if (option.languageCode == languageCode) option,
    ];
  }

  static TtsVoiceOption? byId(String voiceId) {
    for (final option in all) {
      if (option.id == voiceId) {
        return option;
      }
    }

    return null;
  }

  static String defaultVoiceIdFor(AppLanguage language) {
    return language == AppLanguage.catalan
        ? defaultCatalanVoiceId
        : defaultSpanishVoiceId;
  }

  static String normalizedVoiceId({
    required AppLanguage language,
    required String? voiceId,
  }) {
    final option = voiceId == null || voiceId.isEmpty ? null : byId(voiceId);
    if (option?.languageCode == language.ttsCode) {
      return option!.id;
    }

    return defaultVoiceIdFor(language);
  }

  static bool isSystemVoice(String? voiceId) {
    if (voiceId == null || voiceId.isEmpty) {
      return false;
    }

    return byId(voiceId)?.useSystemVoice ?? false;
  }
}
