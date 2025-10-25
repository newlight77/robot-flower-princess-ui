import 'package:dartz/dartz.dart';
import '../../../../../shared/error/failures.dart';
import '../../entities/game.dart';

abstract class CreateGameUseCase {
  Future<Either<Failure, Game>> call(String name, int boardSize);
}
