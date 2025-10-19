import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/get_games_use_case.dart';
import '../ports/outbound/game_repository.dart';

class GetGamesImpl implements GetGamesUseCase {
  final GameRepository repository;

  GetGamesImpl(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call() async {
    return await repository.getGames();
  }
}
