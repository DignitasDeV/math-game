import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/dev_options.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/safe_asset_image.dart';
import '../../models/level_config.dart';
import '../../models/player_progress.dart';
import '../../models/world.dart';
import '../../services/audio_service.dart';
import '../../services/content_repository.dart';
import '../../services/profile_controller.dart';
import '../../services/progress_repository.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _selectedWorldId;
  int _worldPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final worldsState = ref.watch(worldsProvider);
    final levelsState = ref.watch(levelsProvider);
    final progressState = ref.watch(activeProgressProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';
    final backgroundAssetPath = _mapBackgroundAssetPath(
      worldsState.valueOrNull,
      _selectedWorldId,
    );

    return MagicScaffold(
      title: 'Mapa',
      backgroundAssetPath: backgroundAssetPath,
      child: worldsState.when(
        data: (worlds) => levelsState.when(
          data: (levels) => progressState.when(
            data: (progress) => _MapContent(
              worlds: worlds,
              levels: levels,
              progress: progress,
              selectedWorldId: _selectedWorldId,
              worldPageIndex: _worldPageIndex,
              languageCode: languageCode,
              onWorldSelected: (worldId) {
                setState(() => _selectedWorldId = worldId);
              },
              onBackToWorlds: () {
                setState(() => _selectedWorldId = null);
              },
              onWorldPageChanged: (pageIndex) {
                setState(() => _worldPageIndex = pageIndex);
              },
            ),
            loading: () => const _LoadingMap(),
            error: (_, __) => _MapError(languageCode: languageCode),
          ),
          loading: () => const _LoadingMap(),
          error: (_, __) => _MapError(languageCode: languageCode),
        ),
        loading: () => const _LoadingMap(),
        error: (_, __) => _MapError(languageCode: languageCode),
      ),
    );
  }
}

String _mapBackgroundAssetPath(
  List<World>? worlds,
  String? selectedWorldId,
) {
  final selectedWorld = _selectedWorld(worlds ?? const [], selectedWorldId);
  return selectedWorld?.backgroundAssetPath ??
      'assets/images/backgrounds/home_background_screen.webp';
}

class _MapContent extends StatelessWidget {
  const _MapContent({
    required this.worlds,
    required this.levels,
    required this.progress,
    required this.selectedWorldId,
    required this.worldPageIndex,
    required this.languageCode,
    required this.onWorldSelected,
    required this.onBackToWorlds,
    required this.onWorldPageChanged,
  });

  final List<World> worlds;
  final List<LevelConfig> levels;
  final PlayerProgress? progress;
  final String? selectedWorldId;
  final int worldPageIndex;
  final String languageCode;
  final ValueChanged<String> onWorldSelected;
  final VoidCallback onBackToWorlds;
  final ValueChanged<int> onWorldPageChanged;

  @override
  Widget build(BuildContext context) {
    final selectedWorld = _selectedWorld(worlds, selectedWorldId);
    final selectedWorldLevels = selectedWorld == null
        ? const <LevelConfig>[]
        : _levelsForWorld(selectedWorld, levels);
    if (selectedWorld != null &&
        selectedWorld.isImplemented &&
        selectedWorldLevels.isNotEmpty &&
        _isWorldUnlocked(selectedWorld, selectedWorldLevels)) {
      return _WorldLevelsView(
        world: selectedWorld,
        levels: selectedWorldLevels,
        languageCode: languageCode,
        isLevelUnlocked: _isLevelUnlocked,
        isLevelCompleted: _isLevelCompleted,
        starsForLevel: _starsForLevel,
        onBack: onBackToWorlds,
      );
    }

    return _WorldsView(
      worlds: worlds,
      levels: levels,
      pageIndex: worldPageIndex,
      languageCode: languageCode,
      isWorldUnlocked: _isWorldUnlocked,
      onWorldSelected: onWorldSelected,
      onPageChanged: onWorldPageChanged,
    );
  }

