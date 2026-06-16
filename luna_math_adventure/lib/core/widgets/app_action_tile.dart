import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../services/audio_service.dart';

class AppActionTile extends StatelessWidget {
  const AppActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconSize = 40,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double iconSize;

  static const _tileColors = [
    AppColors.magicPink,
    AppColors.softLilac,
    AppColors.skyBlue,
    AppColors.softMint,
    AppColors.starGold,
    AppColors.magicPink,
  ];

  static Color colorForIndex(int index) =>
      _tileColors[index % _tileColors.length];

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.softLilac;
    final iconColor =
        HSLColor.fromColor(tileColor).withLightness(0.35).toColor();

    return Material(
      color: tileColor.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: tileColor.withValues(alpha: 0.3),
        highlightColor: tileColor.withValues(alpha: 0.15),
        onTap: () => playTapAndRun(context, onTap),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize + 24,
                height: iconSize + 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTypography.cardTitle.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
