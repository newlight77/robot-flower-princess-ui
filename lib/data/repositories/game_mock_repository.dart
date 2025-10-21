import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/ports/outbound/game_repository.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import '../datasources/game_mock_datasource.dart';

class GameMockRepository implements GameRepository {
  final GameMockDataSource mockDataSource;

  GameMockRepository(this.mockDataSource);

  @override
  Future<Either<Failure, Game>> createGame(String name, int boardSize) async {
    try {
      final gameModel = await mockDataSource.createGame(name, boardSize);
      return Right(gameModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGames({int limit = 10}) async {
    try {
      final gameModels = await mockDataSource.getGames(limit: limit);
      return Right(gameModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> getGame(String gameId) async {
    try {
      final gameModel = await mockDataSource.getGame(gameId);
      return Right(gameModel.toEntity());
    } catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    try {
      final gameModel = await mockDataSource.executeAction(gameId, action, direction);
      return Right(gameModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> autoPlay(String gameId) async {
    try {
      final gameModel = await mockDataSource.autoPlay(gameId);
      return Right(gameModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameBoard>>> replayGame(String gameId) async {
    try {
      final boardStates = await mockDataSource.replayGame(gameId);
      final boards = boardStates.map((json) => GameBoard.fromJson(json)).toList();
      return Right(boards);
    } catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }
}