  bool _isWorldUnlocked(World world, List<LevelConfig> worldLevels) {
    if (AppDevOptions.unlockAllLevels) {
      return true;
    }

    if (!world.isImplemented || worldLevels.isEmpty) {
      return false;
    }

    final firstImplementedWorld = _firstImplementedWorld();
    if (firstImplementedWorld?.id == world.id) {
      return true;
    }

    return worldLevels.any(_isLevelUnlocked);
  }

  bool _isLevelUnlocked(LevelConfig level) {
    if (AppDevOptions.unlockAllLevels) {
      return true;
    }

    return progress?.unlockedLevelIds.contains(level.id) ??
        level.id == 'heart_forest_01';
  }

  bool _isLevelCompleted(LevelConfig level) {
    return progress?.completedLevelIds.contains(level.id) ?? false;
  }

  int _starsForLevel(LevelConfig level) {
    return progress?.starsByLevel[level.id] ?? 0;
  }

  World? _firstImplementedWorld() {
    for (final world in worlds) {
      final worldLevels = _levelsForWorld(world, levels);
      if (world.isImplemented && worldLevels.isNotEmpty) {
        return world;
      }
    }

    return null;
  }
}

World? _selectedWorld(List<World> worlds, String? selectedWorldId) {
  if (selectedWorldId == null) {
    return null;
  }

  for (final world in worlds) {
    if (world.id == selectedWorldId) {
      return world;
    }
  }

  return null;
}

List<LevelConfig> _levelsForWorld(World world, List<LevelConfig> levels) {
  final levelsById = {
    for (final level in levels) level.id: level,
  };
  final worldLevels = <LevelConfig>[];

  for (final levelId in world.levelIds) {
    final level = levelsById[levelId];
    if (level != null) {
      worldLevels.add(level);
    }
  }

  return worldLevels;
}

class _WorldsView extends StatelessWidget {
  const _WorldsView({
    required this.worlds,
    required this.levels,
    required this.pageIndex,
    required this.languageCode,
    required this.isWorldUnlocked,
    required this.onWorldSelected,
    required this.onPageChanged,
  });

  static const _pageSize = 4;

  final List<World> worlds;
  final List<LevelConfig> levels;
  final int pageIndex;
  final String languageCode;
  final bool Function(World world, List<LevelConfig> worldLevels)
      isWorldUnlocked;
  final ValueChanged<String> onWorldSelected;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final pageCount =
        worlds.isEmpty ? 1 : (worlds.length + _pageSize - 1) ~/ _pageSize;
    final currentPage = pageIndex < 0
        ? 0
        : pageIndex >= pageCount
            ? pageCount - 1
            : pageIndex;
    final firstWorldIndex = currentPage * _pageSize;
    final visibleWorlds =
        worlds.skip(firstWorldIndex).take(_pageSize).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppScreenHeader(
          title: _worldsTitle(languageCode),
          subtitle: _worldsSubtitle(languageCode),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: _FixedGrid(
            itemCount: visibleWorlds.length,
            minColumns: 2,
            maxColumns: 2,
            minCells: _pageSize,
            itemBuilder: (context, index) {
              final world = visibleWorlds[index];
              final worldLevels = _levelsForWorld(world, levels);
              final isAvailable = world.isImplemented && worldLevels.isNotEmpty;
              final isUnlocked =
                  isAvailable && isWorldUnlocked(world, worldLevels);
              return _WorldCard(
                world: world,
                levelCount: worldLevels.length,
                languageCode: languageCode,
                isAvailable: isAvailable,
                isUnlocked: isUnlocked,
                onTap: isUnlocked ? () => onWorldSelected(world.id) : null,
              );
            },
          ),
        ),
        if (pageCount > 1) ...[
          const SizedBox(height: AppSpacing.md),
          _WorldPageControls(
            currentPage: currentPage,
            pageCount: pageCount,
            languageCode: languageCode,
            onPrevious:
                currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            onNext: currentPage < pageCount - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ],
    );
  }
}

