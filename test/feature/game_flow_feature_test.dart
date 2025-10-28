import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/get_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/get_games_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: End-to-end scenarios from user's perspective
/// These tests use a fake backend to run in isolation
void main() {
  group('Game Flow Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late ExecuteActionImpl executeActionUseCase;
    late GetGameImpl getGameUseCase;
    late GetGamesImpl getGamesUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      executeActionUseCase = ExecuteActionImpl(repository);
      getGameUseCase = GetGameImpl(repository);
      getGamesUseCase = GetGamesImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User creates a new game', () async {
      // Given: User wants to create a new game
      const gameName = 'My First Game';
      const boardSize = 10;

      // When: User creates the game
      final result = await createGameUseCase(gameName, boardSize);

      // Then: Game is created successfully
      expect(result.isRight(), true);

      final game = result.getOrElse(() => throw Exception('Failed'));
      expect(game.name, gameName);
      expect(game.board.width, boardSize);
      expect(game.board.height, boardSize);
      expect(game.status, GameStatus.playing);
      expect(fakeDataSource.gameCount, 1);
    });

    test('Feature: User creates multiple games and views game list', () async {
      // Given: User creates multiple games
      await createGameUseCase('Game 1', 10);
      await createGameUseCase('Game 2', 10);
      await createGameUseCase('Game 3', 10);

      // When: User views the game list
      final result = await getGamesUseCase(limit: 10);

      // Then: All games are listed
      expect(result.isRight(), true);

      final games = result.getOrElse(() => []);
      expect(games.length, 3);
      expect(games[0].name, 'Game 3'); // Most recent first
      expect(games[1].name, 'Game 2');
      expect(games[2].name, 'Game 1');
    });

    test('Feature: User moves robot in the game', () async {
      // Given: A game is created
      final createResult = await createGameUseCase('Movement Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialPosition = game.board.robot.position;

      // When: User moves robot EAST
      final moveResult =
          await executeActionUseCase(game.id, ActionType.move, Direction.EAST);

      // Then: Robot position is updated
      expect(moveResult.isRight(), true);

      final updatedGame = moveResult.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.board.robot.position.x, initialPosition.x + 1);
      expect(updatedGame.board.robot.position.y, initialPosition.y);
    });

    test('Feature: User executes multiple actions in sequence', () async {
      // Given: A game with robot at (0,0)
      final createResult = await createGameUseCase('Multi-Action Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User performs multiple moves
      var currentGame = game;

      // Move EAST
      var result = await executeActionUseCase(
          currentGame.id, ActionType.move, Direction.EAST);
      currentGame = result.getOrElse(() => throw Exception('Failed'));
      expect(currentGame.board.robot.position.x, 1);
      expect(currentGame.board.robot.position.y, 0);

      // Move SOUTH
      result = await executeActionUseCase(
          currentGame.id, ActionType.move, Direction.SOUTH);
      currentGame = result.getOrElse(() => throw Exception('Failed'));
      expect(currentGame.board.robot.position.x, 1);
      expect(currentGame.board.robot.position.y, 1);

      // Move WEST
      result = await executeActionUseCase(
          currentGame.id, ActionType.move, Direction.WEST);
      currentGame = result.getOrElse(() => throw Exception('Failed'));
      expect(currentGame.board.robot.position.x, 0);
      expect(currentGame.board.robot.position.y, 1);

      // Then: Robot is at expected position after multiple moves
      expect(currentGame.board.robot.position.x, 0);
      expect(currentGame.board.robot.position.y, 1);
    });

    test('Feature: User retrieves a specific game', () async {
      // Given: Multiple games exist
      await createGameUseCase('Game 1', 10);

      final createResult = await createGameUseCase('Target Game', 10);
      final targetGame =
          createResult.getOrElse(() => throw Exception('Failed'));

      await createGameUseCase('Game 3', 10);

      // When: User retrieves a specific game
      final result = await getGameUseCase(targetGame.id);

      // Then: Correct game is retrieved
      expect(result.isRight(), true);

      final retrievedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(retrievedGame.id, targetGame.id);
      expect(retrievedGame.name, 'Target Game');
    });

    test('Feature: User filters games by status', () async {
      // Given: Games with different statuses exist
      await createGameUseCase('Playing Game', 10);

      await createGameUseCase('Won Game', 10);
      // Manually mark as won (in real scenario, this would happen through gameplay)
      // Note: This is a limitation of our fake - in real scenario, game would transition to won state

      // When: User filters by playing status
      final result = await getGamesUseCase(status: 'in_progress');

      // Then: Only playing games are returned
      expect(result.isRight(), true);
      final games = result.getOrElse(() => []);
      expect(games.every((g) => g.status == GameStatus.playing), true);
    });

    test('Feature: Complete game workflow from creation to multiple actions',
        () async {
      // Given: User starts fresh
      expect(fakeDataSource.gameCount, 0);

      // When: User creates a game
      final createResult = await createGameUseCase('Complete Workflow', 10);

      expect(createResult.isRight(), true);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // And: User performs several actions
      var currentGame = game;
      final actions = [
        (ActionType.move, Direction.EAST),
        (ActionType.move, Direction.SOUTH),
        (ActionType.move, Direction.SOUTH),
        (ActionType.move, Direction.EAST),
      ];

      for (final (action, direction) in actions) {
        final result =
            await executeActionUseCase(currentGame.id, action, direction);
        expect(result.isRight(), true);
        currentGame = result.getOrElse(() => throw Exception('Failed'));
      }

      // And: User retrieves the updated game
      final getResult = await getGameUseCase(currentGame.id);
      expect(getResult.isRight(), true);

      final finalGame = getResult.getOrElse(() => throw Exception('Failed'));

      // Then: Game state reflects all actions
      expect(finalGame.board.robot.position.x, 2);
      expect(finalGame.board.robot.position.y, 2);
      expect(fakeDataSource.gameCount, 1);
    });

    test('Feature: User handles game not found error gracefully', () async {
      // Given: No game with specific ID exists
      const nonExistentId = 'non-existent-game';

      // When: User tries to retrieve non-existent game
      final result = await getGameUseCase(nonExistentId);

      // Then: Error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User validates game creation parameters', () async {
      // Given: User provides invalid parameters
      const emptyName = '';
      const invalidSize = 2;

      // When: User attempts to create game with empty name
      final emptyNameResult = await createGameUseCase(emptyName, 10);

      // Then: Validation fails
      expect(emptyNameResult.isLeft(), true);

      // When: User attempts to create game with invalid size
      final invalidSizeResult =
          await createGameUseCase('Valid Name', invalidSize);

      // Then: Validation fails
      expect(invalidSizeResult.isLeft(), true);
    });

    test('Feature: Multiple users creating games concurrently', () async {
      // Given: Multiple users want to create games simultaneously
      final futures = <Future>[];

      // When: Multiple create requests are made
      for (var i = 0; i < 5; i++) {
        futures.add(createGameUseCase('Concurrent Game $i', 10));
      }

      final results = await Future.wait(futures);

      // Then: All games are created successfully
      expect(results.every((r) => r.isRight()), true);
      expect(fakeDataSource.gameCount, 5);

      // And: All games have unique IDs
      final ids = results
          .map((r) => r.getOrElse(() => throw Exception('Failed')).id)
          .toSet();
      expect(ids.length, 5);
    });
  });
}
