import '../../core/widgets/placeholder_page.dart';

class ChildNameScreen extends PlaceholderPage {
  const ChildNameScreen({super.key})
      : super(
          title: 'Nombre',
          message: 'Aqui se guardara el nombre de la nina para personalizar la aventura.',
          primaryLabel: 'Elegir unicornio',
          primaryRoute: '/unicorn-variant',
        );
}
