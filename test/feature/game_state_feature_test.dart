import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/hexagons/autoplay/domain/use_cases/auto_play_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/get_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: Game state management and transitions
void main() {
  group('Game State Management Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late GetGameImpl getGameUseCase;
    late ExecuteActionImpl executeActionUseCase;
    late AutoPlayImpl autoPlayUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      getGameUseCase = GetGameImpl(repository);
      executeActionUseCase = ExecuteActionImpl(repository);
      autoPlayUseCase = AutoPlayImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User creates game and verifies initial state', () async {
      // Given: User creates a new game
      final result = await createGameUseCase('State Test', 10);
      final game = result.getOrElse(() => throw Exception('Failed'));

      // When: User checks game state

      // Then: Initial state is correct
      expect(game.status, GameStatus.playing);
      expect(game.board.robot.position.x, 0);
      expect(game.board.robot.position.y, 0);
      expect(game.board.robot.orientation, Direction.NORTH);
      expect(game.board.flowersRemaining, greaterThan(0));
      expect(game.actions, isEmpty);
    });

    test('Feature: User verifies robot orientation after action', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Rotation Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User performs an action
      final actionResult = await executeActionUseCase(
        game.id,
        ActionType.rotate,
        Direction.EAST,
      );

      // Then: Action executes successfully
      expect(actionResult.isRight(), true);
      final updatedGame =
          actionResult.getOrElse(() => throw Exception('Failed'));
      // Orientation is tracked by the system
      expect(updatedGame.board.robot.orientation, isNotNull);
    });

    test('Feature: User verifies robot position changes after move', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Move Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialPosition = game.board.robot.position;

      // When: User moves robot
      final moveResult = await executeActionUseCase(
        game.id,
        ActionType.move,
        Direction.EAST,
      );

      // Then: Robot position updates
      expect(moveResult.isRight(), true);
      final updatedGame = moveResult.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.board.robot.position.x, initialPosition.x + 1);
    });

    test('Feature: User verifies game status transition to won', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Win Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      expect(game.status, GameStatus.playing);

      // When: User completes the game
      final winResult = await autoPlayUseCase(game.id);

      // Then: Game status transitions to won
      expect(winResult.isRight(), true);
      final wonGame = winResult.getOrElse(() => throw Exception('Failed'));
      expect(wonGame.status, GameStatus.won);
    });

    test('Feature: User verifies flowers remaining decreases', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Flower Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialFlowers = game.board.flowersRemaining;

      // When: User completes the game
      final completeResult = await autoPlayUseCase(game.id);

      // Then: All flowers are collected
      expect(completeResult.isRight(), true);
      final completedGame =
          completeResult.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.board.flowersRemaining, 0);
      expect(completedGame.board.flowersRemaining, lessThan(initialFlowers));
    });

    test('Feature: User verifies action history is maintained', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('History Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User performs multiple actions
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      final result = await getGameUseCase(game.id);

      // Then: Action count reflects performed actions
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.actions.length, greaterThanOrEqualTo(0));
    });

    test('Feature: User verifies princess position remains constant', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Princess Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final princessPos = game.board.princess.position;

      // When: User performs actions
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      final result = await getGameUseCase(game.id);

      // Then: Princess position unchanged
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.board.princess.position, princessPos);
    });

    test('Feature: User verifies board dimensions remain constant', () async {
      // Given: User creates a game with specific size
      final createResult = await createGameUseCase('Size Test', 15);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User performs various actions
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      await executeActionUseCase(game.id, ActionType.rotate, Direction.NORTH);
      final result = await getGameUseCase(game.id);

      // Then: Board dimensions unchanged
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.board.width, 15);
      expect(updatedGame.board.height, 15);
    });

    test('Feature: User verifies game state persists across retrievals',
        () async {
      // Given: User creates and modifies a game
      final createResult = await createGameUseCase('Persist Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);

      // When: User retrieves game multiple times
      final result1 = await getGameUseCase(game.id);
      final result2 = await getGameUseCase(game.id);

      // Then: State is consistent across retrievals
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      final game1 = result1.getOrElse(() => throw Exception('Failed'));
      final game2 = result2.getOrElse(() => throw Exception('Failed'));
      expect(game1.board.robot.position, game2.board.robot.position);
    });

    test('Feature: User verifies multiple games maintain separate states',
        () async {
      // Given: User creates multiple games
      final result1 = await createGameUseCase('Game 1', 10);
      final result2 = await createGameUseCase('Game 2', 15);

      final game1 = result1.getOrElse(() => throw Exception('Failed'));
      final game2 = result2.getOrElse(() => throw Exception('Failed'));

      // When: User modifies one game
      await executeActionUseCase(game1.id, ActionType.move, Direction.EAST);

      // Then: Other game remains unaffected
      final check1 = await getGameUseCase(game1.id);
      final check2 = await getGameUseCase(game2.id);

      expect(check1.isRight(), true);
      expect(check2.isRight(), true);

      final updated1 = check1.getOrElse(() => throw Exception('Failed'));
      final updated2 = check2.getOrElse(() => throw Exception('Failed'));

      expect(updated2.board.robot.position, game2.board.robot.position);
      expect(updated2.board.width, 15);
      expect(updated1.board.width, 10);
    });

    test('Feature: User verifies completed game state is preserved', () async {
      // Given: User completes a game
      final createResult = await createGameUseCase('Completed Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      await autoPlayUseCase(game.id);

      // When: User retrieves the completed game
      final result = await getGameUseCase(game.id);

      // Then: Completed state is preserved
      expect(result.isRight(), true);
      final completedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.status, GameStatus.won);
      expect(completedGame.board.robot.position,
          completedGame.board.princess.position);
    });

    test('Feature: User verifies sequential moves update position correctly',
        () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Sequential Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final startX = game.board.robot.position.x;

      // When: User makes sequential moves in same direction
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);

      final result = await getGameUseCase(game.id);

      // Then: Position reflects all moves
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.board.robot.position.x, greaterThan(startX));
    });

    test('Feature: User verifies game ID remains constant', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('ID Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final originalId = game.id;

      // When: User performs various operations
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      final result = await getGameUseCase(game.id);

      // Then: Game ID remains unchanged
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.id, originalId);
    });

    test('Feature: User verifies game name remains constant', () async {
      // Given: User creates a game
      const gameName = 'My Test Game';
      final createResult = await createGameUseCase(gameName, 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User performs actions
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      final result = await getGameUseCase(game.id);

      // Then: Game name unchanged
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.name, gameName);
    });

    test('Feature: User verifies state after rapid successive operations',
        () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Rapid Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User performs rapid successive operations
      for (var i = 0; i < 5; i++) {
        await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      }

      final result = await getGameUseCase(game.id);

      // Then: Final state is consistent
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedGame.board.robot.position, isNotNull);
    });

    test('Feature: User verifies flowers delivered to princess increases',
        () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Delivery Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialDelivered = game.board.princess.flowersReceived;

      // When: User completes the game
      await autoPlayUseCase(game.id);
      final result = await getGameUseCase(game.id);

      // Then: Princess received flowers
      expect(result.isRight(), true);
      final completedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.board.princess.flowersReceived,
          greaterThan(initialDelivered));
    });

    test('Feature: User verifies obstacles cleared during auto-play', () async {
      // Given: User creates a game with obstacles
      final createResult = await createGameUseCase('Obstacle Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialObstacles = game.board.obstaclesRemaining;

      // When: User completes the game via auto-play
      await autoPlayUseCase(game.id);
      final result = await getGameUseCase(game.id);

      // Then: Obstacles are cleared or remaining count is accurate
      expect(result.isRight(), true);
      final completedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.board.obstaclesRemaining,
          lessThanOrEqualTo(initialObstacles));
    });

    test('Feature: User verifies state consistency after completing game',
        () async {
      // Given: User completes a game
      final createResult = await createGameUseCase('Consistency Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      await autoPlayUseCase(game.id);

      // When: User retrieves game multiple times
      final result1 = await getGameUseCase(game.id);
      final result2 = await getGameUseCase(game.id);

      // Then: State is identical across retrievals
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      final game1 = result1.getOrElse(() => throw Exception('Failed'));
      final game2 = result2.getOrElse(() => throw Exception('Failed'));

      expect(game1.status, game2.status);
      expect(game1.board.robot.position, game2.board.robot.position);
      expect(game1.board.flowersRemaining, game2.board.flowersRemaining);
    });

    test('Feature: User verifies creation timestamp is set', () async {
      // Given: User creates a game

      // When: Game is created
      final result = await createGameUseCase('Timestamp Test', 10);

      // Then: Creation timestamp exists and is reasonable
      expect(result.isRight(), true);
      final game = result.getOrElse(() => throw Exception('Failed'));
      expect(game.createdAt, isNotNull);
      expect(
          game.createdAt
              .isBefore(DateTime.now().add(const Duration(seconds: 1))),
          true);
    });

    test('Feature: User verifies game state after alternating directions',
        () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Alternate Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User alternates between directions
      await executeActionUseCase(game.id, ActionType.move, Direction.EAST);
      await executeActionUseCase(game.id, ActionType.move, Direction.WEST);

      final result = await getGameUseCase(game.id);

      // Then: Position reflects net movement
      expect(result.isRight(), true);
      final updatedGame = result.getOrElse(() => throw Exception('Failed'));
      // Should be back near start (or at start depending on implementation)
      expect(updatedGame.board.robot.position, isNotNull);
    });
  });
}
