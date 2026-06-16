import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../services/audio_service.dart';

class QuickNavigationFab extends StatefulWidget {
  const QuickNavigationFab({
    required this.currentPath,
    required this.canPop,
    super.key,
  });

  final String currentPath;
  final bool canPop;

  @override
  State<QuickNavigationFab> createState() => _QuickNavigationFabState();
}

class _QuickNavigationFabState extends State<QuickNavigationFab> {
  var _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final actions = _actionsFor(widget.currentPath, widget.canPop);
    final isExercisePath = _isExercisePath(widget.currentPath);
    final bottomOffset = isExercisePath ? 96.0 : AppSpacing.lg;
    final mainButtonSize = isExercisePath ? 52.0 : 58.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _isOpen = false),
            ),
          ),
        Positioned(
          right: AppSpacing.lg,
          bottom: bottomOffset,
          child: SafeArea(
            minimum: const EdgeInsets.only(
              right: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: AppMotion.normal,
                  reverseDuration: AppMotion.quick,
                  switchInCurve: AppMotion.emphasized,
                  switchOutCurve: AppMotion.exit,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        alignment: Alignment.bottomRight,
                        child: child,
                      ),
                    );
                  },
                  child: _isOpen
                      ? _QuickNavigationActionList(
                          key: const ValueKey('quick-nav-open'),
                          actions: actions,
                          onSelected: (action) => _runAction(context, action),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('quick-nav-closed'),
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _QuickNavigationMainButton(
                  isOpen: _isOpen,
                  size: mainButtonSize,
                  onPressed: () => setState(() => _isOpen = !_isOpen),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _runAction(
    BuildContext context,
    _QuickNavigationAction action,
  ) async {
    setState(() => _isOpen = false);

    if (action.route case final route?) {
      await playTapAndRun(context, () => context.go(route));
      return;
    }

    if (action.isBack) {
      await playBackAndRun(context, context.pop);
    }
  }
}

class _QuickNavigationMainButton extends StatelessWidget {
  const _QuickNavigationMainButton({
    required this.isOpen,
    required this.size,
    required this.onPressed,
  });

  final bool isOpen;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isOpen ? 'Cerrar' : 'Navegacion rapida',
      child: Material(
        color: AppColors.pinkAccent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shadowColor: AppColors.purpleText.withValues(alpha: 0.28),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => playTapAndRun(
            context,
            onPressed,
            stopSpeech: false,
          ),
          child: SizedBox.square(
            dimension: size,
            child: AnimatedRotation(
              turns: isOpen ? 0.125 : 0,
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              child: AnimatedSwitcher(
                duration: AppMotion.quick,
                switchInCurve: AppMotion.standard,
                switchOutCurve: AppMotion.exit,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isOpen ? Symbols.close_rounded : Symbols.apps_rounded,
                  key: ValueKey(isOpen),
                  color: Colors.white,
                  size: size * 0.55,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickNavigationActionList extends StatelessWidget {
  const _QuickNavigationActionList({
    required this.actions,
    required this.onSelected,
    super.key,
  });

  final List<_QuickNavigationAction> actions;
  final ValueChanged<_QuickNavigationAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.softLilac.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleText.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              _QuickNavigationActionButton(
                action: actions[index],
                index: index,
                onPressed: () => onSelected(actions[index]),
              ),
              if (index < actions.length - 1)
                const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickNavigationActionButton extends StatelessWidget {
  const _QuickNavigationActionButton({
    required this.action,
    required this.index,
    required this.onPressed,
  });

  final _QuickNavigationAction action;
  final int index;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground =
        HSLColor.fromColor(action.color).withLightness(0.33).toColor();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 180 + index * 35),
      curve: AppMotion.standard,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 14, 0),
            child: child,
          ),
        );
      },
      child: Tooltip(
        message: action.label,
        child: Material(
          color: action.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            splashColor: action.color.withValues(alpha: 0.28),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.label,
                    style: AppTypography.label.copyWith(color: foreground),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 38,
                      child: Icon(action.icon, color: foreground, size: 25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickNavigationAction {
  const _QuickNavigationAction({
    required this.label,
    required this.icon,
    required this.color,
    this.route,
    this.isBack = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String? route;
  final bool isBack;
}

List<_QuickNavigationAction> _actionsFor(String currentPath, bool canPop) {
  final isGame = _isGamePath(currentPath);
  final actions = <_QuickNavigationAction>[
    if (canPop)
      const _QuickNavigationAction(
        label: 'Atras',
        icon: Symbols.arrow_back_rounded,
        color: AppColors.starGold,
        isBack: true,
      ),
    const _QuickNavigationAction(
      label: 'Inicio',
      icon: Symbols.home_rounded,
      color: AppColors.magicPink,
      route: '/home',
    ),
    const _QuickNavigationAction(
      label: 'Mapa',
      icon: Symbols.map_rounded,
      color: AppColors.softMint,
      route: '/map',
    ),
    const _QuickNavigationAction(
      label: 'Ayuda',
      icon: Symbols.lightbulb_rounded,
      color: AppColors.skyBlue,
      route: '/help',
    ),
    if (!isGame)
      const _QuickNavigationAction(
        label: 'Ajustes',
        icon: Symbols.tune_rounded,
        color: AppColors.softLilac,
        route: '/settings',
      ),
  ];

  return [
    for (final action in actions)
      if (action.route == null || action.route != currentPath) action,
  ];
}

bool _isExercisePath(String currentPath) {
  return _isGamePath(currentPath) || currentPath == '/practice';
}

bool _isGamePath(String currentPath) {
  return currentPath == '/game' || currentPath.startsWith('/game/');
}
