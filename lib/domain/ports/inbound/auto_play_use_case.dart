import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/game.dart';
import '../../value_objects/auto_play_strategy.dart';

abstract class AutoPlayUseCase {
  Future<Either<Failure, Game>> call(
    String gameId, {
    AutoPlayStrategy strategy = AutoPlayStrategy.greedy,
  });
}
