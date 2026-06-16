import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../services/audio_service.dart';
import '../../services/profile_repository.dart';

class ChildNameScreen extends ConsumerStatefulWidget {
  const ChildNameScreen({super.key});

  @override
  ConsumerState<ChildNameScreen> createState() => _ChildNameScreenState();
}

class _ChildNameScreenState extends ConsumerState<ChildNameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: 'Nombre',
      backgroundAssetPath: 'assets/images/backgrounds/home_background_screen.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppScreenHeader(
            icon: Symbols.face_rounded,
            title: '¿Cómo te llamas?',
            subtitle: 'Usaremos tu nombre para hacer la aventura más personal.',
          ),
          const Spacer(),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.input,
            decoration: InputDecoration(
              labelText: 'Tu nombre',
              prefixIcon: const Icon(Symbols.face_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onSubmitted: (_) => _continue(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () => playTapAndRun(context, _continue),
              icon: const Icon(Symbols.arrow_forward_rounded),
              label: const Text('Elegir avatar'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _continue() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }

    ref.read(onboardingDraftProvider.notifier).setChildName(name);
    context.go('/unicorn-avatar');
  }
}
