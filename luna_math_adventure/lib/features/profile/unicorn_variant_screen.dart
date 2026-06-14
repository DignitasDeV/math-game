import '../../core/widgets/placeholder_page.dart';

class UnicornVariantScreen extends PlaceholderPage {
  const UnicornVariantScreen({super.key})
      : super(
          title: 'Unicornio o unicornia',
          message: 'Pantalla placeholder para elegir variante visual y genero narrativo.',
          primaryLabel: 'Poner nombre',
          primaryRoute: '/unicorn-name',
        );
}
