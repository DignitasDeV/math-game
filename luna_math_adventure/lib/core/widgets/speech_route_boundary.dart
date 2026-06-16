import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/speech_playback_controller.dart';

class SpeechRouteBoundary extends ConsumerStatefulWidget {
  const SpeechRouteBoundary({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<SpeechRouteBoundary> createState() =>
      _SpeechRouteBoundaryState();
}

class _SpeechRouteBoundaryState extends ConsumerState<SpeechRouteBoundary> {
  @override
  void dispose() {
    unawaited(ref.read(speechPlaybackControllerProvider.notifier).stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
