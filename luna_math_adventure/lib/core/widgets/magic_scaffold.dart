import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_background_style.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
import 'quick_navigation_fab.dart';
import 'responsive_asset_background.dart';
import 'responsive_screen.dart';

class MagicScaffold extends ConsumerWidget {
  const MagicScaffold({
    required this.title,
    required this.child,
    this.actions = const [],
    this.backgroundAssetPath,
    this.showBackButton = true,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final String? backgroundAssetPath;
  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final currentPath = GoRouterState.of(context).uri.path;
    final canPop = showBackButton && router.canPop();
    final canQuickNavigate = ref.watch(activeProfileProvider) != null &&
        !_isQuickNavigationExcluded(currentPath);
    final hasAppBar = canPop || actions.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: hasAppBar,
      appBar: hasAppBar
          ? AppBar(
              title: Text(title),
              actions: actions,
              automaticallyImplyLeading: false,
              leading: canPop
                  ? IconButton(
                      onPressed: () => playBackAndRun(context, context.pop),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Volver',
                    )
                  : null,
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: AppBackgroundStyle.baseDecoration,
          ),
          if (backgroundAssetPath case final path?)
            ResponsiveAssetBackground(assetPath: path),
          DecoratedBox(
            decoration: AppBackgroundStyle.imageOverlayDecoration,
          ),
          SafeArea(
            child: ResponsiveScreen(
              child: child,
            ),
          ),
          if (canQuickNavigate)
            QuickNavigationFab(
              currentPath: currentPath,
              canPop: router.canPop(),
            ),
        ],
      ),
    );
  }
}

bool _isQuickNavigationExcluded(String currentPath) {
  return switch (currentPath) {
    '/' ||
    '/profiles' ||
    '/language' ||
    '/child-name' ||
    '/unicorn-avatar' ||
    '/unicorn-name' ||
    '/home' =>
      true,
    _ => false,
  };
}
