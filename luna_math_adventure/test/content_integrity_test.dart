import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/models/app_language.dart';
import 'package:luna_math_adventure/models/exercise_template.dart';
import 'package:luna_math_adventure/models/help_topic.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/player_profile.dart';
import 'package:luna_math_adventure/models/reward.dart';
import 'package:luna_math_adventure/models/unicorn_avatar.dart';
import 'package:luna_math_adventure/models/visual_item.dart';
import 'package:luna_math_adventure/models/world.dart';
import 'package:luna_math_adventure/services/exercise_generator.dart';
import 'package:luna_math_adventure/services/exercise_pool_generator.dart';
import 'package:luna_math_adventure/services/exercise_session_planner.dart';

void main() {
  test('configured levels can generate full exercise sessions', () {
    final levels = _loadLevels();
    final templateTypes = _loadTemplates()
        .map((template) => template.type)
        .where((type) => type.isNotEmpty)
        .toSet();
    final visualItemIds = _loadVisualItems()
        .map((item) => item.id)
        .where((id) => id.isNotEmpty)
        .toSet();

    expect(levels, isNotEmpty);

    for (final level in levels) {
      expect(level.exerciseTypes, isNotEmpty, reason: level.id);
      expect(level.visualItemIds, isNotEmpty, reason: level.id);
      expect(
        level.visualItemIds.every(visualItemIds.contains),
        isTrue,
        reason: '${level.id} references unknown visual item ids.',
      );

      for (final type in level.exerciseTypes) {
        expect(
          templateTypes,
          contains(type),
          reason: '${level.id} has no template for "$type".',
        );
      }

      final planner = ExerciseSessionPlanner(
        level: level,
        random: Random(1),
      );
      final candidates = [
        for (var index = 0; index < level.questionsToComplete; index++)
          planner.next(),
      ];

      expect(candidates, hasLength(level.questionsToComplete),
          reason: level.id);
    }
  });

  test('exercise templates contain Spanish and Catalan text', () {
    final templates = _loadTemplates();

    expect(templates, isNotEmpty);

    for (final template in templates) {
      expect(template.id, isNotEmpty);
      expect(template.type, isNotEmpty, reason: template.id);
      expect(template.visiblePattern.es.trim(), isNotEmpty,
          reason: template.id);
      expect(template.visiblePattern.ca.trim(), isNotEmpty,
          reason: template.id);
      expect(template.spokenPattern.es.trim(), isNotEmpty, reason: template.id);
      expect(template.spokenPattern.ca.trim(), isNotEmpty, reason: template.id);
      expect(template.hintPattern.es.trim(), isNotEmpty, reason: template.id);
      expect(template.hintPattern.ca.trim(), isNotEmpty, reason: template.id);
      expect(
        template.spokenHintPattern.es.trim(),
        isNotEmpty,
        reason: template.id,
      );
      expect(
        template.spokenHintPattern.ca.trim(),
        isNotEmpty,
        reason: template.id,
      );
    }
  });

  test('localized content contains Catalan text for all user-facing data', () {
    for (final world in _loadWorlds()) {
      expect(world.name.ca.trim(), isNotEmpty, reason: world.id);
      expect(world.description.ca.trim(), isNotEmpty, reason: world.id);
    }

    for (final level in _loadLevels()) {
      expect(level.title.ca.trim(), isNotEmpty, reason: level.id);
      expect(level.subtitle.ca.trim(), isNotEmpty, reason: level.id);
    }

    for (final reward in _loadRewards()) {
      expect(reward.name.ca.trim(), isNotEmpty, reason: reward.id);
    }

    for (final item in _loadVisualItems()) {
      expect(item.singularLabel.ca.trim(), isNotEmpty, reason: item.id);
      expect(item.pluralLabel.ca.trim(), isNotEmpty, reason: item.id);
      expect(item.pluralWithArticleLabel.ca.trim(), isNotEmpty,
          reason: item.id);
      expect(item.oneWithArticleLabel.ca.trim(), isNotEmpty, reason: item.id);
      expect(item.gender.ca.trim(), isNotEmpty, reason: item.id);
    }

    for (final topic in _loadHelpTopics()) {
      expect(topic.category.ca.trim(), isNotEmpty, reason: topic.id);
      expect(topic.title.ca.trim(), isNotEmpty, reason: topic.id);
      expect(topic.summary.ca.trim(), isNotEmpty, reason: topic.id);
      expect(topic.body.ca.trim(), isNotEmpty, reason: topic.id);
      expect(topic.spokenText.ca.trim(), isNotEmpty, reason: topic.id);
      for (final example in topic.examples) {
        expect(example.ca.trim(), isNotEmpty, reason: topic.id);
      }
    }
  });

  test('Catalan content avoids known unaccented fallback tokens', () {
    final forbidden = RegExp(
      r'\b(Tambe|despres|mes|Mes|nuvol|nuvols|Dacord|Seguent|gairebe|avancar|Aixi|aixi|perque|cadascu)\b',
    );

    for (final text in _allCatalanJsonStrings()) {
      expect(text, isNot(contains(forbidden)), reason: text);
    }
  });

  test('generated exercises resolve placeholders in Spanish and Catalan', () {
    final templates = _loadTemplates();
    final visualItems = _loadVisualItems();
    final generator = DynamicExerciseGenerator(random: Random(1));
    final unresolved = RegExp(r'\{[A-Za-z][A-Za-z0-9]*\}');

    for (final level in _loadLevels()) {
      final planner = ExerciseSessionPlanner(
        level: level,
        random: Random(1),
      );
      final candidate = planner.next();

      for (final profile in [_spanishProfile, _catalanProfile]) {
        final exercise = generator.buildExercise(
          level: level,
          operation: candidate,
          templates: templates,
          visualItems: visualItems,
          profile: profile,
        );
        final text = [
          exercise.visibleText,
          exercise.spokenText,
          exercise.visibleHint,
          exercise.spokenHint,
          for (final step in exercise.hintSteps) step.visibleText,
          for (final step in exercise.hintSteps) step.spokenText,
        ].join(' ');

        expect(text, isNot(contains(unresolved)),
            reason: '${level.id} ${profile.language.ttsCode}');
      }
    }
  });

  test('Crystal Castle teaches decomposition as a real level concept', () {
    final levels = _loadLevels();
    final firstCrystalLevel = levels.firstWhere(
      (level) => level.id == 'crystal_castle_01',
    );
    final mixedCrystalLevel = levels.firstWhere(
      (level) => level.id == 'crystal_castle_02',
    );
    final bossCrystalLevel = levels.firstWhere(
      (level) => level.id == 'crystal_castle_boss',
    );

    expect(firstCrystalLevel.exerciseTypes, ['decomposition']);
    expect(firstCrystalLevel.minNumber, 10);
    expect(firstCrystalLevel.maxResult, 9);
    expect(
      mixedCrystalLevel.exerciseTypes,
      containsAll(['decomposition', 'addition']),
    );
    expect(
      bossCrystalLevel.exerciseTypes,
      containsAll(['decomposition', 'addition', 'subtraction']),
    );

    final mixedCandidates =
        const ExercisePoolGenerator().generate(mixedCrystalLevel);
    final mixedTypes =
        mixedCandidates.map((candidate) => candidate.type).toSet();

    expect(mixedTypes, containsAll(['decomposition', 'addition']));
  });
}

