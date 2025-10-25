import 'package:dartz/dartz.dart';
import '../../../../shared/error/failures.dart';
import '../../../game/domain/entities/game.dart';
import '../ports/inbound/auto_play_use_case.dart';
import '../../../game/domain/ports/outbound/game_repository.dart';
import '../value_objects/auto_play_strategy.dart';

class AutoPlayImpl implements AutoPlayUseCase {
  final GameRepository repository;

  AutoPlayImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(
    String gameId, {
    AutoPlayStrategy strategy = AutoPlayStrategy.greedy,
  }) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.autoPlay(gameId, strategy: strategy);
  }
}
