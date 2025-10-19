import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game_board.dart';
import '../ports/inbound/replay_game_use_case.dart';
import '../ports/outbound/game_repository.dart';

class ReplayGameImpl implements ReplayGameUseCase {
  final GameRepository repository;

  ReplayGameImpl(this.repository);

  @override
  Future<Either<Failure, List<GameBoard>>> call(String gameId) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.replayGame(gameId);
  }
}