List<LevelConfig> _loadLevels() {
  final value = File('assets/data/levels.json').readAsStringSync();
  final json = jsonDecode(value) as List;
  return json
      .map(
        (item) => LevelConfig.fromJson(
          Map<String, Object?>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<World> _loadWorlds() {
  final value = File('assets/data/worlds.json').readAsStringSync();
  final json = jsonDecode(value) as List;
  return json
      .map(
        (item) => World.fromJson(
          Map<String, Object?>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<ExerciseTemplate> _loadTemplates() {
  final value = File('assets/data/exercise_templates.json').readAsStringSync();
  final json = jsonDecode(value) as List;
  return json
      .map(
        (item) => ExerciseTemplate.fromJson(
          Map<String, Object?>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<VisualItem> _loadVisualItems() {
  final value = File('assets/data/visual_items.json').readAsStringSync();
  final json = jsonDecode(value) as List;
  return json
      .map(
        (item) => VisualItem.fromJson(
          Map<String, Object?>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<Reward> _loadRewards() {
  final value = File('assets/data/rewards.json').readAsStringSync();
  final json = jsonDecode(value) as List;
  return json
      .map(
        (item) => Reward.fromJson(
          Map<String, Object?>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<HelpTopic> _loadHelpTopics() {
  final value = File('assets/data/help_topics.json').readAsStringSync();
  final json = jsonDecode(value) as List;
  return json
      .map(
        (item) => HelpTopic.fromJson(
          Map<String, Object?>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<String> _allCatalanJsonStrings() {
  return [
    for (final path in [
      'assets/data/exercise_templates.json',
      'assets/data/help_topics.json',
      'assets/data/levels.json',
      'assets/data/rewards.json',
      'assets/data/visual_items.json',
      'assets/data/worlds.json',
    ])
      ..._collectCatalanStrings(jsonDecode(File(path).readAsStringSync())),
  ];
}

List<String> _collectCatalanStrings(Object? value) {
  if (value is List) {
    return [
      for (final item in value) ..._collectCatalanStrings(item),
    ];
  }

  if (value is Map) {
    final strings = <String>[];
    for (final entry in value.entries) {
      if (entry.key == 'ca' && entry.value is String) {
        strings.add(entry.value as String);
        continue;
      }

      strings.addAll(_collectCatalanStrings(entry.value));
    }
    return strings;
  }

  return const [];
}

const _spanishProfile = PlayerProfile(
  id: 'profile_es',
  childName: 'Nora',
  unicornName: 'Luna',
  language: AppLanguage.spanish,
  unicornAvatar: UnicornAvatar.avatar01,
  ttsVoiceId: 'es_ES-sharvard-medium',
);

const _catalanProfile = PlayerProfile(
  id: 'profile_ca',
  childName: 'Nora',
  unicornName: 'Luna',
  language: AppLanguage.catalan,
  unicornAvatar: UnicornAvatar.avatar01,
  ttsVoiceId: 'ca_ES-upc_ona-medium',
);
