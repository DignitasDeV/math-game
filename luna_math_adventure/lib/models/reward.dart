import 'localized_text.dart';

class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.assetPath,
  });

  final String id;
  final LocalizedText name;
  final String assetPath;
}
