import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_typography.dart';
import '../../core/widgets/magic_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = <({IconData icon, String label, String route})>[
      (icon: Icons.map, label: 'Mapa', route: '/map'),
      (icon: Icons.calculate, label: 'Juego', route: '/game'),
      (icon: Icons.school, label: 'Practica', route: '/practice'),
      (icon: Icons.card_giftcard, label: 'Premios', route: '/rewards'),
      (icon: Icons.help, label: 'Ayuda', route: '/help'),
      (icon: Icons.settings, label: 'Ajustes', route: '/settings'),
    ];

    return MagicScaffold(
      title: 'Inicio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Elige una puerta magica', style: AppTypography.title),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                for (final item in destinations)
                  FilledButton.tonalIcon(
                    onPressed: () => context.go(item.route),
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
