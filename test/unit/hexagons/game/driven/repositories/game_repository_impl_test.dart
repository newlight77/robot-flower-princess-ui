import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/shared/error/exceptions.dart';
import 'package:robot_flower_princess_front/shared/error/failures.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/datasources/game_remote_datasource.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/models/game_model.dart';
import 'package:robot_flower_princess_front/hexagons/game/driven/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/hexagons/game/domain/value_objects/position.dart';

@GenerateMocks([GameRemoteDataSource])
import 'game_repository_impl_test.mocks.dart';

void main() {
  late GameRepositoryImpl repository;
  late MockGameRemoteDataSource mockDataSource;
  late GameModel testGameModel;

  setUp(() {
    mockDataSource = MockGameRemoteDataSource();
    repository = GameRepositoryImpl(mockDataSource);

    testGameModel = GameModel(
      id: 'test-game-123',
      name: 'Test Game',
      board: const GameBoard(
        width: 5,
        height: 5,
        cells: [],
        robot: Robot(
          position: Position(x: 0, y: 0),
          orientation: Direction.north,
        ),
        princess: Princess(position: Position(x: 4, y: 4)),
        flowersRemaining: 3,
        totalObstacles: 2,
        obstaclesRemaining: 2,
      ),
      status: GameStatus.playing,
      actions: const [],
      createdAt: DateTime.now(),
    );
  });

  group('createGame', () {
    test('should return Game on successful creation', () async {
      when(mockDataSource.createGame('Test Game', 10))
          .thenAnswer((_) async => testGameModel);

      final result = await repository.createGame('Test Game', 10);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (game) {
          expect(game.id, testGameModel.id);
          expect(game.name, testGameModel.name);
        },
      );
      verify(mockDataSource.createGame('Test Game', 10)).called(1);
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.createGame('Test', 10);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.createGame('Test', 10);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Network error');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return ValidationFailure when ValidationException is thrown',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(ValidationException('Invalid board size'));

      final result = await repository.createGame('Test', 1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Invalid board size');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure for unknown exceptions', () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(Exception('Unknown error'));

      final result = await repository.createGame('Test', 10);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('getGames', () {
    test('should return list of Games on success', () async {
      final gameModels = [testGameModel, testGameModel];
      when(mockDataSource.getGames(limit: 10, status: null))
          .thenAnswer((_) async => gameModels);

      final result = await repository.getGames();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (games) {
          expect(games.length, 2);
          expect(games[0].id, testGameModel.id);
        },
      );
      verify(mockDataSource.getGames(limit: 10, status: null)).called(1);
    });

    test('should return empty list when no games exist', () async {
      when(mockDataSource.getGames(
              limit: anyNamed('limit'), status: anyNamed('status')))
          .thenAnswer((_) async => []);

      final result = await repository.getGames();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (games) => expect(games, isEmpty),
      );
    });

    test('should pass limit and status parameters', () async {
      when(mockDataSource.getGames(limit: 5, status: 'in_progress'))
          .thenAnswer((_) async => [testGameModel]);

      final result = await repository.getGames(limit: 5, status: 'in_progress');

      expect(result.isRight(), true);
      verify(mockDataSource.getGames(limit: 5, status: 'in_progress'))
          .called(1);
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.getGames(
              limit: anyNamed('limit'), status: anyNamed('status')))
          .thenThrow(ServerException('Server error'));

      final result = await repository.getGames();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.getGames(
              limit: anyNamed('limit'), status: anyNamed('status')))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.getGames();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure for unknown exceptions', () async {
      when(mockDataSource.getGames(
              limit: anyNamed('limit'), status: anyNamed('status')))
          .thenThrow(Exception('Unknown'));

      final result = await repository.getGames();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('getGame', () {
    test('should return Game on success', () async {
      when(mockDataSource.getGame('test-123'))
          .thenAnswer((_) async => testGameModel);

      final result = await repository.getGame('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (game) => expect(game.id, testGameModel.id),
      );
      verify(mockDataSource.getGame('test-123')).called(1);
    });

    test('should return NotFoundFailure when NotFoundException is thrown',
        () async {
      when(mockDataSource.getGame(any))
          .thenThrow(NotFoundException('Game not found'));

      final result = await repository.getGame('invalid-id');

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, 'Game not found');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.getGame(any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.getGame('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.getGame(any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.getGame('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('executeAction', () {
    test('should return updated Game on successful action', () async {
      when(mockDataSource.executeAction(
        'test-123',
        ActionType.move,
        Direction.north,
      )).thenAnswer((_) async => testGameModel);

      final result = await repository.executeAction(
        'test-123',
        ActionType.move,
        Direction.north,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (game) => expect(game.id, testGameModel.id),
      );
      verify(mockDataSource.executeAction(
              'test-123', ActionType.move, Direction.north))
          .called(1);
    });

    test('should return GameOverFailure when GameOverException is thrown',
        () async {
      when(mockDataSource.executeAction(any, any, any))
          .thenThrow(GameOverException('Game is over'));

      final result = await repository.executeAction(
        'test-123',
        ActionType.move,
        Direction.north,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<GameOverFailure>());
          expect(failure.message, 'Game is over');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return ValidationFailure when ValidationException is thrown',
        () async {
      when(mockDataSource.executeAction(any, any, any))
          .thenThrow(ValidationException('Invalid action'));

      final result = await repository.executeAction(
        'test-123',
        ActionType.move,
        Direction.north,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.executeAction(any, any, any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.executeAction(
        'test-123',
        ActionType.move,
        Direction.north,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.executeAction(any, any, any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.executeAction(
        'test-123',
        ActionType.move,
        Direction.north,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('autoPlay', () {
    test('should return Game on successful auto-play', () async {
      when(mockDataSource.autoPlay('test-123'))
          .thenAnswer((_) async => testGameModel);

      final result = await repository.autoPlay('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (game) => expect(game.id, testGameModel.id),
      );
      verify(mockDataSource.autoPlay('test-123')).called(1);
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.autoPlay(any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.autoPlay('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.autoPlay(any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.autoPlay('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure for unknown exceptions', () async {
      when(mockDataSource.autoPlay(any)).thenThrow(Exception('Unknown'));

      final result = await repository.autoPlay('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('replayGame', () {
    const testBoard = GameBoard(
      width: 5,
      height: 5,
      cells: [],
      robot:
          Robot(position: Position(x: 0, y: 0), orientation: Direction.north),
      princess: Princess(position: Position(x: 4, y: 4)),
      flowersRemaining: 3,
      totalObstacles: 0,
      obstaclesRemaining: 0,
    );

    test('should return list of GameBoards on success', () async {
      final historyResponse = {
        'history': [
          testBoard.toJson(),
          testBoard.toJson(),
        ]
      };
      when(mockDataSource.getGameHistory('test-123'))
          .thenAnswer((_) async => historyResponse);

      final result = await repository.replayGame('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (boards) {
          expect(boards.length, 2);
          expect(boards[0].width, 5);
        },
      );
      verify(mockDataSource.getGameHistory('test-123')).called(1);
    });

    test('should handle history wrapped in states key', () async {
      final historyResponse = {
        'history': {
          'states': [testBoard.toJson()]
        }
      };
      when(mockDataSource.getGameHistory('test-123'))
          .thenAnswer((_) async => historyResponse);

      final result = await repository.replayGame('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (boards) => expect(boards.length, 1),
      );
    });

    test('should handle history wrapped in boards key', () async {
      final historyResponse = {
        'history': {
          'boards': [testBoard.toJson()]
        }
      };
      when(mockDataSource.getGameHistory('test-123'))
          .thenAnswer((_) async => historyResponse);

      final result = await repository.replayGame('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (boards) => expect(boards.length, 1),
      );
    });

    test('should return empty list when history has no recognized structure',
        () async {
      final historyResponse = {
        'history': {'unknown': 'structure'}
      };
      when(mockDataSource.getGameHistory('test-123'))
          .thenAnswer((_) async => historyResponse);

      final result = await repository.replayGame('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (boards) => expect(boards, isEmpty),
      );
    });

    test('should return NotFoundFailure when NotFoundException is thrown',
        () async {
      when(mockDataSource.getGameHistory(any))
          .thenThrow(NotFoundException('Game not found'));

      final result = await repository.replayGame('invalid-id');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.getGameHistory(any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.replayGame('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.getGameHistory(any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.replayGame('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('getGameHistory', () {
    test('should return history map on success', () async {
      final historyMap = {
        'history': [],
        'metadata': {'count': 0}
      };
      when(mockDataSource.getGameHistory('test-123'))
          .thenAnswer((_) async => historyMap);

      final result = await repository.getGameHistory('test-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (history) {
          expect(history, isA<Map<String, dynamic>>());
          expect(history['history'], isA<List>());
        },
      );
      verify(mockDataSource.getGameHistory('test-123')).called(1);
    });

    test('should return NotFoundFailure when NotFoundException is thrown',
        () async {
      when(mockDataSource.getGameHistory(any))
          .thenThrow(NotFoundException('Game not found'));

      final result = await repository.getGameHistory('invalid-id');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      when(mockDataSource.getGameHistory(any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.getGameHistory('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      when(mockDataSource.getGameHistory(any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.getGameHistory('test-123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
