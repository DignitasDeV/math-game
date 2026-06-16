import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../services/audio_service.dart';
import '../../services/profile_controller.dart';
import '../../services/profile_repository.dart';

class UnicornNameScreen extends ConsumerStatefulWidget {
  const UnicornNameScreen({super.key});

  @override
  ConsumerState<UnicornNameScreen> createState() => _UnicornNameScreenState();
}

class _UnicornNameScreenState extends ConsumerState<UnicornNameScreen> {
  late final TextEditingController _controller;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    _controller = TextEditingController(text: draft.unicornName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Nombre mágico',
      backgroundAssetPath: 'assets/images/backgrounds/home_background_screen.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppScreenHeader(
            icon: Symbols.auto_awesome_rounded,
            title: 'Nombre del personaje',
            subtitle: 'Ponle el nombre que quieras.',
          ),
          const Spacer(),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.input,
            decoration: InputDecoration(
              labelText: 'Nombre mágico',
              prefixIcon: const Icon(Symbols.pets_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : () => playTapAndRun(context, _save),
              icon: Icon(
                _isSaving
                    ? Symbols.hourglass_top_rounded
                    : Symbols.rocket_launch_rounded,
              ),
              label: Text(_isSaving ? 'Guardando...' : 'Empezar aventura'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final unicornName = _controller.text.trim();
    if (unicornName.isEmpty || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    final draftController = ref.read(onboardingDraftProvider.notifier);
    draftController.setUnicornName(unicornName);
    final profile = draftController.buildProfile();
    final wasAdded =
        await ref.read(profileControllerProvider.notifier).addProfile(profile);

    if (mounted) {
      context.go(wasAdded ? '/home' : '/profiles');
    }
  }
}
