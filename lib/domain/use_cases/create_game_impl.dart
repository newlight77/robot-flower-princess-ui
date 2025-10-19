import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/create_game_use_case.dart';
import '../ports/outbound/game_repository.dart';

class CreateGameImpl implements CreateGameUseCase {
  final GameRepository repository;

  CreateGameImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(String name, int boardSize) async {
    if (name.isEmpty) {
      return const Left(ValidationFailure('Game name cannot be empty'));
    }
    if (boardSize < 3 || boardSize > 50) {
      return const Left(ValidationFailure('Board size must be between 3 and 50'));
    }
    return await repository.createGame(name, boardSize);
  }
}
