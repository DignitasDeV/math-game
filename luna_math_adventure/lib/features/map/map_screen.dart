import '../../core/widgets/placeholder_page.dart';

class MapScreen extends PlaceholderPage {
  const MapScreen({super.key})
      : super(
          title: 'Mapa',
          message: 'Mapa de mundos y niveles desbloqueados.',
          primaryLabel: 'Probar ejercicio',
          primaryRoute: '/game',
        );
}
