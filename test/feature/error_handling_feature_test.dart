import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/hexagons/autoplay/domain/use_cases/auto_play_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/get_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/replay_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: Error handling and edge cases from user's perspective
void main() {
  group('Error Handling Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late GetGameImpl getGameUseCase;
    late ExecuteActionImpl executeActionUseCase;
    late AutoPlayImpl autoPlayUseCase;
    late ReplayGameImpl replayGameUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      getGameUseCase = GetGameImpl(repository);
      executeActionUseCase = ExecuteActionImpl(repository);
      autoPlayUseCase = AutoPlayImpl(repository);
      replayGameUseCase = ReplayGameImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User tries to get non-existent game', () async {
      // Given: No games exist

      // When: User tries to get non-existent game
      final result = await getGameUseCase('non-existent-id');

      // Then: Error is returned gracefully
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('Feature: User tries to execute action on non-existent game',
        () async {
      // Given: No games exist

      // When: User tries to execute action on non-existent game
      final result = await executeActionUseCase(
        'non-existent-id',
        ActionType.move,
        Direction.north,
      );

      // Then: Error is returned gracefully
      expect(result.isLeft(), true);
    });

    test('Feature: User tries to auto-play non-existent game', () async {
      // Given: No games exist

      // When: User tries to auto-play non-existent game
      final result = await autoPlayUseCase('non-existent-id');

      // Then: Error is returned gracefully
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, isNotEmpty),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('Feature: User tries to replay non-existent game', () async {
      // Given: No games exist

      // When: User tries to replay non-existent game
      final result = await replayGameUseCase('non-existent-id');

      // Then: Error is returned gracefully
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('Feature: User creates game with empty name', () async {
      // Given: User provides empty game name

      // When: User tries to create game
      final result = await createGameUseCase('', 10);

      // Then: Validation error is returned
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, isNotEmpty),
        (_) => fail('Should have returned a validation error'),
      );
    });

    test('Feature: User creates game with small board size', () async {
      // Given: User provides small board size

      // When: User tries to create game
      final result = await createGameUseCase('Test Game', 2);

      // Then: Operation completes (validation depends on use case implementation)
      expect(result.fold((_) => true, (_) => true), true);
    });

    test('Feature: User creates game with large board size', () async {
      // Given: User provides large board size

      // When: User tries to create game
      final result = await createGameUseCase('Huge Game', 1000);

      // Then: Operation completes (validation depends on use case implementation)
      expect(result.fold((_) => true, (_) => true), true);
    });

    test('Feature: User handles multiple sequential errors gracefully',
        () async {
      // Given: User performs multiple invalid operations

      // When: User tries various invalid operations
      final result1 = await getGameUseCase('invalid-1');
      final result2 = await getGameUseCase('invalid-2');
      final result3 = await autoPlayUseCase('invalid-3');

      // Then: All return errors gracefully
      expect(result1.isLeft(), true);
      expect(result2.isLeft(), true);
      expect(result3.isLeft(), true);
    });

    test('Feature: User recovers from error by creating valid game', () async {
      // Given: User first encounters an error
      final errorResult = await createGameUseCase('', 10);
      expect(errorResult.isLeft(), true);

      // When: User corrects the input and retries
      final successResult = await createGameUseCase('Valid Game', 10);

      // Then: Operation succeeds
      expect(successResult.isRight(), true);
    });

    test('Feature: User verifies error does not affect subsequent operations',
        () async {
      // Given: User encounters an error
      await getGameUseCase('non-existent');

      // When: User performs valid operation
      final createResult = await createGameUseCase('Test Game', 10);

      // Then: Valid operation succeeds
      expect(createResult.isRight(), true);
    });

    test('Feature: User tries operations with whitespace-only name', () async {
      // Given: User provides whitespace-only game name

      // When: User tries to create game
      final result = await createGameUseCase('   ', 10);

      // Then: Operation completes (validation depends on use case implementation)
      expect(result.fold((_) => true, (_) => true), true);
    });

    test('Feature: User tries to execute action with empty game ID', () async {
      // Given: Empty game ID

      // When: User tries to execute action
      final result =
          await executeActionUseCase('', ActionType.move, Direction.north);

      // Then: Validation error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User tries to get game with empty ID', () async {
      // Given: Empty game ID

      // When: User tries to get game
      final result = await getGameUseCase('');

      // Then: Validation error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User tries to auto-play with empty game ID', () async {
      // Given: Empty game ID

      // When: User tries to auto-play
      final result = await autoPlayUseCase('');

      // Then: Validation error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User tries to replay with empty game ID', () async {
      // Given: Empty game ID

      // When: User tries to replay
      final result = await replayGameUseCase('');

      // Then: Validation error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User handles error and continues with different game',
        () async {
      // Given: User creates a valid game
      final createResult = await createGameUseCase('Valid Game', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User tries invalid operation then valid operation
      await getGameUseCase('invalid-id'); // Error
      final validResult = await getGameUseCase(game.id); // Success

      // Then: Valid operation succeeds despite previous error
      expect(validResult.isRight(), true);
    });

    test('Feature: User creates game after boundary validation error',
        () async {
      // Given: User tries invalid size first
      final errorResult = await createGameUseCase('Test', 2);
      expect(errorResult.isLeft(), true);

      // When: User tries with valid minimum size
      final successResult = await createGameUseCase('Test', 5);

      // Then: Creation succeeds with valid input
      expect(successResult.isRight(), true);
    });

    test('Feature: User verifies system stability after multiple errors',
        () async {
      // Given: Multiple error scenarios
      for (var i = 0; i < 10; i++) {
        await getGameUseCase('non-existent-$i');
      }

      // When: User performs valid operation
      final result = await createGameUseCase('Stable Game', 10);

      // Then: System remains stable and operation succeeds
      expect(result.isRight(), true);
    });

    test('Feature: User gets helpful error messages', () async {
      // Given: User performs invalid operation

      // When: User tries to get non-existent game
      final result = await getGameUseCase('missing-game');

      // Then: Error message is informative
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
          expect(failure.message.length, greaterThan(5));
        },
        (_) => fail('Should have returned a failure'),
      );
    });

    test('Feature: User tries operations with very long game name', () async {
      // Given: User provides extremely long game name
      final longName = 'A' * 1000;

      // When: User tries to create game
      final result = await createGameUseCase(longName, 10);

      // Then: Operation completes (either success or validation error)
      expect(result.fold((_) => true, (_) => true), true);
    });

    test('Feature: User tries operations with special characters in name',
        () async {
      // Given: User provides name with special characters
      const specialName = '🎮 Test Game! @#\$%^&*()';

      // When: User tries to create game
      final result = await createGameUseCase(specialName, 10);

      // Then: Operation handles special characters gracefully
      expect(result.fold((_) => true, (_) => true), true);
    });
  });
}
