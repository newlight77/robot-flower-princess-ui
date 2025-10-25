import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/ports/outbound/game_repository.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/auto_play_strategy.dart';
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
  Future<Either<Failure, List<Game>>> getGames(
      {int limit = 10, String? status}) async {
    try {
      final gameModels =
          await remoteDataSource.getGames(limit: limit, status: status);
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
  Future<Either<Failure, Game>> autoPlay(
    String gameId, {
    AutoPlayStrategy strategy = AutoPlayStrategy.greedy,
  }) async {
    try {
      final gameModel = await remoteDataSource.autoPlay(gameId, strategy: strategy);
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
      final historyResponse = await remoteDataSource.getGameHistory(gameId);

      // Extract the history list from the response
      final history = historyResponse['history'] as dynamic;
      List<dynamic> boardStates;

      if (history is List) {
        boardStates = history;
      } else if (history is Map<String, dynamic>) {
        // If history is wrapped in an object, try to find the states array
        if (history.containsKey('states')) {
          boardStates = history['states'] as List<dynamic>;
        } else if (history.containsKey('boards')) {
          boardStates = history['boards'] as List<dynamic>;
        } else {
          // If no array found, return empty list
          boardStates = [];
        }
      } else {
        boardStates = [];
      }

      final boards = boardStates
          .map((json) => GameBoard.fromJson(json as Map<String, dynamic>))
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGameHistory(
      String gameId) async {
    try {
      final history = await remoteDataSource.getGameHistory(gameId);
      return Right(history);
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
