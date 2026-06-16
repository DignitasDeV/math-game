abstract class OptionGenerator {
  List<int> optionsFor({
    required int answer,
    required int min,
    required int max,
    int count = 4,
  });
}

class NearbyOptionGenerator implements OptionGenerator {
  @override
  List<int> optionsFor({
    required int answer,
    required int min,
    required int max,
    int count = 4,
  }) {
    final values = <int>{answer};
    var distance = 1;

    while (values.length < count && distance <= max - min + count) {
      final lower = answer - distance;
      if (lower >= min) {
        values.add(lower);
      }

      if (values.length >= count) {
        break;
      }

      final upper = answer + distance;
      if (upper <= max) {
        values.add(upper);
      }

      distance++;
    }

    var fallback = min;
    while (values.length < count && fallback <= max) {
      values.add(fallback);
      fallback++;
    }

    return values.toList()..sort();
  }
}
