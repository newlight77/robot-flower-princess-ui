import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class AutoPlayUseCase {
  Future<Either<Failure, Game>> call(String gameId);
}
