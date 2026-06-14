import 'package:go_router/go_router.dart';

import '../features/game/game_screen.dart';
import '../features/help/help_center_screen.dart';
import '../features/map/map_screen.dart';
import '../features/practice/practice_mode_screen.dart';
import '../features/profile/child_name_screen.dart';
import '../features/profile/language_selection_screen.dart';
import '../features/profile/splash_screen.dart';
import '../features/profile/unicorn_name_screen.dart';
import '../features/profile/unicorn_variant_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/language', builder: (context, state) => const LanguageSelectionScreen()),
    GoRoute(path: '/child-name', builder: (context, state) => const ChildNameScreen()),
    GoRoute(path: '/unicorn-variant', builder: (context, state) => const UnicornVariantScreen()),
    GoRoute(path: '/unicorn-name', builder: (context, state) => const UnicornNameScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
    GoRoute(path: '/game', builder: (context, state) => const GameScreen()),
    GoRoute(path: '/practice', builder: (context, state) => const PracticeModeScreen()),
    GoRoute(path: '/help', builder: (context, state) => const HelpCenterScreen()),
    GoRoute(path: '/rewards', builder: (context, state) => const RewardsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);
