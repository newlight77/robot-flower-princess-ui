import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/ports/outbound/game_repository.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import '../datasources/game_remote_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;

  GameRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Game>> createGame(String name, int boardSize) async {
    try {
      final gameModel = await remoteDataSource.createGame(name, boardSize);
      return Right(gameModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGames() async {
    try {
      final gameModels = await remoteDataSource.getGames();
      return Right(gameModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> getGame(String gameId) async {
    try {
      final gameModel = await remoteDataSource.getGame(gameId);
      return Right(gameModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    try {
      final gameModel = await remoteDataSource.executeAction(
        gameId,
        action,
        direction,
      );
      return Right(gameModel.toEntity());
    } on GameOverException catch (e) {
      return Left(GameOverFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Game>> autoPlay(String gameId) async {
    try {
      final gameModel = await remoteDataSource.autoPlay(gameId);
      return Right(gameModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameBoard>>> replayGame(String gameId) async {
    try {
      final boardStates = await remoteDataSource.replayGame(gameId);
      final boards = boardStates
          .map((json) => GameBoard.fromJson(json))
          .toList();
      return Right(boards);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
