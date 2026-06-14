import '../../core/widgets/placeholder_page.dart';

class LanguageSelectionScreen extends PlaceholderPage {
  const LanguageSelectionScreen({super.key})
      : super(
          title: 'Idioma',
          message: 'Seleccion inicial entre espanol y catala.',
          primaryLabel: 'Continuar',
          primaryRoute: '/child-name',
        );
}