class _WorldPageControls extends StatelessWidget {
  const _WorldPageControls({
    required this.currentPage,
    required this.pageCount,
    required this.languageCode,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final String languageCode;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ImageNavButton(
            assetPath: 'assets/images/ui/buttons/prev.webp',
            fallbackIcon: Symbols.arrow_back_rounded,
            tooltip: languageCode == 'ca-ES'
                ? 'Mons anteriors'
                : 'Mundos anteriores',
            onPressed: onPrevious,
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            '${currentPage + 1}/$pageCount',
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: AppSpacing.lg),
          _ImageNavButton(
            assetPath: 'assets/images/ui/buttons/next.webp',
            fallbackIcon: Symbols.arrow_forward_rounded,
            tooltip:
                languageCode == 'ca-ES' ? 'Mons seguents' : 'Mundos siguientes',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ImageNavButton extends StatelessWidget {
  const _ImageNavButton({
    required this.assetPath,
    required this.fallbackIcon,
    required this.tooltip,
    required this.onPressed,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () => playTapAndRun(
                      context,
                      onPressed!,
                    )
                : null,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 72,
              child: SafeAssetImage(
                assetPath: assetPath,
                fit: BoxFit.contain,
                placeholder: Icon(
                  fallbackIcon,
                  color: AppColors.purpleText,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldLevelsView extends StatelessWidget {
  const _WorldLevelsView({
    required this.world,
    required this.levels,
    required this.languageCode,
    required this.isLevelUnlocked,
    required this.isLevelCompleted,
    required this.starsForLevel,
    required this.onBack,
  });

  final World world;
  final List<LevelConfig> levels;
  final String languageCode;
  final bool Function(LevelConfig level) isLevelUnlocked;
  final bool Function(LevelConfig level) isLevelCompleted;
  final int Function(LevelConfig level) starsForLevel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final completedCount = levels.where(isLevelCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorldLevelsHeader(
          world: world,
          completedCount: completedCount,
          levelCount: levels.length,
          languageCode: languageCode,
          onBack: onBack,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: levels.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final level = levels[index];
              return _LevelTile(
                level: level,
                index: index,
                isUnlocked: isLevelUnlocked(level),
                isCompleted: isLevelCompleted(level),
                stars: starsForLevel(level),
                languageCode: languageCode,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorldLevelsHeader extends StatelessWidget {
  const _WorldLevelsHeader({
    required this.world,
    required this.completedCount,
    required this.levelCount,
    required this.languageCode,
    required this.onBack,
  });

  final World world;
  final int completedCount;
  final int levelCount;
  final String languageCode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowWidth;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softLilac.withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleText.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _WorldBackButton(
                        tooltip: _backTooltip(languageCode),
                        onBack: onBack,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                          child: _WorldHeaderText(
                              world: world, languageCode: languageCode)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _WorldProgressPill(
                      completedCount: completedCount,
                      levelCount: levelCount,
                      languageCode: languageCode,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  _WorldBackButton(
                    tooltip: _backTooltip(languageCode),
                    onBack: onBack,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _WorldHeaderText(
                      world: world,
                      languageCode: languageCode,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _WorldProgressPill(
                    completedCount: completedCount,
                    levelCount: levelCount,
                    languageCode: languageCode,
                  ),
                ],
              ),
      ),
    );
  }
}

class _WorldBackButton extends StatelessWidget {
  const _WorldBackButton({
    required this.tooltip,
    required this.onBack,
  });

  final String tooltip;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.softLilac.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onBack,
        icon: const Icon(Symbols.arrow_back_rounded),
        color: AppColors.purpleText,
      ),
    );
  }
}

class _WorldHeaderText extends StatelessWidget {
  const _WorldHeaderText({
    required this.world,
    required this.languageCode,
  });

  final World world;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          world.name.get(languageCode),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.sectionTitle.copyWith(fontSize: 23),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          world.description.get(languageCode),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.helper.copyWith(
            color: AppColors.purpleText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _WorldProgressPill extends StatelessWidget {
  const _WorldProgressPill({
    required this.completedCount,
    required this.levelCount,
    required this.languageCode,
  });

  final int completedCount;
  final int levelCount;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.starGold.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.starGold.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$completedCount/$levelCount',
        style: AppTypography.label.copyWith(
          color: AppColors.purpleText,
        ),
      ),
    );
  }
}

class _FixedGrid extends StatelessWidget {
  const _FixedGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.minColumns = 2,
    this.maxColumns = 3,
    this.minCells = 0,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int minColumns;
  final int maxColumns;
  final int minCells;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridItemCount = itemCount < minCells ? minCells : itemCount;
        final columns = _columnCount(constraints, gridItemCount);
        final rows = (gridItemCount / columns).ceil();

        return Column(
          children: [
            for (var rowIndex = 0; rowIndex < rows; rowIndex++) ...[
              if (rowIndex > 0) const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Row(
                  children: [
                    for (var columnIndex = 0;
                        columnIndex <
                            _columnsForRow(
                              rowIndex,
                              rows,
                              columns,
                              gridItemCount,
                            );
                        columnIndex++) ...[
                      if (columnIndex > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _gridChild(
                          context,
                          rowIndex * columns + columnIndex,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  int _columnCount(BoxConstraints constraints, int count) {
    if (constraints.maxWidth < AppBreakpoints.narrowWidth) {
      return 1;
    }

    final wideEnoughForThree = constraints.maxWidth >= 560;
    final heightLimited = constraints.maxHeight < 420 && count > 4;
    if ((wideEnoughForThree || heightLimited) && maxColumns >= 3) {
      return count < 3 ? count : 3;
    }

    return count < minColumns ? count : minColumns;
  }

  int _columnsForRow(
    int rowIndex,
    int rows,
    int columns,
    int count,
  ) {
    if (rowIndex < rows - 1) {
      return columns;
    }

    final remaining = count - rowIndex * columns;
    return remaining <= 0 ? columns : remaining;
  }

  Widget _gridChild(BuildContext context, int index) {
    if (index >= itemCount) {
      return const SizedBox.shrink();
    }

    return itemBuilder(context, index);
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({
    required this.world,
    required this.levelCount,
    required this.languageCode,
    required this.isAvailable,
    required this.isUnlocked,
    required this.onTap,
  });

  final World world;
  final int levelCount;
  final String languageCode;
  final bool isAvailable;
  final bool isUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked ? AppColors.magicPink : AppColors.softLilac;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _WorldCardBackground(
            cardAssetPath: _cardBackgroundAssetPath(
              world.backgroundAssetPath,
            ),
            fallbackAssetPath: world.backgroundAssetPath,
            placeholder: ColoredBox(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: isUnlocked ? 0.1 : 0.34),
                  Colors.black.withValues(alpha: isUnlocked ? 0.56 : 0.7),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onTap != null
                ? () => playTapAndRun(
                      context,
                      onTap!,
                    )
                : null,
            splashColor: color.withValues(alpha: 0.25),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      world.name.get(languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.screenTitle.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.34),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _worldCardStatusLabel(
                      languageCode,
                      isAvailable: isAvailable,
                      isUnlocked: isUnlocked,
                      levelCount: levelCount,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldCardBackground extends StatelessWidget {
  const _WorldCardBackground({
    required this.cardAssetPath,
    required this.fallbackAssetPath,
    required this.placeholder,
  });

  final String cardAssetPath;
  final String fallbackAssetPath;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeAssetImage(
        assetPath: cardAssetPath,
        fit: BoxFit.cover,
        placeholder: SafeAssetImage(
          assetPath: fallbackAssetPath,
          fit: BoxFit.cover,
          placeholder: placeholder,
        ),
      ),
    );
  }
}

String _cardBackgroundAssetPath(String backgroundAssetPath) {
  final extensionIndex = backgroundAssetPath.lastIndexOf('.');
  if (extensionIndex < 0) {
    return '${backgroundAssetPath}_card.webp';
  }

  var basePath = backgroundAssetPath.substring(0, extensionIndex);
  if (basePath.endsWith('_screen')) {
    basePath = basePath.substring(0, basePath.length - '_screen'.length);
  }

  return '${basePath}_card.webp';
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.index,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    required this.languageCode,
  });

  final LevelConfig level;
  final int index;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final color = AppActionColors.forIndex(index);
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();
    final statusColor = isUnlocked ? iconColor : AppColors.purpleTextLight;

    return Opacity(
      opacity: isUnlocked ? 1 : 0.72,
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isUnlocked
              ? () => playTapAndRun(
                    context,
                    () => context.go('/game/${level.id}'),
                  )
              : null,
          splashColor: color.withValues(alpha: 0.24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: isUnlocked
                    ? color.withValues(alpha: 0.48)
                    : AppColors.softLilac.withValues(alpha: 0.24),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleText.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _LevelNumberBadge(
                    index: index,
                    isCompleted: isCompleted,
                    isUnlocked: isUnlocked,
                    color: color,
                    iconColor: iconColor,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          level.title.get(languageCode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.cardTitle.copyWith(
                            color: isUnlocked
                                ? AppColors.purpleText
                                : AppColors.purpleTextLight,
                            fontSize: 21,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          level.subtitle.get(languageCode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.helper.copyWith(
                            color: isUnlocked
                                ? AppColors.purpleText
                                : AppColors.purpleTextLight,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _LevelMetaRow(
                          level: level,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          stars: stars,
                          languageCode: languageCode,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _LevelActionBadge(
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    color: color,
                    iconColor: statusColor,
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

class _LevelNumberBadge extends StatelessWidget {
  const _LevelNumberBadge({
    required this.index,
    required this.isCompleted,
    required this.isUnlocked,
    required this.color,
    required this.iconColor,
  });

  final int index;
  final bool isCompleted;
  final bool isUnlocked;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUnlocked
            ? color.withValues(alpha: 0.2)
            : AppColors.softLilac.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.52)
              : AppColors.softLilac.withValues(alpha: 0.32),
          width: 2,
        ),
      ),
      child: isCompleted
          ? Icon(Icons.check_rounded, color: iconColor, size: 30)
          : Text(
              '${index + 1}',
              style: AppTypography.sectionTitle.copyWith(
                color: isUnlocked ? iconColor : AppColors.purpleTextLight,
                fontSize: 23,
              ),
            ),
    );
  }
}

class _LevelMetaRow extends StatelessWidget {
  const _LevelMetaRow({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    required this.languageCode,
    required this.color,
  });

  final LevelConfig level;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final String languageCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _LevelChip(
          icon: _levelTypeIcon(level),
          label: _levelTypeLabel(level, languageCode),
          color: color,
        ),
        _LevelChip(
          icon: Icons.help_outline_rounded,
          label: languageCode == 'ca-ES'
              ? '${level.questionsToComplete} preguntes'
              : '${level.questionsToComplete} preguntas',
          color: AppColors.skyBlue,
        ),
        if (isCompleted)
          _StarsInline(stars: stars)
        else
          _LevelChip(
            icon: isUnlocked ? Icons.flag_rounded : Icons.lock_rounded,
            label: _levelStateLabel(languageCode, isUnlocked),
            color: AppColors.softLilac,
          ),
      ],
    );
  }
}

String _levelStateLabel(String languageCode, bool isUnlocked) {
  if (languageCode == 'ca-ES') {
    return isUnlocked ? 'Per completar' : 'Bloquejat';
  }

  return isUnlocked ? 'Por completar' : 'Bloqueado';
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = HSLColor.fromColor(color).withLightness(0.34).toColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsInline extends StatelessWidget {
  const _StarsInline({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 1; index <= 3; index++)
          Icon(
            index <= stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: index <= stars
                ? AppColors.starGold
                : AppColors.purpleTextLight.withValues(alpha: 0.42),
            size: 18,
          ),
      ],
    );
  }
}

class _LevelActionBadge extends StatelessWidget {
  const _LevelActionBadge({
    required this.isUnlocked,
    required this.isCompleted,
    required this.color,
    required this.iconColor,
  });

  final bool isUnlocked;
  final bool isCompleted;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final icon = !isUnlocked
        ? Icons.lock_rounded
        : isCompleted
            ? Icons.replay_rounded
            : Icons.play_arrow_rounded;

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUnlocked
            ? color.withValues(alpha: 0.18)
            : AppColors.softLilac.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }
}

IconData _levelTypeIcon(LevelConfig level) {
  if (level.exerciseTypes.length > 1) {
    return Icons.auto_awesome_rounded;
  }

  final type = level.exerciseTypes.isEmpty ? '' : level.exerciseTypes.first;
  return switch (type) {
    'count' => Icons.format_list_numbered_rounded,
    'addition' => Icons.add_rounded,
    'subtraction' => Icons.remove_rounded,
    'decomposition' => Icons.apps_rounded,
    _ => Icons.school_rounded,
  };
}

String _levelTypeLabel(LevelConfig level, String languageCode) {
  final isCatalan = languageCode == 'ca-ES';
  if (level.exerciseTypes.length > 1) {
    return isCatalan ? 'Mixt' : 'Mixto';
  }

  final type = level.exerciseTypes.isEmpty ? '' : level.exerciseTypes.first;
  return switch (type) {
    'count' => isCatalan ? 'Comptar' : 'Contar',
    'addition' => isCatalan ? 'Sumar' : 'Sumar',
    'subtraction' => isCatalan ? 'Restar' : 'Restar',
    'decomposition' => isCatalan ? 'Descompondre' : 'Descomponer',
    _ => isCatalan ? 'Repte' : 'Reto',
  };
}

String _worldsTitle(String languageCode) {
  return languageCode == 'ca-ES' ? 'Mons màgics' : 'Mundos mágicos';
}

String _worldsSubtitle(String languageCode) {
  return languageCode == 'ca-ES'
      ? 'Tria un món per veure els seus nivells.'
      : 'Elige un mundo para ver sus niveles.';
}

String _backTooltip(String languageCode) {
  return languageCode == 'ca-ES' ? 'Tornar' : 'Volver';
}

String _levelCountLabel(String languageCode, int levelCount) {
  if (languageCode == 'ca-ES') {
    return levelCount == 1 ? '1 nivell' : '$levelCount nivells';
  }

  return levelCount == 1 ? '1 nivel' : '$levelCount niveles';
}

String _worldCardStatusLabel(
  String languageCode, {
  required bool isAvailable,
  required bool isUnlocked,
  required int levelCount,
}) {
  if (!isAvailable) {
    return _comingSoonLabel(languageCode);
  }

  if (!isUnlocked) {
    return languageCode == 'ca-ES' ? 'Bloquejat' : 'Bloqueado';
  }

  return _levelCountLabel(languageCode, levelCount);
}

String _comingSoonLabel(String languageCode) {
  return languageCode == 'ca-ES' ? 'Properament' : 'Próximamente';
}

class AppActionColors {
  const AppActionColors._();

  static const values = [
    AppColors.magicPink,
    AppColors.softLilac,
    AppColors.skyBlue,
    AppColors.softMint,
    AppColors.starGold,
    AppColors.magicPink,
  ];

  static Color forIndex(int index) => values[index % values.length];
}

class _LoadingMap extends StatelessWidget {
  const _LoadingMap();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _MapError extends StatelessWidget {
  const _MapError({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        languageCode == 'ca-ES'
            ? "No s'ha pogut carregar el mapa."
            : 'No se pudo cargar el mapa.',
      ),
    );
  }
}
