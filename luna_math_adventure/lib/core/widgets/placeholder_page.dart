import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../services/audio_service.dart';
import 'magic_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    required this.message,
    this.icon = Symbols.construction_rounded,
    this.primaryLabel,
    this.primaryRoute,
    this.backgroundAssetPath,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? primaryLabel;
  final String? primaryRoute;
  final String? backgroundAssetPath;

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: title,
      backgroundAssetPath: backgroundAssetPath,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(
            icon,
            size: 64,
            color: AppColors.lilacAccent,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.starGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.construction_rounded,
                  size: 20,
                  color: HSLColor.fromColor(AppColors.starGold)
                      .withLightness(0.35)
                      .toColor(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Próximamente',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          if (primaryLabel != null && primaryRoute != null)
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => playTapAndRun(
                  context,
                  () => context.go(primaryRoute!),
                ),
                icon: const Icon(Symbols.home_rounded),
                label: Text(primaryLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
