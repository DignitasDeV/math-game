import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../models/unicorn_avatar.dart';
import '../../models/unicorn_avatar_stage.dart';
import '../../services/unicorn_avatar_asset_resolver.dart';
import 'safe_asset_image.dart';

class UnicornAvatarImage extends StatelessWidget {
  const UnicornAvatarImage({
    required this.avatar,
    required this.emotion,
    this.stage = UnicornAvatarStage.stage01,
    this.fit = BoxFit.contain,
    this.fallback,
    super.key,
  });

  final UnicornAvatar avatar;
  final UnicornAvatarEmotion emotion;
  final UnicornAvatarStage stage;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return _AssetChain(
      assetPaths: unicornAvatarAssetFallbackPaths(
        avatar: avatar,
        emotion: emotion,
        stage: stage,
      ),
      fit: fit,
      fallback: fallback ?? const _DefaultAvatarFallback(),
    );
  }
}

class _AssetChain extends StatelessWidget {
  const _AssetChain({
    required this.assetPaths,
    required this.fit,
    required this.fallback,
  });

  final List<String> assetPaths;
  final BoxFit fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return _assetAt(0);
  }

  Widget _assetAt(int index) {
    if (index >= assetPaths.length) {
      return fallback;
    }

    return SafeAssetImage(
      assetPath: assetPaths[index],
      fit: fit,
      placeholder: _assetAt(index + 1),
    );
  }
}

class _DefaultAvatarFallback extends StatelessWidget {
  const _DefaultAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Symbols.auto_awesome_rounded,
      color: AppColors.lilacAccent,
    );
  }
}
