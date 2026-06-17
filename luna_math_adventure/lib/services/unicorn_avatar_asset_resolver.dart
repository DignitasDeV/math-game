import '../models/unicorn_avatar.dart';
import '../models/unicorn_avatar_stage.dart';

enum UnicornAvatarEmotion {
  idle,
  happy,
  thinking,
  encouraging,
  celebrating,
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
  final paths = <String>[];

  void addPath({
    required UnicornAvatar candidateAvatar,
    required UnicornAvatarEmotion candidateEmotion,
    required UnicornAvatarStage candidateStage,
  }) {
    final path = unicornAvatarAssetPath(
      avatar: candidateAvatar,
      emotion: candidateEmotion,
      stage: candidateStage,
    );
    if (!paths.contains(path)) {
      paths.add(path);
    }
  }

  for (final candidateStage in _fallbackStages(stage)) {
    addPath(
      candidateAvatar: avatar,
      candidateEmotion: emotion,
      candidateStage: candidateStage,
    );
    if (emotion != UnicornAvatarEmotion.idle) {
      addPath(
        candidateAvatar: avatar,
        candidateEmotion: UnicornAvatarEmotion.idle,
        candidateStage: candidateStage,
      );
    }
  }

  for (final candidateStage in _fallbackStages(stage)) {
    addPath(
      candidateAvatar: unicornAvatarFallback,
      candidateEmotion: emotion,
      candidateStage: candidateStage,
    );
    if (emotion != UnicornAvatarEmotion.idle) {
      addPath(
        candidateAvatar: unicornAvatarFallback,
        candidateEmotion: UnicornAvatarEmotion.idle,
        candidateStage: candidateStage,
      );
    }
  }

  return paths;
}

List<UnicornAvatarStage> _fallbackStages(UnicornAvatarStage stage) {
  return UnicornAvatarStage.values
      .where((candidate) => candidate.index <= stage.index)
      .toList(growable: false)
      .reversed
      .toList(growable: false);
}
