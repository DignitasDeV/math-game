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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final progress = ref.watch(activeProgressProvider).valueOrNull;
    final hasStartedAdventure =
        progress != null && progress.completedLevelIds.isNotEmpty;
    final playLabel = hasStartedAdventure ? 'Continuar' : 'Empezar aventura';
    final playRoute = activeProfile == null
        ? '/language'
        : AppDevOptions.unlockAllLevels && !hasStartedAdventure
            ? '/map'
            : '/game/${progress?.lastLevelId ?? 'heart_forest_01'}';

    final destinations = <({IconData icon, String label, String route})>[
      (
        icon: Symbols.explore_rounded,
        label: 'Mapa',
        route: '/map',
      ),
      (
        icon: Symbols.play_circle_rounded,
        label: playLabel,
        route: playRoute,
      ),
      (
        icon: Symbols.fitness_center_rounded,
        label: 'Practica libre',
        route: '/practice',
      ),
      (
        icon: Symbols.emoji_events_rounded,
        label: 'Recompensas',
        route: '/rewards',
      ),
      (
        icon: Symbols.lightbulb_rounded,
        label: 'Ayuda',
        route: '/help',
      ),
      (
        icon: Symbols.tune_rounded,
        label: 'Ajustes',
        route: '/settings',
      ),
    ];

    return MagicScaffold(
      title: '',
      backgroundAssetPath: 'assets/images/backgrounds/home_background_screen.webp',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            title: activeProfile == null
                ? 'Elige una aventura magica'
                : 'Hola, ${activeProfile.childName}!',
            subtitle: 'Que quieres hacer hoy?',
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ResponsiveActionGrid(
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
            ),
          ),
        ],
      ),
    );
  }
}
