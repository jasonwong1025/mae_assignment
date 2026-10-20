import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/recipe_repository.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/recipe_ai_service.dart';

/// Stands in for Gemini: returns a fixed answer, or fails.
class _FakeAi implements RecipeAiService {
  String answer = '{"ingredients": []}';
  RecipeAiException? failure;
  final requests = <({String dish, int servings})>[];

  @override
  Future<String> ingredientsJson({
    required String dish,
    required int servings,
  }) async {
    requests.add((dish: dish, servings: servings));
    if (failure case final error?) throw error;
    return answer;
  }
}

List<String> _lines(List<({String name, int quantity})> lines) {
  return [for (final line in lines) '${line.quantity} ${line.name}'];
}

void main() {
  late _FakeAi ai;
  late RecipeRepository repository;

  setUp(() {
    ai = _FakeAi();
    repository = RecipeRepository(ai);
  });

  group('RecipeRepository.parse', () {
    test('reads a normal answer', () {
      final lines = RecipeRepository.parse(
        '{"ingredients": [{"name": "chicken breast", "quantity": 2},'
        ' {"name": "coconut milk", "quantity": 1}]}',
      );

      expect(_lines(lines), ['2 chicken breast', '1 coconut milk']);
    });

    test('a missing or odd quantity becomes 1, a big one is capped', () {
      final lines = RecipeRepository.parse(
        '{"ingredients": [{"name": "onion"}, {"name": "egg", "quantity": "x"},'
        ' {"name": "rice", "quantity": 500}, {"name": "garlic", "quantity": 0},'
        ' {"name": "chilli", "quantity": 2.6}]}',
      );

      expect(_lines(lines), [
        '1 onion',
        '1 egg',
        '99 rice',
        '1 garlic',
        '3 chilli',
      ]);
    });

    test('drops entries that are not ingredients', () {
      final lines = RecipeRepository.parse(
        '{"ingredients": ["salt", 7, null, {"name": 5}, {"name": "  "},'
        ' {"name": "x"}, {"name": "123"}, {"name": "${'a' * 61}"},'
        ' {"name": "tomato"}]}',
      );

      expect(_lines(lines), ['1 tomato']);
    });

    test('removes duplicates, ignoring capitals and spacing', () {
      final lines = RecipeRepository.parse(
        '{"ingredients": [{"name": "Red  onion", "quantity": 1},'
        ' {"name": "red onion", "quantity": 3}]}',
      );

      expect(_lines(lines), ['1 Red onion']);
    });

    test('keeps at most 25 ingredients', () {
      final many = [
        for (var i = 0; i < 40; i++) '{"name": "item number $i letters"}',
      ].join(',');

      expect(RecipeRepository.parse('{"ingredients": [$many]}'), hasLength(25));
    });

    test('anything that is not the expected JSON gives nothing', () {
      for (final answer in [
        '',
        'not json',
        '[]',
        'null',
        '{"ingredients": "tomato"}',
        '{"something": []}',
      ]) {
        expect(RecipeRepository.parse(answer), isEmpty, reason: answer);
      }
    });
  });

  group('RecipeRepository.suggest', () {
    test('sends the dish and servings, and returns the ingredients', () async {
      ai.answer = '{"ingredients": [{"name": "egg", "quantity": 6}]}';

      final lines = await repository.suggest('  omelette  ', servings: 3);

      expect(_lines(lines), ['6 egg']);
      expect(ai.requests.single, (dish: 'omelette', servings: 3));
    });

    test(
      'refuses a dish that is too short or too long, without calling',
      () async {
        for (final dish in ['', '  ', 'ab', 'x' * 501]) {
          expect(
            repository.suggest(dish),
            throwsA(isA<RecipeException>()),
            reason: dish.length.toString(),
          );
        }
        expect(ai.requests, isEmpty);
      },
    );

    test('refuses a silly number of servings', () async {
      for (final servings in [0, -1, 21]) {
        expect(
          repository.suggest('laksa', servings: servings),
          throwsA(isA<RecipeException>()),
        );
      }
      expect(ai.requests, isEmpty);
    });

    test('an answer with no usable ingredients asks to try again', () async {
      ai.answer = '{"ingredients": [{"name": "?"}]}';

      expect(
        repository.suggest('laksa'),
        throwsA(
          isA<RecipeException>().having(
            (e) => e.message,
            'message',
            contains('No ingredients could be found'),
          ),
        ),
      );
    });

    test('maps a model failure to a friendly message', () async {
      Future<String> messageFor(String reason) async {
        ai.failure = RecipeAiException(reason);
        try {
          await repository.suggest('laksa');
        } on RecipeException catch (error) {
          return error.message;
        }
        return '';
      }

      expect(await messageFor('429 quota exceeded'), contains('busy'));
      expect(await messageFor('TimeoutException'), contains('too long'));
      final other = await messageFor('PERMISSION_DENIED api key leaked');
      expect(other, contains('not available right now'));
      // Raw details never reach the screen.
      expect(other, isNot(contains('PERMISSION_DENIED')));
    });
  });
}
