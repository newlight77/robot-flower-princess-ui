import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';

abstract class GetGamesUseCase {
  Future<Either<Failure, List<Game>>> call();
}
