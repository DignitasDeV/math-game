abstract class OptionGenerator {
  List<int> optionsFor({required int answer, required int min, required int max});
}

class NearbyOptionGenerator implements OptionGenerator {
  @override
  List<int> optionsFor({required int answer, required int min, required int max}) {
    final values = <int>{
      answer,
      (answer - 1).clamp(min, max).toInt(),
      (answer + 1).clamp(min, max).toInt(),
    };
    return values.toList()..sort();
  }
}
