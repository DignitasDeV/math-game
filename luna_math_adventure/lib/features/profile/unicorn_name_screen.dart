import '../../core/widgets/placeholder_page.dart';

class UnicornNameScreen extends PlaceholderPage {
  const UnicornNameScreen({super.key})
      : super(
          title: 'Nombre magico',
          message: 'Aqui se nombrara al companero magico de la aventura.',
          primaryLabel: 'Ir a casa',
          primaryRoute: '/home',
        );
}
