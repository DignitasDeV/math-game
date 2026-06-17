enum UnicornAvatarStage {
  stage01('stage_01'),
  stage02('stage_02'),
  stage03('stage_03'),
  stage04('stage_04');

  const UnicornAvatarStage(this.id);

  final String id;

  String get assetPrefix => id;

  static UnicornAvatarStage fromId(String? id) {
    for (final stage in UnicornAvatarStage.values) {
      if (stage.id == id || stage.name == id) {
        return stage;
      }
    }

    return UnicornAvatarStage.stage01;
  }
}
