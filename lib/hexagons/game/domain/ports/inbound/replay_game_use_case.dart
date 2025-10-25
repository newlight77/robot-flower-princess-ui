import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/game_board.dart';

abstract class ReplayGameUseCase {
  Future<Either<Failure, List<GameBoard>>> call(String gameId);
}
