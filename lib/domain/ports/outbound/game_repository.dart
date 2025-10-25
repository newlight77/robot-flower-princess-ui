import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';
import '../../entities/game_board.dart';
import '../../value_objects/action_type.dart';
import '../../value_objects/auto_play_strategy.dart';
import '../../value_objects/direction.dart';

abstract class GameRepository {
  Future<Either<Failure, Game>> createGame(String name, int boardSize);
  Future<Either<Failure, List<Game>>> getGames(
      {int limit = 10, String? status});
  Future<Either<Failure, Game>> getGame(String gameId);
  Future<Either<Failure, Game>> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  );
  Future<Either<Failure, Game>> autoPlay(
    String gameId, {
    AutoPlayStrategy strategy = AutoPlayStrategy.greedy,
  });
  Future<Either<Failure, List<GameBoard>>> replayGame(String gameId);
  Future<Either<Failure, Map<String, dynamic>>> getGameHistory(String gameId);
}
