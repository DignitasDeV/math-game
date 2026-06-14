import 'app_language.dart';
import 'unicorn_variant.dart';

class PlayerProfile {
  const PlayerProfile({
    required this.childName,
    required this.unicornName,
    required this.language,
    required this.unicornVariant,
  });

  final String childName;
  final String unicornName;
  final AppLanguage language;
  final UnicornVariant unicornVariant;
}
