import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:robot_flower_princess_front/core/error/exceptions.dart';
import 'package:robot_flower_princess_front/core/error/failures.dart';
import 'package:robot_flower_princess_front/data/datasources/game_remote_datasource.dart';
import 'package:robot_flower_princess_front/data/models/game_model.dart';
import 'package:robot_flower_princess_front/data/repositories/game_repository_impl.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/entities/princess.dart';
import 'package:robot_flower_princess_front/domain/value_objects/game_status.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

@GenerateMocks([GameRemoteDataSource])
import 'game_repository_impl_test.mocks.dart';

void main() {
  late GameRepositoryImpl repository;
  late MockGameRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockGameRemoteDataSource();
    repository = GameRepositoryImpl(mockDataSource);
  });

  final testGameModel = GameModel(
    id: '1',
    name: 'Test Game',
    board: const GameBoard(
      width: 10,
      height: 10,
      cells: [],
      robot: Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.north,
      ),
      princess: Princess(position: Position(x: 9, y: 9)),
      flowersRemaining: 5,
      totalObstacles: 0,
      obstaclesRemaining: 0,
    ),
    status: GameStatus.playing,
    createdAt: DateTime.now(),
  );

  group('createGame', () {
    test('should return Game when datasource call is successful', () async {
      when(mockDataSource.createGame(any, any))
          .thenAnswer((_) async => testGameModel);

      final result = await repository.createGame('Test Game', 10);

      expect(result.isRight(), true);
      verify(mockDataSource.createGame('Test Game', 10));
    });

    test('should return ServerFailure when datasource throws ServerException',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(ServerException('Server error'));

      final result = await repository.createGame('Test Game', 10);

      expect(result, const Left(ServerFailure('Server error')));
    });

    test('should return NetworkFailure when datasource throws NetworkException',
        () async {
      when(mockDataSource.createGame(any, any))
          .thenThrow(NetworkException('Network error'));

      final result = await repository.createGame('Test Game', 10);

      expect(result, const Left(NetworkFailure('Network error')));
    });
  });

  group('getGames', () {
    test('should return list of Games when datasource call is successful',
        () async {
      when(mockDataSource.getGames(limit: anyNamed('limit')))
          .thenAnswer((_) async => [testGameModel]);

      final result = await repository.getGames();

      expect(result.isRight(), true);
      verify(mockDataSource.getGames(limit: anyNamed('limit')));
    });
  });
}
