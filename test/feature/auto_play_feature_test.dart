import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/hexagons/autoplay/domain/use_cases/auto_play_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/get_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: Auto-play scenarios from user's perspective
void main() {
  group('Auto-Play Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late AutoPlayImpl autoPlayUseCase;
    late GetGameImpl getGameUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      autoPlayUseCase = AutoPlayImpl(repository);
      getGameUseCase = GetGameImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: User triggers auto-play on a new game', () async {
      // Given: User creates a new game
      final createResult = await createGameUseCase('Auto-Play Game', 10);
      expect(createResult.isRight(), true);

      final game = createResult.getOrElse(() => throw Exception('Failed'));
      expect(game.status, GameStatus.playing);

      // When: User triggers auto-play
      final autoPlayResult = await autoPlayUseCase(game.id);

      // Then: Game completes automatically
      expect(autoPlayResult.isRight(), true);

      final completedGame =
          autoPlayResult.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.status, GameStatus.won);
      expect(completedGame.board.robot.position,
          completedGame.board.princess.position);
    });

    test('Feature: User auto-plays multiple games in sequence', () async {
      // Given: User creates multiple games
      final games = [];
      for (var i = 0; i < 3; i++) {
        final result = await createGameUseCase('Game $i', 10);
        games.add(result.getOrElse(() => throw Exception('Failed')));
      }

      // When: User auto-plays each game
      final completedGames = [];
      for (final game in games) {
        final result = await autoPlayUseCase(game.id);
        expect(result.isRight(), true);
        completedGames.add(result.getOrElse(() => throw Exception('Failed')));
      }

      // Then: All games are completed
      expect(completedGames.length, 3);
      expect(completedGames.every((g) => g.status == GameStatus.won), true);
    });

    test('Feature: User retrieves game state after auto-play', () async {
      // Given: User creates and auto-plays a game
      final createResult = await createGameUseCase('Retrieve After Auto', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      final autoPlayResult = await autoPlayUseCase(game.id);
      expect(autoPlayResult.isRight(), true);

      // When: User retrieves the game
      final getResult = await getGameUseCase(game.id);

      // Then: Game state reflects auto-play completion
      expect(getResult.isRight(), true);
      final retrievedGame =
          getResult.getOrElse(() => throw Exception('Failed'));
      expect(retrievedGame.status, GameStatus.won);
      expect(retrievedGame.id, game.id);
    });

    test('Feature: User attempts auto-play on non-existent game', () async {
      // Given: No game exists
      const nonExistentId = 'fake-game-id';

      // When: User tries to auto-play
      final result = await autoPlayUseCase(nonExistentId);

      // Then: Error is returned
      expect(result.isLeft(), true);
    });

    test('Feature: User auto-plays game with different board sizes', () async {
      // Given: Games with various board sizes
      final boardSizes = [5, 10, 15, 20];
      final results = <String, bool>{};

      for (final size in boardSizes) {
        // When: Create and auto-play each size
        final createResult = await createGameUseCase('Size $size Game', size);
        final game = createResult.getOrElse(() => throw Exception('Failed'));

        final autoPlayResult = await autoPlayUseCase(game.id);

        // Then: All succeed regardless of board size
        results['size_$size'] = autoPlayResult.isRight();
      }

      expect(results.values.every((success) => success), true);
    });

    test('Feature: User verifies robot reaches princess after auto-play',
        () async {
      // Given: A game is created
      final createResult = await createGameUseCase('Position Check', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final princessPosition = game.board.princess.position;

      // When: User auto-plays the game
      final result = await autoPlayUseCase(game.id);
      expect(result.isRight(), true);

      final completedGame = result.getOrElse(() => throw Exception('Failed'));

      // Then: Robot is at princess position
      expect(completedGame.board.robot.position, princessPosition);
      expect(completedGame.status, GameStatus.won);
    });

    test('Feature: User auto-plays game and verifies flowers delivered',
        () async {
      // Given: A game is created
      final createResult = await createGameUseCase('Flower Delivery', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      final initialFlowers = game.board.flowersRemaining;

      // When: User auto-plays
      final result = await autoPlayUseCase(game.id);
      expect(result.isRight(), true);

      final completedGame = result.getOrElse(() => throw Exception('Failed'));

      // Then: All flowers are collected and delivered
      expect(completedGame.board.flowersRemaining, 0);
      expect(completedGame.board.princess.flowersReceived, initialFlowers);
    });

    test('Feature: User auto-plays small game quickly', () async {
      // Given: A small 5x5 game for quick completion
      final createResult = await createGameUseCase('Quick Game', 5);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // When: User auto-plays
      final stopwatch = Stopwatch()..start();
      final result = await autoPlayUseCase(game.id);
      stopwatch.stop();

      // Then: Game completes successfully
      expect(result.isRight(), true);
      final completedGame = result.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.status, GameStatus.won);

      // And: Completes in reasonable time (< 1 second for fake)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Feature: User checks game persistence after auto-play', () async {
      // Given: User creates and auto-plays a game
      final createResult = await createGameUseCase('Persistence Test', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      await autoPlayUseCase(game.id);

      // When: User retrieves the game multiple times
      final result1 = await getGameUseCase(game.id);
      final result2 = await getGameUseCase(game.id);

      // Then: Game state remains consistent
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      final game1 = result1.getOrElse(() => throw Exception('Failed'));
      final game2 = result2.getOrElse(() => throw Exception('Failed'));

      expect(game1.status, game2.status);
      expect(game1.board.robot.position, game2.board.robot.position);
    });

    test('Feature: User validates empty game ID for auto-play', () async {
      // Given: User provides empty game ID
      const emptyId = '';

      // When: User attempts auto-play
      final result = await autoPlayUseCase(emptyId);

      // Then: Validation error is returned
      expect(result.isLeft(), true);
    });
  });
}
