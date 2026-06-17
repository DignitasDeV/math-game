import 'dart:math';

import '../models/level_config.dart';
import '../models/operation_candidate.dart';
import 'exercise_pool_generator.dart';

class ExerciseSessionPlanner {
  ExerciseSessionPlanner({
    required this.level,
    Random? random,
    ExercisePoolGenerator poolGenerator = const ExercisePoolGenerator(),
    int recentLimit = 10,
    int recentResultLimit = 4,
  })  : _random = random ?? Random(),
        _poolGenerator = poolGenerator,
        _recentLimit = recentLimit,
        _recentResultLimit = recentResultLimit {
    reset();
  }

  final LevelConfig level;
  final Random _random;
  final ExercisePoolGenerator _poolGenerator;
  final int _recentLimit;
  final int _recentResultLimit;

  final _recentKeys = <String>[];
  final _recentResults = <int>[];
  final _typeCycle = <String>[];
  var _typeCursor = 0;
  var _pool = <OperationCandidate>[];

  void reset() {
    _recentKeys.clear();
    _recentResults.clear();
    _typeCursor = 0;
    _resetTypeCycle();
    _pool = _createShuffledPool();
  }

  OperationCandidate next() {
    if (_pool.isEmpty) {
      _pool = _createShuffledPool();
    }

    final index = _nextCandidateIndex();
    final candidate = _pool.removeAt(index);
    _markRecent(candidate);
    return candidate;
  }

  List<OperationCandidate> _createShuffledPool() {
    final pool = _poolGenerator.generate(level);
    if (pool.isEmpty) {
      throw StateError('No exercise candidates for level ${level.id}.');
    }

    pool.shuffle(_random);
    return pool;
  }

  void _resetTypeCycle() {
    _typeCycle
      ..clear()
      ..addAll(level.exerciseTypes.toSet());
    _typeCycle.shuffle(_random);
  }

  int _nextCandidateIndex() {
    var index = _candidateIndex(avoidRecent: true);
    if (index != -1) {
      return index;
    }

    _recentKeys.clear();
    index = _candidateIndex(avoidRecent: false);
    if (index != -1) {
      return index;
    }

    throw StateError('No exercise candidates available for level ${level.id}.');
  }

  int _candidateIndex({required bool avoidRecent}) {
    final preferredType = _preferredType(avoidRecent: avoidRecent);
    if (preferredType != null) {
      final preferredIndex = _bestCandidateIndex(
        _candidateIndexes(
          type: preferredType,
          avoidRecent: avoidRecent,
        ),
      );
      if (preferredIndex != -1) {
        return preferredIndex;
      }
    }

    return _bestCandidateIndex(
      _candidateIndexes(avoidRecent: avoidRecent),
    );
  }

  List<int> _candidateIndexes({
    String? type,
    required bool avoidRecent,
  }) {
    final indexes = <int>[];
    for (var index = 0; index < _pool.length; index++) {
      final candidate = _pool[index];
      if (type != null && candidate.type != type) {
        continue;
      }
      if (avoidRecent && _recentKeys.contains(candidate.key)) {
        continue;
      }

      indexes.add(index);
    }

    return indexes;
  }

  int _bestCandidateIndex(List<int> indexes) {
    if (indexes.isEmpty) {
      return -1;
    }

    return indexes.reduce((bestIndex, candidateIndex) {
      final best = _pool[bestIndex];
      final candidate = _pool[candidateIndex];
      final bestScore = _candidateScore(best);
      final candidateScore = _candidateScore(candidate);
      return candidateScore > bestScore ? candidateIndex : bestIndex;
    });
  }

  int _candidateScore(OperationCandidate candidate) {
    var score = 0;

    if (candidate.result != 0) {
      score += 4;
    }
    if (!_recentResults.contains(candidate.result)) {
      score += 2;
    }

    return score;
  }

  String? _preferredType({required bool avoidRecent}) {
    if (_typeCycle.length <= 1) {
      return null;
    }

    for (var attempt = 0; attempt < _typeCycle.length; attempt++) {
      final type = _typeCycle[_typeCursor % _typeCycle.length];
      _typeCursor++;
      final hasCandidate = _pool.any(
        (candidate) =>
            candidate.type == type &&
            (!avoidRecent || !_recentKeys.contains(candidate.key)),
      );
      if (hasCandidate) {
        return type;
      }
    }

    return null;
  }

  void _markRecent(OperationCandidate candidate) {
    if (_recentLimit > 0) {
      _recentKeys.add(candidate.key);
      if (_recentKeys.length > _recentLimit) {
        _recentKeys.removeAt(0);
      }
    }

    if (_recentResultLimit > 0) {
      _recentResults.add(candidate.result);
      if (_recentResults.length > _recentResultLimit) {
        _recentResults.removeAt(0);
      }
    }
  }
}
