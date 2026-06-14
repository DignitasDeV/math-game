import '../../core/widgets/placeholder_page.dart';

class SettingsScreen extends PlaceholderPage {
  const SettingsScreen({super.key})
      : super(
          title: 'Ajustes',
          message: 'Idioma, voz, volumen y preferencias familiares.',
          primaryLabel: 'Inicio',
          primaryRoute: '/home',
        );
}
