abstract class HintGenerator {
  String hintFor(String exerciseId);
}

class SimpleHintGenerator implements HintGenerator {
  @override
  String hintFor(String exerciseId) {
    return 'Cuenta las estrellas una a una.';
  }
}
