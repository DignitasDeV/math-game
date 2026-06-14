import '../models/app_language.dart';

abstract class LocalizationRepository {
  Future<Map<String, String>> loadVisibleTexts(AppLanguage language);
  Future<Map<String, String>> loadSpokenTexts(AppLanguage language);
}

class AssetLocalizationRepository implements LocalizationRepository {
  @override
  Future<Map<String, String>> loadVisibleTexts(AppLanguage language) async => {};

  @override
  Future<Map<String, String>> loadSpokenTexts(AppLanguage language) async => {};
}
