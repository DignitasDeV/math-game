import 'localized_text.dart';

class World {
  const World({
    required this.id,
    required this.name,
    required this.levelIds,
  });

  final String id;
  final LocalizedText name;
  final List<String> levelIds;
}
