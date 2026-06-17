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
import '../../services/ui_copy.dart';

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
    final languageCode = ref.watch(onboardingDraftProvider).language.ttsCode;

    return MagicScaffold(
      title: UiCopy.text(languageCode, es: 'Nombre', ca: 'Nom'),
      backgroundAssetPath:
          'assets/images/backgrounds/home_background_screen.webp',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppScreenHeader(
            icon: Symbols.face_rounded,
            title: UiCopy.text(
              languageCode,
              es: '¿Cómo te llamas?',
              ca: 'Com et dius?',
            ),
            subtitle: UiCopy.text(
              languageCode,
              es: 'Usaremos tu nombre para hacer la aventura más personal.',
              ca: "Farem servir el teu nom per fer l'aventura més personal.",
            ),
          ),
          const Spacer(),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.input,
            decoration: InputDecoration(
              labelText: UiCopy.text(
                languageCode,
                es: 'Tu nombre',
                ca: 'El teu nom',
              ),
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
              label: Text(UiCopy.text(
                languageCode,
                es: 'Elegir avatar',
                ca: 'Triar avatar',
              )),
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
