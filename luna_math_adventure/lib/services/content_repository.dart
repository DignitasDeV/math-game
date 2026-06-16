import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/level_config.dart';
import '../models/exercise_template.dart';
import '../models/help_topic.dart';
import '../models/reward.dart';
import '../models/visual_item.dart';
import '../models/world.dart';

abstract class ContentRepository {
  Future<List<World>> loadWorlds();
  Future<List<LevelConfig>> loadLevels();
  Future<LevelConfig?> loadLevel(String levelId);
  Future<List<ExerciseTemplate>> loadExerciseTemplates();
  Future<List<HelpTopic>> loadHelpTopics();
  Future<List<VisualItem>> loadVisualItems();
  Future<List<Reward>> loadRewards();
}

class AssetContentRepository implements ContentRepository {
  @override
  Future<List<World>> loadWorlds() async {
    final value = await rootBundle.loadString('assets/data/worlds.json');
    final json = jsonDecode(value) as List;
    final worlds = json
        .map((item) => World.fromJson(Map<String, Object?>.from(item as Map)))
        .toList();
    worlds.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return worlds;
  }

  @override
  Future<List<LevelConfig>> loadLevels() async {
    final value = await rootBundle.loadString('assets/data/levels.json');
    final json = jsonDecode(value) as List;
    final levels = json
        .map(
          (item) => LevelConfig.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .toList();
    levels.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return levels;
  }

  @override
  Future<LevelConfig?> loadLevel(String levelId) async {
    final levels = await loadLevels();
    for (final level in levels) {
      if (level.id == levelId) {
        return level;
      }
    }

    return null;
  }

  @override
  Future<List<ExerciseTemplate>> loadExerciseTemplates() async {
    final value = await rootBundle.loadString(
      'assets/data/exercise_templates.json',
    );
    final json = jsonDecode(value) as List;
    return json
        .map(
          (item) => ExerciseTemplate.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<HelpTopic>> loadHelpTopics() async {
    final value = await rootBundle.loadString('assets/data/help_topics.json');
    final json = jsonDecode(value) as List;
    final topics = json
        .map(
          (item) => HelpTopic.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .where((topic) => topic.id.isNotEmpty)
        .toList();
    topics.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return topics;
  }

  @override
  Future<List<VisualItem>> loadVisualItems() async {
    final value = await rootBundle.loadString('assets/data/visual_items.json');
    final json = jsonDecode(value) as List;
    return json
        .map(
          (item) => VisualItem.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<Reward>> loadRewards() async {
    final value = await rootBundle.loadString('assets/data/rewards.json');
    final json = jsonDecode(value) as List;
    return json
        .map(
          (item) => Reward.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .toList();
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return AssetContentRepository();
});

final worldsProvider = FutureProvider<List<World>>((ref) {
  return ref.watch(contentRepositoryProvider).loadWorlds();
});

final levelsProvider = FutureProvider<List<LevelConfig>>((ref) {
  return ref.watch(contentRepositoryProvider).loadLevels();
});

final helpTopicsProvider = FutureProvider<List<HelpTopic>>((ref) {
  return ref.watch(contentRepositoryProvider).loadHelpTopics();
});

final rewardsProvider = FutureProvider<List<Reward>>((ref) {
  return ref.watch(contentRepositoryProvider).loadRewards();
});
