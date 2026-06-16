import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppBackgroundStyle {
  const AppBackgroundStyle._();

  static const baseDecoration = BoxDecoration(
    gradient: AppColors.backgroundGradient,
  );

  static final imageOverlayDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.24),
        Colors.white.withValues(alpha: 0.12),
        AppColors.cloud.withValues(alpha: 0.38),
      ],
    ),
  );
}
