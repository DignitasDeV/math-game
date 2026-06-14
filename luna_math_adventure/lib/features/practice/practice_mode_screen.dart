import '../../core/widgets/placeholder_page.dart';

class PracticeModeScreen extends PlaceholderPage {
  const PracticeModeScreen({super.key})
      : super(
          title: 'Practica libre',
          message: 'Modo para repetir conteo, sumas y restas sin presion.',
          primaryLabel: 'Inicio',
          primaryRoute: '/home',
        );
}
