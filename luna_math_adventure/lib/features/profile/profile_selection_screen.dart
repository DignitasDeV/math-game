import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/unicorn_avatar_image.dart';
import '../../models/player_profile.dart';
import '../../models/unicorn_avatar.dart';
import '../../models/unicorn_avatar_stage.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
import '../../services/profile_repository.dart';
import '../../services/progress_repository.dart';
import '../../services/ui_copy.dart';
import '../../services/unicorn_avatar_asset_resolver.dart';

class ProfileSelectionScreen extends ConsumerWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(profileControllerProvider);
    final languageCode =
        ref.watch(activeProfileProvider)?.language.ttsCode ?? 'es-ES';

    return MagicScaffold(
      title: UiCopy.text(languageCode, es: 'Perfiles', ca: 'Perfils'),
      backgroundAssetPath:
          'assets/images/backgrounds/home_background_screen.webp',
      showBackButton: false,
      child: familyState.when(
        data: (family) {
          if (!family.hasProfiles) {
            return _EmptyProfiles(
              languageCode: languageCode,
              onCreate: () => _createProfile(context, ref),
            );
          }

          final canAddProfile = family.profiles.length < maxFamilyProfiles;
          final itemCount = family.profiles.length + (canAddProfile ? 1 : 0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                title: UiCopy.text(
                  languageCode,
                  es: '¿Quién va a jugar?',
                  ca: 'Qui jugarà?',
                ),
                subtitle: canAddProfile
                    ? UiCopy.text(
                        languageCode,
                        es: 'Elige un perfil o mantén pulsado para editar.',
                        ca: 'Tria un perfil o mantén premut per editar.',
                      )
                    : UiCopy.text(
                        languageCode,
                        es: 'Ya hay 8 perfiles. Mantén pulsado para editar.',
                        ca: 'Ja hi ha 8 perfils. Mantén premut per editar.',
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _profileColumns(constraints.maxWidth);
                    final isNarrow =
                        constraints.maxWidth < AppBreakpoints.narrowWidth;
                    final avatarSize = _avatarSize(
                      width: constraints.maxWidth,
                      columns: columns,
                    );
                    final childAspectRatio =
                        isNarrow ? (columns == 1 ? 1.18 : 0.82) : 0.72;

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: itemCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing:
                            isNarrow ? AppSpacing.md : AppSpacing.xl,
                        crossAxisSpacing:
                            isNarrow ? AppSpacing.md : AppSpacing.lg,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        if (index >= family.profiles.length) {
                          return _AddProfileTile(
                            avatarSize: avatarSize,
                            languageCode: languageCode,
                            onTap: () => _createProfile(context, ref),
                          );
                        }

                        final profile = family.profiles[index];
                        return _ProfileAvatarTile(
                          profile: profile,
                          avatarSize: avatarSize,
                          isActive: profile.id == family.activeProfileId,
                          onTap: () => _selectProfile(context, ref, profile),
                          onLongPress: () => _showProfileOptions(
                            context,
                            ref,
                            profile,
                            languageCode,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () => playTapAndRun(
              context,
              () => ref.invalidate(profileControllerProvider),
            ),
            child: Text(UiCopy.retry(languageCode)),
          ),
        ),
      ),
    );
  }

  Future<void> _selectProfile(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
  ) async {
    await ref
        .read(profileControllerProvider.notifier)
        .selectProfile(profile.id);
    if (context.mounted) {
      context.go('/home');
    }
  }

  void _createProfile(BuildContext context, WidgetRef ref) {
    final family = ref.read(profileControllerProvider).valueOrNull;
    if (family != null && family.profiles.length >= maxFamilyProfiles) {
      return;
    }

    ref.read(onboardingDraftProvider.notifier).reset();
    context.go('/language');
  }

  Future<void> _showProfileOptions(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    String languageCode,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.bottomSheet,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  profile.childName,
                  textAlign: TextAlign.center,
                  style: AppTypography.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                _ProfileOptionButton(
                  icon: Symbols.edit_rounded,
                  label: UiCopy.text(
                    languageCode,
                    es: 'Editar nombre',
                    ca: 'Editar nom',
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _editProfileName(context, ref, profile, languageCode);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileOptionButton(
                  icon: Symbols.favorite_rounded,
                  label: UiCopy.text(
                    languageCode,
                    es: 'Editar nombre del unicornio',
                    ca: "Editar nom de l'unicorn",
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _editUnicornName(context, ref, profile, languageCode);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileOptionButton(
                  icon: Symbols.auto_awesome_rounded,
                  label: UiCopy.text(
                    languageCode,
                    es: 'Cambiar avatar',
                    ca: 'Canviar avatar',
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _editProfileAvatar(context, ref, profile, languageCode);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileOptionButton(
                  icon: Symbols.delete_rounded,
                  label: UiCopy.text(
                    languageCode,
                    es: 'Eliminar perfil',
                    ca: 'Eliminar perfil',
                  ),
                  color: AppColors.gentleError,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDeleteProfile(context, ref, profile, languageCode);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfileName(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    String languageCode,
  ) async {
    final controller = TextEditingController(text: profile.childName);
    final name = await showDialog<String>(
      context: context,
      animationStyle: AppMotion.dialog,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(UiCopy.text(
            languageCode,
            es: 'Editar nombre',
            ca: 'Editar nom',
          )),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: UiCopy.text(
                languageCode,
                es: 'Nombre del perfil',
                ca: 'Nom del perfil',
              ),
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(UiCopy.text(
                languageCode,
                es: 'Cancelar',
                ca: 'Cancel·lar',
              )),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text.trim(),
              ),
              child: Text(UiCopy.text(
                languageCode,
                es: 'Guardar',
                ca: 'Desar',
              )),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (name == null || name.isEmpty) {
      return;
    }

    await ref.read(profileControllerProvider.notifier).updateProfile(
          profile.copyWith(childName: name),
        );
  }

  Future<void> _editUnicornName(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    String languageCode,
  ) async {
    final controller = TextEditingController(text: profile.unicornName);
    final unicornName = await showDialog<String>(
      context: context,
      animationStyle: AppMotion.dialog,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(UiCopy.text(
            languageCode,
            es: 'Editar unicornio',
            ca: "Editar l'unicorn",
          )),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: UiCopy.text(
                languageCode,
                es: 'Nombre del unicornio',
                ca: "Nom de l'unicorn",
              ),
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(UiCopy.text(
                languageCode,
                es: 'Cancelar',
                ca: 'Cancel·lar',
              )),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text.trim(),
              ),
              child: Text(UiCopy.text(
                languageCode,
                es: 'Guardar',
                ca: 'Desar',
              )),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (unicornName == null || unicornName.isEmpty) {
      return;
    }

    await ref.read(profileControllerProvider.notifier).updateProfile(
          profile.copyWith(unicornName: unicornName),
        );
  }

  Future<void> _editProfileAvatar(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    String languageCode,
  ) async {
    final unicornStage = await ref
        .read(profileProgressProvider(profile.id).future)
        .then((progress) => progress.unlockedUnicornStage);
    if (!context.mounted) {
      return;
    }

    final avatar = await showModalBottomSheet<UnicornAvatar>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      sheetAnimationStyle: AppMotion.bottomSheet,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        UiCopy.text(
                          languageCode,
                          es: 'Cambiar avatar',
                          ca: 'Canviar avatar',
                        ),
                        style: AppTypography.sectionTitle,
                      ),
                    ),
                    IconButton(
                      tooltip: UiCopy.text(
                        languageCode,
                        es: 'Cerrar',
                        ca: 'Tancar',
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Symbols.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 600
                          ? 3
                          : constraints.maxWidth < 340
                              ? 1
                              : 2;
                      final rows =
                          (UnicornAvatar.values.length + columns - 1) ~/
                              columns;
                      final cellWidth = (constraints.maxWidth -
                              AppSpacing.md * (columns - 1)) /
                          columns;
                      final cellHeight =
                          (constraints.maxHeight - AppSpacing.md * (rows - 1)) /
                              rows;

                      return GridView.count(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: cellWidth / cellHeight,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final avatar in UnicornAvatar.values)
                            _AvatarChoiceTile(
                              avatar: avatar,
                              stage: unicornStage,
                              isSelected: avatar == profile.unicornAvatar,
                              onTap: () =>
                                  Navigator.of(sheetContext).pop(avatar),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (avatar == null) {
      return;
    }

    await ref.read(profileControllerProvider.notifier).updateProfile(
          profile.copyWith(unicornAvatar: avatar),
        );
  }

  Future<void> _confirmDeleteProfile(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    String languageCode,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      animationStyle: AppMotion.dialog,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(UiCopy.text(
            languageCode,
            es: 'Eliminar perfil',
            ca: 'Eliminar perfil',
          )),
          content: Text(
            UiCopy.text(
              languageCode,
              es: '¿Quieres eliminar el perfil de ${profile.childName}?',
              ca: 'Vols eliminar el perfil de ${profile.childName}?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(UiCopy.text(
                languageCode,
                es: 'Cancelar',
                ca: 'Cancel·lar',
              )),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(UiCopy.text(
                languageCode,
                es: 'Eliminar',
                ca: 'Eliminar',
              )),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await ref
        .read(profileControllerProvider.notifier)
        .deleteProfile(profile.id);
  }
}

class _EmptyProfiles extends StatelessWidget {
  const _EmptyProfiles({
    required this.languageCode,
    required this.onCreate,
  });

  final String languageCode;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(
          Symbols.auto_awesome_rounded,
          size: 72,
          color: AppColors.lilacAccent,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          UiCopy.text(
            languageCode,
            es: 'Crea el primer perfil',
            ca: 'Crea el primer perfil',
          ),
          textAlign: TextAlign.center,
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          UiCopy.text(
            languageCode,
            es: 'Cada niña o niño tendrá su propia aventura y progreso.',
            ca: 'Cada nena o nen tindrà la seva aventura i el seu progrés.',
          ),
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
        const Spacer(),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: () => playTapAndRun(context, onCreate),
            icon: const Icon(Symbols.person_add_rounded),
            label: Text(UiCopy.text(
              languageCode,
              es: 'Crear perfil',
              ca: 'Crear perfil',
            )),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatarTile extends ConsumerWidget {
  const _ProfileAvatarTile({
    required this.profile,
    required this.avatarSize,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  final PlayerProfile profile;
  final double avatarSize;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = profile.unicornAvatar.accentColor;
    final borderColor = isActive ? AppColors.pinkAccent : Colors.white;
    final shadowColor = color.withValues(alpha: isActive ? 0.38 : 0.22);
    final unicornStage = ref
            .watch(profileProgressProvider(profile.id))
            .valueOrNull
            ?.unlockedUnicornStage ??
        UnicornAvatarStage.stage01;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => playTapAndRun(context, onTap),
        onLongPress: () => playTapAndRun(context, onLongPress),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ClipOval(
                    child: UnicornAvatarImage(
                      avatar: profile.unicornAvatar,
                      stage: unicornStage,
                      emotion: UnicornAvatarEmotion.idle,
                      fallback: Icon(
                        Symbols.auto_awesome_rounded,
                        size: avatarSize * 0.46,
                        color: HSLColor.fromColor(color)
                            .withLightness(0.35)
                            .toColor(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile.childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 2),
              Text(
                profile.unicornName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOptionButton extends StatelessWidget {
  const _ProfileOptionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.softLilac;
    final foregroundColor =
        HSLColor.fromColor(buttonColor).withLightness(0.35).toColor();

    return Material(
      color: buttonColor.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onPressed),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.cardTitle.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarChoiceTile extends StatelessWidget {
  const _AvatarChoiceTile({
    required this.avatar,
    required this.stage,
    required this.isSelected,
    required this.onTap,
  });

  final UnicornAvatar avatar;
  final UnicornAvatarStage stage;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = avatar.accentColor;
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();

    return Material(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onTap),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.pinkAccent : Colors.white,
                  width: 3,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: ClipOval(
                  child: UnicornAvatarImage(
                    avatar: avatar,
                    stage: stage,
                    emotion: UnicornAvatarEmotion.idle,
                    fallback: Icon(
                      Symbols.auto_awesome_rounded,
                      size: 38,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile({
    required this.avatarSize,
    required this.languageCode,
    required this.onTap,
  });

  final double avatarSize;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        HSLColor.fromColor(AppColors.skyBlue).withLightness(0.35).toColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => playTapAndRun(context, onTap),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.62),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.82),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.skyBlue.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Symbols.add_rounded,
                  size: avatarSize * 0.48,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                UiCopy.text(
                  languageCode,
                  es: 'Añadir perfil',
                  ca: 'Afegir perfil',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 2),
              Text(
                UiCopy.text(
                  languageCode,
                  es: 'Hasta 8',
                  ca: 'Fins a 8',
                ),
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _profileColumns(double width) {
  if (width >= 720) {
    return 4;
  }
  if (width >= AppBreakpoints.narrowWidth) {
    return 3;
  }
  if (width < 340) {
    return 1;
  }
  return 2;
}

double _avatarSize({
  required double width,
  required int columns,
}) {
  final available = width - AppSpacing.lg * (columns - 1);
  final cellWidth = available / columns;
  return cellWidth.clamp(92.0, 150.0).toDouble();
}
