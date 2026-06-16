import '../models/unicorn_avatar.dart';

enum UnicornAvatarEmotion {
  idle,
  happy,
  thinking,
  encouraging,
  celebrating,
}

enum UnicornAvatarStage {
  stage01('stage_01');

  const UnicornAvatarStage(this.assetPrefix);

  final String assetPrefix;
}

const unicornAvatarFallback = UnicornAvatar.avatar01;

String unicornAvatarAssetPath({
  required UnicornAvatar avatar,
  required UnicornAvatarEmotion emotion,
  UnicornAvatarStage stage = UnicornAvatarStage.stage01,
}) {
  return 'assets/images/characters/${avatar.folderName}/'
      '${stage.assetPrefix}_${emotion.name}.webp';
}

List<String> unicornAvatarAssetFallbackPaths({
  required UnicornAvatar avatar,
  required UnicornAvatarEmotion emotion,
  UnicornAvatarStage stage = UnicornAvatarStage.stage01,
}) {
  final selectedPath = unicornAvatarAssetPath(
    avatar: avatar,
    emotion: emotion,
    stage: stage,
  );
  final selectedIdlePath = unicornAvatarAssetPath(
    avatar: avatar,
    emotion: UnicornAvatarEmotion.idle,
    stage: stage,
  );
  final fallbackPath = unicornAvatarAssetPath(
    avatar: unicornAvatarFallback,
    emotion: emotion,
    stage: stage,
  );
  final fallbackIdlePath = unicornAvatarAssetPath(
    avatar: unicornAvatarFallback,
    emotion: UnicornAvatarEmotion.idle,
    stage: stage,
  );

  return [
    selectedPath,
    if (selectedIdlePath != selectedPath) selectedIdlePath,
    if (fallbackPath != selectedPath && fallbackPath != selectedIdlePath)
      fallbackPath,
    if (fallbackIdlePath != selectedPath &&
        fallbackIdlePath != selectedIdlePath &&
        fallbackIdlePath != fallbackPath)
      fallbackIdlePath,
  ];
}
