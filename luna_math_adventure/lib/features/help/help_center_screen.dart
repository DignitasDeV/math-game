import '../../core/widgets/placeholder_page.dart';

class HelpCenterScreen extends PlaceholderPage {
  const HelpCenterScreen({super.key})
      : super(
          title: 'Ayuda',
          message: 'Centro de pistas visuales y explicaciones habladas.',
          primaryLabel: 'Inicio',
          primaryRoute: '/home',
        );
}
