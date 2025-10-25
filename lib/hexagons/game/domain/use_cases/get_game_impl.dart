import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/get_game_use_case.dart';
import '../ports/outbound/game_repository.dart';

class GetGameImpl implements GetGameUseCase {
  final GameRepository repository;

  GetGameImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(String gameId) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.getGame(gameId);
  }
}
