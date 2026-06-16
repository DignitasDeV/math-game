import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/responsive_action_grid.dart';
import '../../core/widgets/unicorn_avatar_image.dart';
import '../../models/unicorn_avatar.dart';
import '../../services/audio_service.dart';
import '../../services/profile_repository.dart';
import '../../services/unicorn_avatar_asset_resolver.dart';

class UnicornAvatarScreen extends ConsumerWidget {
  const UnicornAvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MagicScaffold(
      title: 'Avatar',
      backgroundAssetPath: 'assets/images/backgrounds/home_background_screen.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppScreenHeader(
            icon: Symbols.auto_awesome_rounded,
            title: 'Elige tu avatar',
            subtitle: 'Elige el aspecto del personaje. Despues le pondras nombre.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ResponsiveActionGrid(
              children: [
                for (final avatar in UnicornAvatar.values)
                  _AvatarButton(
                    avatar: avatar,
                    onPressed: () => _select(context, ref, avatar),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, UnicornAvatar avatar) {
    ref.read(onboardingDraftProvider.notifier).setUnicornAvatar(avatar);
    context.go('/unicorn-name');
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.avatar,
    required this.onPressed,
  });

  final UnicornAvatar avatar;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = avatar.accentColor;
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();

    return Material(
      color: color.withValues(alpha: 0.17),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playTapAndRun(context, onPressed),
        splashColor: color.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: UnicornAvatarImage(
              avatar: avatar,
              emotion: UnicornAvatarEmotion.idle,
              fallback: Icon(
                Symbols.auto_awesome_rounded,
                size: 44,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
