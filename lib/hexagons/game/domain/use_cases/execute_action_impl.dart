import 'package:dartz/dartz.dart';
import '../../../../shared/error/failures.dart';
import '../entities/game.dart';
import '../ports/inbound/execute_action_use_case.dart';
import '../ports/outbound/game_repository.dart';
import '../value_objects/action_type.dart';
import '../value_objects/direction.dart';

class ExecuteActionImpl implements ExecuteActionUseCase {
  final GameRepository repository;

  ExecuteActionImpl(this.repository);

  @override
  Future<Either<Failure, Game>> call(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    if (gameId.isEmpty) {
      return const Left(ValidationFailure('Game ID cannot be empty'));
    }
    return await repository.executeAction(gameId, action, direction);
  }
}
