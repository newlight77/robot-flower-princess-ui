import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/game.dart';
import '../../value_objects/action_type.dart';
import '../../value_objects/direction.dart';

abstract class ExecuteActionUseCase {
  Future<Either<Failure, Game>> call(
    String gameId,
    ActionType action,
    Direction direction,
  );
}
