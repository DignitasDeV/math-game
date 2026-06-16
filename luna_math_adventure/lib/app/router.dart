import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/speech_route_boundary.dart';
import '../features/game/game_screen.dart';
import '../features/help/help_center_screen.dart';
import '../features/map/map_screen.dart';
import '../features/practice/practice_mode_screen.dart';
import '../features/profile/child_name_screen.dart';
import '../features/profile/language_selection_screen.dart';
import '../features/profile/profile_selection_screen.dart';
import '../features/profile/splash_screen.dart';
import '../features/profile/unicorn_avatar_screen.dart';
import '../features/profile/unicorn_name_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => _route(const SplashScreen())),
    GoRoute(
      path: '/profiles',
      builder: (context, state) => _route(const ProfileSelectionScreen()),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => _route(const LanguageSelectionScreen()),
    ),
    GoRoute(
      path: '/child-name',
      builder: (context, state) => _route(const ChildNameScreen()),
    ),
    GoRoute(
      path: '/unicorn-avatar',
      builder: (context, state) => _route(const UnicornAvatarScreen()),
    ),
    GoRoute(
      path: '/unicorn-name',
      builder: (context, state) => _route(const UnicornNameScreen()),
    ),
    GoRoute(path: '/home', builder: (context, state) => _route(const HomeScreen())),
    GoRoute(path: '/map', builder: (context, state) => _route(const MapScreen())),
    GoRoute(path: '/game', builder: (context, state) => _route(const GameScreen())),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) => _route(
        GameScreen(
          levelId: state.pathParameters['levelId'],
        ),
      ),
    ),
    GoRoute(
      path: '/practice',
      builder: (context, state) => _route(const PracticeModeScreen()),
    ),
    GoRoute(path: '/help', builder: (context, state) => _route(const HelpCenterScreen())),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => _route(const RewardsScreen()),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => _route(const SettingsScreen()),
    ),
  ],
);

SpeechRouteBoundary _route(Widget child) => SpeechRouteBoundary(child: child);
