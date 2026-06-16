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
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
import '../../services/profile_repository.dart';
import '../../services/unicorn_avatar_asset_resolver.dart';

class ProfileSelectionScreen extends ConsumerWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(profileControllerProvider);

    return MagicScaffold(
      title: 'Perfiles',
      backgroundAssetPath: 'assets/images/backgrounds/home_background_screen.webp',
      showBackButton: false,
      child: familyState.when(
        data: (family) {
          if (!family.hasProfiles) {
            return _EmptyProfiles(
              onCreate: () => _createProfile(context, ref),
            );
          }

          final canAddProfile = family.profiles.length < maxFamilyProfiles;
          final itemCount = family.profiles.length + (canAddProfile ? 1 : 0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                title: 'Quien va a jugar?',
                subtitle: canAddProfile
                    ? 'Elige un perfil o manten pulsado para editar.'
                    : 'Ya hay 8 perfiles. Manten pulsado para editar.',
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _profileColumns(constraints.maxWidth);
                    final avatarSize = _avatarSize(
                      width: constraints.maxWidth,
                      columns: columns,
                    );

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: itemCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.xl,
                        crossAxisSpacing: AppSpacing.lg,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        if (index >= family.profiles.length) {
                          return _AddProfileTile(
                            avatarSize: avatarSize,
                            onTap: () => _createProfile(context, ref),
                          );
                        }

                        final profile = family.profiles[index];
                        return _ProfileAvatarTile(
                          profile: profile,
                          avatarSize: avatarSize,
                          isActive: profile.id == family.activeProfileId,
                          onTap: () => _selectProfile(context, ref, profile),
                          onLongPress: () =>
                              _showProfileOptions(context, ref, profile),
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
            child: const Text('Reintentar'),
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
    await ref.read(profileControllerProvider.notifier).selectProfile(profile.id);
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
                  label: 'Editar nombre',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _editProfileName(context, ref, profile);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileOptionButton(
                  icon: Symbols.auto_awesome_rounded,
                  label: 'Cambiar avatar',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _editProfileAvatar(context, ref, profile);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileOptionButton(
                  icon: Symbols.delete_rounded,
                  label: 'Eliminar perfil',
                  color: AppColors.gentleError,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDeleteProfile(context, ref, profile);
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
  ) async {
    final controller = TextEditingController(text: profile.childName);
    final name = await showDialog<String>(
      context: context,
      animationStyle: AppMotion.dialog,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar nombre'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Nombre del perfil'),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text.trim(),
              ),
              child: const Text('Guardar'),
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

  Future<void> _editProfileAvatar(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
  ) async {
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
                    const Expanded(
                      child: Text(
                        'Cambiar avatar',
                        style: AppTypography.sectionTitle,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Symbols.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 600 ? 3 : 2;
                      final rows =
                          (UnicornAvatar.values.length + columns - 1) ~/
                              columns;
                      final cellWidth =
                          (constraints.maxWidth -
                              AppSpacing.md * (columns - 1)) /
                          columns;
                      final cellHeight =
                          (constraints.maxHeight -
                              AppSpacing.md * (rows - 1)) /
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
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      animationStyle: AppMotion.dialog,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar perfil'),
          content: Text(
            'Quieres eliminar el perfil de ${profile.childName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await ref.read(profileControllerProvider.notifier).deleteProfile(profile.id);
  }
}

class _EmptyProfiles extends StatelessWidget {
  const _EmptyProfiles({required this.onCreate});

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
        const Text(
          'Crea el primer perfil',
          textAlign: TextAlign.center,
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Cada nina o nino tendra su propia aventura y progreso.',
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
        const Spacer(),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: () => playTapAndRun(context, onCreate),
            icon: const Icon(Symbols.person_add_rounded),
            label: const Text('Crear perfil'),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatarTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = profile.unicornAvatar.accentColor;
    final borderColor = isActive ? AppColors.pinkAccent : Colors.white;
    final shadowColor = color.withValues(alpha: isActive ? 0.38 : 0.22);

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
    required this.isSelected,
    required this.onTap,
  });

  final UnicornAvatar avatar;
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
    required this.onTap,
  });

  final double avatarSize;
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
                'Anadir perfil',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 2),
              Text(
                'Hasta 8',
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
  if (width >= 500) {
    return 3;
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
