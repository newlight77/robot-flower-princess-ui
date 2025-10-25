import 'package:dartz/dartz.dart';
import '../../../../../shared/error/failures.dart';
import '../../entities/game.dart';

abstract class GetGameUseCase {
  Future<Either<Failure, Game>> call(String gameId);
}
