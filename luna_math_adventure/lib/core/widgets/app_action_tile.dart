import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../services/audio_service.dart';

class AppActionTile extends StatelessWidget {
  const AppActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconSize = 40,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double iconSize;
  final bool compact;

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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: compact
              ? _CompactActionTileContent(
                  icon: icon,
                  label: label,
                  iconColor: iconColor,
                  iconSize: iconSize,
                )
              : _ActionTileContent(
                  icon: icon,
                  label: label,
                  iconColor: iconColor,
                  iconSize: iconSize,
                ),
        ),
      ),
    );
  }
}

class _ActionTileContent extends StatelessWidget {
  const _ActionTileContent({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconSize,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionTileIcon(
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
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
    );
  }
}

class _CompactActionTileContent extends StatelessWidget {
  const _CompactActionTileContent({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconSize,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionTileIcon(
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.cardTitle.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: iconColor,
          size: 18,
        ),
      ],
    );
  }
}

class _ActionTileIcon extends StatelessWidget {
  const _ActionTileIcon({
    required this.icon,
    required this.iconColor,
    required this.iconSize,
  });

  final IconData icon;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: iconSize + 24,
      height: iconSize + 24,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}
