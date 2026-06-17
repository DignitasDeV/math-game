import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconSize = 48,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.title),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: AppTypography.body),
        ],
      ],
    );
  }
}
