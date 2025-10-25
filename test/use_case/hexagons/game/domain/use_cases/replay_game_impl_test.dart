import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/ports/outbound/game_repository.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/use_cases/replay_game_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';

@GenerateMocks([GameRepository])
import 'replay_game_impl_test.mocks.dart';

void main() {
  late ReplayGameImpl useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = ReplayGameImpl(mockRepository);
  });

  const board1 = GameBoard(
    width: 10,
    height: 10,
    cells: [],
    robot: Robot(
      position: Position(x: 0, y: 0),
      orientation: Direction.north,
    ),
    princess: Princess(position: Position(x: 9, y: 9)),
    flowersRemaining: 5,
    totalObstacles: 3,
    obstaclesRemaining: 3,
  );

  const board2 = GameBoard(
    width: 10,
    height: 10,
    cells: [],
    robot: Robot(
      position: Position(x: 1, y: 0),
      orientation: Direction.east,
    ),
    princess: Princess(position: Position(x: 9, y: 9)),
    flowersRemaining: 5,
    totalObstacles: 3,
    obstaclesRemaining: 3,
  );

  const board3 = GameBoard(
    width: 10,
    height: 10,
    cells: [],
    robot: Robot(
      position: Position(x: 2, y: 0),
      orientation: Direction.east,
      collectedFlowers: [Position(x: 1, y: 0)],
    ),
    princess: Princess(position: Position(x: 9, y: 9)),
    flowersRemaining: 4,
    totalObstacles: 3,
    obstaclesRemaining: 3,
  );

  const board4 = GameBoard(
    width: 10,
    height: 10,
    cells: [],
    robot: Robot(
      position: Position(x: 9, y: 9),
      orientation: Direction.east,
      collectedFlowers: [],
      deliveredFlowers: [
        Position(x: 1, y: 0),
        Position(x: 2, y: 1),
        Position(x: 3, y: 2),
        Position(x: 4, y: 3),
        Position(x: 5, y: 4),
      ],
    ),
    princess: Princess(position: Position(x: 9, y: 9), flowersReceived: 5),
    flowersRemaining: 0,
    totalObstacles: 3,
    obstaclesRemaining: 0,
  );

  final testHistory = [board1, board2, board3, board4];

  group('ReplayGameImpl', () {
    test('should retrieve game history successfully with valid game ID',
        () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(testHistory));

      final result = await useCase('game-123');

      expect(result, Right(testHistory));
      verify(mockRepository.replayGame('game-123'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when game ID is empty', () async {
      final result = await useCase('');

      expect(result, const Left(ValidationFailure('Game ID cannot be empty')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return NotFoundFailure when game does not exist', () async {
      when(mockRepository.replayGame(any)).thenAnswer(
          (_) async => const Left(NotFoundFailure('Game not found')));

      final result = await useCase('non-existent-game');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.replayGame('non-existent-game'));
    });

    test('should return ServerFailure when repository fails', () async {
      when(mockRepository.replayGame(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to fetch history')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.replayGame('game-123'));
    });

    test('should handle network failures', () async {
      when(mockRepository.replayGame(any)).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verify(mockRepository.replayGame('game-123'));
    });

    test('should return history with multiple board states', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(testHistory));

      final result = await useCase('game-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned history'),
        (history) {
          expect(history.length, 4);
          expect(history[0].robot.position, const Position(x: 0, y: 0));
          expect(history[1].robot.position, const Position(x: 1, y: 0));
          expect(history[2].robot.position, const Position(x: 2, y: 0));
          expect(history[3].robot.position, const Position(x: 9, y: 9));
        },
      );
    });

    test('should handle empty history (game just created)', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => const Right([]));

      final result = await useCase('new-game-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned empty history'),
        (history) => expect(history, isEmpty),
      );
    });

    test('should handle single state history', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => const Right([board1]));

      final result = await useCase('game-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned history'),
        (history) {
          expect(history.length, 1);
          expect(history[0].robot.position, const Position(x: 0, y: 0));
        },
      );
    });

    test('should verify robot progression through history', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(testHistory));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned history'),
        (history) {
          // Verify robot moves
          expect(history[0].robot.position.x, 0);
          expect(history[1].robot.position.x, 1);
          expect(history[2].robot.position.x, 2);

          // Verify flowers collected
          expect(history[0].robot.collectedFlowers.length, 0);
          expect(history[2].robot.collectedFlowers.length, 1);

          // Verify final state
          expect(history[3].robot.deliveredFlowers.length, 5);
          expect(history[3].princess.flowersReceived, 5);
        },
      );
    });

    test('should preserve board dimensions across history', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(testHistory));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned history'),
        (history) {
          for (final board in history) {
            expect(board.width, 10);
            expect(board.height, 10);
          }
        },
      );
    });

    test('should work with various game ID formats', () async {
      final gameIds = [
        'game-123',
        'abc123',
        'test_game_1',
        'GAME-UPPER-CASE',
        '12345',
      ];

      for (final gameId in gameIds) {
        when(mockRepository.replayGame(gameId))
            .thenAnswer((_) async => Right(testHistory));

        final result = await useCase(gameId);

        expect(result.isRight(), true);
        verify(mockRepository.replayGame(gameId));
      }
    });

    test('should handle validation failure from repository', () async {
      when(mockRepository.replayGame(any)).thenAnswer(
          (_) async => const Left(ValidationFailure('Invalid game state')));

      final result = await useCase('game-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('should handle long game histories', () async {
      final longHistory = List<GameBoard>.generate(
        100,
        (index) => GameBoard(
          width: 10,
          height: 10,
          cells: const [],
          robot: Robot(
            position: Position(x: index % 10, y: index ~/ 10),
            orientation: Direction.east,
          ),
          princess: const Princess(position: Position(x: 9, y: 9)),
          flowersRemaining: 5,
          totalObstacles: 3,
          obstaclesRemaining: 3,
        ),
      );

      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(longHistory));

      final result = await useCase('long-game-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned history'),
        (history) => expect(history.length, 100),
      );
    });

    test('should verify obstacles cleared across history', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(testHistory));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned history'),
        (history) {
          expect(history[0].obstaclesRemaining, 3);
          expect(history[3].obstaclesRemaining, 0);
        },
      );
    });

    test('should verify flowers remaining decreases across history', () async {
      when(mockRepository.replayGame(any))
          .thenAnswer((_) async => Right(testHistory));

      final result = await useCase('game-123');

      result.fold(
        (_) => fail('Should have returned history'),
        (history) {
          expect(history[0].flowersRemaining, 5);
          expect(history[2].flowersRemaining, 4);
          expect(history[3].flowersRemaining, 0);
        },
      );
    });
  });
}
