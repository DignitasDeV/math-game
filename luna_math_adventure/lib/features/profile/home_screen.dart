import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/dev_options.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_action_tile.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/responsive_action_grid.dart';
import '../../services/profile_controller.dart';
import '../../services/progress_repository.dart';
import '../../services/ui_copy.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final progress = ref.watch(activeProgressProvider).valueOrNull;
    final hasStartedAdventure =
        progress != null && progress.completedLevelIds.isNotEmpty;
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';
    final playLabel = hasStartedAdventure
        ? UiCopy.text(languageCode, es: 'Continuar', ca: 'Continuar')
        : UiCopy.text(
            languageCode,
            es: 'Empezar aventura',
            ca: 'Començar aventura',
          );
    final playRoute = activeProfile == null
        ? '/language'
        : AppDevOptions.unlockAllLevels && !hasStartedAdventure
            ? '/map'
            : '/game/${progress?.lastLevelId ?? 'heart_forest_01'}';

    final destinations = <({IconData icon, String label, String route})>[
      (
        icon: Symbols.explore_rounded,
        label: UiCopy.map(languageCode),
        route: '/map',
      ),
      (
        icon: Symbols.play_circle_rounded,
        label: playLabel,
        route: playRoute,
      ),
      (
        icon: Symbols.fitness_center_rounded,
        label: UiCopy.text(
          languageCode,
          es: 'Práctica libre',
          ca: 'Pràctica lliure',
        ),
        route: '/practice',
      ),
      (
        icon: Symbols.emoji_events_rounded,
        label: UiCopy.rewards(languageCode),
        route: '/rewards',
      ),
      (
        icon: Symbols.lightbulb_rounded,
        label: UiCopy.help(languageCode),
        route: '/help',
      ),
      (
        icon: Symbols.tune_rounded,
        label: UiCopy.settings(languageCode),
        route: '/settings',
      ),
    ];

    return MagicScaffold(
      title: '',
      backgroundAssetPath:
          'assets/images/backgrounds/home_background_screen.webp',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            title: activeProfile == null
                ? UiCopy.text(
                    languageCode,
                    es: 'Elige una aventura mágica',
                    ca: 'Tria una aventura màgica',
                  )
                : UiCopy.text(
                    languageCode,
                    es: 'Hola, ${activeProfile.childName}!',
                    ca: 'Hola, ${activeProfile.childName}!',
                  ),
            subtitle: UiCopy.text(
              languageCode,
              es: '¿Qué quieres hacer hoy?',
              ca: 'Què vols fer avui?',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow =
                    constraints.maxWidth < AppBreakpoints.narrowWidth;
                if (isNarrow) {
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: destinations.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      return SizedBox(
                        height: 82,
                        child: AppActionTile(
                          icon: destination.icon,
                          label: destination.label,
                          color: AppActionTile.colorForIndex(index),
                          iconSize: 34,
                          compact: true,
                          onTap: () => context.go(destination.route),
                        ),
                      );
                    },
                  );
                }

                return ResponsiveActionGrid(
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      AppActionTile(
                        icon: destinations[i].icon,
                        label: destinations[i].label,
                        color: AppActionTile.colorForIndex(i),
                        iconSize: 54,
                        onTap: () => context.go(destinations[i].route),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
