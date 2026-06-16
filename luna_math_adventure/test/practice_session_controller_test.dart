import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luna_math_adventure/features/practice/practice_session_controller.dart';
import 'package:luna_math_adventure/models/exercise_template.dart';
import 'package:luna_math_adventure/models/help_topic.dart';
import 'package:luna_math_adventure/models/level_config.dart';
import 'package:luna_math_adventure/models/localized_text.dart';
import 'package:luna_math_adventure/models/reward.dart';
import 'package:luna_math_adventure/models/visual_item.dart';
import 'package:luna_math_adventure/models/world.dart';
import 'package:luna_math_adventure/services/content_repository.dart';
import 'package:luna_math_adventure/services/exercise_pool_generator.dart';

void main() {
  group('buildPracticeLevel', () {
    test('count 1-5 only generates count exercises up to 5', () {
      final level = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.count,
          difficulty: PracticeDifficulty.upTo5,
        ),
      );
      final candidates = const ExercisePoolGenerator().generate(level);

      expect(level.questionsToComplete, practiceQuestionsToComplete);
      expect(level.rewardId, isNull);
      expect(candidates, isNotEmpty);
      expect(candidates.every((candidate) => candidate.type == 'count'), isTrue);
      expect(candidates.every((candidate) => candidate.result <= 5), isTrue);
    });

    test('addition 1-10 only generates addition exercises up to 10', () {
      final level = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.addition,
          difficulty: PracticeDifficulty.upTo10,
        ),
      );
      final candidates = const ExercisePoolGenerator().generate(level);

      expect(candidates, isNotEmpty);
      expect(
        candidates.every((candidate) => candidate.type == 'addition'),
        isTrue,
      );
      expect(candidates.every((candidate) => candidate.result <= 10), isTrue);
    });

    test('subtraction 1-20 does not generate negative results', () {
      final level = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.subtraction,
          difficulty: PracticeDifficulty.upTo20,
        ),
      );
      final candidates = const ExercisePoolGenerator().generate(level);

      expect(candidates, isNotEmpty);
      expect(
        candidates.every((candidate) => candidate.type == 'subtraction'),
        isTrue,
      );
      expect(candidates.every((candidate) => candidate.result >= 0), isTrue);
      expect(candidates.every((candidate) => candidate.result <= 20), isTrue);
    });

    test('mixed includes count, addition, and subtraction', () {
      final level = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.mixed,
          difficulty: PracticeDifficulty.upTo10,
        ),
      );
      final candidates = const ExercisePoolGenerator().generate(level);
      final types = candidates.map((candidate) => candidate.type).toSet();

      expect(types, containsAll(['count', 'addition', 'subtraction']));
    });

    test('difficulty maps to adventure-style visual support stages', () {
      final easy = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.addition,
          difficulty: PracticeDifficulty.upTo5,
        ),
      );
      final medium = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.addition,
          difficulty: PracticeDifficulty.upTo10,
        ),
      );
      final hard = buildPracticeLevel(
        const PracticeSessionConfig(
          topic: PracticeTopic.addition,
          difficulty: PracticeDifficulty.upTo20,
        ),
      );

      expect(easy.sortOrder, lessThan(7));
      expect(medium.sortOrder, greaterThanOrEqualTo(7));
      expect(hard.sortOrder, greaterThanOrEqualTo(7));
    });
  });

  test('controller completes after eight questions without progress state', () async {
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      practiceSessionProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final controller = container.read(practiceSessionProvider.notifier);
    await controller.start(
      const PracticeSessionConfig(
        topic: PracticeTopic.addition,
        difficulty: PracticeDifficulty.upTo10,
      ),
    );

    for (var index = 0; index < practiceQuestionsToComplete; index++) {
      final session = container.read(practiceSessionProvider).valueOrNull!;
      controller.submitAnswer(session.exercise.answer);
      controller.nextExercise();
    }

    final completed = container.read(practiceSessionProvider).valueOrNull!;
    expect(completed.isComplete, isTrue);
    expect(completed.correctAnswers, practiceQuestionsToComplete);
  });
}

class _FakeContentRepository implements ContentRepository {
  @override
  Future<List<ExerciseTemplate>> loadExerciseTemplates() async {
    return const [
      ExerciseTemplate(
        id: 'count',
        type: 'count',
        visiblePattern: LocalizedText(es: 'Cuenta {a}', ca: 'Compta {a}'),
        spokenPattern: LocalizedText(es: 'Cuenta {a}', ca: 'Compta {a}'),
        hintPattern: LocalizedText(es: 'Mira con calma', ca: 'Mira amb calma'),
        spokenHintPattern: LocalizedText(
          es: 'Mira con calma',
          ca: 'Mira amb calma',
        ),
      ),
      ExerciseTemplate(
        id: 'addition',
        type: 'addition',
        visiblePattern: LocalizedText(es: '{a} + {b}', ca: '{a} + {b}'),
        spokenPattern: LocalizedText(es: '{a} + {b}', ca: '{a} + {b}'),
        hintPattern: LocalizedText(es: 'Suma despacio', ca: 'Suma a poc a poc'),
        spokenHintPattern: LocalizedText(
          es: 'Suma despacio',
          ca: 'Suma a poc a poc',
        ),
      ),
      ExerciseTemplate(
        id: 'subtraction',
        type: 'subtraction',
        visiblePattern: LocalizedText(es: '{a} - {b}', ca: '{a} - {b}'),
        spokenPattern: LocalizedText(es: '{a} - {b}', ca: '{a} - {b}'),
        hintPattern: LocalizedText(es: 'Resta despacio', ca: 'Resta a poc a poc'),
        spokenHintPattern: LocalizedText(
          es: 'Resta despacio',
          ca: 'Resta a poc a poc',
        ),
      ),
    ];
  }

  @override
  Future<List<VisualItem>> loadVisualItems() async {
    return const [
      VisualItem(
        id: 'heart_pink',
        assetPath: 'assets/images/items/heart_pink.webp',
        singularLabel: LocalizedText(es: 'corazón', ca: 'cor'),
        pluralLabel: LocalizedText(es: 'corazones', ca: 'cors'),
        pluralWithArticleLabel: LocalizedText(
          es: 'los corazones',
          ca: 'els cors',
        ),
        oneWithArticleLabel: LocalizedText(es: 'un corazón', ca: 'un cor'),
        gender: LocalizedText(es: 'masculine', ca: 'masculine'),
      ),
    ];
  }

  @override
  Future<List<HelpTopic>> loadHelpTopics() async => const [];

  @override
  Future<LevelConfig?> loadLevel(String levelId) async => null;

  @override
  Future<List<LevelConfig>> loadLevels() async => const [];

  @override
  Future<List<Reward>> loadRewards() async => const [];

  @override
  Future<List<World>> loadWorlds() async => const [];
}
