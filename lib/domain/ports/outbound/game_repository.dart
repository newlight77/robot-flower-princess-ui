import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';
import '../../entities/game_board.dart';
import '../../value_objects/action_type.dart';
import '../../value_objects/direction.dart';

abstract class GameRepository {
  Future<Either<Failure, Game>> createGame(String name, int boardSize);
  Future<Either<Failure, List<Game>>> getGames();
  Future<Either<Failure, Game>> getGame(String gameId);
  Future<Either<Failure, Game>> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  );
  Future<Either<Failure, Game>> autoPlay(String gameId);
  Future<Either<Failure, List<GameBoard>>> replayGame(String gameId);
}
