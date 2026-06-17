import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../models/app_language.dart';
import '../../services/audio_service.dart';
import '../../services/profile_repository.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MagicScaffold(
      title: 'Idioma',
      backgroundAssetPath:
          'assets/images/backgrounds/home_background_screen.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppScreenHeader(
            icon: Symbols.language_rounded,
            title: 'Elige idioma',
            subtitle: 'Tria idioma',
          ),
          const Spacer(),
          _LanguageButton(
            language: AppLanguage.spanish,
            badge: 'ES',
            subtitle: 'Jugar en español',
            color: AppColors.magicPink,
            onPressed: () => _selectLanguage(context, ref, AppLanguage.spanish),
          ),
          const SizedBox(height: AppSpacing.lg),
          _LanguageButton(
            language: AppLanguage.catalan,
            badge: 'CA',
            subtitle: 'Jugar en català',
            color: AppColors.skyBlue,
            onPressed: () => _selectLanguage(context, ref, AppLanguage.catalan),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) {
    ref.read(onboardingDraftProvider.notifier).setLanguage(language);
    context.go('/child-name');
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.language,
    required this.badge,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  final AppLanguage language;
  final String badge;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowWidth;
    final horizontalPadding = isNarrow ? AppSpacing.md : AppSpacing.xl;
    final gap = isNarrow ? AppSpacing.md : AppSpacing.lg;

    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onPressed),
        splashColor: color.withValues(alpha: 0.3),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: AppTypography.label.copyWith(
                    color: iconColor,
                  ),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sectionTitle.copyWith(
                        color: iconColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isNarrow ? AppSpacing.sm : AppSpacing.md),
              Icon(Icons.arrow_forward_ios_rounded, color: iconColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
