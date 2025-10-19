import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/auto_play_use_case.dart';
import '../ports/outbound/game_repository.dart';

class AutoPlayImpl implements AutoPlayUseCase {
  final GameRepository repository;

  AutoPlayImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(String gameId) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.autoPlay(gameId);
  }
}
