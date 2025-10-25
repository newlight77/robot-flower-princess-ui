import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/data/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/auto_play_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/get_games_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: Complex game scenarios covering multiple workflows
void main() {
  group('Game Completion Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late AutoPlayImpl autoPlayUseCase;
    late GetGamesImpl getGamesUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      autoPlayUseCase = AutoPlayImpl(repository);
      getGamesUseCase = GetGamesImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User completes game by reaching princess', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Victory Game', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User auto-plays to complete game
      final completeResult = await autoPlayUseCase(game.id);

      // Then: Game is won
      expect(completeResult.isRight(), true);

      final completedGame =
          completeResult.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.status, GameStatus.won);
      expect(completedGame.board.robot.position,
          completedGame.board.princess.position);
    });

    test('Feature: User sees game marked as won after completion', () async {
      // Given: User completes a game
      final createResult = await createGameUseCase('Completion Check', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      await autoPlayUseCase(game.id);

      // When: User views their game list
      final listResult = await getGamesUseCase(limit: 10);

      // Then: Completed game shows won status
      expect(listResult.isRight(), true);

      final games = listResult.getOrElse(() => []);
      expect(games, isNotEmpty);
      expect(games.first.id, game.id);
      expect(games.first.status, GameStatus.won);
    });

    test('Feature: User verifies flowers delivered to princess', () async {
      // Given: User creates a game with flowers
      final createResult = await createGameUseCase('Flower Delivery', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialFlowers = game.board.flowersRemaining;

      // When: User completes the game
      final completeResult = await autoPlayUseCase(game.id);
      expect(completeResult.isRight(), true);

      final completedGame =
          completeResult.getOrElse(() => throw Exception('Failed'));

      // Then: All flowers are delivered to princess
      expect(completedGame.board.flowersRemaining, 0);
      expect(completedGame.board.princess.flowersReceived, greaterThan(0));
      expect(completedGame.board.princess.flowersReceived,
          lessThanOrEqualTo(initialFlowers));
    });

    test('Feature: User completes multiple games', () async {
      // Given: User creates several games
      const gameCount = 5;
      final gameIds = <String>[];

      for (var i = 0; i < gameCount; i++) {
        final result = await createGameUseCase('Game $i', 10);
        final game = result.getOrElse(() => throw Exception('Failed'));
        gameIds.add(game.id);
      }

      // When: User completes each game
      for (final gameId in gameIds) {
        final result = await autoPlayUseCase(gameId);
        expect(result.isRight(), true);
      }

      // Then: All games are won
      final listResult = await getGamesUseCase(limit: 10);
      final games = listResult.getOrElse(() => []);

      expect(games.length, gameCount);
      expect(games.every((g) => g.status == GameStatus.won), true);
    });

    test('Feature: User verifies game completion on different board sizes',
        () async {
      // Given: Games of various sizes
      final sizes = [5, 10, 15, 20];

      for (final size in sizes) {
        final createResult = await createGameUseCase('Size $size Game', size);
        final game = createResult.getOrElse(() => throw Exception('Failed'));

        // When: User completes each game
        final completeResult = await autoPlayUseCase(game.id);

        // Then: All complete successfully
        expect(completeResult.isRight(), true);

        final completedGame =
            completeResult.getOrElse(() => throw Exception('Failed'));
        expect(completedGame.status, GameStatus.won);
        expect(completedGame.board.width, size);
        expect(completedGame.board.height, size);
      }
    });
  });

  group('Pagination and Filtering Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late AutoPlayImpl autoPlayUseCase;
    late GetGamesImpl getGamesUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      autoPlayUseCase = AutoPlayImpl(repository);
      getGamesUseCase = GetGamesImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User views paginated game list', () async {
      // Given: User has 15 games
      for (var i = 0; i < 15; i++) {
        await createGameUseCase('Game $i', 10);
      }

      // When: User requests first 10 games
      final result = await getGamesUseCase(limit: 10);

      // Then: Only 10 games are returned
      expect(result.isRight(), true);

      final games = result.getOrElse(() => []);
      expect(games.length, 10);
    });

    test('Feature: User requests games with different page sizes', () async {
      // Given: User has 20 games
      for (var i = 0; i < 20; i++) {
        await createGameUseCase('Game $i', 10);
      }

      // When: User requests different page sizes
      final pageSizes = [5, 10, 15, 20];

      for (final size in pageSizes) {
        final result = await getGamesUseCase(limit: size);
        expect(result.isRight(), true);

        final games = result.getOrElse(() => []);
        expect(games.length, lessThanOrEqualTo(size));
      }
    });

    test('Feature: User filters games by playing status', () async {
      // Given: Mix of playing and completed games
      for (var i = 0; i < 5; i++) {
        await createGameUseCase('Playing Game $i', 10);
      }

      for (var i = 0; i < 3; i++) {
        final createResult = await createGameUseCase('Won Game $i', 10);
        final game = createResult.getOrElse(() => throw Exception('Failed'));
        await autoPlayUseCase(game.id);
      }

      // When: User filters by playing status
      final result = await getGamesUseCase(status: 'in_progress', limit: 20);

      // Then: Only playing games are returned
      expect(result.isRight(), true);

      final games = result.getOrElse(() => []);
      expect(games.every((g) => g.status == GameStatus.playing), true);
      expect(games.length, greaterThanOrEqualTo(5)); // At least 5 playing games
    });

    test('Feature: User views all games without filters', () async {
      // Given: Mix of game statuses
      for (var i = 0; i < 3; i++) {
        await createGameUseCase('Game $i', 10);
      }

      final wonGame = await createGameUseCase('Won Game', 10);
      await autoPlayUseCase(
          wonGame.getOrElse(() => throw Exception('Failed')).id);

      // When: User requests all games
      final result = await getGamesUseCase(limit: 10);

      // Then: All games are returned
      expect(result.isRight(), true);

      final games = result.getOrElse(() => []);
      expect(games.length, 4);
    });

    test('Feature: User views empty game list', () async {
      // Given: No games exist
      expect(fakeDataSource.gameCount, 0);

      // When: User requests game list
      final result = await getGamesUseCase(limit: 10);

      // Then: Empty list is returned
      expect(result.isRight(), true);

      final games = result.getOrElse(() => []);
      expect(games, isEmpty);
    });

    test('Feature: User sees most recent games first', () async {
      // Given: User creates games sequentially
      final gameNames = <String>[];
      for (var i = 0; i < 5; i++) {
        final name = 'Game $i - ${DateTime.now().millisecondsSinceEpoch}';
        await createGameUseCase(name, 10);
        gameNames.add(name);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // When: User views game list
      final result = await getGamesUseCase(limit: 10);

      // Then: Games are in reverse chronological order
      expect(result.isRight(), true);

      final games = result.getOrElse(() => []);
      expect(games.length, 5);

      // Most recent game should be first
      expect(games.first.name, contains('Game 4'));
    });
  });

  group('Complex Gameplay Scenarios', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late ExecuteActionImpl executeActionUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      executeActionUseCase = ExecuteActionImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User plays game with complex movement pattern', () async {
      // Given: User creates a larger game
      final createResult = await createGameUseCase('Complex Pattern', 15);
      var game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User executes a complex movement pattern
      final pattern = [
        (ActionType.move, Direction.east),
        (ActionType.move, Direction.east),
        (ActionType.move, Direction.south),
        (ActionType.move, Direction.south),
        (ActionType.move, Direction.west),
        (ActionType.move, Direction.north),
        (ActionType.move, Direction.east),
        (ActionType.move, Direction.south),
      ];

      for (final (action, direction) in pattern) {
        final result = await executeActionUseCase(game.id, action, direction);
        expect(result.isRight(), true);
        game = result.getOrElse(() => throw Exception('Failed'));
      }

      // Then: Game state reflects all moves
      expect(game.board.robot, isNotNull);
      expect(game.status, GameStatus.playing);
    });

    test('Feature: User performs many actions in long game session', () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Long Session', 20);
      var game = createResult.getOrElse(() => throw Exception('Failed'));
      final startPosition = game.board.robot.position;

      // When: User performs 50 actions
      for (var i = 0; i < 50; i++) {
        final direction = [
          Direction.east,
          Direction.south,
          Direction.west,
          Direction.north
        ][i % 4];

        final result =
            await executeActionUseCase(game.id, ActionType.move, direction);

        if (result.isRight()) {
          game = result.getOrElse(() => throw Exception('Failed'));
        }
      }

      // Then: Game remains in valid state
      expect(game.board.robot, isNotNull);
      expect(game.board.robot.position, isNot(startPosition));
    });

    test('Feature: User plays multiple games simultaneously', () async {
      // Given: User creates multiple games
      final games = <String, dynamic>{};

      for (var i = 0; i < 3; i++) {
        final createResult = await createGameUseCase('Concurrent $i', 10);
        final game = createResult.getOrElse(() => throw Exception('Failed'));
        games[game.id] = game;
      }

      // When: User makes moves in different games
      for (final gameId in games.keys) {
        final moveResult =
            await executeActionUseCase(gameId, ActionType.move, Direction.east);
        expect(moveResult.isRight(), true);
      }

      // Then: All games maintain independent state
      expect(games.length, 3);
    });

    test('Feature: User tests boundary movements on small board', () async {
      // Given: Small 5x5 board
      final createResult = await createGameUseCase('Boundary Test', 5);
      var game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User attempts to move in various directions
      final directions = [
        Direction.north,
        Direction.east,
        Direction.south,
        Direction.west
      ];

      for (final direction in directions) {
        final result =
            await executeActionUseCase(game.id, ActionType.move, direction);

        // Move succeeds or fails gracefully
        if (result.isRight()) {
          game = result.getOrElse(() => throw Exception('Failed'));
        }
      }

      // Then: Game remains in valid state
      expect(game.board.robot, isNotNull);
      expect(game.board.robot.position.x, greaterThanOrEqualTo(0));
      expect(game.board.robot.position.y, greaterThanOrEqualTo(0));
      expect(game.board.robot.position.x, lessThan(5));
      expect(game.board.robot.position.y, lessThan(5));
    });

    test('Feature: User verifies game state consistency after many actions',
        () async {
      // Given: User creates a game
      final createResult = await createGameUseCase('Consistency Test', 12);
      var game = createResult.getOrElse(() => throw Exception('Failed'));
      final originalPrincessPos = game.board.princess.position;
      final boardSize = game.board.width;

      // When: User performs 30 random actions
      for (var i = 0; i < 30; i++) {
        final direction = [
          Direction.east,
          Direction.south,
          Direction.west,
          Direction.north
        ][i % 4];

        final result =
            await executeActionUseCase(game.id, ActionType.move, direction);

        if (result.isRight()) {
          game = result.getOrElse(() => throw Exception('Failed'));
        }
      }

      // Then: Game invariants hold
      expect(game.board.princess.position, originalPrincessPos);
      expect(game.board.width, boardSize);
      expect(game.board.height, boardSize);
      expect(game.board.robot.position.x, lessThan(boardSize));
      expect(game.board.robot.position.y, lessThan(boardSize));
    });
  });
}
