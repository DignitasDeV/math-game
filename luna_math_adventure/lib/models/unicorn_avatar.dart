import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

enum UnicornAvatar {
  avatar01(
    id: 'avatar_01',
    folderName: 'avatar_01',
    accentColor: AppColors.magicPink,
  ),
  avatar02(
    id: 'avatar_02',
    folderName: 'avatar_02',
    accentColor: AppColors.starGold,
  ),
  avatar03(
    id: 'avatar_03',
    folderName: 'avatar_03',
    accentColor: AppColors.skyBlue,
  ),
  avatar04(
    id: 'avatar_04',
    folderName: 'avatar_04',
    accentColor: AppColors.softMint,
  ),
  avatar05(
    id: 'avatar_05',
    folderName: 'avatar_05',
    accentColor: AppColors.softLilac,
  ),
  avatar06(
    id: 'avatar_06',
    folderName: 'avatar_06',
    accentColor: AppColors.hintOrange,
  );

  const UnicornAvatar({
    required this.id,
    required this.folderName,
    required this.accentColor,
  });

  final String id;
  final String folderName;
  final Color accentColor;

  static UnicornAvatar fromProfileJson(Map<String, Object?> json) {
    final avatarId = json['unicornAvatarId'] as String?;
    if (avatarId != null) {
      return fromId(avatarId);
    }

    return switch (json['unicornVariant'] as String?) {
      'unicorn' => UnicornAvatar.avatar02,
      'unicornia' => UnicornAvatar.avatar01,
      _ => UnicornAvatar.avatar01,
    };
  }

  static UnicornAvatar fromId(String id) {
    final normalizedId = _legacyAvatarIdAliases[id] ?? id;
    for (final avatar in UnicornAvatar.values) {
      if (avatar.id == normalizedId || avatar.name == normalizedId) {
        return avatar;
      }
    }

    return UnicornAvatar.avatar01;
  }
}

const _legacyAvatarIdAliases = {
  'aurora': 'avatar_01',
  'star': 'avatar_02',
  'rainbow': 'avatar_03',
  'cloud': 'avatar_04',
};
