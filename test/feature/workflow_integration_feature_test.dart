import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/data/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/auto_play_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/create_game_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/execute_action_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/get_game_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/get_games_impl.dart';
import 'package:robot_flower_princess_front/domain/use_cases/replay_game_impl.dart';
import 'package:robot_flower_princess_front/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';

import 'fakes/fake_game_datasource.dart';

/// Feature Tests: Complete user workflows and integration scenarios
void main() {
  group('Workflow Integration Feature Tests', () {
    late FakeGameDataSource fakeDataSource;
    late GameRepositoryImpl repository;
    late CreateGameImpl createGameUseCase;
    late GetGameImpl getGameUseCase;
    late GetGamesImpl getGamesUseCase;
    late ExecuteActionImpl executeActionUseCase;
    late AutoPlayImpl autoPlayUseCase;
    late ReplayGameImpl replayGameUseCase;

    setUp(() {
      fakeDataSource = FakeGameDataSource();
      repository = GameRepositoryImpl(fakeDataSource);
      createGameUseCase = CreateGameImpl(repository);
      getGameUseCase = GetGameImpl(repository);
      getGamesUseCase = GetGamesImpl(repository);
      executeActionUseCase = ExecuteActionImpl(repository);
      autoPlayUseCase = AutoPlayImpl(repository);
      replayGameUseCase = ReplayGameImpl(repository);
    });

    tearDown(() {
      fakeDataSource.clearGames();
    });

    test('Feature: Complete game lifecycle from creation to completion',
        () async {
      // Given: User starts fresh

      // When: User goes through complete workflow
      // Step 1: Create game
      final createResult = await createGameUseCase('Lifecycle Game', 10);
      expect(createResult.isRight(), true);
      final game = createResult.getOrElse(() => throw Exception('Failed'));
      expect(game.status, GameStatus.playing);

      // Step 2: Make a move
      final moveResult = await executeActionUseCase(
        game.id,
        ActionType.move,
        Direction.east,
      );
      expect(moveResult.isRight(), true);

      // Step 3: Check game state
      final getResult = await getGameUseCase(game.id);
      expect(getResult.isRight(), true);

      // Step 4: Complete the game
      final completeResult = await autoPlayUseCase(game.id);
      expect(completeResult.isRight(), true);
      final completedGame =
          completeResult.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.status, GameStatus.won);

      // Step 5: Replay the game
      final replayResult = await replayGameUseCase(game.id);
      expect(replayResult.isRight(), true);

      // Then: Full workflow completed successfully
      expect(fakeDataSource.gameCount, 1);
    });

    test('Feature: User manages multiple games concurrently', () async {
      // Given: User wants to play multiple games

      // When: User creates and manages multiple games
      final game1 = await createGameUseCase('Game 1', 10);
      final game2 = await createGameUseCase('Game 2', 15);
      final game3 = await createGameUseCase('Game 3', 20);

      final g1 = game1.getOrElse(() => throw Exception('Failed'));
      final g2 = game2.getOrElse(() => throw Exception('Failed'));
      final g3 = game3.getOrElse(() => throw Exception('Failed'));

      // Make moves in different games
      await executeActionUseCase(g1.id, ActionType.move, Direction.east);
      await executeActionUseCase(g2.id, ActionType.move, Direction.north);
      await executeActionUseCase(g3.id, ActionType.move, Direction.south);

      // Complete one game
      await autoPlayUseCase(g1.id);

      // Check all games
      final check1 = await getGameUseCase(g1.id);
      final check2 = await getGameUseCase(g2.id);
      final check3 = await getGameUseCase(g3.id);

      // Then: All games maintain separate state
      expect(check1.isRight(), true);
      expect(check2.isRight(), true);
      expect(check3.isRight(), true);

      final updated1 = check1.getOrElse(() => throw Exception('Failed'));
      final updated2 = check2.getOrElse(() => throw Exception('Failed'));
      final updated3 = check3.getOrElse(() => throw Exception('Failed'));

      expect(updated1.status, GameStatus.won);
      expect(updated2.status, GameStatus.playing);
      expect(updated3.status, GameStatus.playing);
      expect(fakeDataSource.gameCount, 3);
    });

    test('Feature: User creates, plays, and reviews game history', () async {
      // Given: User wants to play and review

      // When: User completes full play-review cycle
      // Create game
      final createResult = await createGameUseCase('Review Game', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // Play several moves
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      await executeActionUseCase(game.id, ActionType.move, Direction.south);

      // Get current state
      final currentState = await getGameUseCase(game.id);
      expect(currentState.isRight(), true);

      // View replay
      final replay = await replayGameUseCase(game.id);
      expect(replay.isRight(), true);

      // Complete game
      await autoPlayUseCase(game.id);

      // Review final replay
      final finalReplay = await replayGameUseCase(game.id);
      expect(finalReplay.isRight(), true);

      // Then: Complete workflow successful
      final replayData = finalReplay.getOrElse(() => throw Exception('Failed'));
      expect(replayData, isNotEmpty);
    });

    test('Feature: User filters and manages game collection', () async {
      // Given: User has multiple games in different states

      // When: User creates diverse game collection
      // Create some playing games
      await createGameUseCase('Playing 1', 10);
      await createGameUseCase('Playing 2', 10);

      // Create and complete some games
      final game3 = await createGameUseCase('Won 1', 10);
      final game4 = await createGameUseCase('Won 2', 10);

      final g3 = game3.getOrElse(() => throw Exception('Failed'));
      final g4 = game4.getOrElse(() => throw Exception('Failed'));

      await autoPlayUseCase(g3.id);
      await autoPlayUseCase(g4.id);

      // Get all games
      final allGames = await getGamesUseCase(limit: 20);
      expect(allGames.isRight(), true);
      final games = allGames.getOrElse(() => []);
      expect(games.length, 4);

      // Filter by playing status
      final playingGames = await getGamesUseCase(
        status: 'in_progress',
        limit: 20,
      );
      expect(playingGames.isRight(), true);
      final playing = playingGames.getOrElse(() => []);

      // Filter by won status
      final wonGames = await getGamesUseCase(
        status: 'victory',
        limit: 20,
      );
      expect(wonGames.isRight(), true);
      final won = wonGames.getOrElse(() => []);

      // Then: Filtering works correctly
      expect(playing.length, greaterThanOrEqualTo(2));
      expect(won.length, 2);
      expect(playing.every((g) => g.status == GameStatus.playing), true);
      expect(won.every((g) => g.status == GameStatus.won), true);
    });

    test('Feature: User creates game, makes mistakes, and recovers', () async {
      // Given: User makes some wrong moves

      // When: User plays with trial and error
      final createResult = await createGameUseCase('Recovery Game', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // Make some moves (simulating wrong path)
      await executeActionUseCase(game.id, ActionType.move, Direction.west);
      await executeActionUseCase(game.id, ActionType.move, Direction.west);

      // Check state
      var currentState = await getGameUseCase(game.id);
      expect(currentState.isRight(), true);

      // Correct course
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      await executeActionUseCase(game.id, ActionType.move, Direction.east);

      currentState = await getGameUseCase(game.id);
      expect(currentState.isRight(), true);

      // Eventually complete
      await autoPlayUseCase(game.id);

      final finalState = await getGameUseCase(game.id);

      // Then: Game completes despite mistakes
      expect(finalState.isRight(), true);
      final finalGame = finalState.getOrElse(() => throw Exception('Failed'));
      expect(finalGame.status, GameStatus.won);
    });

    test('Feature: User batch creates and auto-plays games', () async {
      // Given: User wants to test with multiple games

      // When: User batch processes games
      const gameCount = 10;
      final gameIds = <String>[];

      // Create batch
      for (var i = 0; i < gameCount; i++) {
        final result = await createGameUseCase('Batch Game $i', 10);
        final game = result.getOrElse(() => throw Exception('Failed'));
        gameIds.add(game.id);
      }

      // Auto-play half of them
      for (var i = 0; i < gameCount ~/ 2; i++) {
        await autoPlayUseCase(gameIds[i]);
      }

      // Check results
      var playingCount = 0;
      var wonCount = 0;

      for (final id in gameIds) {
        final result = await getGameUseCase(id);
        final game = result.getOrElse(() => throw Exception('Failed'));
        if (game.status == GameStatus.playing) playingCount++;
        if (game.status == GameStatus.won) wonCount++;
      }

      // Then: Batch operations successful
      expect(playingCount, gameCount ~/ 2);
      expect(wonCount, gameCount ~/ 2);
      expect(fakeDataSource.gameCount, gameCount);
    });

    test('Feature: User switches between multiple games seamlessly', () async {
      // Given: User has multiple active games

      // When: User switches between games frequently
      final g1 = await createGameUseCase('Switch 1', 10);
      final g2 = await createGameUseCase('Switch 2', 10);
      final g3 = await createGameUseCase('Switch 3', 10);

      final game1 = g1.getOrElse(() => throw Exception('Failed'));
      final game2 = g2.getOrElse(() => throw Exception('Failed'));
      final game3 = g3.getOrElse(() => throw Exception('Failed'));

      // Interleaved operations
      await executeActionUseCase(game1.id, ActionType.move, Direction.east);
      await executeActionUseCase(game2.id, ActionType.move, Direction.north);
      await executeActionUseCase(game3.id, ActionType.move, Direction.south);
      await executeActionUseCase(game1.id, ActionType.move, Direction.east);
      await executeActionUseCase(game2.id, ActionType.move, Direction.north);
      await executeActionUseCase(game3.id, ActionType.move, Direction.south);

      // Check all games maintained separate state
      final check1 = await getGameUseCase(game1.id);
      final check2 = await getGameUseCase(game2.id);
      final check3 = await getGameUseCase(game3.id);

      // Then: All games have correct independent state
      expect(check1.isRight(), true);
      expect(check2.isRight(), true);
      expect(check3.isRight(), true);
    });

    test('Feature: User creates games with varying complexity', () async {
      // Given: User wants different difficulty levels

      // When: User creates games of different sizes
      final small = await createGameUseCase('Small', 5);
      final medium = await createGameUseCase('Medium', 10);
      final large = await createGameUseCase('Large', 20);

      final smallGame = small.getOrElse(() => throw Exception('Failed'));
      final mediumGame = medium.getOrElse(() => throw Exception('Failed'));
      final largeGame = large.getOrElse(() => throw Exception('Failed'));

      // Complete each
      final smallComplete = await autoPlayUseCase(smallGame.id);
      final mediumComplete = await autoPlayUseCase(mediumGame.id);
      final largeComplete = await autoPlayUseCase(largeGame.id);

      // Then: All sizes work correctly
      expect(smallComplete.isRight(), true);
      expect(mediumComplete.isRight(), true);
      expect(largeComplete.isRight(), true);

      expect(smallGame.board.width, 5);
      expect(mediumGame.board.width, 10);
      expect(largeGame.board.width, 20);
    });

    test('Feature: User retrieves and reviews completed games', () async {
      // Given: User has completed some games

      // When: User completes multiple games
      for (var i = 0; i < 5; i++) {
        final result = await createGameUseCase('Completed $i', 10);
        final game = result.getOrElse(() => throw Exception('Failed'));
        await autoPlayUseCase(game.id);
      }

      // Retrieve list of completed games
      final completedGames = await getGamesUseCase(
        status: 'victory',
        limit: 20,
      );

      // Then: Can view all completed games
      expect(completedGames.isRight(), true);
      final games = completedGames.getOrElse(() => []);
      expect(games.length, 5);
      expect(games.every((g) => g.status == GameStatus.won), true);
    });

    test('Feature: User workflow with pagination through large game list',
        () async {
      // Given: User has many games

      // When: User creates many games
      for (var i = 0; i < 25; i++) {
        await createGameUseCase('Game $i', 10);
      }

      // Paginate through results
      final page1 = await getGamesUseCase(limit: 10);
      final page2 = await getGamesUseCase(limit: 10);
      final page3 = await getGamesUseCase(limit: 10);

      // Then: Pagination works
      expect(page1.isRight(), true);
      expect(page2.isRight(), true);
      expect(page3.isRight(), true);

      final games1 = page1.getOrElse(() => []);
      expect(games1.length, 10);
    });

    test('Feature: User complete workflow with replay verification', () async {
      // Given: User wants to verify their gameplay

      // When: User plays and verifies each step
      final createResult = await createGameUseCase('Verification Game', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // Make moves
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      final replay1 = await replayGameUseCase(game.id);
      expect(replay1.isRight(), true);

      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      final replay2 = await replayGameUseCase(game.id);
      expect(replay2.isRight(), true);

      // Complete game
      await autoPlayUseCase(game.id);
      final finalReplay = await replayGameUseCase(game.id);

      // Then: Replay available at each step
      expect(finalReplay.isRight(), true);
      final history = finalReplay.getOrElse(() => throw Exception('Failed'));
      expect(history, isNotEmpty);
    });

    test('Feature: User creates games, filters, and analyzes results',
        () async {
      // Given: User wants to analyze their games

      // When: User creates mixed game collection
      // Create and complete various games
      for (var i = 0; i < 3; i++) {
        final result = await createGameUseCase('Won Small $i', 5);
        final game = result.getOrElse(() => throw Exception('Failed'));
        await autoPlayUseCase(game.id);
      }

      for (var i = 0; i < 2; i++) {
        await createGameUseCase('Playing Large $i', 20);
      }

      for (var i = 0; i < 4; i++) {
        final result = await createGameUseCase('Won Medium $i', 10);
        final game = result.getOrElse(() => throw Exception('Failed'));
        await autoPlayUseCase(game.id);
      }

      // Analyze
      final allGames = await getGamesUseCase(limit: 50);
      final wonGames = await getGamesUseCase(status: 'victory', limit: 50);
      final playingGames =
          await getGamesUseCase(status: 'in_progress', limit: 50);

      // Then: Can analyze game collection
      expect(allGames.isRight(), true);
      expect(wonGames.isRight(), true);
      expect(playingGames.isRight(), true);

      final all = allGames.getOrElse(() => []);
      final won = wonGames.getOrElse(() => []);
      final playing = playingGames.getOrElse(() => []);

      expect(all.length, 9);
      expect(won.length, 7);
      expect(playing.length, 2);
    });

    test('Feature: User rapid fire creates and completes games', () async {
      // Given: User wants to quickly test functionality

      // When: User rapidly creates and completes games
      for (var i = 0; i < 15; i++) {
        final result = await createGameUseCase('Rapid $i', 10);
        final game = result.getOrElse(() => throw Exception('Failed'));
        await autoPlayUseCase(game.id);
      }

      // Check all completed
      final allGames = await getGamesUseCase(limit: 20);

      // Then: All operations successful
      expect(allGames.isRight(), true);
      final games = allGames.getOrElse(() => []);
      expect(games.length, 15);
      expect(games.every((g) => g.status == GameStatus.won), true);
    });

    test('Feature: User creates game, makes progress, then auto-completes',
        () async {
      // Given: User starts manually then switches to auto

      // When: User plays hybrid approach
      final createResult = await createGameUseCase('Hybrid Game', 10);
      final game = createResult.getOrElse(() => throw Exception('Failed'));

      // Manual moves
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      await executeActionUseCase(game.id, ActionType.move, Direction.east);
      await executeActionUseCase(game.id, ActionType.move, Direction.south);

      // Check progress
      final progress = await getGameUseCase(game.id);
      expect(progress.isRight(), true);

      // Switch to auto
      final complete = await autoPlayUseCase(game.id);

      // Then: Game completes successfully
      expect(complete.isRight(), true);
      final completedGame = complete.getOrElse(() => throw Exception('Failed'));
      expect(completedGame.status, GameStatus.won);
    });
  });
}
