import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/unicorn_avatar.dart';
import 'package:luna_math_adventure/services/unicorn_avatar_asset_resolver.dart';

void main() {
  test('builds stage 01 avatar asset paths', () {
    final path = unicornAvatarAssetPath(
      avatar: UnicornAvatar.avatar03,
      emotion: UnicornAvatarEmotion.celebrating,
    );

    expect(
      path,
      'assets/images/characters/avatar_03/stage_01_celebrating.webp',
    );
  });

  test('fallback paths include selected state, idle, and default emotion', () {
    final paths = unicornAvatarAssetFallbackPaths(
      avatar: UnicornAvatar.avatar04,
      emotion: UnicornAvatarEmotion.happy,
    );

    expect(paths, [
      'assets/images/characters/avatar_04/stage_01_happy.webp',
      'assets/images/characters/avatar_04/stage_01_idle.webp',
      'assets/images/characters/avatar_01/stage_01_happy.webp',
      'assets/images/characters/avatar_01/stage_01_idle.webp',
    ]);
  });
}
