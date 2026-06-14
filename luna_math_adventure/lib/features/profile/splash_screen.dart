import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_typography.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 96),
              const SizedBox(height: 24),
              const Text(
                'Luna Math Adventure',
                textAlign: TextAlign.center,
                style: AppTypography.title,
              ).animate().fadeIn().slideY(begin: 0.15),
              const SizedBox(height: 12),
              const Text(
                'Matematicas con magia, pistas y recompensas.',
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/language'),
                child: const Text('Empezar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
