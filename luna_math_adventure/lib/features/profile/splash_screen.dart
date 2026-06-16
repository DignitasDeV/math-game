import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_background_style.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/responsive_asset_background.dart';
import '../../core/widgets/responsive_screen.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: AppBackgroundStyle.baseDecoration,
          ),
          const ResponsiveAssetBackground(
            assetPath: 'assets/images/backgrounds/home_background_screen.webp',
          ),
          DecoratedBox(
            decoration: AppBackgroundStyle.imageOverlayDecoration,
          ),
          SafeArea(
            child: ResponsiveScreen(
              child: profileState.when(
                data: (family) {
                  final targetRoute = family.hasProfiles ? '/profiles' : null;

                  if (targetRoute != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        context.go(targetRoute);
                      }
                    });
                  }

                  return _SplashContent(
                    action: targetRoute == null
                        ? FilledButton(
                            onPressed: () => playTapAndRun(
                              context,
                              () => context.go('/language'),
                            ),
                            child: const Text('Crear perfil'),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  );
                },
                loading: () => const _SplashContent(
                  action: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _SplashContent(
                  action: FilledButton(
                    onPressed: () => playTapAndRun(
                      context,
                      () => ref.invalidate(profileControllerProvider),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.action});

  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),
        const Icon(
          Icons.auto_awesome_rounded,
          size: 72,
          color: AppColors.lilacAccent,
        ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Luna Math\nAdventure',
          textAlign: TextAlign.center,
          style: AppTypography.display,
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Matemáticas con magia, pistas y recompensas.',
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        const Spacer(flex: 3),
        SizedBox(
          height: 56,
          child: action,
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }
}
