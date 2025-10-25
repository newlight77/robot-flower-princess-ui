import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class CreateGameUseCase {
  Future<Either<Failure, Game>> call(String name, int boardSize);
}
