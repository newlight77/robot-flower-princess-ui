import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/replay_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: Game replay scenarios from user's perspective
void main() {
  group('Replay Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late ExecuteActionImpl executeActionUseCase;
    late ReplayGameImpl replayGameUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      executeActionUseCase = ExecuteActionImpl(repository);
      replayGameUseCase = ReplayGameImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User replays a newly created game', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Replay Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User requests replay
      final result = await replayGameUseCase(game.id);

      // Then: Game history is returned
      expect(result.isRight(), true);

      final history = result.getOrElse(() => throw Exception('Failed'));
      expect(history, isNotEmpty);
      expect(history.first.robot.position, game.board.robot.position);
    });

    test('Feature: User replays game after making moves', () async {
      // Given: User creates a game and makes moves
      final createResult = await createGameUseCase('Move Replay', 10);
      var game = createResult.getOrElse(() => throw Exception('Failed'));

      // Make 3 moves
      for (var i = 0; i < 3; i++) {
        final moveResult = await executeActionUseCase(
            game.id, ActionType.move, Direction.EAST);
        game = moveResult.getOrElse(() => throw Exception('Failed'));
      }

      // When: User replays the game
      final result = await replayGameUseCase(game.id);

      // Then: History shows all board states
      expect(result.isRight(), true);

      final history = result.getOrElse(() => throw Exception('Failed'));
      expect(history.length, greaterThanOrEqualTo(1));

      // Verify progression through history
      if (history.length > 1) {
        expect(history.first.robot.position.x,
            lessThan(history.last.robot.position.x));
      }
    });

    test('Feature: User views step-by-step game progression', () async {
      // Given: User creates game and performs sequence of actions
      final createResult = await createGameUseCase('Step Progression', 10);
      var game = createResult.getOrElse(() => throw Exception('Failed'));

      final actions = [
        (ActionType.move, Direction.EAST),
        (ActionType.move, Direction.SOUTH),
        (ActionType.move, Direction.SOUTH),
        (ActionType.move, Direction.WEST),
      ];

      for (final (action, direction) in actions) {
        final result = await executeActionUseCase(game.id, action, direction);
        game = result.getOrElse(() => throw Exception('Failed'));
      }

      // When: User replays
      final result = await replayGameUseCase(game.id);

      // Then: Can see game progression
      expect(result.isRight(), true);

      final history = result.getOrElse(() => throw Exception('Failed'));
      expect(history, isNotEmpty);

      // Verify board dimensions consistent throughout
      for (final board in history) {
        expect(board.width, 10);
        expect(board.height, 10);
      }
    });

    test('Feature: User replays non-existent game', () async {
      // Given: No game exists
      const nonExistentId = 'fake-game-id';

      // When: User tries to replay
      final result = await replayGameUseCase(nonExistentId);

      // Then: Error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User validates empty game ID for replay', () async {
      // Given: User provides empty game ID
      const emptyId = '';

      // When: User attempts replay
      final result = await replayGameUseCase(emptyId);

      // Then: Validation error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User replays multiple different games', () async {
      // Given: Multiple games with different actions
      final games = [];
      for (var i = 0; i < 3; i++) {
        final createResult = await createGameUseCase('Game $i', 10);
        var game = createResult.getOrElse(() => throw Exception('Failed'));

        // Make different number of moves in each game
        for (var j = 0; j <= i; j++) {
          final moveResult = await executeActionUseCase(
              game.id, ActionType.move, Direction.EAST);
          game = moveResult.getOrElse(() => throw Exception('Failed'));
        }

        games.add(game);
      }

      // When: User replays each game
      for (final game in games) {
        final result = await replayGameUseCase(game.id);

        // Then: Each replay succeeds
        expect(result.isRight(), true);

        final history = result.getOrElse(() => throw Exception('Failed'));
        expect(history, isNotEmpty);
      }
    });

    test('Feature: User verifies robot position changes in replay', () async {
      // Given: User creates game and moves robot
      final createResult = await createGameUseCase('Position Replay', 10);
      var game = createResult.getOrElse(() => throw Exception('Failed'));

      // Move robot twice
      var moveResult =
          await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      game = moveResult.getOrElse(() => throw Exception('Failed'));

      moveResult =
          await executeActionUseCase(game.id, ActionType.move, Direction.SOUTH);
      game = moveResult.getOrElse(() => throw Exception('Failed'));

      final currentPosition = game.board.robot.position;

      // When: User replays
      final result = await replayGameUseCase(game.id);

      // Then: Can verify position in history
      expect(result.isRight(), true);

      final history = result.getOrElse(() => throw Exception('Failed'));
      expect(history, isNotEmpty);

      // History shows current game state
      expect(history.first.robot.position, currentPosition);
    });

    test('Feature: User replays game to review strategy', () async {
      // Given: User plays a complex game
      final createResult = await createGameUseCase('Strategy Review', 15);
      var game = createResult.getOrElse(() => throw Exception('Failed'));

      // Execute a series of strategic moves
      final strategy = [
        (ActionType.move, Direction.EAST),
        (ActionType.move, Direction.EAST),
        (ActionType.move, Direction.SOUTH),
        (ActionType.move, Direction.SOUTH),
        (ActionType.move, Direction.WEST),
      ];

      for (final (action, direction) in strategy) {
        final result = await executeActionUseCase(game.id, action, direction);
        game = result.getOrElse(() => throw Exception('Failed'));
      }

      // When: User wants to review their strategy
      final result = await replayGameUseCase(game.id);

      // Then: Complete history is available for review
      expect(result.isRight(), true);

      final history = result.getOrElse(() => throw Exception('Failed'));
      expect(history, isNotEmpty);

      // Verify history includes all states
      for (final board in history) {
        expect(board.robot, isNotNull);
        expect(board.princess, isNotNull);
      }
    });

    test('Feature: User checks princess position remains constant in replay',
        () async {
      // Given: User creates and plays a game
      final createResult = await createGameUseCase('Princess Position', 10);
      var game = createResult.getOrElse(() => throw Exception('Failed'));
      final princessPosition = game.board.princess.position;

      // Make several moves
      for (var i = 0; i < 3; i++) {
        final moveResult = await executeActionUseCase(
            game.id, ActionType.move, Direction.EAST);
        game = moveResult.getOrElse(() => throw Exception('Failed'));
      }

      // When: User replays
      final result = await replayGameUseCase(game.id);

      // Then: Princess position is constant throughout
      expect(result.isRight(), true);

      final history = result.getOrElse(() => throw Exception('Failed'));
      for (final board in history) {
        expect(board.princess.position, princessPosition);
      }
    });

    test('Feature: User replays game on different board sizes', () async {
      // Given: Games with various board sizes
      final boardSizes = [5, 10, 15];

      for (final size in boardSizes) {
        final createResult = await createGameUseCase('Size $size', size);
        var game = createResult.getOrElse(() => throw Exception('Failed'));

        // Make a move
        final moveResult = await executeActionUseCase(
            game.id, ActionType.move, Direction.EAST);
        game = moveResult.getOrElse(() => throw Exception('Failed'));

        // When: User replays
        final result = await replayGameUseCase(game.id);

        // Then: Replay works for all sizes
        expect(result.isRight(), true);

        final history = result.getOrElse(() => throw Exception('Failed'));
        expect(history, isNotEmpty);

        // Verify board size consistency
        for (final board in history) {
          expect(board.width, size);
          expect(board.height, size);
        }
      }
    });
  });
}
